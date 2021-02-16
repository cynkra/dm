
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

# sql_schema_exists() -----------------------------------------------------

#' Check for existence of a schema on a database
#'
#' @description `sql_schema_exists()` checks, if a schema exists on the database.
#'
#' @inheritParams sql_schema_list
#'
#' @details Methods are not available for all DBMS.
#'
#' Additional arguments are:
#'
#'   - `dbname`: supported for MSSQL. Check if a schema exists on a different
#'   database on the connected MSSQL-server; default: database addressed by `dest`.
#' @return A boolean: `TRUE` if schema exists, `FALSE` otherwise.
#'
#' @family schema handling functions
#' @export
sql_schema_exists <- function(dest, schema, ...) {
  check_param_class(schema, "character")
  check_param_length(schema)
  UseMethod("sql_schema_exists")
}

#' @export
sql_schema_exists.src_dbi <- function(dest, schema, ...) {
  sql_schema_exists(dest$con, schema, ...)
}

#' @export
`sql_schema_exists.Microsoft SQL Server` <- function(dest, schema, dbname = NULL, ...) {
  schema %in% sql_schema_list(dest, dbname = dbname)$schema_name
}


#' @export
sql_schema_exists.PqConnection <- function(dest, schema, ...) {
  schema %in% sql_schema_list(dest)$schema_name
}

# sql_schema_create() -----------------------------------------------------

#' Create a schema on a database
#'
#' @description `sql_schema_create()` creates a schema on the database.
#'
#' @inheritParams sql_schema_list
#'
#' @details Methods are not available for all DBMS.
#'
#' An error is thrown if a schema of that name already exists.
#'
#' Additional arguments are:
#'
#'   - `dbname`: supported for MSSQL. Create a schema in a different
#'   database on the connected MSSQL-server; default: database addressed by `dest`.
#'
#' @return `NULL` invisibly.
#'
#' @family schema handling functions
#' @export
sql_schema_create <- function(dest, schema, ...) {
  check_param_class(schema, "character")
  check_param_length(schema)
  if (sql_schema_exists(dest, schema, ...)) {abort_schema_exists(schema, ...)}
  UseMethod("sql_schema_create")
}

#' @export
sql_schema_create.src_dbi <- function(dest, schema, ...) {
  sql_schema_create(dest$con, schema, ...)
}

#' @export
sql_schema_create.PqConnection <- function(dest, schema, ...) {
  DBI::dbExecute(dest, glue::glue("CREATE SCHEMA {schema}"))
  message(glue::glue("Schema {tick(schema)} created."))
  invisible(NULL)
}

#' @export
`sql_schema_create.Microsoft SQL Server` <- function(dest, schema, dbname = NULL, ...) {
  if (!is_null(dbname)) {
    original_dbname <- attributes(dest)$info$dbname
    DBI::dbExecute(dest, glue::glue("USE {dbname}"))
    withr::defer(DBI::dbExecute(dest, glue::glue("USE {original_dbname}")))
    msg_suffix <- paste0(" on database ", tick(dbname))
  } else {
    msg_suffix <- ""
  }
  DBI::dbExecute(dest, glue::glue("CREATE SCHEMA {schema}"))
  message(glue::glue("Schema {tick(schema)} created{msg_suffix}."))
  invisible(NULL)
}

# sql_schema_table_list() -------------------------------------------------

#' List the tables in a schema on a database
#'
#' @description `sql_schema_table_list()` list the tables in a schema on the database.
#'
#' @inheritParams sql_schema_list
#'
#' @details Methods are not available for all DBMS.
#'
#' An error is thrown if no schema of that name exists.
#'
#' Additional arguments are:
#'
#'   - `dbname`: supported for MSSQL. Look for tables on a different
#'   database on the connected MSSQL-server; default: database addressed by `dest`.
#'
#' @return A tibble with the following columns:
#'   \describe{
#'     \item{`table_name`}{name of the table,}
#'     \item{`remote_table_name`}{identifier of the table on the DBMS.
#'     Can be used to access the listed tables with the syntax
#'     `tbl(dest, remote_table_name).`}
#'   }
#'
#' @family schema handling functions
#' @export
sql_schema_table_list <- function(dest, schema = NULL, ...) {
  if (!is_null(schema)) {
    check_param_class(schema, "character")
    check_param_length(schema)
  }
  if (!is_null(schema) && !sql_schema_exists(dest, schema, ...)) {abort_no_schema_exists(schema, ...)}
  UseMethod("sql_schema_table_list")
}

