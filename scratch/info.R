library(tidyverse)
pkgload::load_all()

#src <- dm::dm_get_src(dm_financial())
#src <- test_src_maria()
#src <- test_src_postgres()
src <- test_src_mssql()

# DuckDB doesn't have references
#src <- test_src_duckdb()

con <- src$con

if (FALSE) {
  try(DBI::dbRemoveTable(con, "airlines"))
  try(DBI::dbRemoveTable(con, "airports"))
  try(DBI::dbRemoveTable(con, "planes"))
  try(DBI::dbRemoveTable(con, "flights"))
  try(DBI::dbRemoveTable(con, "weather"))
  dm_nycflights13() %>%
    dm_zoom_to(flights) %>%
    semi_join(planes) %>%
    dm_update_zoomed() %>%
    copy_dm_to(con, ., temporary = FALSE)
}

DBI::dbListTables(con, schema_name = "information_schema")

obj <- DBI::dbListObjects(con)
obj %>% filter(is_prefix)

DBI::dbListObjects(con, DBI::Id(schema = "INFORMATION_SCHEMA"))

info <-
  dm_meta(con)

info %>%
  dm_draw()

info %>%
  dm_get_tables()

info_local <-
  info %>%
  collect()

quote_fq_schema <- function(con, catalog, schema) {
  if (is_postgres(con) || is_mssql(con)) {
    catalog <- dbQuoteIdentifier(con, catalog)
    schema <- dbQuoteIdentifier(con, schema)
    paste0(catalog, ".", schema)
  } else {
    bla
  }
}

quote_fq_table <- function(con, fq_schema, table) {
  table <- dbQuoteIdentifier(con, table)
  paste0(fq_schema, ".", table)
}

# quote_fq_column <- function(con, fq_table, column) {
#   table <- dbQuoteIdentifier(con, column)
#   paste0(fq_table, ".", column)
# }

fq_r_table_if_needed <- function(catalog, schema, table) {
  fq <- tibble(catalog, schema, table)

  fq %>%
    group_by(table) %>%
    mutate(n = n()) %>%
    ungroup() %>%
    mutate(fq_table = if_else(n > 1, fq_r_table(catalog, schema, table), table)) %>%
    pull()
}

fq_r_table <- function(catalog, schema, table) {
  if (length(unique(catalog)) > 1) {
    catalog <- paste0(catalog, ".")
  } else {
    catalog <- ""
  }

  if (length(unique(schema)) > 1) {
    schema <- paste0(schema, ".")
  } else {
    schema <- ""
  }

  paste0(catalog, schema, table)
}

info_local_named <-
  info_local %>%

  # FIXME: Simplify with rekey, https://github.com/cynkra/dm/issues/519
  dm_zoom_to(schemata) %>%
  mutate(fq_schema_name = quote_fq_schema(!!con, catalog_name, schema_name), .before = catalog_name) %>%
  dm_update_zoomed() %>%

  dm_zoom_to(tables) %>%
  left_join(schemata, select = fq_schema_name) %>%
  mutate(fq_table_name = quote_fq_table(!!con, fq_schema_name, table_name), .before = table_catalog) %>%
  mutate(r_table_name = fq_r_table_if_needed(table_catalog, table_schema, table_name)) %>%
  dm_update_zoomed() %>%

  dm_zoom_to(table_constraints) %>%
  left_join(tables, select = fq_table_name) %>%
  mutate(fq_constraint_name = quote_fq_table(!!con, quote_fq_schema(!!con, constraint_catalog, constraint_schema), constraint_name), .before = constraint_catalog) %>%
  select(fq_constraint_name, fq_table_name, everything()) %>%
  dm_update_zoomed() %>%

  dm_zoom_to(columns) %>%
  left_join(tables, select = fq_table_name) %>%
  #mutate(fq_column_name = quote_fq_column(!!con, fq_table_name, column_name), .before = column_name) %>%
  select(fq_table_name, everything()) %>%
  #select(fq_table_name, fq_column_name, everything()) %>%
  dm_update_zoomed() %>%

  dm_zoom_to(key_column_usage) %>%
  left_join(columns, select = fq_table_name) %>%
  left_join(table_constraints, select = fq_constraint_name) %>%
  select(fq_constraint_name, fq_table_name, everything()) %>%
  dm_update_zoomed() %>%

  dm_zoom_to(constraint_column_usage) %>%
  left_join(columns, select = fq_table_name) %>%
  left_join(table_constraints, select = fq_constraint_name) %>%
  select(fq_constraint_name, fq_table_name, everything()) %>%
  dm_update_zoomed()

