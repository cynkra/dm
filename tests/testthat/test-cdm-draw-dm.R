test_that("cdm_get_colors() behaves as intended", {
  withr::local_options(c(lifecycle_verbosity = "quiet"))
  expect_equal(
    cdm_get_colors(cdm_nycflights13()),
    dm_get_colors(cdm_nycflights13())
  )
})