#' @export
`sql_schema_table_list.src_Microsoft SQL Server` <- function(dest, schema = NULL, dbname = NULL, ...) {
  if (!is_null(dbname)) {
    check_param_class(dbname, "character")
    check_param_length(dbname)
  }
  enframe(
    get_src_tbl_names(dest, schema = schema, dbname = dbname),
    name = "table_name",
    value = "remote_table_name") %>%
    mutate(remote_table_name = dbplyr::ident_q(remote_table_name))
}

#' @export
sql_schema_table_list.src_PqConnection <- function(dest, schema = NULL, ...) {
  enframe(
    get_src_tbl_names(dest, schema = schema),
    name = "table_name",
    value = "remote_table_name") %>%
    mutate(remote_table_name = dbplyr::ident_q(remote_table_name))
}

#' @export
`sql_schema_table_list.Microsoft SQL Server` <- function(dest, schema = NULL, dbname = NULL, ...) {
  `sql_schema_table_list.src_Microsoft SQL Server`(
    dest = dbplyr::src_dbi(dest),
    schema = schema,
    dbname = dbname,
    ...)
}

#' @export
sql_schema_table_list.PqConnection <- function(dest, schema = NULL, ...) {
  sql_schema_table_list.src_PqConnection(
    dest = dbplyr::src_dbi(dest),
    schema = schema,
    ...)
}

# sql_schema_drop() -------------------------------------------------------

#' Remove a schema from a database
#'
#' @description `sql_schema_drop()` deletes an empty schema from the database.
#'
#' @inheritParams sql_schema_list
#'
#' @details Methods are not available for all DBMS.
#'
#' An error is thrown if no schema of that name exists.
#'
#' Additional arguments are:
#'
#'   - `dbname`: supported for MSSQL. Remove a schema from a different
#'   database on the connected MSSQL-server; default: database addressed by `dest`.
#'
#' @return `NULL` invisibly.
#'
#' @family schema handling functions
#' @export
sql_schema_drop <- function(dest, schema, ...) {
  check_param_class(schema, "character")
  check_param_length(schema)
  if (nrow(sql_schema_table_list(dest, schema, ...)) > 0) {
    abort_schema_not_empty(schema, ...)
  }
  UseMethod("sql_schema_drop")
}

#' @export
sql_schema_drop.src_dbi <- function(dest, schema, ...) {
  sql_schema_drop(dest$con, schema, ...)
}

#' @export
sql_schema_drop.PqConnection <- function(dest, schema, ...) {
  DBI::dbExecute(dest, glue::glue("DROP SCHEMA {schema}"))
  message(glue::glue("Schema {tick(schema)} dropped."))
  invisible(NULL)
}

#' @export
`sql_schema_drop.Microsoft SQL Server` <- function(dest, schema, dbname = NULL, ...) {
  if (!is_null(dbname)) {
    check_param_class(dbname, "character")
    check_param_length(dbname)
    original_dbname <- attributes(dest)$info$dbname
    DBI::dbExecute(dest, glue::glue("USE {dbname}"))
    withr::defer(DBI::dbExecute(dest, glue::glue("USE {original_dbname}")))
    msg_infix <- paste0(" on database ", tick(dbname))
  } else {
    msg_infix <- ""
  }
  DBI::dbExecute(dest, glue::glue("DROP SCHEMA {schema}"))
  message(glue::glue("Schema {tick(schema)}{msg_infix} dropped."))
  invisible(NULL)
}
