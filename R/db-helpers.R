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
    "2020_08_28_07_13_03"
  } else {
    time <- as.character(Sys.time())
    gsub("[-:. ]", "_", time)
  }
}

get_pid <- function() {
  if (Sys.getenv("IN_PKGDOWN") != "") {
    "12345"
  } else {
    as.character(Sys.getpid())
  }
}

class_to_db_class <- function(dest, class_vector) {
  if (is_mssql(dest) || is_postgres(dest)) {
    case_when(
      class_vector == "character" ~ "VARCHAR(100)",
      class_vector == "integer" ~ "INT",
      TRUE ~ class_vector
    )
  } else {
    return(class_vector)
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

is_mssql <- function(dest) {
  inherits(dest, c(
    "Microsoft SQL Server", "src_Microsoft SQL Server", "dblogConnection-Microsoft SQL Server", "src_dblogConnection-Microsoft SQL Server"
  ))
}

is_postgres <- function(dest) {
  inherits(dest, "src_PostgreSQLConnection") ||
    inherits(dest, "src_PqConnection") ||
    inherits(dest, "PostgreSQLConnection") ||
    inherits(dest, "PqConnection")
}

is_mariadb <- function(dest) {
  inherits_any(dest, c("MariaDBConnection", "src_MariaDBConnection", "src_DoltConnection", "src_DoltLocalConnection"))
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

  # Any entries in `new` with a higher count than in `old`
  clashes <- names(purrr::keep(table(new), ~ .x > table(old)[.x]))

  purrr::imap_chr(
    purrr::set_names(clashes),
    ~ glue::glue("* {paste0(dQuote(old[new == .x], q = FALSE), collapse = ', ')} => {dQuote(.y, q = FALSE)}")
  )
}


make_local_names <- function(schema_names, table_names, tidy_names = FALSE) {

  if (tidy_names) {

    check_suggested("snakecase", use = TRUE)

    schema_names_untidy <- schema_names
    schema_names <- snakecase::to_snake_case(schema_names)


    schema_clashes <- find_name_clashes(schema_names_untidy, schema_names)

    if (length(schema_clashes) > 0)
      stop(paste0(c("Forcing tidy schema names leads to name clashes:", schema_clashes), collapse = "\n"))


    table_names_untidy <- table_names
    table_names <- snakecase::to_snake_case(table_names)

    combined_names_untidy <- glue::glue("{schema_names}.{table_names_untidy}")
    combined_names <- glue::glue("{schema_names}.{table_names}")

    combined_clashes <- find_name_clashes(combined_names_untidy, combined_names)

    if (length(combined_clashes) > 0)
      stop(paste0(c("Forcing tidy table names leads to name clashes:", combined_clashes), collapse = "\n"))
  }


  if (length(unique(schema_names)) == 1)
    table_names
  else
    combined_names
}


get_src_tbl_names <- function(src, schema = NULL, dbname = NULL, tidy_names = FALSE) {
  if (!is_mssql(src) && !is_postgres(src) && !is_mariadb(src)) {
    warn_if_arg_not(schema, only_on = c("MSSQL", "Postgres", "MariaDB"))
    warn_if_arg_not(dbname, only_on = "MSSQL")
    return(set_names(src_tbls(src)))
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
  } else if (is_mariadb(src)) {
    # MariaDB
    schema <- schema_mariadb(con, schema)
    dbname <- warn_if_arg_not(dbname, only_on = "MSSQL")
    names_table <- get_names_table_mariadb(con)
  }

  names_table %>%
    # sql expressions need to be wrapped in parentheses
    filter(schema_name %in% !!(if (inherits(schema, "sql")) glue_sql_collapse(schema) else schema)) %>%
    collect() %>%
    # create remote names for the tables in the given schema (name is table_name; cannot be duplicated within a single schema)
    transmute(
      local_name = make_local_names(schema_name, table_name, tidy_names = tidy_names),
      remote_name = schema_if(schema_name, table_name, con, dbname),
    ) %>%
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

get_names_table_mariadb <- get_names_table_postgres
