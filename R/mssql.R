mssql_sys_db <- function(con, dbname, name) {
  if (is.na(dbname)) {
    fq_name <- name
    sql_name <- sql("DB_NAME()")
  } else {
    fq_name <- paste0(dbname, ".", name)
    sql_name <- dbname
  }
  tbl(con, dbplyr::ident_q(fq_name)) %>%
    mutate(catalog = !!sql_name) %>%
    select(catalog, everything())
}

mssql_sys_all_db <- function(con, dbname, name, warn = FALSE) {
  lazy <- map(dbname, ~ tryCatch(
    mssql_sys_db(con, .x, name),
    error = function(e) {
      if (warn) {
        warn(paste0("Can't access database ", .x, ": ", conditionMessage(e)))
      }
      NULL
    }
  ))
  reduce(compact(lazy), union_all)
}

mssql_constraint_column_usage <- function(con, table_constraints, dbname) {
  info_fkc <-
    table_constraints %>%
    select(constraint_catalog, constraint_schema, constraint_name, constraint_type) %>%
    filter(constraint_type == "FOREIGN KEY")

  fkc <-
    mssql_sys_all_db(con, dbname, "sys.foreign_key_columns", warn = TRUE)
  columns <-
    mssql_sys_all_db(con, dbname, "sys.columns") %>%
    select(catalog = catalog, column_name = name, object_id, column_id)
  tables <-
    mssql_sys_all_db(con, dbname, "sys.tables") %>%
    select(catalog = catalog, schema_id, table_name = name, object_id)
  schemas <-
    mssql_sys_all_db(con, dbname, "sys.schemas") %>%
    select(catalog = catalog, schema_id, table_schema = name)
  objects <-
    mssql_sys_all_db(con, dbname, "sys.objects") %>%
    select(constraint_name = name, object_id)

  sys_fkc_column_usage <-
    fkc %>%
    left_join(columns, by = c("catalog", "referenced_object_id" = "object_id", "referenced_column_id" = "column_id")) %>%
    left_join(tables, by = c("catalog", "referenced_object_id" = "object_id")) %>%
    left_join(schemas, by = c("catalog", "schema_id")) %>%
    left_join(objects, by = c("constraint_object_id" = "object_id")) %>%
    # table_schema is used twice
    transmute(constraint_catalog = catalog, constraint_schema = table_schema, constraint_name, table_schema, table_name, column_name, ordinal_position = constraint_column_id)

  tbl_lc(con, dbplyr::ident_q("information_schema.constraint_column_usage")) %>%
    semi_join(info_fkc, by = c("constraint_catalog", "constraint_schema", "constraint_name")) %>%
    select(-table_schema, -table_name, -column_name) %>%
    distinct() %>%
    left_join(sys_fkc_column_usage, by = c("constraint_catalog", "constraint_schema", "constraint_name"))
}
