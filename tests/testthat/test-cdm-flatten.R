test_that("`cdm_flatten_to_tbl()`, `cdm_join_to_tbl()` and `dm_squash_to_tbl()` work", {
  withr::local_options(c(lifecycle_verbosity = "quiet"))
  expect_identical(
    cdm_flatten_to_tbl(dm_for_flatten, fact),
    dm_flatten_to_tbl(dm_for_flatten, fact)
  )

  expect_identical(
    cdm_join_to_tbl(dm_for_flatten, fact, dim_3),
    dm_join_to_tbl(dm_for_flatten, fact, dim_3)
  )

  expect_identical(
    cdm_squash_to_tbl(dm_more_complex, t5),
    dm_squash_to_tbl(dm_more_complex, t5)
  )

})
