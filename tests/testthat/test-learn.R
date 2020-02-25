test_that("Learning from MSSQL works?", {


  # dm_learn_from_mssql() --------------------------------------------------
  src_mssql <- skip_if_error(src_test("mssql"))

  # create an object on the MSSQL-DB that can be learned
  if (!any(src_tbls(src_mssql) %>%
    grepl("^t1_", .))) {
    copy_dm_to(src_mssql, dm_for_filter, unique_table_names = TRUE, temporary = FALSE)
  }

  dm_for_filter_mssql_learned <- dm_from_src(src_mssql)

  def_learned_renamed_reclassed <-
    dm_rename_tbl(
      dm_for_filter_mssql_learned,
      structure(src_tbls(dm_for_filter_mssql_learned), names = src_tbls(dm_for_filter))
    ) %>%
    dm_get_def() %>%
    select(-data)

  def_original <-
    dm_get_def(dm_for_filter) %>%
    select(-data)

  expect_identical(
    def_learned_renamed_reclassed,
    def_original
  )
})

# dm_learn_from_postgres() --------------------------------------------------
test_that("Learning from Postgres works?", {
  src_postgres <- skip_if_error(src_test("postgres"))
  con_postgres <- src_postgres$con

  # create an object on the Postgres-DB that can be learned
  if (is_postgres_empty()) {
    copy_dm_to(con_postgres, dm_for_filter, unique_table_names = TRUE, temporary = FALSE)
  }

  dm_for_filter_postgres_learned <- dm_from_src(src_postgres)
  dm_for_filter_postges_learned_from_con <- dm_from_src(con_postgres)

  dm_postgres_learned_renamed <-
    dm_rename_tbl(
      dm_for_filter_postgres_learned,
      !!!set_names(src_tbls(dm_for_filter_postgres_learned), src_tbls(dm_for_filter))
    )

  dm_postgres_learned_from_con_renamed <-
    dm_rename_tbl(
      dm_for_filter_postges_learned_from_con,
      !!!set_names(src_tbls(dm_for_filter_postges_learned_from_con), src_tbls(dm_for_filter))
    )

  expect_equivalent_dm(
    dm_postgres_learned_renamed,
    dm_for_filter
  )

  expect_equivalent_dm(
    dm_postgres_learned_from_con_renamed,
    dm_for_filter
  )

  # clean up Postgres-DB
  clear_postgres()
})

test_that("Learning from SQLite works (#288)?", {
  src_sqlite <- skip_if_error(src_sqlite(":memory:", TRUE))

  copy_to(src_sqlite, tibble(a = 1:3), name = "test")

  expect_equivalent_dm(
    dm_from_src(src_sqlite) %>%
      dm_select_tbl(test) %>%
      collect(),
    dm(test = tibble(a = 1:3))
  )
})
