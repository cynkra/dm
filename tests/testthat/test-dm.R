test_that("can access tables", {
  expect_identical(tbl(cdm_nycflights13(), "airlines"), nycflights13::airlines)
  expect_cdm_error(
    tbl(cdm_nycflights13(), "x"),
    class = "table_not_in_dm"
  )
})

test_that("can create dm with as_dm()", {
  test_obj_df <- as_dm(cdm_get_tables(cdm_test_obj))

  walk(
    cdm_test_obj_src, ~ expect_equivalent_dm(as_dm(cdm_get_tables(.)), test_obj_df)
  )
})

test_that("creation of empty `dm` works", {
  expect_true(
    is_empty(dm())
  )

  expect_true(
    is_empty(new_dm())
  )
})

test_that("some methods/functions for `zoomed_dm` work", {
  expect_identical(
    colnames(cdm_zoom_to_tbl(dm_for_filter, t1)),
    c("a", "b")
  )

  expect_identical(
    dim(cdm_zoom_to_tbl(dm_for_filter, t1)),
    c(10L, 2L)
  )
})
