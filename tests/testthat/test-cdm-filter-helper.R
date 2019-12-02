test_that("cdm_nrow() works?", {
  withr::local_options(c(lifecycle_verbosity = "quiet"))
  expect_equal(
    sum(cdm_nrow(cdm_test_obj)),
    rows_dm_obj)
})
