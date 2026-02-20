# Tests for the pure R graph implementations in R/igraph.R.
# Tests use graph_from_data_frame() to obtain the correct graph type
# (igraph when installed, dm_graph otherwise), so they run correctly
# in both cases.

# Helper: simple directed graph a->b->c, b->d
make_graph_abc <- function(directed = TRUE) {
  graph_from_data_frame(
    tibble::tibble(
      from = c("a", "b", "b"),
      to = c("b", "c", "d")
    ),
    directed = directed,
    vertices = c("a", "b", "c", "d")
  )
}

# Helper: directed cycle a->b->c->a
make_graph_cycle <- function() {
  graph_from_data_frame(
    tibble::tibble(
      from = c("a", "b", "c"),
      to = c("b", "c", "a")
    ),
    directed = TRUE,
    vertices = c("a", "b", "c")
  )
}

# graph_from_data_frame ----------------------------------------------------

test_that("graph_from_data_frame: non-empty data frame builds correct graph", {
  d <- tibble::tibble(from = c("a", "b"), to = c("b", "c"))
  g <- graph_from_data_frame(d, directed = TRUE, vertices = c("a", "b", "c"))
  expect_setequal(names(graph_vertices(g)), c("a", "b", "c"))
  expect_equal(length(graph_edges(g)), 2L)
  expect_setequal(attr(graph_edges(g), "vnames"), c("a|b", "b|c"))
})

test_that("graph_from_data_frame: zero-row data frame builds graph with no edges", {
  d <- tibble::tibble(from = character(0), to = character(0))
  g <- graph_from_data_frame(d, directed = FALSE, vertices = c("x", "y"))
  expect_setequal(names(graph_vertices(g)), c("x", "y"))
  expect_equal(length(graph_edges(g)), 0L)
})

test_that("graph_from_data_frame: NULL vertices derives vertex names from edges", {
  d <- tibble::tibble(from = c("a", "b"), to = c("b", "c"))
  g <- graph_from_data_frame(d, directed = FALSE)
  expect_setequal(names(graph_vertices(g)), c("a", "b", "c"))
  expect_equal(length(graph_edges(g)), 2L)
})

# graph_vertices ------------------------------------------------------------------------

test_that("graph_vertices returns vertices with correct names", {
  g <- make_graph_abc()
  expect_setequal(names(graph_vertices(g)), c("a", "b", "c", "d"))
})

test_that("graph_vertices on graph with no vertices returns empty result", {
  g <- graph_from_data_frame(
    tibble::tibble(from = character(0), to = character(0)),
    directed = FALSE,
    vertices = character(0)
  )
  expect_equal(length(graph_vertices(g)), 0L)
})

# graph_edges ------------------------------------------------------------------------

test_that("graph_edges returns edges with vnames attribute", {
  g <- make_graph_abc()
  e <- graph_edges(g)
  expect_equal(length(e), 3L)
  expect_setequal(attr(e, "vnames"), c("a|b", "b|c", "b|d"))
})

test_that("graph_edges on graph with no edges returns empty result", {
  g <- graph_from_data_frame(
    tibble::tibble(from = character(0), to = character(0)),
    directed = FALSE,
    vertices = c("x")
  )
  expect_equal(length(graph_edges(g)), 0L)
})

# graph_vcount -------------------------------------------------------------------

test_that("graph_vcount returns correct vertex count", {
  expect_equal(graph_vcount(make_graph_abc()), 4L)
})

test_that("graph_vcount returns 0 for empty graph", {
  g <- graph_from_data_frame(
    tibble::tibble(from = character(0), to = character(0)),
    directed = FALSE,
    vertices = character(0)
  )
  expect_equal(graph_vcount(g), 0L)
})

# graph_dfs ----------------------------------------------------------------------

test_that("graph_dfs visits all reachable vertices from root", {
  g <- make_graph_abc()
  dfs <- graph_dfs(g, "a", unreachable = FALSE, dist = TRUE)
  visited <- names(dfs$order)[!is.na(names(dfs$order))]
  expect_setequal(visited, c("a", "b", "c", "d"))
})

