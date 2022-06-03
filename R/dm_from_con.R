#' Load a dm from a remote data source
#'
#' `dm_from_con()` creates a [dm] from some or all tables in a [src]
#' (a database or an environment) or which are accessible via a DBI-Connection.
#' For Postgres and SQL Server databases, primary and foreign keys
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
#'   Currently works only for Postgres and SQL Server databases.
#'   The default attempts to query and issues an informative message.
#' @param ...
#'   `r lifecycle::badge("experimental")`
#'
#'   Additional parameters for the schema learning query.
#'
#'   - `schema`: supported for MSSQL (default: `"dbo"`), Postgres (default: `"public"`), and MariaDB/MySQL
#'     (default: current database). Learn the tables in a specific schema (or database for MariaDB/MySQL).
#'   - `dbname`: supported for MSSQL. Access different databases on the connected MSSQL-server;
#'     default: active database.
#'   - `table_type`: supported for Postgres (default: `"BASE TABLE"`). Specify the table type. Options are:
#'     1. `"BASE TABLE"` for a persistent table (normal table type)
#'     2. `"VIEW"` for a view
#'     3. `"FOREIGN TABLE"` for a foreign table
#'     4. `"LOCAL TEMPORARY"` for a temporary table
#'
#' @return A `dm` object.
#'
#' @export
#' @examplesIf dm:::dm_has_financial()
#' con <- DBI::dbConnect(
#'   RMariaDB::MariaDB(),
#'   username = "guest",
#'   password = "relational",
#'   dbname = "Financial_ijs",
#'   host = "relational.fit.cvut.cz"
#' )
#'
#' dm_from_src(con)
#'
#' DBI::dbDisconnect(con)
dm_from_con <- function(con = NULL, table_names = NULL, learn_keys = NULL,
                        ...) {
  stopifnot(is(con, "DBIConnection") || inherits(con, "Pool"))

  if (inherits(con, "Pool")) {
    con <- pool_con <- pool::poolCheckout(con)
    on.exit(pool::poolReturn(pool_con))
  }

  src <- src_from_src_or_con(con)

  if (is.null(learn_keys) || isTRUE(learn_keys)) {
    # FIXME: Try to make it work everywhere
    tryCatch(
      {
        dm_learned <- dm_learn_from_db(src, ...)
        if (is_null(learn_keys)) {
          inform("Keys queried successfully, use `learn_keys = TRUE` to mute this message.")
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
          abort_learn_keys(conditionMessage(e))
        }
        # FIXME: Use new-style error messages.
        inform(paste0("Keys could not be queried: ", conditionMessage(e), ". Use `learn_keys = FALSE` to mute this message."))
        NULL
      }
    )
  }

  if (is_null(table_names)) {
    src_tbl_names <- get_src_tbl_names(src, ...)
  } else {
    src_tbl_names <- table_names
  }

  if (inherits(src_tbl_names, "SQL")) {
    tbls <-
      src_tbl_names %>%
      map(dbplyr::ident_q) %>%
      map(possibly(tbl, NULL), src = src)
  } else {
    tbls <-
      set_names(src_tbl_names) %>%
      quote_ids(con) %>%
      map(possibly(tbl, NULL), src = src)
  }

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

#' @export
#' @keywords internal
dm_from_src <- function(src = NULL, table_names = NULL, learn_keys = NULL,
                        ...) {
  if (is_null(src)) {
    return(empty_dm())
  }

  deprecate_soft("0.3.0", "dm::dm_from_src()", "dm::dm_from_con()")
  dm_from_con(con = con_from_src_or_con(src), table_names, learn_keys, ...)
}

quote_ids <- function(x, con, schema = NULL) {
  if (is.null(con)) {
    return(x)
  }

  if (is_null(schema)) {
    map(
      x,
      ~ dbplyr::ident_q(dbplyr::build_sql(dbplyr::ident(.x), con = con))
    )
  } else {
    map(
      x,
      ~ dbplyr::ident_q(schema_if(rep(schema, length(.x)), .x, con))
    )
  }
}

# Errors ------------------------------------------------------------------

abort_learn_keys <- function(reason) {
  abort(error_txt_learn_keys(reason), class = dm_error_full("learn_keys"))
}

error_txt_learn_keys <- function(reason) {
  # FIXME: Use new-style error messages.
  paste0(
    "Failed to learn keys from database: ", reason,
    ". Use `learn_keys = FALSE` to work around."
  )
}

abort_tbl_access <- function(bad) {
  dm_abort(
    error_txt_tbl_access(bad),
    "tbl_access"
  )
}

warn_tbl_access <- function(bad) {
  dm_warn(
    c(
      error_txt_tbl_access(bad),
      i = "Set the `table_name` argument to avoid this warning."
    ),
    "tbl_access"
  )
}

error_txt_tbl_access <- function(bad) {
  c(
    glue("Table(s) {commas(tick(bad))} cannot be accessed."),
    i = "Use `tbl(src, ...)` to troubleshoot."
  )
}