info_simple <-
  dm(!!!dm_get_tables(info_local_named)) %>%
  dm_add_pk(schemata, fq_schema_name) %>%
  dm_add_pk(tables, fq_table_name) %>%
  dm_add_fk(tables, fq_schema_name, schemata) %>%
  dm_add_pk(columns, c(fq_table_name, column_name)) %>%
  dm_add_fk(columns, fq_table_name, tables) %>%
  #dm_add_fk(table_constraints, table_schema, schemata) %>%
  dm_add_pk(table_constraints, fq_constraint_name) %>%
  dm_add_fk(table_constraints, fq_table_name, tables) %>%
  # constraint_schema vs. table_schema?

  # not on mssql:
  #dm_add_fk(referential_constraints, c(constraint_schema, table_name), tables) %>%
  #dm_add_fk(referential_constraints, c(constraint_schema, referenced_table_name), tables) %>%

  dm_add_pk(key_column_usage, c(fq_constraint_name, ordinal_position)) %>%
  dm_add_fk(key_column_usage, c(fq_table_name, column_name), columns) %>%
  dm_add_fk(key_column_usage, fq_constraint_name, table_constraints) %>%

  # not on mariadb;
  dm_add_pk(constraint_column_usage, c(fq_constraint_name, ordinal_position)) %>%
  dm_add_fk(constraint_column_usage, c(fq_table_name, column_name), columns) %>%
  dm_add_fk(constraint_column_usage, fq_constraint_name, table_constraints) %>%
  dm_add_fk(constraint_column_usage, c(fq_constraint_name, ordinal_position), key_column_usage) %>%

  dm_select(columns, -c(table_catalog, table_schema, table_name)) %>%
  dm_select(table_constraints, -c(table_catalog, table_schema, table_name)) %>%
  dm_select(key_column_usage, -c(table_catalog, table_schema, table_name)) %>%
  dm_select(key_column_usage, -c(constraint_catalog, constraint_schema, constraint_name)) %>%
  dm_select(constraint_column_usage, -c(table_catalog, table_schema, table_name)) %>%
  dm_select(constraint_column_usage, -c(constraint_catalog, constraint_schema, constraint_name)) %>%
  dm_set_colors(brown = c(tables, columns), blue = schemata, green4 = ends_with("_constraints"), orange = ends_with("_usage"))

info_simple %>%
  dm_draw()

key_dm <-
  info_simple %>%

  dm_zoom_to(table_constraints) %>%
  filter(constraint_type == "PRIMARY KEY") %>%
  dm_insert_zoomed("pk_constraints") %>%
  dm_zoom_to(key_column_usage) %>%
  semi_join(pk_constraints) %>%
  dm_insert_zoomed("pk") %>%

  dm_zoom_to(table_constraints) %>%
  filter(constraint_type == "FOREIGN KEY") %>%
  dm_update_zoomed() %>%
  dm_zoom_to(constraint_column_usage) %>%
  semi_join(table_constraints) %>%
  rename(fk_fq_table_name = fq_table_name, fk_column_name = column_name) %>%
  left_join(key_column_usage) %>%
  rename(pk_fq_table_name = fq_table_name, pk_column_name = column_name) %>%

  # Postgres: Can return int64 here
  mutate(ordinal_position = as.integer(ordinal_position)) %>%
  dm_insert_zoomed("fk") %>%
  dm_add_fk(fk, c(pk_fq_table_name, pk_column_name), columns) %>%

  dm_zoom_to(columns) %>%
  left_join(tables, select = r_table_name) %>%
  dm_update_zoomed() %>%

  dm_select_tbl(columns, pk, fk)

key_dm %>%
  dm_draw()

key_dm %>%
  dm_get_tables()
