
build_copy_queries <- function(con, dm) {
  ## apply filters
  dm <- dm_apply_filters(dm)

  ## helper to quote all elements of a column and enumerate (concat) element wise
  quote_enum_col <- function(x) {
    map_chr(x, ~toString(map_chr(.x, DBI::dbQuoteIdentifier, con = con)))
  }

  ## fetch types, keys and uniques
  col_types <- get_sql_col_types(dm, con)
  pks <- dm_get_all_pks_impl(dm)
  fks <- dm_get_all_fks_impl(dm)

  # if a fk that does't match a pk, this pk candidate should be unique
  uniques <-
    fks %>%
    select(table = parent_table, pk_col = parent_key_cols) %>%
    anti_join(pks, by = c("table", "pk_col")) %>%
    distinct()

  ## build sql definitions to use in `CREATE TABLE ...`

  # column definitions
  col_defs <-
    col_types %>%
    mutate(col_def = glue("{DBI::dbQuoteIdentifier(con, col)} {type}")) %>%
    group_by(table) %>%
    summarize(col_defs = paste(col_def, collapse = ",\n  "))

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

  # foreign key definitions
  if(is_duckdb(con)) {
    if(nrow(fks)) {
      warn("duckdb doesn't support foreign keys, these will be ignored")
    }
    # setup ulterior left join so it'll create a NA col for `fk_def`
    fk_defs <- tibble(table = character(0), fk_defs = character(0))
  } else {
    fk_defs <-
      fks %>%
      transmute(
        table = child_table,
        fk_def = paste0(
          "FOREIGN KEY (",
          quote_enum_col(child_fk_cols),
          ") REFERENCES ",
          quote_enum_col(parent_table),
          "(",
          quote_enum_col(parent_key_cols),
          ")")) %>%
      group_by(table) %>%
      summarize(fk_defs = paste(fk_def, collapse = ",\n  "))
  }

  ## compile `CREATE TABLE ...` queries
  queries <- col_defs %>%
    left_join(pk_defs, by = "table") %>%
    left_join(unique_defs, by = "table") %>%
    left_join(fk_defs, by = "table") %>%
    group_by(table) %>%
    mutate(
      table_quoted = quote_enum_col(table),
      all_defs = paste(na.omit(c(col_defs, pk_defs, unique_defs, fk_defs)), collapse = ",\n  ")) %>%
    ungroup() %>%
    transmute(table, sql = DBI::SQL(glue("CREATE TABLE {table_quoted}(\n  {all_defs}\n);")))

  ## Reorder queries according to topological sort so pks are created before associated fks
  graph <- create_graph_from_dm(dm, directed = TRUE)
  topo <- igraph::topo_sort(graph, mode = "in")
  idx <- match(names(topo), queries$table)

  if (length(idx) == nrow(queries)) {
    queries <- queries[idx,]
  }

  queries
}

get_sql_col_types <- function(dm, con) {
  # TODO: fetch explicit types from dm, either from col attributes or dm itself
  get_sql_col_types0 <- . %>%
    tbl_impl(dm, .) %>%
    DBI::dbDataType(con, .) %>%
    enframe("col", "type")

  dm %>%
    src_tbls_impl() %>%
    set_names() %>%
    map_dfr(get_sql_col_types0, .id = "table")
}
