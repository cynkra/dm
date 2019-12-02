test_that("cdm_nrow() works?", {
  map(
    cdm_test_obj_src,
    ~ expect_equal(
      sum(cdm_nrow(.x)),
      rows_dm_obj
    )
  )
})
