# Only run if the top level call is devtools::test()

calls <-
  sys.calls() %>%
  as.list() %>%
  map(as.list) %>%
  map(1) %>%
  map_chr(as_label)

if (any(calls %in% c("devtools::test", "testthat::test_check"))) {
  tbl_sum.tbl_sql <- function(x, ...) c()
  vctrs::s3_register("tibble::tbl_sum", "tbl_sql")
}
