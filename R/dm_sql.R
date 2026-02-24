## SQL script backend for copy_dm_to()
## taken to new file to avoid merge conflicts to ongoing changes in db-interface.R #1739

#' @name dm_sql
#'
#' @title Create \emph{DDL} and \emph{DML} scripts for a `dm` a and database connection
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Generate SQL scripts to create tables, load data and set constraints, keys and indices.
#' This function powers [copy_dm_to()] and is useful if you need more control
#' over the process of copying a `dm` to a database.
#'
#' @param dm A `dm` object.
#' @param dest Connection to database.
#' @param table_names A named character vector or named vector of [DBI::Id],
#'   [DBI::SQL] or dbplyr objects created with [dbplyr::ident()], [dbplyr::in_schema()]
#'   or [dbplyr::in_catalog()],
#'   with one unique element for each table in `dm`.
#'   The default, `NULL`, means to use the original table names.
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
#' @examplesIf rlang::is_installed(c("RSQLite", "dbplyr"))
#' con <- DBI::dbConnect(RSQLite::SQLite())
#' dm <- dm_nycflights13()
#' s <- dm_sql(dm, con)
#' s
#' DBI::dbDisconnect(con)
dm_sql <- function(
  dm,
  dest,
  table_names = NULL,
  temporary = TRUE
) {
  #
  check_suggested("dbplyr", "dm_sql")

  stopifnot(is(dest, "DBIConnection"))

  table_names <- ddl_quote_table_names(table_names, dm, dest)

  dm <- ddl_reorder_dm(dm, dest)

  list(
    ## CREATE TABLE and PRIMARY KEY, FOREIGN KEYS and UNIQUE KEYS on DuckDB and SQLite
    pre = dm_ddl_pre(dm, dest, table_names, temporary),
    ## INSERT INTO, handle autoincrement
    load = dm_dml_load(dm, dest, table_names, temporary),
    ## FOREIGN KEYS and UNIQUE KEYS (except DuckDB and SQLite), INDEXES
    post = dm_ddl_post(dm, dest, table_names, temporary)
  )
}

ddl_quote_table_names <- function(table_names, dm, dest) {
  if (is.null(table_names)) {
    table_names <- set_names(names(dm))
  } else {
    stopifnot(names(dm) %in% names(table_names))
  }

  map(
    table_names,
    ~ {
      if (inherits(.x, "sql")) {
        # no op, need this because sql is also a character
      } else if (is.character(.x) || is(.x, "Id")) {
        .x <- DBI::dbQuoteIdentifier(dest, .x)
      }

      dbplyr::escape(.x, con = dest)
    }
  )
}

ddl_reorder_dm <- function(dm, con) {
  if (!ddl_need_early_constraints(con)) {
    return(dm)
  }

  ## For databases that do not support adding constraints after table creation,
  ## reorder queries according to topological sort so uks are created before associated fks
  graph <- create_graph_from_dm(dm, directed = TRUE)
  topo <- names(graph_topo_sort(graph, mode = "in"))

  if (length(topo) == length(dm)) {
    dm <- dm[topo]
  } else {
    cli_warn(c(
      # FIXME: show cycle
      "Cycles in the relationship graph prevent creation of foreign key constraints.",
      i = if (is_duckdb(dest)) "DuckDB does not support adding constraints after table creation.",
      i = if (is_sqlite(dest)) "SQLite does not support adding constraints after table creation.",
      NULL
    ))
    dm <- dm_rm_fk(dm)
  }

  dm
}

