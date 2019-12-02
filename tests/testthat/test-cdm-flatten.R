test_that("`cdm_flatten_to_tbl()` and `cdm_join_to_tbl()` work", {
  withr::local_options(c(lifecycle_verbosity = "quiet"))
  expect_identical(
    cdm_flatten_to_tbl(dm_for_flatten, fact),
    dm_flatten_to_tbl(dm_for_flatten, fact)
  )

  expect_identical(
    dm_join_to_tbl(dm_for_flatten, fact, dim_3),
    cdm_join_to_tbl(dm_for_flatten, fact, dim_3)
  )
})
