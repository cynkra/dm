test_that("dm_nrow() works?", {
  map(
    dm_test_obj_src,
    ~ expect_equal(
      sum(dm_nrow(.x)),
      rows_dm_obj
    )
  )
})
