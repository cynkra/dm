## SQL script backend for copy_dm_to()
## taken to new file to avoid merge conflicts to ongoing changes in db-interface.R #1739

#' @name dm_sql
#'
#' @title Create \emph{DDL} and \emph{DML} scripts for `dm` and database connection
#'
#' @description
#' Generate SQL scripts to create tables, load data and set constraints, keys and indices.
#'
#' @param dm A `dm` object.
#' @param dest Connection to database.
#' @param table_names A named character vector, with one unique element
#'   for each table in `dm`. The default, `NULL`, means to use the original table names.
#' @param temporary Should the tables be marked as \emph{temporary}? Defaults to `TRUE`.
#'
#' @details
#' \itemize{
#'   \item{ `dm_ddl_pre()` generates `CREATE TABLE` statements (including `PRIMARY KEY` definition). }
#'   \item{ `dm_dml_load()` generates `INSERT INTO` statements. }
#'   \item{ `dm_ddl_post()` generates scripts for `FOREIGN KEY`, `UNIQUE KEY` and `INDEX`. }
#'   \item{ `dm_sql()` calls all three above and returns a complete set of scripts. }
#' }
#'
#' @return Nested list of SQL statements.
#'
#' @export
#' @examplesIf rlang::is_installed("RSQLite")
#' con <- DBI::dbConnect(RSQLite::SQLite())
#' dm <- dm_nycflights13()
#' s <- dm_sql(dm, con)
#' s
#' DBI::dbDisconnect(con)
dm_sql <- function(
    dm,
    dest,
    table_names = NULL,
    temporary = TRUE) {
  #
  table_names <- ddl_check_table_names(table_names, dm)

  list(
    ## CREATE TABLE and PRIMARY KEY
    pre = dm_ddl_pre(dm, dest, table_names, temporary),
    ## INSERT INTO, handle autoincrement, TODO handle+test ai together with !set_key_constraints
    load = dm_dml_load(dm, dest, table_names, temporary),
    ## FOREIGN KEYS, UNIQUE KEYS, INDEXES
    post = dm_ddl_post(dm, dest, table_names, temporary)
  )
}

ddl_check_table_names <- function(table_names, dm) {
  if (is.null(table_names)) {
    table_names <- set_names(names(dm))
  }

  table_names
}

#' @rdname dm_sql
#' @export
#' @autoglobal
dm_ddl_pre <- function(
    dm,
    dest,
    table_names = NULL,
    temporary = TRUE) {
  #
  table_names <- ddl_check_table_names(table_names, dm)

  ## Reorder queries according to topological sort so pks are created before associated fks
  graph <- create_graph_from_dm(dm, directed = TRUE)
  topo <- names(igraph::topo_sort(graph, mode = "in"))

  if (length(topo) == length(dm)) {
    dm <- dm[topo]
  }

  ## use 0-rows object
  ptype_dm <- collect(dm_ptype(dm))

  con <- con_from_src_or_con(dest)

  ## helper to quote all elements of a column and enumerate (concat) element wise
  quote_enum_col <- function(x) {
    map_chr(x, ~ toString(map_chr(.x, DBI::dbQuoteIdentifier, conn = con)))
  }

  ## helper to set on delete statement for fks if required
  set_on_delete_col <- function(x) {
    if (is_duckdb(dest) && any(x == "cascade")) {
      inform(glue('`on_delete = "cascade"` not supported for duckdb'))
      ""
    } else {
      map_chr(x, ~ {
        switch(.x,
          "no_action" = "",
          "cascade" = " ON DELETE CASCADE",
          abort(glue('`on_delete = "{.x}"` not supported'))
        )
      })
    }
  }

  ## fetch types, keys and uniques
  pks <- dm_get_all_pks_impl(ptype_dm) %>% rename(name = table)

  ## build sql definitions to use in `CREATE TABLE ...`

  # column definitions
  get_sql_col_types <- function(x) {
    # autoincrementing is not possible for composite keys, so `pk_col` is guaranteed
    # to be a scalar
    pk_col <- vec_slice(pks, pks$table == x)

    tbl <- tbl_impl(ptype_dm, x)
    types <- DBI::dbDataType(con, tbl)

    # database-specific type conversions
    if (is_mariadb(dest)) {
      types[types == "TEXT"] <- "VARCHAR(255)"
    }
    if (is_sqlite(dest)) {
      types[types == "INT"] <- "INTEGER"
    }

    # database-specific autoincrementing column types
    if (isTRUE(pk_col$autoincrement)) {
      # extract column name representing primary key
      pk_col_name <- pk_col$pk_col[[1]]

      # Postgres:
      if (is_postgres(dest)) {
        types[pk_col_name] <- "SERIAL"
      }

      # SQL Server:
      if (is_mssql(dest)) {
        types[pk_col_name] <- paste0(types[pk_col], " IDENTITY")
      }

      # MariaDB:
      # Doesn't have a special data type. Uses `AUTO_INCREMENT` attribute instead.
      # Ref: https://mariadb.com/kb/en/auto_increment/
      if (is_mariadb(dest)) {
        autoincrement_attribute <- paste0(types[pk_col], " AUTO_INCREMENT")
      }

      # DuckDB:
      # Doesn't have a special data type. Uses `CREATE SEQUENCE` instead.
      # Ref: https://duckdb.org/docs/sql/statements/create_sequence

      # SQLite:
      # For a primary key, autoincrementing works by default, and it is almost never
      # necessary to use the `AUTOINCREMENT` keyword. So nothing we need to do here.
      # Ref: https://www.sqlite.org/autoinc.html
    }

    enframe(types, "col", "type")
  }

  tbl_defs <- tibble(name = names(ptype_dm))

  col_defs <-
    ptype_dm %>%
    src_tbls_impl() %>%
    set_names() %>%
    map_dfr(get_sql_col_types, .id = "name") %>%
    mutate(col_def = glue("{DBI::dbQuoteIdentifier(con, col)} {type}")) %>%
    group_by(name) %>%
    summarize(
      col_defs = paste(col_def, collapse = ",\n  "),
      columns = list(col)
    )

  # primary key definitions
  pk_defs <-
    pks %>%
    transmute(
      name,
      pk_defs = paste0("PRIMARY KEY (", quote_enum_col(pk_col), ")")
    )

  ## compile `CREATE TABLE ...` queries
  create_table_queries <-
    tbl_defs %>%
    left_join(col_defs, by = "name") %>%
    left_join(pk_defs, by = "name") %>%
    group_by(name, columns) %>%
    mutate(
      remote_name = table_names[name],
      all_defs = paste(
        Filter(
          Negate(is.na),
          c(col_defs, pk_defs)
        ),
        collapse = ",\n  "
      )
    ) %>%
    ungroup() %>%
    transmute(name, remote_name, columns, sql_table = DBI::SQL(glue(
      "CREATE {if (temporary) 'TEMPORARY ' else ''}TABLE {purrr::map_chr(remote_name, ~ DBI::dbQuoteIdentifier(con, .x))} (\n  {all_defs}\n)"
    )))

  set_names(map(create_table_queries$sql_table, DBI::SQL), create_table_queries$name)
}

