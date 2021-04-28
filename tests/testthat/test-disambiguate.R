test_that("dm_disambiguate_cols() works as intended", {
  expect_snapshot({
    dm_for_flatten() %>% dm_disambiguate_cols() %>% dm_paste(options = c("select", "keys"))
  })
})
