expect_pred_chain <- function(fc, chain) {
  # Check that node is unique
  expect_true(identical(fc$node, unique(fc$node)))

  filtered_fc <-
    fc |>
    filter(node %in% !!chain)

  # Beware of https://github.com/r-lib/testthat/issues/929
  expect_equal(filtered_fc$node, !!chain)
}

expect_not_pred <- function(fc, node) {
  # Check that node is missing
  expect_false(any(node %in% fc$node))
}
