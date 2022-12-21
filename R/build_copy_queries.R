
build_copy_queries <- function(dest, dm, set_key_constraints = TRUE, temporary = TRUE, table_names = set_names(names(dm))) {
  con <- con_from_src_or_con(dest)

  ## helper to quote all elements of a column and enumerate (concat) element wise
  quote_enum_col <- function(x) {
    map_chr(x, ~ toString(map_chr(.x, DBI::dbQuoteIdentifier, conn = con)))
  }

  ## fetch types, keys and uniques
  pks <- dm_get_all_pks_impl(dm) %>% rename(name = table)
  fks <- dm_get_all_fks_impl(dm)

  # if a that doesn't match a pk, this non-pk col should be unique
  uniques <-
    fks %>%
    select(name = parent_table, pk_col = parent_key_cols) %>%
    anti_join(pks, by = c("name", "pk_col")) %>%
    distinct()

  ## build sql definitions to use in `CREATE TABLE ...`

  # column definitions
  get_sql_col_types <- function(x) {
    # autoincrementing is not possible for composite keys, so `pk_col` is guaranteed
    # to be a scalar
    pk_col <-
      dm %>%
      dm_get_all_pks(x) %>%
      filter(autoincrement) %>%
      pull(pk_col)

    tbl <- tbl_impl(dm, x)
    types <- DBI::dbDataType(con, tbl)
    autoincrement_attribute <- ""

    # database-specific type conversions
    if (is_mariadb(dest)) {
      types[types == "TEXT"] <- "VARCHAR(255)"
    }
    if (is_sqlite(dest)) {
      types[types == "INT"] <- "INTEGER"
    }

    # database-specific autoincrementing column types
    if (length(pk_col) > 0L) {
      # extract column name representing primary key
      pk_col <- pk_col %>% extract2(1L)

      # Postgres:
      if (is_postgres(dest)) {
        types[pk_col] <- "SERIAL"
      }

      # SQL Server:
      if (is_mssql(dest)) {
        types[pk_col] <- "INT IDENTITY"
      }

      # MariaDB:
      # Doesn't have a special data type. Uses `AUTO_INCREMENT` attribute instead.
      # Ref: https://mariadb.com/kb/en/auto_increment/
      if (is_mariadb(dest)) {
        autoincrement_attribute <- " AUTO_INCREMENT"
      }

      # DuckDB:
      # Doesn't have a special data type. Uses `CREATE SEQUENCE` instead.
      # Ref: https://duckdb.org/docs/sql/statements/create_sequence

      # SQLite:
      # For a primary key, autoincrementing works by default, and it is almost never
      # necessary to use the `AUTOINCREMENT` keyword. So nothing we need to do here.
      # Ref: https://www.sqlite.org/autoinc.html
    }
    df_col_types <-
      enframe(types, "col", "type") %>%
      mutate(autoincrement_attribute = "")

    if (length(pk_col) > 0L) {
      df_col_types <-
        df_col_types %>%
        mutate(autoincrement_attribute = if_else(
          col == pk_col,
          !!autoincrement_attribute,
          autoincrement_attribute
        )
      )
    }

    df_col_types
  }

  col_defs <-
    dm %>%
    src_tbls_impl() %>%
    set_names() %>%
    map_dfr(get_sql_col_types, .id = "name") %>%
    mutate(col_def = glue("{DBI::dbQuoteIdentifier(con, col)} {type}{autoincrement_attribute}")) %>%
    group_by(name) %>%
    summarize(
      col_defs = paste(col_def, collapse = ",\n  "),
      columns = list(col)
    )

  # default values
  pk_defs <- tibble(name = character(0), pk_defs = character(0))
  fk_defs <- tibble(name = character(0), fk_defs = character(0))
  unique_defs <- tibble(name = character(0), unique_defs = character(0))
  index_queries <- tibble(
    name = character(0),
    sql_index = list(),
    index_name = list()
  )

  if (set_key_constraints) {
    # primary key definitions
    pk_defs <-
      pks %>%
      transmute(
        name,
        pk_defs = paste0("PRIMARY KEY (", quote_enum_col(pk_col), ")")
      )

    # unique constraint definitions
    unique_defs <-
      uniques %>%
      transmute(
        name,
        unique_def = paste0(
          "UNIQUE (",
          quote_enum_col(pk_col),
          ")"
        )
      ) %>%
      group_by(name) %>%
      summarize(unique_defs = paste(unique_def, collapse = ",\n  "))

    # foreign key definitions and indexing queries
    # https://github.com/r-lib/rlang/issues/1422
    if (is_duckdb(con) && package_version(asNamespace("duckdb")$.__NAMESPACE__.$spec[["version"]]) < "0.3.4.1") {
      if (nrow(fks)) {
        warn("duckdb doesn't support foreign keys, these won't be set in the remote database but are preserved in the `dm`")
      }
    } else if (is_mariadb(con) && temporary) {
      if (nrow(fks) > 0 && !is_testing()) {
        warn("MySQL and MariaDB don't support foreign keys for temporary tables, these won't be set in the remote database but are preserved in the `dm`")
      }
    } else {
      fk_defs <-
        fks %>%
        transmute(
          name = child_table,
          fk_def = paste0(
            "FOREIGN KEY (",
            quote_enum_col(child_fk_cols),
            ") REFERENCES ",
            unlist(table_names[parent_table]),
            " (",
            quote_enum_col(parent_key_cols),
            ")"
          )
        ) %>%
        group_by(name) %>%
        summarize(fk_defs = paste(fk_def, collapse = ",\n  "))

      index_queries <-
        fks %>%
        mutate(
          name = child_table,
          index_name = map_chr(child_fk_cols, paste, collapse = "_"),
          remote_name = unlist(table_names[name]) %||% character(0),
          remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, DBI::SQL(remote_name)), ~ .x@name[["table"]]),
          index_name = make.unique(paste0(remote_name_unquoted, "__", index_name), sep = "__")
        ) %>%
        group_by(name) %>%
        summarize(
          sql_index = list(DBI::SQL(paste0(
            "CREATE INDEX ",
            index_name,
            " ON ",
            remote_name,
            " (",
            quote_enum_col(child_fk_cols),
            ")"
          ))),
          index_name = list(index_name)
        )
    }
  }

  ## compile `CREATE TABLE ...` queries
  create_table_queries <-
    col_defs %>%
    left_join(pk_defs, by = "name") %>%
    left_join(unique_defs, by = "name") %>%
    left_join(fk_defs, by = "name") %>%
    group_by(name, columns) %>%
    mutate(
      remote_name = table_names[name],
      all_defs = paste(
        Filter(
          Negate(is.na),
          c(col_defs, pk_defs, unique_defs, fk_defs)
        ),
        collapse = ",\n  "
      )
    ) %>%
    ungroup() %>%
    transmute(name, remote_name, columns, sql_table = DBI::SQL(glue(
      "CREATE {if (temporary) 'TEMPORARY ' else ''}TABLE {unlist(remote_name)} (\n  {all_defs}\n)"
    )))

  queries <- left_join(create_table_queries, index_queries, by = "name")

  ## Reorder queries according to topological sort so pks are created before associated fks
  graph <- create_graph_from_dm(dm, directed = TRUE)
  topo <- igraph::topo_sort(graph, mode = "in")
  idx <- match(names(topo), queries$name)

  if (length(idx) == nrow(create_table_queries)) {
    queries <- queries[idx, ]
  }

  queries
}
