mssql_sys_db <- function(con, dbname, sys_table, vars = NULL) {
  if (is.na(dbname)) {
    id <- DBI::Id(schema = "sys", table = sys_table)
    sql_name <- sql("DB_NAME()")
  } else {
    id <- DBI::Id(catalog = dbname, schema = "sys", table = sys_table)
    sql_name <- dbname
  }
  dplyr::tbl(con, id, vars = vars) %>%
    dplyr::mutate(catalog = !!sql_name) %>%
    dplyr::select(catalog, tidyselect::everything())
}

#' @autoglobal
mssql_constraint_column_usage <- function(con, table_constraints, dbname) {
  info_fkc <-
    table_constraints %>%
    dplyr::select(constraint_catalog, constraint_schema, constraint_name, constraint_type) %>%
    dplyr::filter(constraint_type == "FOREIGN KEY")

  fkc <- mssql_sys_db(
    con,
    dbname,
    "foreign_key_columns",
    vars = c(
      "constraint_object_id",
      "constraint_column_id",
      "referenced_object_id",
      "referenced_column_id"
    )
  )

  columns <-
    mssql_sys_db(
      con,
      dbname,
      "columns",
      vars = c(
        "name",
        "object_id",
        "column_id"
      )
    ) %>%
    dplyr::rename(column_name = name)

  tables <-
    mssql_sys_db(
      con,
      dbname,
      "tables",
      vars = c(
        "schema_id",
        "name",
        "object_id"
      )
    ) %>%
    dplyr::rename(table_name = name)

  schemas <-
    mssql_sys_db(
      con,
      dbname,
      "schemas",
      vars = c(
        "schema_id",
        "name"
      )
    ) %>%
    dplyr::rename(table_schema = name)

  objects <-
    mssql_sys_db(
      con,
      dbname,
      "objects",
      vars = c(
        "name",
        "object_id"
      )
    ) %>%
    dplyr::select(constraint_name = name, object_id)

  sys_fkc_column_usage <-
    fkc %>%
    dplyr::left_join(
      columns,
      by = c("catalog", "referenced_object_id" = "object_id", "referenced_column_id" = "column_id")
    ) %>%
    dplyr::left_join(tables, by = c("catalog", "referenced_object_id" = "object_id")) %>%
    dplyr::collapse() %>%
    dplyr::left_join(schemas, by = c("catalog", "schema_id")) %>%
    dplyr::collapse() %>%
    dplyr::left_join(objects, by = c("constraint_object_id" = "object_id")) %>%
    # table_schema is used twice
    dplyr::transmute(
      constraint_catalog = catalog,
      constraint_schema = table_schema,
      constraint_name,
      table_schema,
      table_name,
      column_name,
      ordinal_position = constraint_column_id
    )

  tbl_lc(
    con,
    "information_schema.constraint_column_usage",
    vars = c(
      "table_catalog",
      "table_schema",
      "table_name",
      "column_name",
      "constraint_catalog",
      "constraint_schema",
      "constraint_name"
    )
  ) %>%
    dplyr::semi_join(info_fkc, by = c("constraint_catalog", "constraint_schema", "constraint_name")) %>%
    dplyr::select(-table_schema, -table_name, -column_name) %>%
    dplyr::distinct() %>%
    dplyr::left_join(
      sys_fkc_column_usage,
      by = c("constraint_catalog", "constraint_schema", "constraint_name")
    )
}

mssql_escape <- function(x, con) {
  # https://github.com/tidyverse/dbplyr/issues/934
  if (is.logical(x)) {
    dbplyr::sql(dplyr::if_else(x, "1", "0", "NULL"))
  } else {
    dbplyr::escape(x, parens = FALSE, collapse = NULL, con = con)
  }
}
