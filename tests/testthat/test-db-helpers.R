test_that("DB helpers work for MSSQL", {

  skip_if_src_not("mssql")

  con_mssql <- my_test_src()$con

  expect_identical(schema_mssql(con_mssql, "schema"), "schema")
  expect_identical(schema_mssql(con_mssql, NULL), "dbo")
  expect_identical(dbname_mssql(con_mssql, "database_2"), set_names("\"database_2\".", "database_2"))
  expect_identical(dbname_mssql(con_mssql, NULL), set_names("", ""))


  # Clear up after ourselves (we're about to modify the database somewhat...)
  withr::defer({
    try(dbExecute(con_mssql, "DROP TABLE test_db_helpers_1"))
    try(dbExecute(con_mssql, "DROP TABLE schema_db_helpers_2.test_db_helpers_2"))
    try(dbExecute(con_mssql, "DROP SCHEMA schema_db_helpers_2"))
    try(dbExecute(con_mssql, "DROP TABLE schema_db_helpers_3.test_db_helpers_3"))
    try(dbExecute(con_mssql, "DROP SCHEMA schema_db_helpers_3"))
    try(dbExecute(con_mssql, "DROP TABLE [db_helpers_db].[dbo].[test_db_helpers_4]"))
    try(dbExecute(con_mssql, "DROP TABLE [db_helpers_db].[schema_db_helpers_5].[test_db_helpers_5]"))
    try(dbExecute(con_mssql, "DROP TABLE [db_helpers_db].[schema_db_helpers_6].[test_db_helpers_6]"))
    # dropping schema is unnecessary
    try(dbExecute(con_mssql, "DROP DATABASE db_helpers_db"))
  })


  # Create table in default schema 'dbo'
  dbWriteTable(
    con_mssql,
    DBI::Id(schema = "dbo", table = "test_db_helpers_1"),
    value = tibble(a = 1)
  )


  # Create tables in a new schema:
  dbExecute(con_mssql, "CREATE SCHEMA schema_db_helpers_2")

  #   "Tidy" name
  dbWriteTable(
    con_mssql,
    DBI::Id(schema = "schema_db_helpers_2", table = "test_db_helpers_2"),
    value = tibble(a = 1)
  )

  #   "Untidy" name
  dbWriteTable(
    con_mssql,
    DBI::Id(schema = "schema_db_helpers_2", table = "Test DB Helpers Two"),
    value = tibble(a = 1)
  )


  # Create tables in another new schema:
  dbExecute(con_mssql, "CREATE SCHEMA schema_db_helpers_3")

  #   "Tidy" name, but identical to a name in another schema
  dbWriteTable(
    con_mssql,
    DBI::Id(schema = "schema_db_helpers_3", table = "test_db_helpers_2"),
    value = tibble(a = 1)
  )

  #   "Untidy" name which will tidy into the same name as another table in the same schema
  dbWriteTable(
    con_mssql,
    DBI::Id(schema = "schema_db_helpers_3", table = "Test DB Helpers 2"),
    value = tibble(a = 1)
  )




  # Default schema
  res <- get_src_tbl_names(my_test_src())

  expect_identical(
    get_src_tbl_names(my_test_src())["test_db_helpers_1"],
    DBI::SQL("\"dbo\".\"test_db_helpers_1\"")
  )



  # Non-default schema, no tidy names
  res <- get_src_tbl_names(my_test_src(), schema = "schema_db_helpers_2")

  expect_named(res, c("test_db_helpers_2", "Test DB Helpers Two"))

  expect_identical(
    res["test_db_helpers_2"],
    DBI::SQL("\"schema_db_helpers_2\".\"test_db_helpers_2\"")
  )

  expect_identical(
    res["Test DB Helpers Two"],
    DBI::SQL("\"schema_db_helpers_2\".\"Test DB Helpers Two\"")
  )


  # Non-default schema, tidy names
  res <- get_src_tbl_names(my_test_src(), schema = "schema_db_helpers_2", tidy_names = TRUE)
  expect_named(res, c("test_db_helpers_2", "test_db_helpers_two"))

  expect_identical(
    res["test_db_helpers_two"],
    DBI::SQL("\"schema_db_helpers_2\".\"Test DB Helpers Two\"")
  )


  # Non-default schema, tidy names, with name clash
  expect_error(
    get_src_tbl_names(my_test_src(), schema = "schema_db_helpers_3", tidy_names = TRUE),
    paste(
      "Forcing tidy table names leads to name clashes:",
      "* \"schema_db_helpers_3.test_db_helpers_2\", \"schema_db_helpers_3.Test DB Helpers 2\" => \"schema_db_helpers_3.test_db_helpers_2\"",
      "Try again with `tidy_names = FALSE`.",
      sep = "\n"
    ),
    fixed = TRUE
  )


  # Multiple schemas, no tidy names
  res <- get_src_tbl_names(my_test_src(), schema = c("schema_db_helpers_2", "schema_db_helpers_3"))
  expect_named(res, c(
    "schema_db_helpers_2.test_db_helpers_2",
    "schema_db_helpers_2.Test DB Helpers 2",
    "schema_db_helpers_3.test_db_helpers_2",
  ))

  expect_identical(
    results["schema_db_helpers_2.test_db_helpers_2"],
    DBI::SQL("\"schema_db_helpers_2\".\"test_db_helpers_2\"")
  )
  expect_identical(
    results["schema_db_helpers_3.test_db_helpers_2"],
    DBI::SQL("\"schema_db_helpers_3\".\"test_db_helpers_2\"")
  )


  # Multiple schemas, tidy names (same name clash in schema_db_helpers_2)
  expect_error(
    get_src_tbl_names(my_test_src(), schema = c("schema_db_helpers_2", "schema_db_helpers_3"), tidy_names = TRUE),
    paste(
      "Forcing tidy table names leads to name clashes:",
      "* \"schema_db_helpers_3.test_db_helpers_2\", \"schema_db_helpers_3.Test DB Helpers 2\" => \"schema_db_helpers_3.test_db_helpers_2\"",
      "Try again with `tidy_names = FALSE`.",
      sep = "\n"
    ),
    fixed = TRUE
  )



  # create table on 'dbo' on another DB
  dbExecute(con_mssql, "CREATE DATABASE db_helpers_db")
  dbWriteTable(
    con_mssql,
    DBI::Id(db = "db_helpers_db", schema = "dbo", table = "test_db_helpers_4"),
    value = tibble(a = 1)
  )

  # create table in a schema on another DB
  original_dbname <- attributes(con_mssql)$info$dbname
  DBI::dbExecute(con_mssql, "USE db_helpers_db")
  DBI::dbExecute(con_mssql, "CREATE SCHEMA schema_db_helpers_5")
  dbWriteTable(
    con_mssql,
    DBI::Id(db = "db_helpers_db", schema = "schema_db_helpers_5", table = "test_db_helpers_5"),
    value = tibble(a = 1)
  )

  DBI::dbExecute(con_mssql, paste0("USE ", original_dbname))
  # create table in a different schema on another DB
  DBI::dbExecute(con_mssql, "USE db_helpers_db")
  DBI::dbExecute(con_mssql, "CREATE SCHEMA schema_db_helpers_6")
  dbWriteTable(
    con_mssql,
    DBI::Id(schema = "schema_db_helpers_6", table = "test_db_helpers_6"),
    value = tibble(a = 1)
  )
  DBI::dbExecute(con_mssql, paste0("USE ", original_dbname))



  # non-default db, default schema
  expect_identical(
    get_src_tbl_names(my_test_src(), dbname = "db_helpers_db")["test_db_helpers_4"],
    DBI::SQL("\"db_helpers_db\".\"dbo\".\"test_db_helpers_4\"")
  )

  # non-default db, non-default schema
  expect_identical(
    get_src_tbl_names(my_test_src(), dbname = "db_helpers_db", schema = "schema_db_helpers_5")["test_db_helpers_5"],
    DBI::SQL("\"db_helpers_db\".\"schema_db_helpers_5\".\"test_db_helpers_5\"")
  )

  # non-default db, multiple schemata
  results <- get_src_tbl_names(my_test_src(), dbname = "db_helpers_db", schema = c("schema_db_helpers_5", "schema_db_helpers_6"))
  expect_named(
    results,
    c("schema_db_helpers_5.test_db_helpers_5", "schema_db_helpers_6.test_db_helpers_6")
  )
  expect_identical(
    results["schema_db_helpers_5.test_db_helpers_5"],
    DBI::SQL("\"db_helpers_db\".\"schema_db_helpers_5\".\"test_db_helpers_5\"")
  )
  expect_identical(
    results["schema_db_helpers_6.test_db_helpers_6"],
    DBI::SQL("\"db_helpers_db\".\"schema_db_helpers_6\".\"test_db_helpers_6\"")
  )
})