#' @rdname dm_sql
#' @export
#' @autoglobal
dm_ddl_pre <- function(
  dm,
  dest,
  table_names = NULL,
  temporary = TRUE
) {
  #
  check_suggested("dbplyr", "dm_ddl_pre")

  table_names <- ddl_quote_table_names(table_names, dm, dest)

  dm <- ddl_reorder_dm(dm, dest)

  ## use 0-rows object if from database
  if (is_src_db(dm)) {
    ptype_dm <- collect(dm_ptype(dm))
  } else {
    ptype_dm <- dm
  }

  con <- con_from_src_or_con(dest)

  ## fetch types, keys and uniques
  pks <- dm_get_all_pks_impl(ptype_dm)
  uks <- dm_get_all_uks_impl(ptype_dm)
  fks <- dm_get_all_fks_impl(ptype_dm)

  ## build sql definitions to use in `CREATE TABLE ...`

  tbl_defs <- tibble(name = names(ptype_dm))

  # column definitions
  col_defs <-
    ptype_dm %>%
    dm_get_tables() %>%
    ddl_get_col_defs(con, table_names, pks) %>%
    group_by(name) %>%
    summarize(
      col_defs = paste(col_def, collapse = ",\n  ")
    ) %>%
    ungroup()

  # primary key definitions
  pk_defs <-
    pks %>%
    ddl_get_pk_def(con, table_names)

  # Only add constraints if not adding them later
  if (!ddl_need_early_constraints(dest)) {
    uks <- vec_slice(uks, 0)
    fks <- vec_slice(fks, 0)
  }

  uk_defs <-
    uks %>%
    ddl_get_uk_defs(con, table_names) %>%
    group_by(name) %>%
    summarize(uk_defs = paste(uk_def, collapse = ",\n  ")) %>%
    ungroup()

  fk_defs <-
    fks %>%
    ddl_get_fk_defs(con, table_names) %>%
    group_by(name) %>%
    summarize(fk_defs = paste(fk_def, collapse = ",\n  ")) %>%
    ungroup()

  ## compile `CREATE TABLE ...` queries
  create_table_queries <-
    tbl_defs %>%
    left_join(col_defs, by = "name") %>%
    left_join(pk_defs, by = "name") %>%
    left_join(uk_defs, by = "name") %>%
    left_join(fk_defs, by = "name") %>%
    rowwise() %>%
    mutate(
      remote_name = table_names[name],
      all_defs = paste(
        Filter(
          Negate(is.na),
          c(col_defs, pk_def, uk_defs, fk_defs)
        ),
        collapse = ",\n  "
      )
    ) %>%
    ungroup() %>%
    transmute(
      name,
      remote_name,
      sql_table = DBI::SQL(glue(
        "CREATE {if (temporary) 'TEMPORARY ' else ''}TABLE {remote_name} (\n  {all_defs}\n)"
      ))
    )

  set_names(map(create_table_queries$sql_table, DBI::SQL), create_table_queries$name)
}

#' @rdname dm_sql
#' @export
dm_dml_load <- function(
  dm,
  dest,
  table_names = NULL,
  temporary = TRUE
) {
  #
  check_suggested("dbplyr", "dm_dml_load")

  table_names <- ddl_quote_table_names(table_names, dm, dest)

  dm <- ddl_reorder_dm(dm, dest)

  if (is_mssql(dest)) {
    pks <- dm_get_all_pks_impl(dm)
  } else {
    pks <- NULL
  }

  dm %>%
    names() %>%
    set_names() %>%
    map(dml_tbl_load, dm, table_names, pks, dest) %>%
    compact()
}

#' @rdname dm_sql
#' @export
dm_ddl_post <- function(
  dm,
  dest,
  table_names = NULL,
  temporary = TRUE
) {
  #
  check_suggested("dbplyr", "dm_ddl_post")

  table_names <- ddl_quote_table_names(table_names, dm, dest)

  ## use 0-rows object
  ptype_dm <- collect(dm_ptype(dm))

  con <- con_from_src_or_con(dest)

  ## fetch types, keys and uniques
  uks <- dm_get_all_uks_impl(ptype_dm)
  fks <- dm_get_all_fks_impl(ptype_dm)

  ## build sql definitions to use in `CREATE TABLE ...`

  tbl_defs <- tibble(name = names(ptype_dm))

  # Get this before we perhaps erase fks
  index_defs <- ddl_get_index_defs(fks, con, table_names)

  # unique constraint definitions
  if (nrow(uks) == 0) {
    # No action
  } else if (ddl_need_early_constraints(dest)) {
    uks <- vec_slice(uks, 0)
  }

  uk_defs <-
    ddl_get_uk_defs(uks, con, table_names) %>%
    group_by(name) %>%
    summarize(
      uk_defs = if (length(remote_name) == 0) {
        list(NULL)
      } else {
        list(DBI::SQL(glue(
          # FIXME: Designate temporary table if possible
          "ALTER TABLE {remote_name[[1]]} ADD {uk_def}"
        )))
      }
    ) %>%
    ungroup()

  # foreign key definitions and indexing queries
  # https://github.com/r-lib/rlang/issues/1422
  if (nrow(fks) == 0) {
    # No action
  } else if (is_mariadb(con) && temporary) {
    if (!is_testing()) {
      warn(
        "MySQL and MariaDB don't support foreign keys for temporary tables, these won't be set in the remote database but are preserved in the `dm`"
      )
    }
    fks <- vec_slice(fks, 0)
  } else if (ddl_need_early_constraints(dest)) {
    fks <- vec_slice(fks, 0)
  }

  fk_defs <-
    ddl_get_fk_defs(fks, con, table_names) %>%
    group_by(name) %>%
    summarize(
      fk_defs = if (length(remote_name) == 0) {
        list(NULL)
      } else {
        list(DBI::SQL(glue(
          # FIXME: Designate temporary table if possible
          "ALTER TABLE {remote_name[[1]]} ADD {fk_def}"
        )))
      }
    ) %>%
    ungroup()

  queries <-
    tbl_defs %>%
    left_join(uk_defs, by = "name") %>%
    left_join(fk_defs, by = "name") %>%
    left_join(index_defs, by = "name")

  list(
    uk = compact(set_names(queries$uk_defs, queries$name)),
    fk = compact(set_names(queries$fk_defs, queries$name)),
    indexes = compact(set_names(queries$index_defs, queries$name))
  )
}