test_that("graph_dfs dist=TRUE gives 0 distance for root", {
  g <- make_graph_abc()
  dfs <- graph_dfs(g, "a", unreachable = FALSE, dist = TRUE)
  expect_equal(dfs$dist[["a"]], 0)
  expect_equal(dfs$dist[["b"]], 1)
})

test_that("graph_dfs parent=TRUE gives NA parent for root", {
  g <- make_graph_abc()
  dfs <- graph_dfs(g, "a", unreachable = FALSE, parent = TRUE)
  # parent structure has one entry per vertex; unclass converts to integer for both igraph and dm_graph
  parent_indices <- unclass(dfs$parent)
  a_idx <- which(names(graph_vertices(g)) == "a")
  expect_true(is.na(parent_indices[[a_idx]]))
})

# graph_topo_sort ----------------------------------------------------------------

test_that("graph_topo_sort mode='in' places parent-tables before children", {
  # FK graph: child -> parent
  g <- graph_from_data_frame(
    tibble::tibble(from = c("child"), to = c("parent")),
    directed = TRUE,
    vertices = c("parent", "child")
  )
  topo <- graph_topo_sort(g, mode = "in")
  topo_names <- names(topo)
  expect_lt(which(topo_names == "parent"), which(topo_names == "child"))
})

test_that("graph_topo_sort returns all vertices", {
  g <- make_graph_abc()
  topo <- graph_topo_sort(g, mode = "in")
  expect_setequal(names(topo), c("a", "b", "c", "d"))
})

test_that("graph_topo_sort mode='in' and mode='out' are reversed for linear chain", {
  g <- graph_from_data_frame(
    tibble::tibble(from = c("a", "b"), to = c("b", "c")),
    directed = TRUE,
    vertices = c("a", "b", "c")
  )
  topo_in <- names(graph_topo_sort(g, mode = "in"))
  topo_out <- names(graph_topo_sort(g, mode = "out"))
  expect_equal(topo_in, rev(topo_out))
})

# graph_distances ----------------------------------------------------------------

test_that("graph_distances returns 0 for self-distance", {
  g <- make_graph_abc(directed = FALSE)
  d <- graph_distances(g, "a")
  expect_equal(d[1, "a"], 0)
})

test_that("graph_distances returns 1 for adjacent vertex", {
  g <- make_graph_abc(directed = FALSE)
  d <- graph_distances(g, "a")
  expect_equal(d[1, "b"], 1)
})

test_that("graph_distances returns Inf for disconnected vertex", {
  # a-b connected, c disconnected
  g <- graph_from_data_frame(
    tibble::tibble(from = c("a"), to = c("b")),
    directed = FALSE,
    vertices = c("a", "b", "c")
  )
  d <- graph_distances(g, "a")
  expect_true(is.infinite(d[1, "c"]))
})

# graph_induced_subgraph ---------------------------------------------------------

test_that("graph_induced_subgraph keeps only specified vertices", {
  g <- make_graph_abc()
  sub <- graph_induced_subgraph(g, c("a", "b", "c"))
  expect_setequal(names(graph_vertices(sub)), c("a", "b", "c"))
})

test_that("graph_induced_subgraph removes edges to excluded vertices", {
  g <- make_graph_abc()
  # Keeping a, b, c (not d): edges a->b and b->c remain, b->d is removed
  sub <- graph_induced_subgraph(g, c("a", "b", "c"))
  expect_equal(length(graph_edges(sub)), 2L)
})

# graph_delete_vertices ----------------------------------------------------------

test_that("graph_delete_vertices removes specified vertex", {
  g <- make_graph_abc()
  g2 <- graph_delete_vertices(g, "b")
  expect_false("b" %in% names(graph_vertices(g2)))
})

test_that("graph_delete_vertices removes incident edges", {
  g <- make_graph_abc()
  g2 <- graph_delete_vertices(g, "b")
  # all edges involving b are removed (a->b, b->c, b->d)
  expect_equal(length(graph_edges(g2)), 0L)
})

# graph_neighbors ----------------------------------------------------------------

test_that("graph_neighbors mode='out' gives outgoing neighbors", {
  g <- make_graph_abc()
  nbrs <- graph_neighbors(g, "b", mode = "out")
  expect_setequal(names(nbrs), c("c", "d"))
})

