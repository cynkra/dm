test_that("cdm_semi_join() does the right thing?", {
  map2(
    dm_for_filter_src,
    t1_src,
    ~ expect_equal(
      cdm_semi_join(.x, t1, filter(.y, a < 8, a > 3)) %>%
        cdm_get_tables() %>%
        map(collect),
      output_1
    )
  )

  map2(
    dm_for_filter_src,
    t3_src,
    ~ expect_equal(
      cdm_semi_join(.x, t3, filter(.y, g == "five")) %>%
        cdm_get_tables() %>%
        map(collect),
      output_3
    )
  )

  map2(
    dm_for_filter_src,
    t3_src,
    ~ expect_error(
      cdm_semi_join(.x, t3, filter(.y, g == "five") %>% select(f)),
      class = cdm_error("wrong_table_cols_semi_join"),
      error_txt_wrong_table_cols_semi_join("t3"),
      fixed = TRUE
    )
  )
})
