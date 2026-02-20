# Extracted from test-igraph.R:204

# setup ------------------------------------------------------------------------
library(testthat)
test_env <- simulate_test_env(package = "dm", path = "..")
attach(test_env, warn.conflicts = FALSE)

# prequel ----------------------------------------------------------------------
make_graph_abc <- function(directed = TRUE) {
  # a -> b -> c, b -> d
  new_dm_graph(
    directed = directed,
    vnames = c("a", "b", "c", "d"),
    from = c(1L, 2L, 2L),
    to = c(2L, 3L, 4L)
  )
}
make_graph_cycle <- function() {
  # a -> b -> c -> a (directed cycle)
  new_dm_graph(
    directed = TRUE,
    vnames = c("a", "b", "c"),
    from = c(1L, 2L, 3L),
    to = c(2L, 3L, 1L)
  )
}
make_graph_empty <- function() {
  new_dm_graph(directed = FALSE, vnames = character(0), from = integer(0), to = integer(0))
}
make_graph_single_node <- function() {
  new_dm_graph(directed = FALSE, vnames = "x", from = integer(0), to = integer(0))
}

# test -------------------------------------------------------------------------
g <- make_graph_abc(directed = FALSE)
sp <- dm_shortest_paths(g, "a", g$vnames, predecessors = TRUE)
pred <- sp$predecessors
expect_true(is.na(pred[["a"]]))
