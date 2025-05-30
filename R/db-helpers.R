unique_db_table_name <- local({
  i <- 0

  function(table_name) {
    i <<- i + 1
    glue("{table_name}_", as.character(i), "_", systime_convenient(), "_", get_pid())
  }
})

systime_convenient <- function() {
  # FIXME: Race condition here, but fast enough
  local_options(digits.secs = 6)

  if (Sys.getenv("IN_PKGDOWN") != "") {
    "20200828_071303"
  } else {
    time <- as.character(Sys.time())
    gsub("[-:.]", "", gsub(" ", "_", time))
  }
}

get_pid <- function() {
  if (Sys.getenv("IN_PKGDOWN") != "") {
    "12345"
  } else {
    as.character(Sys.getpid())
  }
}

is_db <- function(x) {
  inherits(x, "src_sql")
}

is_src_db <- function(dm) {
  is_db(dm_get_src_impl(dm))
}

is_duckdb <- function(dest) {
  inherits(dest, c("duckdb_connection", "src_duckdb_connection"))
}

is_sqlite <- function(dest) {
  inherits(dest, "SQLiteConnection")
}

is_mssql <- function(dest) {
  inherits(dest, c(
    "Microsoft SQL Server", "src_Microsoft SQL Server", "dblogConnection-Microsoft SQL Server", "src_dblogConnection-Microsoft SQL Server"
  ))
}

is_postgres <- function(dest) {
  inherits_any(dest, c(
    "src_PostgreSQLConnection", "src_PqConnection", "PostgreSQLConnection", "PqConnection", "src_PostgreSQL"
  ))
}

is_redshift <- function(dest) {
  inherits_any(dest, c(
    "src_RedshiftConnection", "RedshiftConnection"
  ))
}

is_mariadb <- function(dest) {
  inherits_any(
    dest,
    c(
      "MariaDBConnection",
      "src_MariaDBConnection",
      "MySQLConnection",
      "src_MySQLConnection",
      "src_DoltConnection",
      "src_DoltLocalConnection"
    )
  )
}

schema_supported_dbs <- function() {
  tibble::tribble(
    ~db_name, ~id_function, ~test_shortcut,
    "SQL Server", "is_mssql", "mssql",
    "Postgres", "is_postgres", "postgres",
    "MariaDB", "is_mariadb", "maria",
  )
}

is_schema_supported <- function(con) {
  funs <- schema_supported_dbs()[["id_function"]]

  any(purrr::map_lgl(funs, ~ do.call(., args = list(dest = con))))
}

src_from_src_or_con <- function(dest) {
  if (is.src(dest)) dest else dbplyr::src_dbi(dest)
}

con_from_src_or_con <- function(dest) {
  if (is.src(dest)) dest$con else dest
}

repair_table_names_for_db <- function(table_names, temporary, con, schema = NULL) {
  if (temporary) {
    if (!is.null(schema)) {
      abort_temporary_not_in_schema()
    }
    # FIXME: Better logic for temporary table names
    if (is_mssql(con)) {
      names <- paste0("#", table_names)
    } else {
      names <- table_names
    }
    names <- unique_db_table_name(names)
  } else {
    # permanent tables
    if (!is.null(schema) && !is_schema_supported(con)) {
      abort_no_schemas_supported(con = con)
    }
    names <- table_names
  }
  names <- set_names(names, table_names)
  quote_ids(names, con_from_src_or_con(con), schema)
}

find_name_clashes <- function(old, new) {
  # Any entries in `new` with more than one corresponding entry in `old`
  purrr::keep(split(old, new), ~ length(unique(.x)) > 1)
}

