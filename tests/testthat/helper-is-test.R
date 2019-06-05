
is_this_a_test <- function() {
# Only run if the top level call is devtools::test() or testthat::test_check()

calls <-
  sys.calls() %>%
  as.list() %>%
  map(as.list) %>%
  map(1) %>%
  map_chr(as_label)

is_test_call <- any(calls %in% c("devtools::test", "testthat::test_check"))

is_testing <- rlang::is_installed("testthat") && testthat::is_testing()

is_test_call || is_testing

}
