expect_pred_chain <- function(fc, chain) {
  filtered_fc <-
    fc %>%
    filter(node %in% !!chain)

  expect_equal(filtered_fc$node, !!chain)
}
