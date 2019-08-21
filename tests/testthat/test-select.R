

test_that("cdm_select_tbl() selects a part of a larger `dm` as a reduced `dm`?", {
  map2(
    dm_for_filter_src,
    dm_for_filter_smaller_src,
    ~ expect_equal(
      cdm_select_tbl(.x, t3, t4, t5) %>% cdm_get_tables() %>% map(collect),
      cdm_get_tables(.y) %>% map(collect)
    )
  )

  map(
    dm_for_filter_src,
    ~ expect_equal(
      cdm_select_tbl(.x, t1, t6),
      new_dm(
        src = cdm_get_src(.x),
        tables = list("t1" = tbl(.x, "t1"), "t6" = tbl(.x, "t6")),
        data_model = cdm_get_data_model(.x) %>%
          rm_table_from_data_model(c("t2", "t3", "t4", "t5"))
      )
    )
  )

  map(
    dm_for_filter_src,
    ~ expect_equal(
        cdm_select_tbl(.x, t1_new = t1, t6_new = t6),
      new_dm(
        src = cdm_get_src(.x),
        tables = list("t1_new" = tbl(.x, "t1"), "t6_new" = tbl(.x, "t6")),
        data_model = cdm_get_data_model(.x) %>%
          rm_table_from_data_model(c("t2", "t3", "t4", "t5")) %>%
          datamodel_rename_table("t1", "t1_new") %>%
          datamodel_rename_table("t6", "t6_new")
      )
    )
  )
})
