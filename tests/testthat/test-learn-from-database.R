test_that("Learning from MSSQL works?", {


  # cdm_learn_from_mssql() --------------------------------------------------
  con_mssql <- skip_if_error(src_test("mssql"))

  # create an object on the MSSQL-DB that can be learned
  if (!any(src_tbls(src_mssql) %>%
    str_detect(., "^t1_"))) {
    cdm_copy_to(con_mssql, dm_for_filter, unique_table_names = TRUE, temporary = FALSE)
  }

  dm_for_filter_mssql_learned <- cdm_learn_from_db(con_mssql)

  data_model_mssql_learned_renamed_reclassed <-
    cdm_rename_tbl(
      dm_for_filter_mssql_learned,
      structure(src_tbls(dm_for_filter_mssql_learned), names = src_tbls(dm_for_filter))
    ) %>%
    cdm_get_data_model() %>%
    data_model_db_types_to_R_types()

  data_model_original <-
    cdm_get_data_model(dm_for_filter)

  expect_identical(
    data_model_mssql_learned_renamed_reclassed,
    data_model_original
  )
})

# cdm_learn_from_postgres() --------------------------------------------------
test_that("Learning from Postgres works?", {

  src_postgres <- skip_if_error(src_test("postgres"))
  con_postgres <- src_postgres$con

  # create an object on the Postgres-DB that can be learned
  if (is_postgres_empty()) {
    cdm_copy_to(con_postgres, dm_for_filter, unique_table_names = TRUE, temporary = FALSE)
  }

  dm_for_filter_postgres_learned <- cdm_learn_from_db(con_postgres)

  dm_postgres_learned_renamed <-
    cdm_rename_tbl(
      dm_for_filter_postgres_learned,
      structure(src_tbls(dm_for_filter_postgres_learned), names = src_tbls(dm_for_filter))
    )

  expect_equivalent_dm(
    dm_postgres_learned_renamed,
    dm_for_filter
  )

  # clean up Postgres-DB
  clear_postgres()
})
