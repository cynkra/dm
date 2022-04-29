# Only run if the top level call is devtools::test() or testthat::test_check()
if (is_this_a_test()) {
  # trim both the print output of `tbl_df` and `tbl_sql` so they match
  # FIXME: what if a table has more than 10 rows?
  if (rlang::is_installed("dbplyr")) {
    tbl_sum.tbl_sql <- function(x, ...) c()
    s3_register("tibble::tbl_sum", "tbl_sql", tbl_sum.tbl_sql)
    s3_register("pillar::tbl_sum", "tbl_sql", tbl_sum.tbl_sql)
    tbl_format_header.tbl_sql <- function(x, ...) invisible()
    s3_register("pillar::tbl_format_header", "tbl_sql", tbl_format_header.tbl_sql)
  }
  # Not sure why this works without s3_register(), and is also required
  tbl_sum.tbl_df <- function(x, ...) c()
}
