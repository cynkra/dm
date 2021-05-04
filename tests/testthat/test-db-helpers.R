test_that("DB helpers work for MSSQL", {
  skip_if_src_not("mssql")
  con_mssql <- my_test_src()$con
  expect_identical(schema_mssql(con_mssql, "schema"), "schema")
  expect_identical(schema_mssql(con_mssql, NULL), "dbo")
  expect_identical(dbname_mssql(con_mssql, "database_2"), set_names("\"database_2\".", "database_2"))
  expect_identical(dbname_mssql(con_mssql, NULL), set_names("", ""))

  withr::defer({
    try(dbExecute(con_mssql, "DROP TABLE test_db_helpers"))
    try(dbExecute(con_mssql, "DROP TABLE schema_db_helpers.test_db_helpers_2"))
    try(dbExecute(con_mssql, "DROP SCHEMA schema_db_helpers"))
    try(dbExecute(con_mssql, "DROP TABLE [db_helpers_db].[dbo].[test_db_helpers_3]"))
    try(dbExecute(con_mssql, "DROP TABLE [db_helpers_db].[schema_db_helpers_2].[test_db_helpers_4]"))
    # dropping schema is unnecessary
    try(dbExecute(con_mssql, "DROP DATABASE db_helpers_db"))
  })

  # create table in 'dbo'
  dbWriteTable(
    con_mssql,
    DBI::Id(schema = "dbo", table = "test_db_helpers"),
    value = tibble(a = 1)
  )
  # create table in a schema
  dbExecute(con_mssql, "CREATE SCHEMA schema_db_helpers")
  dbWriteTable(
    con_mssql,
    DBI::Id(schema = "schema_db_helpers", table = "test_db_helpers_2"),
    value = tibble(a = 1)
  )
  # create table on 'dbo' on another DB
  dbExecute(con_mssql, "CREATE DATABASE db_helpers_db")
  dbWriteTable(
    con_mssql,
    DBI::Id(db = "db_helpers_db", schema = "dbo", table = "test_db_helpers_3"),
    value = tibble(a = 1)
  )
  # create table in a schema on another DB
  original_dbname <- attributes(con_mssql)$info$dbname
  DBI::dbExecute(con_mssql, "USE db_helpers_db")
  DBI::dbExecute(con_mssql, "CREATE SCHEMA schema_db_helpers_2")
  DBI::dbExecute(con_mssql, paste0("USE ", original_dbname))
  dbWriteTable(
    con_mssql,
    DBI::Id(db = "db_helpers_db", schema = "schema_db_helpers_2", table = "test_db_helpers_4"),
    value = tibble(a = 1)
  )

  expect_identical(
    get_src_tbl_names(my_test_src())["test_db_helpers"],
    DBI::SQL("\"dbo\".\"test_db_helpers\"")
  )
  expect_identical(
    get_src_tbl_names(my_test_src(), schema = "schema_db_helpers")["test_db_helpers_2"],
    DBI::SQL("\"schema_db_helpers\".\"test_db_helpers_2\"")
  )
  expect_identical(
    get_src_tbl_names(my_test_src(), dbname = "db_helpers_db")["test_db_helpers_3"],
    DBI::SQL("\"db_helpers_db\".\"dbo\".\"test_db_helpers_3\"")
  )
  expect_identical(
    get_src_tbl_names(my_test_src(), dbname = "db_helpers_db", schema = "schema_db_helpers_2")["test_db_helpers_4"],
    DBI::SQL("\"db_helpers_db\".\"schema_db_helpers_2\".\"test_db_helpers_4\"")
  )
})


test_that("DB helpers work for Postgres", {
  skip_if_src_not("postgres")
  con_postgres <- my_test_src()$con
  expect_identical(schema_postgres(con_postgres, "schema"), "schema")
  expect_identical(schema_postgres(con_postgres, NULL), "public")

  withr::defer({
    try(dbExecute(con_postgres, "DROP TABLE test_db_helpers"))
    try(dbExecute(con_postgres, "DROP TABLE schema_db_helpers.test_db_helpers_2"))
    try(dbExecute(con_postgres, "DROP SCHEMA schema_db_helpers"))
  })

  # create table in 'public'
  dbWriteTable(
    con_postgres,
    DBI::Id(schema = "public", table = "test_db_helpers"),
    value = tibble(a = 1)
  )
  # create table in a schema
  dbExecute(con_postgres, "CREATE SCHEMA schema_db_helpers")
  dbWriteTable(
    con_postgres,
    DBI::Id(schema = "schema_db_helpers", table = "test_db_helpers_2"),
    value = tibble(a = 1)
  )

  expect_identical(
    get_src_tbl_names(my_test_src())["test_db_helpers"],
    DBI::SQL("\"public\".\"test_db_helpers\"")
  )
  expect_identical(
    get_src_tbl_names(my_test_src(), schema = "schema_db_helpers")["test_db_helpers_2"],
    DBI::SQL("\"schema_db_helpers\".\"test_db_helpers_2\"")
  )
})

test_that("DB helpers work for other DBMS than MSSQL or Postgres", {
  skip_if_local_src()
  skip_if_src("mssql")
  skip_if_src("postgres")
  # for other DBMS than "MSSQL" or "Postgrs", get_src_tbl_names() translates to `src_tbls_impl()`
  con_db <- my_test_src()$con
  dbWriteTable(
    con_db,
    DBI::Id(table = "test_db_helpers"),
    value = tibble(a = 1)
  )
  withr::defer({
    try(dbExecute(con_db, "DROP TABLE test_db_helpers"))
  })

  # test for 2 warnings and if the output contains the new table
  expect_dm_warning(
    expect_dm_warning(
      expect_true("test_db_helpers" %in% get_src_tbl_names(my_test_src(), schema = "schema", dbname = "dbname")),
      class = "arg_not"
    ),
    class = "arg_not"
  )
})
