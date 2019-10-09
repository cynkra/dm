test_that("cdm_select_tbl() selects a part of a larger `dm` as a reduced `dm`?", {
  dm_for_filter_smaller <-
    new_dm2(
      table = cdm_get_tables(dm_for_filter)[c("t1", "t6")],
      name = c("t1", "t6"),
      segment = NA_character_,
      display = NA_character_,
      base_dm = dm_for_filter %>% cdm_rm_fk(t5, m, t6) %>% cdm_rm_fk(t2, d, t1)
    )

  expect_equivalent_dm(
    cdm_select_tbl(dm_for_filter, -t2, -t3, -t4, -t5),
    dm_for_filter_smaller
  )

  expect_equivalent_dm(
    cdm_select_tbl(dm_for_filter, t1_new = t1, t6_new = t6),
    new_dm(
      tables = list("t1_new" = dm_for_filter$t1, "t6_new" = dm_for_filter$t6),
      data_model = cdm_get_data_model(dm_for_filter_smaller) %>%
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
