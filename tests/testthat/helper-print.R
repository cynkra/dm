# Only run if testing:
if (testthat::is_testing()) {
  tbl_sum.tbl_sql <- function(x, ...) c()
  vctrs::s3_register("tibble::tbl_sum", "tbl_sql")
}
