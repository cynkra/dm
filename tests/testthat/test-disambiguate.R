test_that("cdm_disambiguate_cols() works as intended", {
  expect_equivalent_dm(
    cdm_disambiguate_cols(dm_for_disambiguate),
    dm_for_disambiguate_2
  )
})