#' @rdname dm_sql
#' @export
dm_dml_load <- function(
    dm,
    dest,
    table_names = NULL,
    temporary = TRUE) {
  #
  table_names <- ddl_check_table_names(table_names, dm)

  if (is_mssql(dest)) {
    pks <- dm_get_all_pks_impl(dm)
  } else {
    pks <- NULL
  }

  tbl_dml_load <- function(tbl_name) {
    x <- collect(dm[[tbl_name]])
    if (nrow(x) == 0) {
      return(NULL)
    }

    mssql_autoinc <- !is.null(pks) && isTRUE(pks$autoincrement[tbl_name == pks$table])

    remote_name <- table_names[[tbl_name]]
    remote_tbl_quoted <- DBI::dbQuoteIdentifier(dest, remote_name)
    selectvals <- dbplyr::sql_render(dbplyr::copy_inline(dest, x))

    if (is_mariadb(dest)) {
      # Work around https://github.com/tidyverse/dbplyr/pull/1195
      selectvals <- strsplit(selectvals, "\n", fixed = TRUE)[[1]]
      from <- grep("^FROM", selectvals)[[1]]
      idx <- seq_len(from - 1L)
      # https://github.com/tidyverse/dbplyr/pull/1195
      selectvals[idx] <- gsub(" AS NUMERIC", " AS DOUBLE", selectvals[idx])
      selectvals <- paste(selectvals, collapse = "\n")
    }

    ## for some DBes we could skip columns specification, but only when no autoincrement, easier to just specify that always
    ## duckdb autoincrement tests are skipped, could be added by inserting from sequence
    out <- paste0(
      "INSERT INTO ",
      remote_tbl_quoted,
      " (",
      paste(DBI::dbQuoteIdentifier(dest, names(x)), collapse = ", "),
      ")\n",
      selectvals
    )
    DBI::SQL(paste0(
      if (mssql_autoinc) paste0("SET IDENTITY_INSERT ", remote_tbl_quoted, " ON\n"),
      out,
      if (mssql_autoinc) paste0("\nSET IDENTITY_INSERT ", remote_tbl_quoted, " OFF")
    ))
  }

  compact(map(set_names(names(dm)), tbl_dml_load))
}

