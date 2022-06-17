dm_meta <- function(con, catalog = NA, schema = NULL, simple = FALSE) {
  need_collect <- FALSE

  if (is_mssql(con)) {
    if (is.null(catalog)) {
      # FIXME: Classed error message?
      abort("SQL server only supports learning from one database.")
    }

    if (!is.na(catalog)) {
      message("Temporarily switching to database ", tick(catalog), ".")
      old_dbname <- dbGetQuery(con, "SELECT DB_NAME()")[[1]]
      sql <- paste0("USE ", dbQuoteIdentifier(con, catalog))
      old_sql <- paste0("USE ", dbQuoteIdentifier(con, old_dbname))
      dbExecute(con, sql, immediate = TRUE)
      withr::defer({
        dbExecute(con, old_sql, immediate = TRUE)
      })
      need_collect <- TRUE
    }
  }

  if (simple) {
    out <-
      dm_meta_simple_raw(con) %>%
      filter_dm_meta_simple(catalog, schema)
  } else {
    out <-
      dm_meta_raw(con, catalog) %>%
      select_dm_meta() %>%
      filter_dm_meta(catalog, schema)
  }

  if (need_collect) {
    out <-
      out %>%
      collect()
  }

  out
}

dm_meta_raw <- function(con, catalog) {
  src <- src_from_src_or_con(con)

  local_options(digits.secs = 6)

  schemata <- tbl_lc(src, "information_schema.schemata", vars = c(
    "catalog_name", "schema_name", "default_character_set_name"
  ))
  tables <- tbl_lc(src, "information_schema.tables", vars = c(
    "table_catalog", "table_schema", "table_name", "table_type"
  ))
  columns <- tbl_lc(src, "information_schema.columns", vars = c(
    "table_catalog", "table_schema", "table_name", "column_name",
    "ordinal_position", "column_default", "is_nullable", "data_type",
    "character_maximum_length", "character_octet_length", "numeric_precision",
    "numeric_scale", "datetime_precision",
    "character_set_name",
    "collation_name"
  ))
  table_constraints <- tbl_lc(src, "information_schema.table_constraints", vars = c(
    "constraint_catalog", "constraint_schema", "constraint_name",
    "table_name", "constraint_type"
  )) %>%
    mutate(table_catalog = constraint_catalog, table_schema = constraint_schema, .before = table_name)
  key_column_usage <- tbl_lc(src, "information_schema.key_column_usage", vars = c(
    "constraint_catalog", "constraint_schema", "constraint_name",
    "table_catalog", "table_schema", "table_name", "column_name",
    "ordinal_position"
  ))

  if (is_postgres(src)) {
    # Need hand-crafted query for now
    constraint_column_usage <-
      tbl(src, sql(postgres_column_constraints), vars = c(
        "table_catalog", "table_schema", "table_name", "column_name",
        "constraint_catalog", "constraint_schema", "constraint_name",
        "ordinal_position"
      ))
  } else if (is_mssql(src)) {
    constraint_column_usage <- mssql_constraint_column_usage(src, table_constraints, catalog)
  } else {
    constraint_column_usage <-
      tbl_lc(src, "information_schema.key_column_usage", vars = c(
        "table_catalog",
        "referenced_table_schema", "referenced_table_name", "referenced_column_name",
        "constraint_catalog", "constraint_schema", "constraint_name",
        "ordinal_position"
      )) %>%
      filter(!is.na(referenced_table_name)) %>%
      rename(
        table_schema = referenced_table_schema,
        table_name = referenced_table_name,
        column_name = referenced_column_name,
      )
  }

  dm(schemata, tables, columns, table_constraints, key_column_usage, constraint_column_usage) %>%
    dm_meta_add_keys()
}

dm_meta_add_keys <- function(dm_meta) {
  dm_meta %>%
    dm_meta_simple_add_keys() %>%
    # dm_add_fk(table_constraints, table_schema, schemata) %>%
    dm_add_pk(table_constraints, c(constraint_catalog, constraint_schema, constraint_name)) %>%
    dm_add_fk(table_constraints, c(table_catalog, table_schema, table_name), tables) %>%
    # constraint_schema vs. table_schema?

    # not on mssql:
    # dm_add_fk(referential_constraints, c(constraint_schema, table_name), tables) %>%
    # dm_add_fk(referential_constraints, c(constraint_schema, referenced_table_name), tables) %>%

    dm_add_pk(key_column_usage, c(constraint_catalog, constraint_schema, constraint_name, ordinal_position)) %>%
    dm_add_fk(key_column_usage, c(table_catalog, table_schema, table_name, column_name), columns) %>%
    dm_add_fk(key_column_usage, c(constraint_catalog, constraint_schema, constraint_name), table_constraints) %>%
    #
    # not on mariadb;
    dm_add_pk(constraint_column_usage, c(constraint_catalog, constraint_schema, constraint_name, ordinal_position)) %>%
    dm_add_fk(constraint_column_usage, c(table_catalog, table_schema, table_name, column_name), columns) %>%
    dm_add_fk(constraint_column_usage, c(constraint_catalog, constraint_schema, constraint_name), table_constraints) %>%
    dm_add_fk(constraint_column_usage, c(constraint_catalog, constraint_schema, constraint_name, ordinal_position), key_column_usage) %>%
    #
    dm_set_colors(green4 = ends_with("_constraints"), orange = ends_with("_usage"))
}

