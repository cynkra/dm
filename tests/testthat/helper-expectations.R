expect_identical_graph <- function(g1, g2) {
  expect_true(igraph::identical_graphs(g1, g2))
}
