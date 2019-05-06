context("test-filter-dm")

dm_test_obj_src <-

test_that("cdm_filter() works as intended?", {
  map(.x = cdm_test_obj_filter_src,
      ~ expect_silent(cdm_filter(.x, cdm_table_4, c < 6))
      )
})