test_that("DB helpers work for Postgres", {
  skip_if_src_not("postgres")
  con_postgres <- my_test_src()$con
  expect_identical(schema_postgres(con_postgres, "schema"), "schema")
  expect_identical(schema_postgres(con_postgres, NULL), "public")

  withr::defer({
    try(dbExecute(con_postgres, "DROP TABLE test_db_helpers_1"))
    try(dbExecute(con_postgres, "DROP TABLE schema_db_helpers_2.test_db_helpers_2"))
    try(dbExecute(con_postgres, "DROP SCHEMA schema_db_helpers_2"))
    try(dbExecute(con_postgres, "DROP TABLE schema_db_helpers_3.test_db_helpers_3"))
    try(dbExecute(con_postgres, "DROP SCHEMA schema_db_helpers_3"))
  })

  # create table in 'public'
  dbWriteTable(
    con_postgres,
    DBI::Id(schema = "public", table = "test_db_helpers_1"),
    value = tibble(a = 1)
  )
  # create table in a schema
  dbExecute(con_postgres, "CREATE SCHEMA schema_db_helpers_2")
  dbWriteTable(
    con_postgres,
    DBI::Id(schema = "schema_db_helpers_2", table = "test_db_helpers_2"),
    value = tibble(a = 1)
  )
  # create table in a different schema
  dbExecute(con_postgres, "CREATE SCHEMA schema_db_helpers_3")
  dbWriteTable(
    con_postgres,
    DBI::Id(schema = "schema_db_helpers_3", table = "test_db_helpers_3"),
    value = tibble(a = 1)
  )

  # default schema
  expect_identical(
    get_src_tbl_names(my_test_src())["test_db_helpers_1"],
    DBI::SQL("\"public\".\"test_db_helpers_1\"")
  )

  # non-default schema
  expect_identical(
    get_src_tbl_names(my_test_src(), schema = "schema_db_helpers_2")["test_db_helpers_2"],
    DBI::SQL("\"schema_db_helpers_2\".\"test_db_helpers_2\"")
  )

  # multiple schemata
  results <- get_src_tbl_names(my_test_src(), schema = c("schema_db_helpers_2", "schema_db_helpers_3"))
  expect_named(
    results,
    c("schema_db_helpers_2.test_db_helpers_2", "schema_db_helpers_3.test_db_helpers_3")
  )
  expect_identical(
    results["schema_db_helpers_2.test_db_helpers_2"],
    DBI::SQL("\"schema_db_helpers_2\".\"test_db_helpers_2\"")
  )
  expect_identical(
    results["schema_db_helpers_3.test_db_helpers_3"],
    DBI::SQL("\"schema_db_helpers_3\".\"test_db_helpers_3\"")
  )
})



test_that("DB helpers work for other DBMS than MSSQL or Postgres", {
  # FIXME: Why does it fail for those databases?
  skip_if_src("mssql", "postgres")

  # for other DBMS than "MSSQL" or "Postgrs", get_src_tbl_names() translates to `src_tbls_impl()`
  con_db <- my_db_test_src()$con
  dbWriteTable(
    con_db,
    DBI::Id(table = "test_db_helpers"),
    value = tibble(a = 1)
  )
  withr::defer({
    try(dbExecute(con_db, "DROP TABLE test_db_helpers"))
  })

  skip_if_src("maria")

  # test for 2 warnings and if the output contains the new table
  expect_dm_warning(
    expect_dm_warning(
      expect_true("test_db_helpers" %in% names(get_src_tbl_names(my_db_test_src(), schema = "schema", dbname = "dbname"))),
      class = "arg_not"
    ),
    class = "arg_not"
  )

  skip_if_src("mssql", "postgres")

  # test for warning and if the output contains the new table
  expect_dm_warning(
    expect_true("test_db_helpers" %in% names(get_src_tbl_names(my_db_test_src(), dbname = "dbname"))),
    class = "arg_not"
  )
})
