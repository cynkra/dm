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
#' @param set_key_constraints If `TRUE` (default) will mirror `dm` primary and foreign key constraints on a database
#'   and create unique indexes.
#' @param table_names See argument description in \link{copy_dm_to}. Default to names of `dm`.
#' @param temporary Should the tables be marked as \emph{temporary}? Defaults to `TRUE`.
#' @param schema Name of schema to copy the `dm` to.
#'
#' @details
#' \itemize{
#'   \item{ `dm_ddl_pre` generates `CREATE TABLE` statements (including `PRIMARY KEY` definition). }
#'   \item{ `dm_dml_load` generates `INSERT INTO` statements. }
#'   \item{ `dm_ddl_post` generates scripts for `FOREIGN KEYS`, `UNIQUE KEYS` and `INDEXES`. }
#'   \item{ `dm_sql` calls all three above and returns complete set of scripts. }
#' }
#'
#' @return character vector of SQL statements.
#'
#' @export
#' @examplesIf rlang::is_installed("RSQLite") && rlang::is_installed("dbplyr")
#' con <- DBI::dbConnect(RSQLite::SQLite())
#' dm <- dm_nycflights13()
#' s <- dm_sql(dm, con)
#' s
#' DBI::dbDisconnect(con)
dm_sql <- function(dm,
                   dest,
                   temporary = TRUE,
                   schema = NULL) {
  c(
    ## CREATE TABLE and PRIMARY KEY (unless !set_key_constraints)
    ## TODO: set_key_constraints not needed because user can rm PK from dm before calling dm_sql, same with renaming tables in table_names
    dm_ddl_pre(dm, dest, table_names = set_names(names(dm)), set_key_constraints = TRUE, schema = schema),
    ## INSERT INTO, handle autoincrement, TODO handle+test ai together with !set_key_constraints
    dm_dml_load(dm, dest, table_names = set_names(names(dm))),
    ## FOREIGN KEYS, UNIQUE KEYS, INDEXES
    dm_ddl_post(dm, dest, table_names = set_names(names(dm)), schema = schema)
  )
}

## database-specific type conversions
## could that go into DBI package as improvement to dbDataType?
db_types_mapping <- function(types, autoincrement = character(), dest) {
  ## data type mapping
  if (is_mariadb(dest)) {
    types[types == "TEXT"] <- "VARCHAR(255)"
  }
  if (is_sqlite(dest)) {
    types[types == "INT"] <- "INTEGER"
  }
  ## autoincrement types mapping
  if (length(autoincrement)) {
    if (is_postgres(dest)) {
      types[names(types) == autoincrement] <- "SERIAL"
    }
    if (is_mssql(dest)) {
      types[names(types) == autoincrement] <- "INT IDENTITY"
    }
    if (is_mariadb(dest)) {
      # Doesn't have a special data type. Uses `AUTO_INCREMENT` attribute instead.
      # Ref: https://mariadb.com/kb/en/auto_increment/
      types[names(types) == autoincrement] = paste(types[names(types) == autoincrement], "AUTO_INCREMENT")
    }
    # DuckDB:
    # Doesn't have a special data type. Uses `CREATE SEQUENCE` instead.
    # Ref: https://duckdb.org/docs/sql/statements/create_sequence
    # SQLite:
    # For a primary key, autoincrementing works by default, and it is almost never
    # necessary to use the `AUTOINCREMENT` keyword. So nothing we need to do here.
    # Ref: https://www.sqlite.org/autoinc.html
  }
  types
}

