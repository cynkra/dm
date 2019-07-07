# Only run if the top level call is devtools::test() or testthat::test_check()
if (is_this_a_test()) {
  tbl_sql <- dbplyr::tbl_sql
  tbl_sum.tbl_sql <- function(x, ...) c()
  vctrs::s3_register("tibble::tbl_sum", "tbl_sql", tbl_sum.tbl_sql)
}
