unique_db_table_name <- local({
  i <- 0

  function(table_name) {
    i <<- i + 1
    glue("{table_name}_", systime_convenient(), "_", as.character(i))
  }
})

systime_convenient <- function() {
  if (Sys.getenv("IN_PKGDOWN") != "") {
    "2020_08_28_07_13_03"
  } else {
    time <- as.character(Sys.time())
    gsub("[-: ]", "_", time)
  }
}

# Internal copy helper functions
build_copy_data <- function(dm, dest, table_names) {
  source <-
    dm %>%
    dm_apply_filters() %>%
    dm_get_tables_impl()

  copy_data_base <-
    tibble(source_name = src_tbls(dm), name = table_names) %>%
    mutate(df = map(source_name, function(x) tbl(dm, x)))

  if (is_db(dest)) {
    dest_con <- con_from_src_or_con(dest)

    pks <-
      dm_get_all_pks_impl(dm) %>%
      transmute(source_name = table, column = pk_col, pk = TRUE)

    fks <-
      dm_get_all_fks_impl(dm) %>%
      transmute(source_name = child_table, column = child_fk_cols, fk = TRUE)

    # Need to supply NOT NULL modifiers for primary keys
    # because they are difficult to add to MSSQL after the fact
    copy_data_types <-
      copy_data_base %>%
      select(source_name, df) %>%
      mutate(column = map(df, colnames)) %>%
      mutate(type = map(df, ~ map_chr(., ~ DBI::dbDataType(dest_con, .)))) %>%
      select(-df) %>%
      unnest(c(column, type)) %>%
      left_join(pks, by = c("source_name", "column")) %>%
      mutate(full_type = paste0(type, if_else(pk, " NOT NULL PRIMARY KEY", "", ""))) %>%
      group_by(source_name) %>%
      summarize(types = list(deframe(tibble(column, full_type))))

    copy_data_unique_indexes <-
      pks %>%
      transmute(source_name, unique_indexes = map(as.list(column), list))

    copy_data_indexes <-
      fks %>%
      select(source_name, column) %>%
      group_by(source_name) %>%
      summarize(indexes = map(list(column), as.list))

    copy_data <-
      copy_data_base %>%
      inner_join(copy_data_types, by = "source_name") %>%
      left_join(copy_data_unique_indexes, by = "source_name") %>%
      left_join(copy_data_indexes, by = "source_name") %>%
      mutate(indexes = map2(indexes, unique_indexes, setdiff))
  } else {
    copy_data <-
      copy_data_base
  }

  copy_data
}

# Not exported, to give us flexibility to change easily
copy_list_of_tables_to <- function(dest, copy_data,
                                   ..., overwrite = FALSE, df = NULL, name = NULL, types = NULL) {
  pmap(copy_data, copy_to, dest = dest, overwrite = overwrite, ...)
}

create_queries <- function(dest, fk_information) {
  if (is_null(fk_information)) {
    character()
  } else {
    queries_set_fk_relations(dest, fk_information)
  }
}

queries_set_fk_relations <- function(dest, fk_information) {
  db_child_tables <- fk_information$db_child_table
  child_fk_cols <- fk_information$child_fk_cols
  db_parent_tables <- fk_information$db_parent_table
  parent_pk_col <- fk_information$pk_col

  if (is_mssql(dest) || is_postgres(dest)) {
    pmap_chr(
      list(
        db_child_tables,
        child_fk_cols,
        db_parent_tables,
        parent_pk_col
      ),
      ~ glue_sql("ALTER TABLE {`DBI::SQL(..1)`} ADD FOREIGN KEY ({`..2`*}) REFERENCES {`DBI::SQL(..3)`} ({`..4`*}) ON DELETE CASCADE ON UPDATE CASCADE", .con = dest)
    )
  } else {
    return(character())
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
  is_db(dm_get_src(dm))
}

is_mssql <- function(dest) {
  inherits(dest, "Microsoft SQL Server") ||
    inherits(dest, "src_Microsoft SQL Server")
}

is_postgres <- function(dest) {
  inherits(dest, "src_PostgreSQLConnection") ||
    inherits(dest, "src_PqConnection") ||
    inherits(dest, "PostgreSQLConnection") ||
    inherits(dest, "PqConnection")
}

src_from_src_or_con <- function(dest) {
  if (is.src(dest)) dest else dbplyr::src_dbi(dest)
}

con_from_src_or_con <- function(dest) {
  if (is.src(dest)) dest$con else dest
}

repair_table_names_for_db <- function(table_names, temporary, con) {
  if (temporary) {
    # FIXME: Better logic for temporary table names
    if (is_mssql(con)) {
      names <- paste0("#", table_names)
    } else {
      names <- table_names
    }
    names <- unique_db_table_name(names)
  } else {
    names <- table_names
  }
  names <- set_names(names, table_names)
  quote_ids(names, con)
}

get_src_tbl_names <- function(src, schema = NULL, dbname = NULL) {
  if (!is_mssql(src) && !is_postgres(src)) {
    warn_if_not_null(schema)
    warn_if_not_null(dbname, only_on = "MSSQL")
    return(src_tbls(src))
  }

  con <- src$con

  if (is_mssql(src)) {
    # MSSQL
    schema <- schema_mssql(con, schema)
    dbname_sql <- dbname_mssql(con, dbname)
    names_table <- get_names_table_mssql(con, dbname_sql)
    dbname <- names(dbname_sql)
  } else if (is_postgres(src)) {
    # Postgres
    schema <- schema_postgres(con, schema)
    dbname <- warn_if_not_null(dbname, only_on = "MSSQL")
    names_table <- get_names_table_postgres(con)
  }
  check_param_class(schema, "character")
  check_param_length(schema)
  names_table %>%
    filter(schema_name == !!schema) %>%
    # create remote names for the tables in the given schema (name is table_name; cannot be duplicated within a single schema)
    mutate(remote_name = schema_if(schema_name, table_name, con, dbname)) %>%
    select(-schema_name) %>%
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
  DBI::dbGetQuery(
    con,
    glue::glue("SELECT tabs.name AS table_name, schemas.name AS schema_name
      FROM {dbname_sql}sys.tables tabs
      INNER JOIN {dbname_sql}sys.schemas schemas ON
      tabs.schema_id = schemas.schema_id")
  )
}

get_names_table_postgres <- function(con) {
  DBI::dbGetQuery(
    con,
    "SELECT table_schema as schema_name, table_name as table_name from information_schema.tables"
  )
}