#' @rdname dm_sql
#' @export
dm_ddl_post <- function(
    dm,
    dest,
    table_names = NULL,
    temporary = TRUE) {
  #
  table_names <- ddl_check_table_names(table_names, dm)

  ## Reorder queries according to topological sort so pks are created before associated fks
  graph <- create_graph_from_dm(dm, directed = TRUE)
  topo <- names(igraph::topo_sort(graph, mode = "in"))

  if (length(topo) == length(dm)) {
    dm <- dm[topo]
  }

  ## use 0-rows object
  ptype_dm <- collect(dm_ptype(dm))

  con <- con_from_src_or_con(dest)

  ## helper to quote all elements of a column and enumerate (concat) element wise
  quote_enum_col <- function(x) {
    map_chr(x, ~ toString(map_chr(.x, DBI::dbQuoteIdentifier, conn = con)))
  }

  ## helper to set on delete statement for fks if required
  set_on_delete_col <- function(x) {
    if (is_duckdb(dest) && any(x == "cascade")) {
      inform(glue('`on_delete = "cascade"` not supported for duckdb'))
      ""
    } else {
      map_chr(x, ~ {
        switch(.x,
          "no_action" = "",
          "cascade" = " ON DELETE CASCADE",
          abort(glue('`on_delete = "{.x}"` not supported'))
        )
      })
    }
  }

  ## fetch types, keys and uniques
  pks <- dm_get_all_pks_impl(ptype_dm) %>% rename(name = table)
  fks <- dm_get_all_fks_impl(ptype_dm)
  uks <- dm_get_all_uks_impl(ptype_dm) %>% rename(name = table)

  ## build sql definitions to use in `CREATE TABLE ...`

  tbl_defs <- tibble(name = names(ptype_dm))

  # default values
  fk_defs <- tibble(name = character(0), fk_defs = list())
  uk_defs <- tibble(name = character(0), uk_defs = list())
  index_queries <- tibble(
    name = character(0),
    index_defs = list(),
    index_name = list()
  )

  # unique constraint definitions
  if (nrow(uks) == 0) {
    # No action
  } else if (is_duckdb(con)) {
    if (!is_testing()) {
      warn("DuckDB doesn't support adding unique keys to existing tables, these won't be set in the remote database but are preserved in the `dm`")
    }
  } else if (is_sqlite(con)) {
    if (!is_testing()) {
      warn("SQLite doesn't support adding unique keys to existing tables, these won't be set in the remote database but are preserved in the `dm`")
    }
  } else {
    uk_defs <-
      uks %>%
      transmute(
        name,
        remote_name = table_names[name],
        unique_def = paste0(
          "UNIQUE (",
          quote_enum_col(uk_col),
          ")"
        )
      ) %>%
      group_by(name) %>%
      summarize(uk_defs = list(DBI::SQL(glue(
        # FIXME: Designate temporary table if possible
        "ALTER TABLE {DBI::dbQuoteIdentifier(con, remote_name[[1]])} ADD {unique_def}"
      )))) %>%
      ungroup()
  }

  # foreign key definitions and indexing queries
  # https://github.com/r-lib/rlang/issues/1422
  if (nrow(fks) == 0) {
    # No action
  } else if (is_mariadb(con) && temporary) {
    if (!is_testing()) {
      warn("MySQL and MariaDB don't support foreign keys for temporary tables, these won't be set in the remote database but are preserved in the `dm`")
    }
  } else if (is_duckdb(con)) {
    if (!is_testing()) {
      warn("DuckDB doesn't support adding foreign keys to existing tables, these won't be set in the remote database but are preserved in the `dm`")
    }
  } else if (is_sqlite(con)) {
    if (!is_testing()) {
      warn("SQLite doesn't support adding foreign keys to existing tables, these won't be set in the remote database but are preserved in the `dm`")
    }
  } else {
    fk_defs <-
      fks %>%
      transmute(
        name = child_table,
        remote_name = table_names[name],
        fk_def = paste0(
          "FOREIGN KEY (",
          quote_enum_col(child_fk_cols),
          ") REFERENCES ",
          purrr::map_chr(table_names[fks$parent_table], ~ DBI::dbQuoteIdentifier(con, .x)),
          " (",
          quote_enum_col(parent_key_cols),
          ")",
          set_on_delete_col(on_delete)
        )
      ) %>%
      group_by(name) %>%
      summarize(fk_defs = list(DBI::SQL(glue(
        # FIXME: Designate temporary table if possible
        "ALTER TABLE {DBI::dbQuoteIdentifier(con, remote_name[[1]])} ADD {fk_def}"
      )))) %>%
      ungroup()

    index_queries <-
      fks %>%
      mutate(
        name = child_table,
        index_name = map_chr(child_fk_cols, paste, collapse = "_"),
        remote_name = purrr::map_chr(table_names[name], ~ DBI::dbQuoteIdentifier(con, .x)),
        remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, DBI::SQL(remote_name)), ~ .x@name[["table"]]),
        index_name = make.unique(paste0(remote_name_unquoted, "__", index_name), sep = "__")
      ) %>%
      group_by(name) %>%
      summarize(
        index_defs = list(DBI::SQL(paste0(
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

  queries <-
    tbl_defs %>%
    left_join(uk_defs, by = "name") %>%
    left_join(fk_defs, by = "name") %>%
    left_join(index_queries, by = "name")

  list(
    uk = compact(set_names(queries$uk_defs, queries$name)),
    fk = compact(set_names(queries$fk_defs, queries$name)),
    indexes = compact(set_names(queries$index_defs, queries$name))
  )
}
