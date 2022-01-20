test_that("dm_nrow() works?", {
  expect_identical(
    as.integer(sum(dm_nrow(dm_test_obj()))),
    rows_dm_obj
  )
})
