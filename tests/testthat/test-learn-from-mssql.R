test_that("cdm_learn_from_mssql() works?", {
  # create an object on the MSSQL-DB that can be learned
  if (!any(src_tbls(src_mssql) %>%
           str_detect(., "^t1_"))) {
    cdm_copy_to(con_mssql, dm_for_filter, temporary = FALSE)
  }

  dm_for_filter_mssql_learned <- cdm_learn_from_mssql(con_mssql)

  data_model_learned_renamed_reclassed <-
    cdm_rename_tables(
      dm_for_filter_mssql_learned,
      old_table_names = src_tbls(dm_for_filter_mssql_learned),
      new_table_names = src_tbls(dm_for_filter)
    ) %>%
    cdm_get_data_model() %>%
    data_model_db_types_to_R_types()

  data_model_original <-
    cdm_get_data_model(dm_for_filter)

  data_model_original$columns <-
    set_rownames(data_model_original$columns, 1:15) # for some reason the rownames are the column names...

  expect_identical(
    data_model_learned_renamed_reclassed,
    data_model_original
    )
})
