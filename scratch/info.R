library(tidyverse)
pkgload::load_all()

#src <- dm::dm_get_src(dm_financial())
#src <- test_src_maria()
src <- test_src_postgres()
#src <- test_src_mssql()

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

pk <-
  info %>%
  dm_zoom_to(table_constraints) %>%
  filter(constraint_type == "PRIMARY KEY") %>%
  dm_update_zoomed() %>%
  dm_zoom_to(key_column_usage) %>%
  semi_join(table_constraints)

pk

fk <-
  info %>%
  dm_zoom_to(table_constraints) %>%
  filter(constraint_type == "FOREIGN KEY") %>%
  dm_update_zoomed() %>%
  dm_zoom_to(constraint_column_usage) %>%
  semi_join(table_constraints) %>%
  rename(fk_table_catalog = table_catalog, fk_table_schema = table_schema, fk_table_name = table_name, fk_column_name = column_name) %>%
  left_join(key_column_usage) %>%
  rename(pk_table_catalog = table_catalog, pk_table_schema = table_schema, pk_table_name = table_name, pk_column_name = column_name)

fk

info_local <-
  info %>%
  collect()

info_local %>%
  dm_nrow()

info_local$TABLE_CONSTRAINTS %>%
  filter(TABLE_SCHEMA == "Financial_ijs")

info_local$TABLE_CONSTRAINTS %>%
  count(CONSTRAINT_TYPE)

info_local$REFERENTIAL_CONSTRAINTS %>%
  filter(CONSTRAINT_SCHEMA == "Financial_ijs")
