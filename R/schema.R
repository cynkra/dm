
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
sql_schema_list.src_dbi <- function(dest, include_default = TRUE, ...) {
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
    as_tibble()
}

#' @export
sql_schema_list.PqConnection <- function(dest, include_default = TRUE, ...) {
  default_if_true <- if_else(include_default, "", ", 'public'")
  DBI::dbGetQuery(dest, glue::glue("SELECT schema_name, schema_owner FROM information_schema.schemata WHERE
    schema_name NOT IN ('information_schema', 'pg_catalog'{default_if_true})
    AND schema_name NOT LIKE 'pg_toast%'
    AND schema_name NOT LIKE 'pg_temp_%'
    ORDER BY schema_name")) %>%
    as_tibble()
}

# sql_schema_exists() -----------------------------------------------------

#' Check for existence of a schema on a database
#'
#' @description `sql_schema_exists()` checks, if a schema exists on the database.
#'
#' @inheritParams sql_schema_list
#' @param schema Class `character` or `SQL`, name of the schema
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
  sql_to_character(dest, schema) %in% sql_schema_list(dest, dbname = dbname)$schema_name
}


#' @export
sql_schema_exists.PqConnection <- function(dest, schema, ...) {
  sql_to_character(dest, schema) %in% sql_schema_list(dest)$schema_name
}

# sql_schema_create() -----------------------------------------------------

#' Create a schema on a database
#'
#' @description `sql_schema_create()` creates a schema on the database.
#'
#' @inheritParams sql_schema_list
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
#'   database on the connected MSSQL-server; default: database addressed by `dest`.
#'
#' @return `NULL` invisibly.
#'
#' @family schema handling functions
#' @export
sql_schema_create <- function(dest, schema, ...) {
  check_param_class(schema, "character")
  check_param_length(schema)
  if (sql_schema_exists(dest, schema, ...)) {abort_schema_exists(sql_to_character(dest, schema), ...)}
  UseMethod("sql_schema_create")
}

#' @export
sql_schema_create.src_dbi <- function(dest, schema, ...) {
  sql_schema_create(dest$con, schema, ...)
}

#' @export
sql_schema_create.PqConnection <- function(dest, schema, ...) {
  DBI::dbExecute(dest, SQL(glue::glue("CREATE SCHEMA {DBI::dbQuoteIdentifier(dest, schema)}")))
  message(glue::glue("Schema {tick(sql_to_character(dest, schema))} created."))
  invisible(NULL)
}

#' @export
`sql_schema_create.Microsoft SQL Server` <- function(dest, schema, dbname = NULL, ...) {
  if (!is_null(dbname)) {
    original_dbname <- attributes(dest)$info$dbname
    DBI::dbExecute(dest, glue::glue("USE {DBI::dbQuoteIdentifier(dest, dbname)}"))
    withr::defer(DBI::dbExecute(dest, glue::glue("USE {DBI::dbQuoteIdentifier(dest, original_dbname)}")))
  }
  msg_suffix <- fix_msg(sql_to_character(dest, dbname))
  DBI::dbExecute(dest, SQL(glue::glue("CREATE SCHEMA {DBI::dbQuoteIdentifier(dest, schema)}")))
  message(glue::glue("Schema {tick(sql_to_character(dest, schema))} created{msg_suffix}."))
  invisible(NULL)
}

# sql_schema_table_list() -------------------------------------------------

#' List the tables in a schema on a database
#'
#' @description `sql_schema_table_list()` list the tables in a schema on the database.
#'
#' @inheritParams sql_schema_exists
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
#'     \item{`remote_name`}{identifier of the table on the DBMS.
#'     Can be used to access the listed tables with the syntax
#'     `tbl(dest, remote_name).`}
#'   }
#'
#' @family schema handling functions
#' @export
sql_schema_table_list <- function(dest, schema = NULL, ...) {
  if (!is_null(schema)) {
    check_param_class(schema, "character")
    check_param_length(schema)
  }
  if (!is_null(schema) && !sql_schema_exists(dest, schema, ...)) {
    abort_no_schema_exists(sql_to_character(con_from_src_or_con(dest), schema), ...)
  }
  UseMethod("sql_schema_table_list")
}

#' @export
`sql_schema_table_list.src_Microsoft SQL Server` <- function(dest, schema = NULL, dbname = NULL, ...) {
  if (!is_null(dbname)) {
    check_param_class(dbname, "character")
    check_param_length(dbname)
  }
  enframe(
    get_src_tbl_names(dest, schema = sql_to_character(dest$con, schema), dbname = dbname),
    name = "table_name",
    value = "remote_name") %>%
    mutate(remote_name = dbplyr::ident_q(remote_name))
}

#' @export
sql_schema_table_list.src_PqConnection <- function(dest, schema = NULL, ...) {
  enframe(
    get_src_tbl_names(dest, schema = sql_to_character(dest$con, schema)),
    name = "table_name",
    value = "remote_name") %>%
    mutate(remote_name = dbplyr::ident_q(remote_name))
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
#' @description `sql_schema_drop()` deletes a schema from the database.
#' For certain DBMS it is possible to force the removal of a non-empty schema, see below.
#'
#' @inheritParams sql_schema_create
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
#'   database on the connected MSSQL-server; default: database addressed by `dest`.
#'
#' @return `NULL` invisibly.
#'
#' @family schema handling functions
#' @export
sql_schema_drop <- function(dest, schema, force = FALSE, ...) {
  check_param_class(schema, "character")
  check_param_length(schema)
  check_param_class(force, "logical")
  check_param_length(force)
  if (!sql_schema_exists(dest, schema, ...)) {
    abort_no_schema_exists(sql_to_character(con_from_src_or_con(dest), schema), ...)
  }
  UseMethod("sql_schema_drop")
}

#' @export
sql_schema_drop.src_dbi <- function(dest, schema, force = FALSE, ...) {
  sql_schema_drop(dest$con, schema, ...)
}

#' @export
sql_schema_drop.PqConnection <- function(dest, schema, force = FALSE, ...) {
  if (force) {
    force_infix <- " and all objects it contained"
    force_suffix <- " CASCADE"
  } else {
    force_infix <- ""
    force_suffix <- ""
  }
  DBI::dbExecute(dest, SQL(glue::glue("DROP SCHEMA {DBI::dbQuoteIdentifier(dest, schema)}{force_suffix}")))
  message(glue::glue("Dropped schema {tick(sql_to_character(dest, schema))}{force_infix}."))
  invisible(NULL)
}

#' @export
`sql_schema_drop.Microsoft SQL Server` <- function(dest, schema, force = FALSE, dbname = NULL, ...) {
  warn_if_arg_not(
    force,
    only_on = "Postgres",
    correct = FALSE,
    additional_msg = "Please remove potential objects from the schema manually."
  )
  if (!is_null(dbname)) {
    check_param_class(dbname, "character")
    check_param_length(dbname)
    original_dbname <- attributes(dest)$info$dbname
    DBI::dbExecute(dest, glue::glue("USE {dbname}"))
    withr::defer(DBI::dbExecute(dest, glue::glue("USE {original_dbname}")))
  }
  msg_infix <- fix_msg(sql_to_character(dest, dbname))
  DBI::dbExecute(dest, SQL(glue::glue("DROP SCHEMA {DBI::dbQuoteIdentifier(dest, schema)}")))
  message(glue::glue("Dropped schema {tick(sql_to_character(dest, schema))}{msg_infix}."))
  invisible(NULL)
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
