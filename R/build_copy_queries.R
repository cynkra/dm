
build_copy_queries <- function(con, dm, set_key_constraints = TRUE, temporary = TRUE, table_names) {
  ## apply filters
  dm <- dm_apply_filters(dm)

  ## helper to quote all elements of a column and enumerate (concat) element wise
  quote_enum_col <- function(x) {
    map_chr(x, ~toString(map_chr(.x, DBI::dbQuoteIdentifier, con = con)))
  }

  ## fetch types, keys and uniques
  pks <- dm_get_all_pks_impl(dm)
  fks <- dm_get_all_fks_impl(dm)

  # if a that doesn't match a pk, this non-pk col should be unique
  uniques <-
    fks %>%
    select(table = parent_table, pk_col = parent_key_cols) %>%
    anti_join(pks, by = c("table", "pk_col")) %>%
    distinct()

  ## build sql definitions to use in `CREATE TABLE ...`

  # column definitions
  get_sql_col_types <- . %>%
    tbl_impl(dm, .) %>%
    DBI::dbDataType(con, .) %>%
    enframe("col", "type")

  col_defs <-
    dm %>%
    src_tbls_impl() %>%
    set_names() %>%
    map_dfr(get_sql_col_types, .id = "table") %>%
    mutate(col_def = glue("{DBI::dbQuoteIdentifier(con, col)} {type}")) %>%
    group_by(table) %>%
    summarize(col_defs = paste(col_def, collapse = ",\n  "))

  if(!set_key_constraints) {
    pk_defs <- tibble(table = character(0), pk_defs = character(0))
    fk_defs <- tibble(table = character(0), fk_defs = character(0))
    index_queries <- tibble(table = character(0), query = character(0))
    } else {
    # primary key definitions
    pk_defs <-
      pks %>%
      transmute(
        table,
        pk_defs = paste0("PRIMARY KEY (", quote_enum_col(pk_col), ")"))

    # unique constraint definitions
    unique_defs <-
      uniques %>%
      transmute(
        table,
        unique_def = paste0(
          "UNIQUE (",
          quote_enum_col(pk_col),
          ")")) %>%
      group_by(table) %>%
      summarize(unique_defs = paste(unique_def, collapse = ",\n  "))

    # foreign key definitions and indexing queries
    if(is_duckdb(con)) {
      if(nrow(fks)) {
        warn("duckdb doesn't support foreign keys, these won't be set in the remote database but are preserved in the `dm`")
      }
      # setup ulterior left join so it'll create a NA col for `fk_def`
      fk_defs <- tibble(table = character(0), fk_defs = character(0))
      index_queries <- tibble(table = character(0), query = character(0))
    } else {
      fk_defs <-
        fks %>%
        transmute(
          table = child_table,
          fk_def = paste0(
            "FOREIGN KEY (",
            quote_enum_col(child_fk_cols),
            ") REFERENCES ",
            unlist(table_names[parent_table]),
            " (",
            quote_enum_col(parent_key_cols),
            ")")) %>%
        group_by(table) %>%
        summarize(fk_defs = paste(fk_def, collapse = ",\n  "))

      index_queries <- fks %>%
        mutate(index_name = map_chr(child_fk_cols, paste, collapse = "_")) %>%
        transmute(
          table = child_table,
          remote_table = unlist(table_names[table]) %||% character(0),
          sql = DBI::SQL(paste0(
            "CREATE INDEX ",
            # hack (?) to create unique indexes
            sapply(index_name, unique_db_table_name),
            " ON ",
            remote_table,
            " (",
            quote_enum_col(child_fk_cols),
            ")"))
        )
    }
  }
  ## compile `CREATE TABLE ...` queries
  create_table_queries <-
    col_defs %>%
    left_join(pk_defs, by = "table") %>%
    left_join(unique_defs, by = "table") %>%
    left_join(fk_defs, by = "table") %>%
    group_by(table) %>%
    mutate(
      remote_table = table_names[table],
      all_defs = paste(na.omit(c(col_defs, pk_defs, unique_defs, fk_defs)), collapse = ",\n  ")) %>%
    ungroup() %>%
    transmute(table, remote_table, sql = DBI::SQL(glue(
      "CREATE {if (temporary) 'TEMP ' else ''}TABLE {unlist(remote_table)} (\n  {all_defs}\n)")))

  ## Reorder queries according to topological sort so pks are created before associated fks
  graph <- create_graph_from_dm(dm, directed = TRUE)
  topo <- igraph::topo_sort(graph, mode = "in")
  idx <- match(names(topo), create_table_queries$table)

  if (length(idx) == nrow(create_table_queries)) {
    create_table_queries <- create_table_queries[idx,]
  }

  ## Return a list of both type of queries
  lst(create_table_queries, index_queries)
}

