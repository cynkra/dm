test_that("can access tables", {
  expect_identical(tbl(cdm_nycflights13(), "airlines"), nycflights13::airlines)
  expect_error(
    tbl(cdm_nycflights13(), "x"),
    class = cdm_error("table_not_in_dm")
  )
})
