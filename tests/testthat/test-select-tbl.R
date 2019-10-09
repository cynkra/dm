test_that("cdm_select_tbl() selects a part of a larger `dm` as a reduced `dm`?", {
  expect_equivalent_dm(
    cdm_select_tbl(dm_for_filter, t3, t4, t5),
    dm_for_filter_smaller
  )

  expect_equivalent_dm(
    cdm_select_tbl(dm_for_filter, t1, t6),
    new_dm(
      tables = list("t1" = tbl(dm_for_filter, "t1"), "t6" = tbl(dm_for_filter, "t6")),
      data_model = cdm_get_data_model(dm_for_filter) %>%
        rm_table_from_data_model(c("t2", "t3", "t4", "t5"))
    )
  )

  expect_equivalent_dm(
    cdm_select_tbl(dm_for_filter, t1_new = t1, t6_new = t6),
    new_dm(
      tables = list("t1_new" = tbl(dm_for_filter, "t1"), "t6_new" = tbl(dm_for_filter, "t6")),
      data_model = cdm_get_data_model(dm_for_filter) %>%
        rm_table_from_data_model(c("t2", "t3", "t4", "t5")) %>%
        datamodel_rename_table("t1", "t1_new") %>%
        datamodel_rename_table("t6", "t6_new")
    )
  )
})

test_that("cdm_rename_tbl() renames a `dm`", {
  expect_equivalent_dm(
    cdm_rename_tbl(dm_for_filter, c = t3, x = t4, y = t5),
    cdm_select_tbl(dm_for_filter, c = t3, x = t4, y = t5, everything())
  )
})
