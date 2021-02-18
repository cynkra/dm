test_that("schema handling on MSSQL and Postgres works", {
  skip_if_src_not(c("mssql", "postgres"))

  src_db <- my_test_src()
  con_db <- src_db$con
  sql_schema_table_list <- if (is_postgres(src_db)) {
    sql_schema_table_list_postgres
  } else if (is_mssql(src_db)) {
    sql_schema_table_list_mssql
  }

  expect_dm_error(sql_schema_exists(con_db, 1), "parameter_not_correct_class")
  expect_dm_error(sql_schema_exists(con_db, letters[1:2]), "parameter_not_correct_length")
  expect_dm_error(sql_schema_exists(src_db, 1), "parameter_not_correct_class")
  expect_dm_error(sql_schema_exists(src_db, letters[1:2]), "parameter_not_correct_length")

  withr::defer({
      try(dbExecute(con_db, "DROP TABLE test_schema_1"))
      try(dbExecute(con_db, "DROP TABLE 1-dm_schema_TEST.test_schema_2"))
      try(dbExecute(con_db, "DROP SCHEMA 1-dm_schema_TEST"))
  })

  expect_false(sql_schema_exists(con_db, "1-dm_schema_TEST"))
  expect_false(sql_schema_exists(src_db, "1-dm_schema_TEST"))

  # create a table in the default schema
  expect_message(sql_schema_create(con_db, "1-dm_schema_TEST"), "created")
  expect_dm_error(sql_schema_create(con_db, "1-dm_schema_TEST"), "schema_exists")
  expect_true(sql_schema_exists(con_db, "1-dm_schema_TEST"))
  expect_message(sql_schema_drop(con_db, "1-dm_schema_TEST"), "Dropped schema")
  expect_dm_error(sql_schema_drop(con_db, "1-dm_schema_TEST"), "no_schema_exists")
  expect_false(sql_schema_exists(con_db, "1-dm_schema_TEST"))

  expect_message(sql_schema_create(src_db, "1-dm_schema_TEST"), "created")
  expect_true(sql_schema_exists(src_db, "1-dm_schema_TEST"))
  expect_message(sql_schema_drop(src_db, "1-dm_schema_TEST"), "Dropped schema")
  expect_false(sql_schema_exists(src_db, "1-dm_schema_TEST"))

  expect_false("test_schema_1" %in% sql_schema_table_list(con_db)$table_name)
  expect_false("test_schema_1" %in% sql_schema_table_list(src_db)$table_name)


  dbWriteTable(
    con_db,
    DBI::Id(table = "test_schema_1"),
    value = tibble(a = 1:5)
  )

  expect_true("test_schema_1" %in% sql_schema_table_list(con_db)$table_name)
  expect_true("test_schema_1" %in% sql_schema_table_list(src_db)$table_name)

  remote_table_1 <- filter(sql_schema_table_list(src_db), table_name == "test_schema_1") %>%
    pull(remote_name)
  expect_identical(
    tbl(src_db, remote_table_1) %>% collect(),
    tibble(a = 1:5)
  )

  expect_message(sql_schema_create(src_db, "1-dm_schema_TEST"), "created")

  dbWriteTable(
    con_db,
    DBI::Id(schema = "1-dm_schema_TEST", table = "test_schema_2"),
    value = tibble(b = letters[1:5])
  )

  expect_identical(
    sql_schema_table_list(con_db, schema = "1-dm_schema_TEST"),
    tibble(
      table_name = "test_schema_2",
      remote_name = dbplyr::ident_q("\"1-dm_schema_TEST\".\"test_schema_2\"")
    )
  )

  remote_table_2 <- filter(
    sql_schema_table_list(src_db, schema = "1-dm_schema_TEST"),
    table_name == "test_schema_2"
  ) %>%
    pull(remote_name)
  expect_identical(
    tbl(src_db, remote_table_2) %>% collect(),
    tibble(b = letters[1:5])
  )
})

test_that("schema handling on MSSQL works for different DBs", {
  skip_if_src_not("mssql")

  src_db <- my_test_src()
  con_db <- src_db$con

  withr::defer({
    try(DBI::dbExecute(con_db, "DROP DATABASE test_db_for_schema_dm"))
  })

  original_dbname <- attributes(con_db)$info$dbname
  DBI::dbExecute(con_db, "CREATE DATABASE test_db_for_schema_dm")
  expect_false(sql_schema_exists(con_db, schema = "test_schema", dbname = "test_db_for_schema_dm"))

  expect_message(
    sql_schema_create(con_db, schema = "test_schema", dbname = "test_db_for_schema_dm"),
    "on database `test_db_for_schema_dm`"
  )

  expect_dm_error(
    sql_schema_create(con_db, schema = "test_schema", dbname = "test_db_for_schema_dm"),
    "schema_exists"
  )

  expect_message(
    sql_schema_drop(con_db, schema = "test_schema", dbname = "test_db_for_schema_dm"),
    "on database `test_db_for_schema_dm`"
  )

  expect_message(
    sql_schema_create(con_db, schema = "test_schema", dbname = "test_db_for_schema_dm"),
    "on database `test_db_for_schema_dm`"
  )

  expect_true(sql_schema_exists(con_db, schema = "test_schema", dbname = "test_db_for_schema_dm"))

  expect_identical(
    sql_schema_table_list(con_db, schema = "test_schema", dbname = "test_db_for_schema_dm"),
    tibble(
      table_name = character(),
      remote_name = dbplyr::ident_q()
    )
  )

  dbWriteTable(
    con_db,
    DBI::Id(db = "test_db_for_schema_dm", schema = "test_schema", table = "test_1"),
    value = tibble(c = c(5L))
  )

  expect_identical(
    sql_schema_table_list(con_db, schema = "test_schema", dbname = "test_db_for_schema_dm"),
    tibble(
      table_name = "test_1",
      remote_name = dbplyr::ident_q("\"test_db_for_schema_dm\".\"test_schema\".\"test_1\"")
    )
  )
})
