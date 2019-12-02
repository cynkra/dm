test_that("cdm_add_tbl() works", {
  withr::local_options(c(lifecycle_verbosity = "quiet"))
  expect_identical(
    cdm_add_tbl(dm_for_filter, cars_table = mtcars),
    dm_add_tbl(dm_for_filter, cars_table = mtcars)
  )
})

test_that("cdm_rm_tbl() works", {
  withr::local_options(c(lifecycle_verbosity = "quiet"))
  expect_identical(
    cdm_rm_tbl(dm_for_flatten, starts_with("dim")),
    dm_rm_tbl(dm_for_flatten, starts_with("dim"))
  )
})
