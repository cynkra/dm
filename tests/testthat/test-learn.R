# FIXME: #313: learn only from current source

test_that("Standard learning from MSSQL (schema 'dbo') works?", {

schema_name <- random_schema()

test_that("Standard learning from MSSQL (schema 'dbo') or Postgres (schema 'public') works?", {

  skip_if_src_not(c("mssql", "postgres"))
  # dm_learn_from_mssql() --------------------------------------------------
  src_db <- my_test_src()

  # create an object on the MSSQL-DB that can be learned
  if (!any(src_tbls(src_mssql) %>%
    grepl("^tf_1_", .))) {
    copy_dm_to(src_mssql, dm_for_filter(), temporary = FALSE, table_names = unique_db_table_name)
  }

  dm_for_filter_mssql_learned_all <- dm_from_src(src_mssql)

  # in case there happen to be other tables in schema "dbo"
  dm_for_filter_mssql_learned <- dm_select_tbl(
    dm_for_filter_mssql_learned_all,
    which(grepl("tf_[1-6]_[0-9]{4}_[0-9_]{5}_[0-9]", names(dm_for_filter_mssql_learned_raw)))
  )

  def_learned_renamed_reclassed <-
    dm_rename_tbl(
      dm_for_filter_mssql_learned,
      structure(src_tbls(dm_for_filter_mssql_learned), names = src_tbls(dm_for_filter()))
    ) %>%
    dm_get_def() %>%
    select(-data)

  def_original <-
    dm_get_def(dm_for_filter()) %>%
    select(-data)

  expect_identical(
    def_learned_renamed_reclassed,
    def_original
  )
})


test_that("Learning from specific schema on MSSQL works?", {

  src_mssql <- skip_if_error(src_test("mssql"))
  con_mssql <- src_mssql$con

  # this schema name should be special enough to avoid any conflicts
  DBI::dbExecute(con_mssql, "CREATE SCHEMA testthat_for_dm")

  table_names <- src_tbls(dm_for_disambiguate())
  copy_dm_to(src_mssql, dm_for_disambiguate(), temporary = FALSE, table_names = function(x) {in_schema("testthat_for_dm", x)})

  dm_for_filter_mssql_learned <- dm_from_src(src_mssql, schema = "testthat_for_dm")
  DBI::dbExecute(con_mssql, "DROP TABLE \"testthat_for_dm\".iris_3")
  DBI::dbExecute(con_mssql, "DROP TABLE \"testthat_for_dm\".iris_2")
  DBI::dbExecute(con_mssql, "DROP TABLE \"testthat_for_dm\".iris_1")
  DBI::dbExecute(con_mssql, "DROP SCHEMA testthat_for_dm")

  def_learned_reclassed <-
    dm_for_filter_mssql_learned %>%
    dm_get_def() %>%
    select(-data)

  def_original <-
    dm_get_def(dm_for_disambiguate()) %>%
    select(-data)

  expect_identical(
    def_learned_reclassed,
    def_original
  )
})


# dm_learn_from_postgres() --------------------------------------------------
test_that("Learning from Postgres works?", {
  src_postgres <- skip_if_error(src_test("postgres"))
  con_postgres <- src_postgres$con

test_that("Learning from specific schema on MSSQL or Postgres works?", {

  skip_if_src_not(c("mssql", "postgres"))
  src_db <- my_test_src()
  con_db <- src_db$con

  schema_name_q <- DBI::dbQuoteIdentifier(con_db, schema_name)

  DBI::dbExecute(con_db, paste0("CREATE SCHEMA ", schema_name_q))

  dm_for_disambiguate_copied <- copy_dm_to(
    src_db,
    dm_for_disambiguate(),
    temporary = FALSE,
    table_names = ~ DBI::SQL(dbplyr::in_schema(schema_name_q, .x))
  )
  order_of_deletion <- c("iris_3", "iris_2", "iris_1")
  remote_tbl_names <- set_names(paste0(schema_name_q, ".", order_of_deletion), order_of_deletion)

  withr::defer(
    {
      walk(
        remote_tbl_names,
        ~ try(dbExecute(con_db, paste0("DROP TABLE ", .x)))
      )
      try(dbExecute(con_db, paste0("DROP SCHEMA ", schema_name_q)))
    }
  )

  dm_db_learned <- dm_from_src(src_db, schema = schema_name) %>%
    dm_select_tbl(!!!order_of_deletion)

  expect_equivalent_dm(
    dm_db_learned,
    dm_for_disambiguate()[order_of_deletion]
  )
})

test_that("Learning from specific schema on Postgres works?", {

  src_postgres <- skip_if_error(src_test("postgres"))
  con_postgres <- src_postgres$con

  # this schema name should be special enough to avoid any conflicts
  DBI::dbExecute(con_postgres, "CREATE SCHEMA testthat_for_dm")

  table_names <- src_tbls(dm_for_disambiguate())
  copy_dm_to(src_postgres, dm_for_disambiguate(), temporary = FALSE, table_names = function(x) {in_schema("testthat_for_dm", x)})

  dm_for_filter_mssql_learned <- dm_from_src(src_postgres, schema = "testthat_for_dm")
  DBI::dbExecute(con_postgres, "DROP TABLE \"testthat_for_dm\".iris_3")
  DBI::dbExecute(con_postgres, "DROP TABLE \"testthat_for_dm\".iris_2")
  DBI::dbExecute(con_postgres, "DROP TABLE \"testthat_for_dm\".iris_1")
  DBI::dbExecute(con_postgres, "DROP SCHEMA testthat_for_dm")

  def_learned_reclassed <-
    dm_for_filter_mssql_learned %>%
    dm_get_def() %>%
    arrange(table) %>%
    select(-data)

  def_original <-
    dm_get_def(dm_for_disambiguate()) %>%
    select(-data)

  expect_identical(
    def_learned_reclassed,
    def_original
  )
})

test_that("Learning from SQLite works (#288)?", {
  skip("FIXME")
  src_sqlite <- skip_if_error(src_sqlite()(":memory:", TRUE))

  copy_to(src_sqlite(), tibble(a = 1:3), name = "test")

  expect_equivalent_dm(
    dm_from_src(src_sqlite()) %>%
      dm_select_tbl(test) %>%
      collect(),
    dm(test = tibble(a = 1:3))
  )
})
