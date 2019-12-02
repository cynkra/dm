test_that("cdm_disambiguate_cols() works as intended", {
  withr::local_options(c(lifecycle_verbosity = "quiet"))
  expect_equivalent_dm(
    cdm_disambiguate_cols(dm_for_disambiguate),
    dm_disambiguate_cols(dm_for_disambiguate)
  )
})
