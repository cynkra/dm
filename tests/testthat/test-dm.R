test_that("can access tables", {
  expect_identical(tbl(cdm_nycflights13(), "airlines"), nycflights13::airlines)
  expect_error(
    tbl(cdm_nycflights13(), "x"),
    class = cdm_error("table_not_in_dm")
  )
})

test_that("can create dm with as_dm()", {
  test_obj_df <- as_dm(cdm_get_tables(cdm_test_obj))

  walk(
    cdm_test_obj_src, ~ expect_equivalent_dm(as_dm(cdm_get_tables(.)), test_obj_df)
  )
})
