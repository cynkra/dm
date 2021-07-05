test_that("dm_disambiguate_cols() works as intended", {
  expect_equivalent_dm(
    expect_message(dm_disambiguate_cols(dm_for_disambiguate())),
    dm_for_disambiguate_2()
  )
})
