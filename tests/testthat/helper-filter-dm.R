expect_pred_chain <- function(fc, chain) {
  filtered_fc <-
    fc %>%
    filter(node %in% !!chain)

  # Beware of https://github.com/r-lib/testthat/issues/929
  expect_equal(filtered_fc$node, !!chain)
}
