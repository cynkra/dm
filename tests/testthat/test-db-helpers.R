test_that("DB helpers work for MSSQL", {
  skip_if_src_not("mssql")
  con_mssql <- my_test_src()$con
  expect_identical(schema_mssql(con_mssql, "schema"), "schema")
  expect_identical(schema_mssql(con_mssql, NULL), "dbo")
  expect_identical(dbname_mssql(con_mssql, "database_2"), set_names("\"database_2\".", "database_2"))
  expect_identical(dbname_mssql(con_mssql, NULL), set_names("", ""))
})


test_that("DB helpers work for Postgres", {
  skip_if_src_not("postgres")
  con_postgres <- my_test_src()$con
  expect_identical(schema_postgres(con_postgres, "schema"), "schema")
  expect_identical(schema_postgres(con_postgres, NULL), "public")
})