#' @autoglobal
get_src_tbl_names <- function(src, schema = NULL, dbname = NULL, names = NULL) {
  if (!is_mssql(src) && !is_postgres(src) && !is_redshift(src) && !is_mariadb(src)) {
    warn_if_arg_not(schema, only_on = c("MSSQL", "Postgres", "Redshift", "MariaDB"))
    warn_if_arg_not(dbname, only_on = "MSSQL")
    tables <- src_tbls(src)
    out <- purrr::map(tables, ~ DBI::Id(table = .x))

    return(set_names(out, tables))
  }

  con <- con_from_src_or_con(src)

  if (!is.null(schema)) {
    check_param_class(schema, "character")
  }

  if (is_mssql(src)) {
    # MSSQL
    schema <- schema_mssql(con, schema)
    dbname_sql <- dbname_mssql(con, dbname)
    names_table <- get_names_table_mssql(con, dbname_sql)
    dbname <- names(dbname_sql)
  } else if (is_postgres(src)) {
    # Postgres
    schema <- schema_postgres(con, schema)
    dbname <- warn_if_arg_not(dbname, only_on = "MSSQL")
    names_table <- get_names_table_postgres(con)
  } else if (is_redshift(src)) {
    # Redshift
    schema <- schema_redshift(con, schema)
    dbname <- warn_if_arg_not(dbname, only_on = "MSSQL")
    names_table <- get_names_table_redshift(con)
  } else if (is_mariadb(src)) {
    # MariaDB
    schema <- schema_mariadb(con, schema)
    dbname <- warn_if_arg_not(dbname, only_on = "MSSQL")
    names_table <- get_names_table_mariadb(con)
  }

  # Use smart default for `.names`, if it wasn't provided
  if (!is.null(names)) {
    names_pattern <- names
  } else if (length(schema) == 1) {
    names_pattern <- "{.table}"
  } else {
    names_pattern <- "{.schema}.{.table}"
    cli::cli_inform('Using {.code .names = "{names_pattern}"}')
  }

  names_table <- names_table %>%
    filter(schema_name %in% !!(if (inherits(schema, "sql")) glue_sql_collapse(schema) else schema)) %>%
    collect() %>%
    # create remote names for the tables in the given schema (name is table_name; cannot be duplicated within a single schema)
    mutate(
      local_name = glue(names_pattern, .table = table_name, .schema = schema_name),
      remote_name = schema_if(schema_name, table_name, con, dbname)
    )

  # SQL table names are only guaranteed to be unique in a single schema, so if
  # we have multiple schemas, we might end up with the same local_name pointing
  # to more than one remote_name
  # In such a case, raise a warning, and keep only the first relevant schema
  if (length(schema) > 1) {
    # Order according to ordering of `schema`, so that in a moment we can keep "first" table in event of a clash
    names_table <- names_table %>%
      mutate(schema_name = factor(schema_name, levels = schema)) %>%
      arrange(schema_name)

    clashes <- with(names_table, find_name_clashes(remote_name, local_name))

    if (length(clashes) > 0) {
      cli::cli_warn(c(
        "Some table names aren't unique:",
        purrr::imap_chr(
          clashes,
          ~ cli::format_inline(
            "Local name {.field {.y}} will refer to {.cls {DBI::dbQuoteIdentifier(con, .x[[1]])}}, ",
            "rather than to {.or {.cls {map(.x[-1], DBI::dbQuoteIdentifier, conn = con)}}}"
          )
        ) %>%
          purrr::set_names(rep("*", length(clashes)))
      ))

      # Keep only first schema for each local_name
      names_table <- slice_head(names_table, by = local_name)
    }
  }

  names_table %>%
    select(local_name, remote_name) %>%
    deframe()
}

# `schema_*()` : default schema if NULL, otherwise unchanged
schema_mssql <- function(con, schema) {
  if (is_null(schema)) {
    schema <- "dbo"
  }
  schema
}

schema_postgres <- function(con, schema) {
  if (is_null(schema)) {
    schema <- "public"
  }
  schema
}

schema_redshift <- schema_postgres

schema_mariadb <- function(con, schema) {
  if (is_null(schema)) {
    schema <- sql("database()")
  }
  schema
}

dbname_mssql <- function(con, dbname) {
  if (is_null(dbname)) {
    dbname <- ""
    dbname_sql <- ""
  } else {
    check_param_class(dbname, "character")
    dbname_sql <- paste0(DBI::dbQuoteIdentifier(con, dbname), ".")
  }
  set_names(dbname_sql, dbname)
}


get_names_table_mssql <- function(con, dbname_sql) {
  tbl(
    con,
    sql(glue::glue("
      SELECT tabs.name AS table_name, schemas.name AS schema_name
      FROM {dbname_sql}sys.tables tabs
      INNER JOIN {dbname_sql}sys.schemas schemas ON
      tabs.schema_id = schemas.schema_id
    "))
  )
}

get_names_table_postgres <- function(con) {
  tbl(
    con,
    sql("SELECT table_schema as schema_name, table_name as table_name from information_schema.tables")
  )
}

get_names_table_redshift <- get_names_table_postgres

get_names_table_mariadb <- get_names_table_postgres
