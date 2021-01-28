
# sql_schema_list() -------------------------------------------------------

#' List schemas on a database
#'
#' @description `sql_schema_list()` lists the available schemas on the database.
#'
#' @inheritParams copy_dm_to
#' @param include_default Boolean, if `TRUE` (default), also the default schema
#' on the database is included in the result
#' @param ... Passed on to the individual methods.
#'
#' @details Methods are not available for all DBMS.
#'
#' Additional arguments are:
#'
#'   - `dbname`: supported for MSSQL. List schemas on a different database on the connected MSSQL-server;
#'   default: database addressed by `dest`.
#'
#' @return A tibble with the following columns:
#'   \describe{
#'     \item{`schema_name`}{the names of the schemas,}
#'     \item{`schema_owner`}{the schema owner names.}
#'   }
#'
#' @export
#' @family schema handling functions
#'
#' @name sql_schema_list
sql_schema_list <- function(dest, include_default = TRUE, ...) {
  check_param_class(include_default, "logical")
  UseMethod("sql_schema_list")
}

#' @export
`sql_schema_list.src_dbi` <- function(dest, include_default = TRUE, ...) {
  sql_schema_list(dest$con, include_default = include_default, ...)
}

#' @export
`sql_schema_list.Microsoft SQL Server` <- function(dest, include_default = TRUE, dbname = NULL, ...) {
  dbname_sql <- if (is_null(dbname)) {
    ""
  } else {
    check_param_class(dbname, "character")
    check_param_length(dbname)
    paste0(DBI::dbQuoteIdentifier(dest, dbname), ".")
  }
  default_if_true <- if_else(include_default, "", " AND NOT s.name = 'dbo'")
  DBI::dbGetQuery(dest, glue::glue("SELECT s.name as schema_name,
    u.name AS schema_owner
    FROM {dbname_sql}sys.schemas s
    INNER JOIN {dbname_sql}sys.sysusers u
    ON u.uid = s.principal_id
    WHERE u.issqluser = 1
    AND u.name NOT IN ('sys', 'guest', 'INFORMATION_SCHEMA'){default_if_true}")) %>%
    as_tibble() %>%
    mutate(schema_name = SQL(schema_name))
}

#' @export
sql_schema_list.PqConnection <- function(dest, include_default = TRUE, ...) {
  default_if_true <- if_else(include_default, "", ", 'public'")
  DBI::dbGetQuery(dest, glue::glue("SELECT schema_name, schema_owner FROM information_schema.schemata WHERE
    schema_name NOT IN ('information_schema', 'pg_catalog'{default_if_true})
    AND schema_name NOT LIKE 'pg_toast%'
    AND schema_name NOT LIKE 'pg_temp_%'
    ORDER BY schema_name")) %>%
    as_tibble() %>%
    mutate(schema_name = SQL(schema_name))
}
