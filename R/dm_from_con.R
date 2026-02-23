#' Load a dm from a remote data source
#'
#' @description
#' `dm_from_con()` creates a [dm] from some or all tables in a [src]
#' (a database or an environment) or which are accessible via a DBI-Connection.
#' For Postgres/Redshift and SQL Server databases, primary and foreign keys
#' are imported from the database.
#'
#' @param con A [`DBI::DBIConnection-class`] or a `Pool` object.
#' @param table_names
#'   A character vector of the names of the tables to include.
#' @param learn_keys
#'   `r lifecycle::badge("experimental")`
#'
#'   Set to `TRUE` to query the definition of primary and
#'   foreign keys from the database.
#'   Currently works for Postgres/Redshift, MariaDB/MySQL, SQLite, SQL Server, and DuckDB databases.
#'   The default attempts to query and issues an informative message.
#' @param .names
#'   `r lifecycle::badge("experimental")`
#'
#'   A glue specification that describes how to name the tables
#'   within the output, currently only for MSSQL, Postgres/Redshift and MySQL/MariaDB.
#'   This can use `{.table}` to stand for the table name, and
#'   `{.schema}` to stand for the name of the schema which the table lives
#'   within. The default (`NULL`) is equivalent to `"{.table}"` when a single
#'   schema is specified in `schema`, and `"{.schema}.{.table}"` for the case
#'   where multiple schemas are given, and may change in future versions.
#' @param ... `r lifecycle::badge("experimental")`
#'
#'   Additional parameters for the schema learning query.
#'
#'   - `schema`: supported for MSSQL (default: `"dbo"`), Postgres/Redshift (default: `"public"`), MariaDB/MySQL
#'     (default: current database) and SQLite (default: main schema).
#'     Learn the tables in a specific schema (or database for MariaDB/MySQL).
#'   - `dbname`: supported for MSSQL. Access different databases on the connected MSSQL-server;
#'     default: active database.
#'   - `table_type`: supported for Postgres/Redshift (default: `"BASE TABLE"`). Specify the table type. Options are:
#'     1. `"BASE TABLE"` for a persistent table (normal table type)
#'     2. `"VIEW"` for a view
#'     3. `"FOREIGN TABLE"` for a foreign table
#'     4. `"LOCAL TEMPORARY"` for a temporary table
#'
#' @return A `dm` object.
#'
#' @export
#' @examplesIf dm:::dm_has_financial()
#' con <- dm_get_con(dm_financial())
#'
#' # Avoid DBI::dbDisconnect() here, because we don't own the connection
dm_from_con <- function(
  con = NULL,
  table_names = NULL,
  learn_keys = NULL,
  .names = NULL,
  ...
) {
  dm_local_error_call()
  stopifnot(is(con, "DBIConnection") || inherits(con, "Pool"))

  check_suggested("dbplyr", "dm_from_con")

  if (inherits(con, "Pool")) {
    con <- pool_con <- pool::poolCheckout(con)
    on.exit(pool::poolReturn(pool_con))
  }

  src <- src_from_src_or_con(con)

  # Use smart default for `.names`, if it wasn't provided
  dots <- list2(...)
  if (!is.null(.names)) {
    names_pattern <- .names
  } else if (is.null(dots$schema) || length(dots$schema) == 1) {
    names_pattern <- "{.table}"
  } else {
    names_pattern <- "{.schema}.{.table}"
    cli::cli_inform('Using {.code .names = "{names_pattern}"}')
  }

  if (is.null(learn_keys) || isTRUE(learn_keys)) {
    # FIXME: Try to make it work everywhere
    tryCatch(
      {
        dm_learned <- dm_learn_from_db(con, ..., names_pattern = names_pattern)
        if (is_null(learn_keys)) {
          cli::cli_inform(c(
            "Keys queried successfully.",
            i = "Use {.code learn_keys = TRUE} to enforce querying keys and to mute this message."
          ))
        }

        if (is_null(table_names)) {
          return(dm_learned)
        }

        tbls_in_dm <- src_tbls_impl(dm_learned)

        if (!all(table_names %in% tbls_in_dm)) {
          abort_tbl_access(setdiff(table_names, tbls_in_dm))
        }
        tbls_req <- intersect(tbls_in_dm, table_names)

        return(dm_learned %>% dm_select_tbl(!!!tbls_req))
      },
      error = function(e) {
        if (isTRUE(learn_keys)) {
          abort_learn_keys(e)
        }
        cli::cli_inform(
          "Keys could not be queried.",
          x = conditionMessage(e),
          i = "Use {.code learn_keys = FALSE} to avoid trying to query keys and to mute this message."
        )
        NULL
      }
    )
  }

  if (is_null(table_names)) {
    src_tbl_names <- get_src_tbl_names(src, ..., names_pattern = names_pattern)
  } else {
    src_tbl_names <- table_names
    if (is.null(names(src_tbl_names))) {
      names(src_tbl_names) <- src_tbl_names
    }
  }

  tbls <-
    src_tbl_names %>%
    quote_ids(con) %>%
    map(possibly(tbl, NULL), src = src)

  bad <- map_lgl(tbls, is_null)
  if (any(bad)) {
    if (is_null(table_names)) {
      warn_tbl_access(names(tbls)[bad])
      tbls <- tbls[!bad]
    } else {
      abort_tbl_access(names(tbls)[bad])
    }
  }

  new_dm(tbls)
}

#' Load a dm from a remote data source
#'
#' Deprecated  in dm 0.3.0 in favor of [dm_from_con()].
#'
#' @inheritParams dm_from_con
#' @param src A dbplyr source, DBI connection object or a Pool object.
#'
#' @export
#' @keywords internal
dm_from_src <- function(src = NULL, table_names = NULL, learn_keys = NULL, ...) {
  if (is_null(src)) {
    return(empty_dm())
  }

  deprecate_warn("0.3.0", "dm::dm_from_src()", "dm::dm_from_con()")
  dm_from_con(con = con_from_src_or_con(src), table_names, learn_keys, ...)
}

quote_ids <- function(x, con, schema = NULL) {
  if (is.null(con)) {
    return(x)
  }

  if (is_null(schema)) {
    map_if(x, ~ !inherits(.x, "Id"), ~ DBI::Id(table = .x))
  } else {
    map_if(x, ~ !inherits(.x, "Id"), ~ schema_if(rep(schema, length(.x)), .x, con)[[1]])
  }
}

# Errors ------------------------------------------------------------------

abort_learn_keys <- function(parent) {
  cli::cli_abort(
    c(
      "Failed to learn keys from database.",
      i = "Use {.code learn_keys = FALSE} to work around, or {.code dm:::dm_meta()} to debug."
    ),
    class = dm_error_full("learn_keys"),
    parent = parent,
    call = dm_error_call()
  )
}

abort_tbl_access <- function(bad) {
  cli::cli_abort(
    c(
      "{cli::qty(length(bad))}Table{?s} {.field {bad}} cannot be accessed.",
      i = "Use {.code tbl(src, ...)} to troubleshoot."
    ),
    class = dm_error_full("tbl_access"),
    call = dm_error_call()
  )
}

warn_tbl_access <- function(bad) {
  cli::cli_warn(
    c(
      "{cli::qty(length(bad))}Table{?s} {.field {bad}} cannot be accessed.",
      i = "Use {.code tbl(src, ...)} to troubleshoot.",
      i = "Set the {.arg table_name} argument to avoid this warning."
    ),
    class = dm_warning_full("tbl_access")
  )
}
