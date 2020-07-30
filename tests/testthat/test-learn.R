# FIXME: #313: learn only from current source

test_that("Standard learning from MSSQL (schema 'dbo') works?", {


  # dm_learn_from_mssql() --------------------------------------------------
  src_mssql <- skip_if_error(src_test("mssql"))

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

  # create an object on the Postgres-DB that can be learned
  if (is_postgres_empty()) {
    copy_dm_to(con_postgres, dm_for_filter(), temporary = FALSE, table_names = unique_db_table_name)
  }

  dm_for_filter_postgres_learned <- dm_from_src(src_postgres)
  dm_for_filter_postges_learned_from_con <- dm_from_src(con_postgres)

  dm_postgres_learned_renamed <-
    dm_rename_tbl(
      dm_for_filter_postgres_learned,
      !!!set_names(src_tbls(dm_for_filter_postgres_learned), src_tbls(dm_for_filter()))
    )

  dm_postgres_learned_from_con_renamed <-
    dm_rename_tbl(
      dm_for_filter_postges_learned_from_con,
      !!!set_names(src_tbls(dm_for_filter_postges_learned_from_con), src_tbls(dm_for_filter()))
    )

  expect_equivalent_dm(
    dm_postgres_learned_renamed,
    dm_for_filter()
  )

  expect_equivalent_dm(
    dm_postgres_learned_from_con_renamed,
    dm_for_filter()
  )

  # clean up Postgres-DB
  clear_postgres()
})

test_that("Learning from specific schema on Postgres works?", {

  src_postgres <- skip_if_error(src_test("postgres"))
  con_postgres <- src_postgres$con

  # this schema name should be special enough to avoid any conflicts
  DBI::dbExecute(con_postgres, "CREATE SCHEMA testthat_for_dm")

  table_names <- src_tbls(dm_for_disambiguate())
  copy_dm_to(src_postgres, dm_for_disambiguate(), temporary = FALSE, table_names = function(x) {in_schema("testthat_for_dm", x)})

  dm_for_filter_pg_learned <- dm_from_src(src_postgres, schema = "testthat_for_dm")
  DBI::dbExecute(con_postgres, "DROP TABLE \"testthat_for_dm\".iris_3")
  DBI::dbExecute(con_postgres, "DROP TABLE \"testthat_for_dm\".iris_2")
  DBI::dbExecute(con_postgres, "DROP TABLE \"testthat_for_dm\".iris_1")
  DBI::dbExecute(con_postgres, "DROP SCHEMA testthat_for_dm")

  def_learned_reclassed <-
    dm_for_filter_pg_learned %>%
    dm_get_def() %>%
    select(-data)

  def_original <-
    dm_get_def(dm_for_disambiguate()) %>%
    select(-data)

  expect_equivalent_tbl(
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