ddl_cols <- function(x, dest, autoincrement) {
  qcols <- DBI::dbQuoteIdentifier(dest, names(x))
  types <- DBI::dbDataType(dest, x)
  types <- db_types_mapping(types, autoincrement, dest)
  paste(qcols, types)
}
ddl_pk <- function(x, dest) {
  if (length(x)) {
    paste0("  PRIMARY KEY (", paste(DBI::dbQuoteIdentifier(dest, x), collapse = ", "), ")")
  } else {
    character()
  }
}
ddl_tbl <- function(x, name, dest, pk, autoincrement, temporary, set_key_constraints) {
  stopifnot(is.character(pk), is.logical(autoincrement), is.logical(temporary))
  istmp <- if (temporary) "TEMPORARY " else ""
  cols_def <- paste(ddl_cols(x, dest, pk[autoincrement]), collapse = ",\n  ")
  qname <- DBI::dbQuoteIdentifier(dest, name)
  pk_def <- if (set_key_constraints) ddl_pk(pk, dest)
  sprintf(
    "CREATE %sTABLE %s (\n  %s\n)",
    istmp, qname, paste(c(cols_def, pk_def), collapse = ",\n")
  )
}

#' @rdname dm_sql
#' @export
dm_ddl_pre <- function(dm, dest, temporary = TRUE, table_names = set_names(names(dm)), set_key_constraints = TRUE, schema = NULL) {
  pksdf <- lapply(names(dm), dm_get_all_pks_impl, dm = dm) ## lapply so we have entries for tables that does not have PK
  pks <- lapply(pksdf, function(x) if (nrow(x)) x[["pk_col"]][[1L]] else character())
  ais <- vapply(pksdf, function(x) if (nrow(x)) x[["autoincrement"]] else FALSE, NA)
  ## CREATE TABLE, including PK
  stopifnot(
    length(dm) == length(names(dm)), length(dm) == length(pks), length(dm) == length(ais),
    length(table_names) == length(dm), !is.null(names(table_names))
  )
  tbl_def <- mapply(
    ddl_tbl,
    x = dm, ## dm
    name = table_names[names(dm)],
    pk = pks, ## list of character vectors
    autoincrement = ais, ## logical vector
    MoreArgs = list(dest = dest, temporary = temporary, set_key_constraints = set_key_constraints),
    SIMPLIFY = FALSE
  )
  tbl_def
}

#' @rdname dm_sql
#' @export
dm_dml_load <- function(dm, dest, table_names = set_names(names(dm))) {
  tbl_dml_load <- function(tbl_name, dm, remote_name, con) {
    pkdf = dm_get_all_pks_impl(dm, tbl_name)
    x <- collect(dm[[tbl_name]])
    remote_tbl_id <- remote_name[[tbl_name]]
    if (isTRUE(pkdf[["autoincrement"]])) {
      x <- x[!names(x) %in% pkdf[["pk_col"]][[1L]]]
    }
    selectvals <- dbplyr::sql_render(dbplyr::copy_inline(con, x))
    ## for some DBes we could skip columns specification, but only when no autoincrement, easier to just specify that always
    ## duckdb autoincrement tests are skipped, could be added by inserting from sequence
    ins <- paste0("INSERT INTO ", DBI::dbQuoteIdentifier(con, remote_tbl_id), " (", paste(DBI::dbQuoteIdentifier(con, names(x)), collapse = ", "), ")\n")
    paste0(ins, selectvals)
  }
  DBI::SQL(unlist(
    lapply(set_names(names(table_names)), tbl_dml_load, dm = dm, remote_name = table_names, con = dest),
    recursive = FALSE
  ))
}

ddl_fk <- function(dm, dest, table_names, schema) {
  character()
}
ddl_unq <- function(dm, dest, table_names, schema) {
  character()
}
ddl_idx <- function(dm, dest, table_names, schema) {
  character()
}

#' @rdname dm_sql
#' @export
dm_ddl_post <- function(dm, dest, table_names = set_names(names(dm)), schema = NULL) {
  c(
    ddl_fk(dm, dest, table_names = table_names, schema = schema),
    ddl_unq(dm, dest, table_names = table_names, schema = schema),
    ddl_idx(dm, dest, table_names = table_names, schema = schema)
  )
}
