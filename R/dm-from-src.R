#' Load a dm from a remote data source
#'
#' `dm_from_src()` creates a [dm] from some or all tables in a [src]
#' (a database or an environment) or which are accessible via a DBI-Connection.
#' For Postgres and SQL Server databases, primary and foreign keys
#' are imported from the database.
#'
#' @param src A \pkg{dplyr} table source object or a
#'   [`DBI::DBIConnection-class`] object is accepted.
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
#'   - `schema`: supported for MSSQL (default: `"dbo"`) and Postgres (default: `"public"`).
#'   Learn the tables in a specific schema.
#'   - `dbname`: supported for MSSQL. Access different databases on the connected MSSQL-server;
#'   default: database addressed by `src`.
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
dm_from_src <- function(src = NULL, table_names = NULL, learn_keys = NULL,
                        ...) {
  if (is_null(src)) {
    # FIXME: Check empty arguments and ellipsis
    return(empty_dm())
  }
  # both DBI-Connection and {dplyr}-src object are accepted
  src <- src_from_src_or_con(src)
  con <- con_from_src_or_con(src)

  if (is.null(learn_keys) || isTRUE(learn_keys)) {
    dm_learned <- dm_learn_from_db(src, ...)

    if (is.null(dm_learned)) {
      if (isTRUE(learn_keys)) {
        abort_learn_keys()
      }

      inform("Keys could not be queried, use `learn_keys = FALSE` to mute this message.")
    } else {
      if (is_null(learn_keys)) {
        inform("Keys queried successfully, use `learn_keys = TRUE` to mute this message.")
      }

      tbls_in_dm <- src_tbls(dm_learned)

      if (is_null(table_names)) {
        return(dm_learned)
      }

      if (!all(table_names %in% tbls_in_dm)) {
        abort_tbl_access(setdiff(table_names, tbls_in_dm))
      }
      tbls_req <- intersect(tbls_in_dm, table_names)

      return(dm_learned %>% dm_select_tbl(!!!tbls_req))
    }
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

quote_ids <- function(x, con, schema) {
  if (is.null(con)) return(x)

  if (is_null(schema)) {
    map(
      x,
      ~ dbplyr::ident_q(dbplyr::build_sql(dbplyr::ident(.x), con = con))
    )
  } else {
    if (!sql_schema_exists(con, schema)) abort_no_schema_exists(schema)
    map(
      x,
      ~ dbplyr::ident_q(schema_if(rep(schema, length(.x)), .x, con))
    )
  }

}

# Errors ------------------------------------------------------------------

abort_learn_keys <- function() {
  abort(error_txt_learn_keys(), .subclass = dm_error_full("learn_keys"))
}

error_txt_learn_keys <- function() {
  "Failed to learn keys from database. Use `learn_keys = FALSE` to work around."
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
