

test_that("cdm_nrow() works?", {
  map(cdm_test_obj_src,
      ~ expect_identical(
        cdm_nrow(.x, cdm_table_1),
        rows_t1_w_name)
      )
})

test_that("cdm_nrow() works?", {
  map(cdm_test_obj_src,
      ~ expect_equal(
        cdm_nrow(.x) %>% unname(),
        rows_dm_obj)
  )
})
