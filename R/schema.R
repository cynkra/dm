
# db_schema_list() -------------------------------------------------------

#' List schemas on a database
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `db_schema_list()` lists the available schemas on the database.
#'
#' @param con An object of class `"src"` or `"DBIConnection"`.
#' @param include_default Boolean, if `TRUE` (default), also the default schema
#' on the database is included in the result
#' @param ... Passed on to the individual methods.
#'
#' @details Methods are not available for all DBMS.
#'
#' Additional arguments are:
#'
#'   - `dbname`: supported for MSSQL. List schemas on a different database on the connected MSSQL-server;
#'   default: database addressed by `con`.
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
#' @name db_schema_list
db_schema_list <- function(con, include_default = TRUE, ...) {
  check_param_class(include_default, "logical")

  # If we check in the method, we need to specify the user_env argument
  if (inherits(con, "src_dbi")) {
    deprecate_soft("0.2.5", 'dm::db_schema_list(con = "must be a DBI connection, not a dbplyr source,")', )
  }

  UseMethod("db_schema_list")
}

#' @export
db_schema_list.src_dbi <- function(con, include_default = TRUE, ...) {
  db_schema_list(con$con, include_default = include_default, ...)
}

#' @export
`db_schema_list.Microsoft SQL Server` <- function(con, include_default = TRUE, dbname = NULL, ...) {
  dbname_sql <- if (is_null(dbname)) {
    ""
  } else {
    check_param_class(dbname, "character")
    check_param_length(dbname)
    paste0(DBI::dbQuoteIdentifier(con, dbname), ".")
  }
  default_if_true <- if_else(include_default, "", " AND NOT s.name = 'dbo'")
  # ignore built-in schemas for backward compatibility:
  # https://docs.microsoft.com/en-us/sql/relational-databases/security/authentication-access/ownership-and-user-schema-separation?view=sql-server-ver15
  DBI::dbGetQuery(con, glue::glue("SELECT s.name as schema_name
    FROM {dbname_sql}sys.schemas s
    WHERE s.name NOT IN ('sys', 'guest', 'INFORMATION_SCHEMA', 'db_accessadmin',
          'db_backupoperator', 'db_datareader', 'db_datawriter', 'db_ddladmin',
          'db_denydatareader', 'db_denydatawriter', 'db_owner',
          'db_securityadmin'){default_if_true}")) %>%
    as_tibble()
}

#' @export
db_schema_list.PqConnection <- function(con, include_default = TRUE, ...) {
  default_if_true <- if_else(include_default, "", ", 'public'")
  DBI::dbGetQuery(con, glue::glue("SELECT schema_name, schema_owner FROM information_schema.schemata WHERE
    schema_name NOT IN ('information_schema', 'pg_catalog'{default_if_true})
    AND schema_name NOT LIKE 'pg_toast%'
    AND schema_name NOT LIKE 'pg_temp_%'
    ORDER BY schema_name")) %>%
    as_tibble()
}

#' @export
db_schema_list.SQLiteConnection <- function(con, include_default = TRUE, ...) {
  abort_no_schemas_supported("SQLite")
}

#' @export
db_schema_list.Pool <- function(con, include_default = TRUE, ...) {
  pool_con <- pool::poolCheckout(con)
  on.exit(pool::poolReturn(pool_con))
  db_schema_list(pool_con, include_default, ...)
}


# db_schema_exists() -----------------------------------------------------

#' Check for existence of a schema on a database
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `db_schema_exists()` checks, if a schema exists on the database.
#'
#' @inheritParams db_schema_list
#' @param schema Class `character` or `SQL`, name of the schema
#'
#' @details Methods are not available for all DBMS.
#'
#' Additional arguments are:
#'
#'   - `dbname`: supported for MSSQL. Check if a schema exists on a different
#'   database on the connected MSSQL-server; default: database addressed by `con`.
#' @return A boolean: `TRUE` if schema exists, `FALSE` otherwise.
#'
#' @family schema handling functions
#' @export
db_schema_exists <- function(con, schema, ...) {
  check_param_class(schema, "character")
  check_param_length(schema)

  # If we check in the method, we need to specify the user_env argument
  if (inherits(con, "src_dbi")) {
    deprecate_soft("0.2.5", 'dm::db_schema_exists(con = "must be a DBI connection, not a dbplyr source,")', )
  }

  UseMethod("db_schema_exists")
}

#' @export
db_schema_exists.src_dbi <- function(con, schema, ...) {
  db_schema_exists(con$con, schema, ...)
}

#' @export
`db_schema_exists.Microsoft SQL Server` <- function(con, schema, dbname = NULL, ...) {
  sql_to_character(con, schema) %in% db_schema_list(con, dbname = dbname)$schema_name
}


#' @export
db_schema_exists.PqConnection <- function(con, schema, ...) {
  sql_to_character(con, schema) %in% db_schema_list(con)$schema_name
}

#' @export
db_schema_exists.SQLiteConnection <- function(con, schema, ...) {
  abort_no_schemas_supported("SQLite")
}


# db_schema_create() -----------------------------------------------------

#' Create a schema on a database
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `db_schema_create()` creates a schema on the database.
#'
#' @inheritParams db_schema_list
#' @param schema Class `character` or `SQL` (cf. Details), name of the schema
#'
#' @details Methods are not available for all DBMS.
#'
#' An error is thrown if a schema of that name already exists.
#'
#' The argument `schema` (and `dbname` for MSSQL) can be provided as `SQL` objects.
#' Keep in mind, that in this case it is assumed that they are already correctly quoted as identifiers
#' using [`DBI::dbQuoteIdentifier()`].
#'
#' Additional arguments are:
#'
#'   - `dbname`: supported for MSSQL. Create a schema in a different
#'   database on the connected MSSQL-server; default: database addressed by `con`.
#'
#' @return `NULL` invisibly.
#'
#' @family schema handling functions
#' @export
db_schema_create <- function(con, schema, ...) {
  check_param_class(schema, "character")
  check_param_length(schema)

  # If we check in the method, we need to specify the user_env argument
  if (inherits(con, "src_dbi")) {
    deprecate_soft("0.2.5", 'dm::db_schema_create(con = "must be a DBI connection, not a dbplyr source,")', )
  }

  UseMethod("db_schema_create")
}

#' @export
db_schema_create.src_dbi <- function(con, schema, ...) {
  db_schema_create(con$con, schema, ...)
}

#' @export
db_schema_create.PqConnection <- function(con, schema, ...) {
  DBI::dbExecute(con, SQL(glue::glue("CREATE SCHEMA {DBI::dbQuoteIdentifier(con, schema)}")))
  message(glue::glue("Schema {tick(sql_to_character(con, schema))} created."))
  invisible(NULL)
}

#' @export
`db_schema_create.Microsoft SQL Server` <- function(con, schema, dbname = NULL, ...) {
  if (!is_null(dbname)) {
    original_dbname <- attributes(con)$info$dbname
    DBI::dbExecute(con, glue::glue("USE {DBI::dbQuoteIdentifier(con, dbname)}"))
    withr::defer(DBI::dbExecute(con, glue::glue("USE {DBI::dbQuoteIdentifier(con, original_dbname)}")))
  }
  msg_suffix <- fix_msg(sql_to_character(con, dbname))
  DBI::dbExecute(con, SQL(glue::glue("CREATE SCHEMA {DBI::dbQuoteIdentifier(con, schema)}")))
  message(glue::glue("Schema {tick(sql_to_character(con, schema))} created{msg_suffix}."))
  invisible(NULL)
}

#' @export
db_schema_create.SQLiteConnection <- function(con, schema, ...) {
  abort_no_schemas_supported("SQLite")
}

# sql_schema_table_list() -------------------------------------------------

# List the tables in a schema on a database
#
# @description `sql_schema_table_list()` list the tables in a schema on the database.
#
# @inheritParams db_schema_exists
#
# @details Methods are not available for all DBMS.
#
# An error is thrown if no schema of that name exists.
#
# Additional arguments are:
#
#   - `dbname`: supported for MSSQL. Look for tables on a different
#   database on the connected MSSQL-server; default: database addressed by `con`.
#
# @return A tibble with the following columns:
#   \describe{
#     \item{`table_name`}{name of the table,}
#     \item{`remote_name`}{identifier of the table on the DBMS.
#     Can be used to access the listed tables with the syntax
#     `tbl(con, remote_name).`}
#   }
#
# @family schema handling functions
# @export
# sql_schema_table_list <- function(con, schema = NULL, ...) {
#   if (!is_null(schema)) {
#     check_param_class(schema, "character")
#     check_param_length(schema)
#   }
#   if (!is_null(schema) && !db_schema_exists(con, schema, ...)) {
#     abort_no_schema_exists(sql_to_character(con_from_src_or_con(con), schema), ...)
#   }
#   UseMethod("sql_schema_table_list")
# }

# FIXME: this should be done using a dplyr function
sql_schema_table_list_mssql <- function(con, schema = NULL, dbname = NULL) {
  src <- src_from_src_or_con(con)
  if (!is_null(schema)) {
    check_param_class(schema, "character")
    check_param_length(schema)
  }
  if (!is_null(dbname)) {
    check_param_class(dbname, "character")
    check_param_length(dbname)
  }
  enframe(
    get_src_tbl_names(src, schema = sql_to_character(src$con, schema), dbname = dbname),
    name = "table_name",
    value = "remote_name"
  ) %>%
    # FIXME: maybe better a DBI identifier?
    mutate(remote_name = dbplyr::ident_q(remote_name))
}

# FIXME: this should be done using a dplyr function
sql_schema_table_list_postgres <- function(con, schema = NULL) {
  src <- src_from_src_or_con(con)
  if (!is_null(schema)) {
    check_param_class(schema, "character")
    check_param_length(schema)
  }
  enframe(
    get_src_tbl_names(src, schema = sql_to_character(src$con, schema)),
    name = "table_name",
    value = "remote_name"
  ) %>%
    # FIXME: maybe better a DBI identifier?
    mutate(remote_name = dbplyr::ident_q(remote_name))
}

# db_schema_drop() -------------------------------------------------------

#' Remove a schema from a database
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `db_schema_drop()` deletes a schema from the database.
#' For certain DBMS it is possible to force the removal of a non-empty schema, see below.
#'
#' @inheritParams db_schema_create
#' @param force Boolean, default `FALSE`. Set to `TRUE` to drop a schema and
#' all objects it contains at once. Currently only supported for Postgres.
#'
#' @details Methods are not available for all DBMS.
#'
#' An error is thrown if no schema of that name exists.
#'
#' The argument `schema` (and `dbname` for MSSQL) can be provided as `SQL` objects.
#' Keep in mind, that in this case it is assumed that they are already correctly quoted as identifiers.
#'
#' Additional arguments are:
#'
#'   - `dbname`: supported for MSSQL. Remove a schema from a different
#'   database on the connected MSSQL-server; default: database addressed by `con`.
#'
#' @return `NULL` invisibly.
#'
#' @family schema handling functions
#' @export
db_schema_drop <- function(con, schema, force = FALSE, ...) {
  check_param_class(schema, "character")
  check_param_length(schema)
  check_param_class(force, "logical")
  check_param_length(force)

  # If we check in the method, we need to specify the user_env argument
  if (inherits(con, "src_dbi")) {
    deprecate_soft("0.2.5", 'dm::db_schema_drop(con = "must be a DBI connection, not a dbplyr source,")', )
  }

  UseMethod("db_schema_drop")
}

#' @export
db_schema_drop.src_dbi <- function(con, schema, force = FALSE, ...) {
  db_schema_drop(con$con, schema, force, ...)
}

#' @export
db_schema_drop.PqConnection <- function(con, schema, force = FALSE, ...) {
  if (force) {
    force_infix <- " and all objects it contained"
    force_suffix <- " CASCADE"
  } else {
    force_infix <- ""
    force_suffix <- ""
  }
  DBI::dbExecute(con, SQL(glue::glue("DROP SCHEMA {DBI::dbQuoteIdentifier(con, schema)}{force_suffix}")))
  message(glue::glue("Dropped schema {tick(sql_to_character(con, schema))}{force_infix}."))
  invisible(NULL)
}

#' @export
`db_schema_drop.Microsoft SQL Server` <- function(con, schema, force = FALSE, dbname = NULL, ...) {
  warn_if_arg_not(
    force,
    only_on = "Postgres",
    correct = FALSE,
    additional_msg = "Please remove potential objects from the schema manually."
  )
  if (!is_null(dbname)) {
    check_param_class(dbname, "character")
    check_param_length(dbname)
    original_dbname <- attributes(con)$info$dbname
    DBI::dbExecute(con, glue::glue("USE {dbname}"))
    withr::defer(DBI::dbExecute(con, glue::glue("USE {original_dbname}")))
  }
  msg_infix <- fix_msg(sql_to_character(con, dbname))
  DBI::dbExecute(con, SQL(glue::glue("DROP SCHEMA {DBI::dbQuoteIdentifier(con, schema)}")))
  message(glue::glue("Dropped schema {tick(sql_to_character(con, schema))}{msg_infix}."))
  invisible(NULL)
}

#' @export
db_schema_drop.SQLiteConnection <- function(con, schema, force = FALSE, ...) {
  abort_no_schemas_supported("SQLite")
}

fix_msg <- function(dbname) {
  if (!is_null(dbname)) {
    msg_suffix <- paste0(" on database ", tick(dbname))
  } else {
    msg_suffix <- ""
  }
}

sql_to_character <- function(con, sql_or_char) {
  if (inherits(sql_or_char, "SQL")) {
    sql_or_char <- map_chr(
      sql_or_char,
      ~ DBI::dbUnquoteIdentifier(con, .x)[[1]] %>% pluck("name")
    )
  }
  sql_or_char
}