test_that("graph_neighbors mode='in' gives incoming neighbors", {
  g <- make_graph_abc()
  nbrs <- graph_neighbors(g, "b", mode = "in")
  expect_setequal(names(nbrs), c("a"))
})

test_that("graph_neighbors mode='all' gives all neighbors", {
  g <- make_graph_abc()
  nbrs <- graph_neighbors(g, "b", mode = "all")
  expect_setequal(names(nbrs), c("a", "c", "d"))
})

# graph_girth --------------------------------------------------------------------

test_that("graph_girth returns Inf for acyclic graph", {
  g <- make_graph_abc()
  gi <- graph_girth(g)
  expect_true(is.infinite(gi$girth))
  expect_equal(length(gi$circle), 0L)
})

test_that("graph_girth detects directed cycle", {
  g <- make_graph_cycle()
  gi <- graph_girth(g)
  expect_true(is.finite(gi$girth))
  expect_gt(length(gi$circle), 0L)
  expect_true(all(names(gi$circle) %in% c("a", "b", "c")))
})

# graph_shortest_paths -----------------------------------------------------------

test_that("graph_shortest_paths predecessors has one entry per vertex", {
  g <- make_graph_abc(directed = FALSE)
  sp <- graph_shortest_paths(g, "a", names(graph_vertices(g)), predecessors = TRUE)
  # predecessors should have as many entries as the number of vertices
  expect_equal(length(sp$predecessors), graph_vcount(g))
})

test_that("graph_shortest_paths source vertex predecessor is NA", {
  g <- make_graph_abc(directed = FALSE)
  sp <- graph_shortest_paths(g, "a", names(graph_vertices(g)), predecessors = TRUE)
  # source vertex 'a' is the first vertex; its predecessor name should be NA
  a_idx <- which(names(graph_vertices(g)) == "a")
  expect_true(is.na(names(sp$predecessors)[[a_idx]]))
})

test_that("graph_shortest_paths predecessor name of adjacent vertex is source", {
  g <- make_graph_abc(directed = FALSE)
  sp <- graph_shortest_paths(g, "a", names(graph_vertices(g)), predecessors = TRUE)
  # vertex 'b' is adjacent to 'a', so predecessor of 'b' should be 'a'
  b_idx <- which(names(graph_vertices(g)) == "b")
  expect_equal(names(sp$predecessors)[[b_idx]], "a")
})

# Integration tests using dm objects ------------------------------------------

test_that("create_graph_from_dm produces graph with correct vertex count", {
  skip_if_not_installed("nycflights13")
  dm <- dm_nycflights13()
  g <- create_graph_from_dm(dm)
  expect_equal(length(graph_vertices(g)), length(dm))
})

test_that("graph_topo_sort via create_graph_from_dm: parent tables before children", {
  skip_if_not_installed("nycflights13")
  dm <- dm_nycflights13()
  g <- create_graph_from_dm(dm, directed = TRUE)
  topo <- graph_topo_sort(g, mode = "in")
  expect_lt(which(names(topo) == "airlines"), which(names(topo) == "flights"))
})

test_that("dm_filter works correctly with graph wrappers", {
  skip_if_not_installed("nycflights13")
  dm_filtered <- dm_nycflights13() %>%
    dm_filter(airlines = (carrier == "UA"))
  expect_lt(nrow(dm_filtered$airlines), nrow(dm_nycflights13()$airlines))
})

test_that("dm_flatten_to_tbl works correctly with graph wrappers", {
  skip_if_not_installed("nycflights13")
  flat <- dm_nycflights13() %>%
    dm_select_tbl(flights, airlines) %>%
    dm_flatten_to_tbl(.start = flights)
  expect_true(is.data.frame(flat))
  expect_true("name" %in% names(flat))
})

test_that("dm_wrap_tbl works correctly with graph wrappers", {
  skip_if_not_installed("nycflights13")
  wrapped <- dm_nycflights13() %>%
    dm_wrap_tbl(root = airlines)
  expect_equal(length(wrapped), 1L)
})
