test_that("'cdm_disambiguate()' works as intended", {
  expect_equivalent_dm(
    cdm_disambiguate(dm_for_disambiguate),
    dm_for_disambiguate_2
    )
})