ddl_need_early_constraints <- function(con) {
  is_duckdb(con) || is_sqlite(con)
}

ddl_quote_enum_col <- function(x, con) {
  map_chr(x, ~ paste(DBI::dbQuoteIdentifier(.x, conn = con), collapse = ", "))
}

ddl_get_col_defs <- function(tables, con, table_names, pks) {
  duckdb_auto_warned <- FALSE

  get_sql_col_types <- function(tbl, name) {
    # autoincrementing is not possible for composite keys, so `pk_col` is guaranteed
    # to be a scalar
    pk_col <- vec_slice(pks, pks$table == name)

    types <- DBI::dbDataType(con, tbl)

    # database-specific type conversions
    if (is_mariadb(con)) {
      # FIXME: This is wrong in general, only needed for index columns
      if (nrow(tbl) == 0) {
        types[types == "TEXT"] <- "VARCHAR(255)"
      } else {
        for (i in which(types == "TEXT")) {
          chars <- max(nchar(tbl[[i]], type = "bytes", keepNA = FALSE))
          if (chars <= 255) {
            types[[i]] <- paste0("VARCHAR(255)")
          }
        }
      }
    }
    if (is_sqlite(con)) {
      types[types == "INT"] <- "INTEGER"
    }

    # database-specific autoincrementing column types
    if (isTRUE(pk_col$autoincrement)) {
      # extract column name representing primary key
      pk_col_name <- pk_col$pk_col[[1]]

      # Postgres/Redshift:
      if (is_postgres(con) || is_redshift(con)) {
        types[pk_col_name] <- "SERIAL"
      }

      # SQL Server:
      if (is_mssql(con)) {
        types[pk_col_name] <- paste0(types[pk_col_name], " IDENTITY")
      }

      # MariaDB:
      # Doesn't have a special data type. Uses `AUTO_INCREMENT` attribute instead.
      # Ref: https://mariadb.com/kb/en/auto_increment/
      if (is_mariadb(con)) {
        types[pk_col_name] <- paste0(types[pk_col_name], " AUTO_INCREMENT")
      }

      # DuckDB:
      # Doesn't have a special data type. Uses `CREATE SEQUENCE` instead.
      # Ref: https://duckdb.org/docs/sql/statements/create_sequence
      # https://stackoverflow.com/a/72883259/946850
      if (is_duckdb(con)) {
        if (!duckdb_auto_warned) {
          cli_warn(
            "Autoincrementing columns not yet supported for DuckDB, these won't be set in the remote database but are preserved in the `dm`"
          )
          duckdb_auto_warned <<- TRUE
        }
      }

      # SQLite:
      # For a primary key, autoincrementing works by default, and it is almost never
      # necessary to use the `AUTOINCREMENT` keyword. So nothing we need to do here.
      # Ref: https://www.sqlite.org/autoinc.html
    }

    enframe(types, "col", "type")
  }

  tables %>%
    imap(get_sql_col_types) %>%
    list_rbind(names_to = "name") %>%
    mutate(col_def = glue("{DBI::dbQuoteIdentifier(con, col)} {type}"))
}

ddl_get_pk_def <- function(pks, con, table_names) {
  pk_defs <- tibble(
    name = character(),
    remote_name = unname(vec_ptype(table_names)),
    pk_def = character()
  )
  if (nrow(pks) == 0) {
    return(pk_defs)
  }

  out <-
    pks %>%
    rename(name = table) %>%
    transmute(
      name,
      remote_name = unname(table_names[name]),
      pk_def = paste0("PRIMARY KEY (", ddl_quote_enum_col(pk_col, con), ")")
    )

  vec_assert(out, pk_defs)
  out
}

