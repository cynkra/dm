test_that("cdm_semi_join() does the right thing?", {
  map2(
    dm_for_filter_src,
    t1_src,
    ~ expect_equal(
      cdm_semi_join(.x, t1, filter(.y, a < 8, a > 3)) %>%
        cdm_get_tables() %>%
        map(collect),
      output_1)
    )

  map2(
    dm_for_filter_src,
    t3_src,
    ~ expect_equal(
      cdm_semi_join(.x, t3, filter(.y, g == "five")) %>%
        cdm_get_tables() %>%
        map(collect),
      output_3)
  )

  map2(
    dm_for_filter_src,
    t3_src,
    ~ expect_error(
      cdm_semi_join(.x, t3, filter(.y, g == "five") %>% select(f)),
      class = "dm_error_different_cols")
  ) # FIXME: test of wording of error is still missing, see #21
})
