test_that("dm_nrow() works?", {
  expect_identical(
    as.integer(sum(dm_nrow(dm_test_obj))),
    rows_dm_obj
  )

  # FIXME: maybe always include this test on a DB, despite PR #313?
  expect_identical(
    as.integer(sum(dm_nrow(dm_test_obj_sqlite))),
    rows_dm_obj
  )
})
