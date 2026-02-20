# Extracted from test-igraph.R:124

# setup ------------------------------------------------------------------------
library(testthat)
test_env <- simulate_test_env(package = "dm", path = "..")
attach(test_env, warn.conflicts = FALSE)

# prequel ----------------------------------------------------------------------
make_graph_abc <- function(directed = TRUE) {
  dm_graph_from_data_frame(
    tibble::tibble(
      from = c("a", "b", "b"),
      to = c("b", "c", "d")
    ),
    directed = directed,
    vertices = c("a", "b", "c", "d")
  )
}
make_graph_cycle <- function() {
  dm_graph_from_data_frame(
    tibble::tibble(
      from = c("a", "b", "c"),
      to = c("b", "c", "a")
    ),
    directed = TRUE,
    vertices = c("a", "b", "c")
  )
}

# test -------------------------------------------------------------------------
g <- make_graph_abc()
dfs <- dm_dfs(g, "a", unreachable = FALSE, parent = TRUE)
a_idx <- which(names(dfs$parent) == "a")
expect_true(is.na(dfs$parent[[a_idx]]))