ddl_get_uk_defs <- function(uks, con, table_names) {
  uk_defs <- tibble(
    name = character(),
    remote_name = unname(vec_ptype(table_names)),
    uk_def = character()
  )
  if (nrow(uks) == 0) {
    return(uk_defs)
  }

  out <-
    uks %>%
    rename(name = table) %>%
    transmute(
      name,
      remote_name = unname(table_names[name]),
      uk_def = paste0("UNIQUE (", ddl_quote_enum_col(uk_col, con), ")")
    )

  vec_assert(out, uk_defs)
  out
}

ddl_get_fk_defs <- function(fks, con, table_names) {
  fk_defs <- tibble(
    name = character(),
    remote_name = unname(vec_ptype(table_names)),
    fk_def = character()
  )
  if (nrow(fks) == 0) {
    return(fk_defs)
  }

  ## helper to set on delete statement for fks if required
  set_on_delete_col <- function(x) {
    if (is_duckdb(con) && any(x == "cascade")) {
      inform(glue('`on_delete = "cascade"` not supported for duckdb'))
      ""
    } else {
      map_chr(
        x,
        ~ {
          switch(
            .x,
            "no_action" = "",
            "cascade" = " ON DELETE CASCADE",
            cli::cli_abort('{.code on_delete = {.val {.x}}} is not supported.')
          )
        }
      )
    }
  }

  out <-
    fks %>%
    transmute(
      name = child_table,
      remote_name = unname(table_names[name]),
      fk_def = paste0(
        "FOREIGN KEY (",
        ddl_quote_enum_col(child_fk_cols, con),
        ") REFERENCES ",
        table_names[fks$parent_table],
        " (",
        ddl_quote_enum_col(parent_key_cols, con),
        ")",
        set_on_delete_col(on_delete)
      )
    )

  vec_assert(out, fk_defs)
  out
}

dml_tbl_load <- function(tbl_name, dm, table_names, pks, dest) {
  tbl <- collect(dm[[tbl_name]])
  if (nrow(tbl) == 0) {
    return(NULL)
  }

  # pks is NULL if not mssql
  mssql_autoinc <- !is.null(pks) && isTRUE(pks$autoincrement[tbl_name == pks$table])

  remote_name <- table_names[[tbl_name]]
  selectvals <- dbplyr::sql_render(dbplyr::copy_inline(dest, tbl))

  if (is_mariadb(dest)) {
    # Work around https://github.com/tidyverse/dbplyr/pull/1195
    selectvals <- strsplit(selectvals, "\n", fixed = TRUE)[[1]]
    from <- grep("^FROM", selectvals)[[1]]
    idx <- seq_len(from - 1L)
    # https://github.com/tidyverse/dbplyr/pull/1195
    selectvals[idx] <- gsub(" AS NUMERIC", " AS DOUBLE", selectvals[idx])
    # https://github.com/tidyverse/dbplyr/pull/1375
    selectvals[idx] <- gsub("CAST[(]`[^`]*(?:``[^`]*)*` AS INTEGER[)] AS ", "", selectvals[idx])
    selectvals <- paste(selectvals, collapse = "\n")
  }

  ## for some DBes we could skip columns specification, but only when no autoincrement, easier to just specify that always
  ## duckdb autoincrement tests are skipped, could be added by inserting from sequence
  out <- paste0(
    "INSERT INTO ",
    remote_name,
    " (",
    paste(DBI::dbQuoteIdentifier(dest, names(tbl)), collapse = ", "),
    ")\n",
    selectvals
  )
  DBI::SQL(paste0(
    if (mssql_autoinc) paste0("SET IDENTITY_INSERT ", remote_name, " ON\n"),
    out,
    if (mssql_autoinc) paste0("\nSET IDENTITY_INSERT ", remote_name, " OFF")
  ))
}

ddl_get_index_defs <- function(fks, con, table_names) {
  index_defs <- tibble(
    name = character(0),
    index_defs = list(),
    index_name = list()
  )
  if (nrow(fks) == 0) {
    return(index_defs)
  }

  out <-
    fks %>%
    mutate(
      name = child_table,
      index_name = map_chr(child_fk_cols, paste, collapse = "_"),
      remote_name = table_names[name],
      remote_name_unquoted = map_chr(
        DBI::dbUnquoteIdentifier(con, DBI::SQL(remote_name)),
        ~ .x@name[[length(.x@name)]]
      ),
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
        ddl_quote_enum_col(child_fk_cols, con),
        ")"
      ))),
      index_name = list(index_name)
    )

  vec_assert(out, index_defs)
  out
}