dm_meta_simple_raw <- function(con) {
  src <- src_from_src_or_con(con)

  local_options(digits.secs = 6)

  schemata <- tbl_lc(src, "information_schema.schemata", vars = c(
    "catalog_name", "schema_name"
  ))
  tables <- tbl_lc(src, "information_schema.tables", vars = c(
    "table_catalog", "table_schema", "table_name", "table_type"
  ))
  columns <- tbl_lc(src, "information_schema.columns", vars = c(
    "table_catalog", "table_schema", "table_name", "column_name",
    "ordinal_position", "column_default", "is_nullable", "data_type"
  ))

  dm(schemata, tables, columns) %>%
    dm_meta_simple_add_keys()
}

dm_meta_simple_add_keys <- function(dm_meta) {
  dm_meta %>%
    dm_add_pk(schemata, c(catalog_name, schema_name)) %>%
    dm_add_pk(tables, c(table_catalog, table_schema, table_name)) %>%
    dm_add_fk(tables, c(table_catalog, table_schema), schemata) %>%
    dm_add_pk(columns, c(table_catalog, table_schema, table_name, column_name)) %>%
    dm_add_fk(columns, c(table_catalog, table_schema, table_name), tables) %>%
    #
    dm_set_colors(brown = c(tables, columns), blue = schemata)
}

tbl_lc <- function(con, name, vars) {
  # For discovery only!
  if (is.null(vars)) {
    from <- name
  } else {
    from <- sql(paste0(
      "SELECT ",
      paste0(DBI::dbQuoteIdentifier(con_from_src_or_con(con), vars), collapse = ", "),
      "\nFROM ", name
    ))
  }

  tbl(con, from, vars = vars)
}

select_dm_meta <- function(dm_meta) {
  dm_meta %>%
    dm_select(schemata, catalog_name, schema_name) %>%
    dm_select(tables, table_catalog, table_schema, table_name, table_type) %>%
    dm_select(columns, table_catalog, table_schema, table_name, column_name, ordinal_position, column_default, is_nullable) %>%
    dm_select(table_constraints, constraint_catalog, constraint_schema, constraint_name, table_catalog, table_schema, table_name, constraint_type) %>%
    dm_select(key_column_usage, constraint_catalog, constraint_schema, constraint_name, table_catalog, table_schema, table_name, column_name, ordinal_position) %>%
    dm_select(constraint_column_usage, table_catalog, table_schema, table_name, column_name, constraint_catalog, constraint_schema, constraint_name, ordinal_position)
}

filter_dm_meta <- function(dm_meta, catalog = NULL, schema = NULL) {
  force(catalog)
  force(schema)

  schemata <- dm_meta$schemata
  tables <- dm_meta$tables
  columns <- dm_meta$columns
  table_constraints <- dm_meta$table_constraints
  key_column_usage <- dm_meta$key_column_usage
  constraint_column_usage <- dm_meta$constraint_column_usage

  if (!is.null(catalog) && !is.na(catalog)) {
    schemata <- schemata %>% filter(catalog_name %in% !!catalog)
    tables <- tables %>% filter(table_catalog %in% !!catalog)
    columns <- columns %>% filter(table_catalog %in% !!catalog)
    table_constraints <- table_constraints %>% filter(table_catalog %in% !!catalog)
    key_column_usage <- key_column_usage %>% filter(table_catalog %in% !!catalog)
    constraint_column_usage <- constraint_column_usage %>% filter(table_catalog %in% !!catalog)
  }

  if (!is.null(schema)) {
    schemata <- schemata %>% filter(schema_name %in% !!schema)
    tables <- tables %>% filter(table_schema %in% !!schema)
    columns <- columns %>% filter(table_schema %in% !!schema)
    table_constraints <- table_constraints %>% filter(table_schema %in% !!schema)
    key_column_usage <- key_column_usage %>% filter(table_schema %in% !!schema)
    constraint_column_usage <- constraint_column_usage %>% filter(table_schema %in% !!schema)
  }

  dm(
    schemata,
    tables,
    columns,
    table_constraints,
    key_column_usage,
    constraint_column_usage
  ) %>%
    dm_meta_add_keys()
}

filter_dm_meta_simple <- function(dm_meta, catalog = NULL, schema = NULL) {
  force(catalog)
  force(schema)

  schemata <- dm_meta$schemata
  tables <- dm_meta$tables
  columns <- dm_meta$columns

  if (!is.null(catalog) && !is.na(catalog)) {
    schemata <- schemata %>% filter(catalog_name %in% !!catalog)
    tables <- tables %>% filter(table_catalog %in% !!catalog)
    columns <- columns %>% filter(table_catalog %in% !!catalog)
  }

  if (!is.null(schema)) {
    schemata <- schemata %>% filter(schema_name %in% !!schema)
    tables <- tables %>% filter(table_schema %in% !!schema)
    columns <- columns %>% filter(table_schema %in% !!schema)
  }

  dm(schemata, tables, columns) %>%
    dm_meta_simple_add_keys()
}
