test_that("`cdm_flatten_to_tbl()` works", {
  withr::local_options(c(lifecycle_verbosity = "quiet"))
  expect_identical(
    cdm_flatten_to_tbl(dm_for_flatten, fact),
    dm_flatten_to_tbl(dm_for_flatten, fact)
  )
})
