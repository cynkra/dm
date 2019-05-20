# Only run if the top level call is devtools::test()
if (identical(as.list(sys.calls())[[1]][[1]], quote(devtools::test))) {
  tbl_sum.tbl_sql <- function(x, ...) c()
  vctrs::s3_register("tibble::tbl_sum", "tbl_sql")
}
