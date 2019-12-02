test_that("cdm_filter() behaves correctly", {
  withr::local_options(c(lifecycle_verbosity = "quiet"))
  expect_identical(
    cdm_filter(dm_for_filter, t1, a > 4) %>% dm_apply_filters_to_tbl(t2),
    dm_filter(dm_for_filter, t1, a > 4) %>% dm_apply_filters_to_tbl(t2)
  )

  expect_identical(
    dm_filter(dm_for_filter, t1, a > 4) %>% cdm_apply_filters_to_tbl(t2),
    dm_filter(dm_for_filter, t1, a > 4) %>% dm_apply_filters_to_tbl(t2)
  )

  expect_equivalent_dm(
    dm_filter(dm_for_filter, t1, a > 4) %>% cdm_apply_filters(),
    dm_filter(dm_for_filter, t1, a > 4) %>% dm_apply_filters()
  )
})
