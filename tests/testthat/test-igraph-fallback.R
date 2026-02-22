# Fallback vs igraph parity tests -----------------------------------------------
# Require igraph to compare results. Build a dm_graph directly to feed fallbacks.

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

make_dm_graph_abc <- function(directed = TRUE) {
  new_dm_graph(
    directed = directed,
    vnames = c("a", "b", "c", "d"),
    from = c(1L, 2L, 2L),
    to = c(2L, 3L, 4L)
  )
}

make_dm_graph_cycle <- function() {
  new_dm_graph(
    directed = TRUE,
    vnames = c("a", "b", "c"),
    from = c(1L, 2L, 3L),
    to = c(2L, 3L, 1L)
  )
}

test_that("fallback graph_vertices matches igraph graph_vertices", {
  skip_if_not_installed("igraph")
  fb <- graph_vertices_fallback(make_dm_graph_abc())
  ig <- graph_vertices(make_graph_abc())
  expect_setequal(names(fb), names(ig))
})

test_that("fallback graph_edges matches igraph graph_edges", {
  skip_if_not_installed("igraph")
  fb <- graph_edges_fallback(make_dm_graph_abc())
  ig <- graph_edges(make_graph_abc())
  expect_equal(length(fb), length(ig))
  expect_setequal(attr(fb, "vnames"), attr(ig, "vnames"))
})

test_that("fallback graph_vcount matches igraph graph_vcount", {
  skip_if_not_installed("igraph")
  expect_equal(
    graph_vcount_fallback(make_dm_graph_abc()),
    graph_vcount(make_graph_abc())
  )
})

test_that("fallback graph_dfs matches igraph graph_dfs: visited vertices", {
  skip_if_not_installed("igraph")
  fb <- graph_dfs_fallback(make_dm_graph_abc(), "a", unreachable = FALSE, dist = TRUE)
  ig <- graph_dfs(make_graph_abc(), "a", unreachable = FALSE, dist = TRUE)
  fb_visited <- names(fb$order)[!is.na(names(fb$order))]
  ig_visited <- names(ig$order)[!is.na(names(ig$order))]
  expect_setequal(fb_visited, ig_visited)
  expect_equal(fb$dist[["a"]], ig$dist[["a"]])
  expect_equal(fb$dist[["b"]], ig$dist[["b"]])
})

test_that("fallback graph_topo_sort matches igraph graph_topo_sort: ordering constraint", {
  skip_if_not_installed("igraph")
  g_fb <- new_dm_graph(
    directed = TRUE,
    vnames = c("parent", "child"),
    from = 2L,
    to = 1L
  )
  g_ig <- graph_from_data_frame(
    tibble::tibble(from = "child", to = "parent"),
    directed = TRUE,
    vertices = c("parent", "child")
  )
  topo_fb <- names(graph_topo_sort_fallback(g_fb, mode = "in"))
  topo_ig <- names(graph_topo_sort(g_ig, mode = "in"))
  expect_lt(which(topo_fb == "parent"), which(topo_fb == "child"))
  expect_lt(which(topo_ig == "parent"), which(topo_ig == "child"))
})

test_that("fallback graph_distances matches igraph graph_distances", {
  skip_if_not_installed("igraph")
  g_fb <- make_dm_graph_abc(directed = FALSE)
  g_ig <- make_graph_abc(directed = FALSE)
  fb <- graph_distances_fallback(g_fb, "a")
  ig <- graph_distances(g_ig, "a")
  expect_equal(fb[1, "a"], ig[1, "a"])
  expect_equal(fb[1, "b"], ig[1, "b"])
})

test_that("fallback graph_induced_subgraph matches igraph: correct vertices and edges", {
  skip_if_not_installed("igraph")
  g_fb <- make_dm_graph_abc()
  g_ig <- make_graph_abc()
  sub_fb <- graph_induced_subgraph_fallback(g_fb, c("a", "b", "c"))
  sub_ig <- graph_induced_subgraph(g_ig, c("a", "b", "c"))
  expect_setequal(names(graph_vertices_fallback(sub_fb)), names(graph_vertices(sub_ig)))
  expect_equal(length(graph_edges_fallback(sub_fb)), length(graph_edges(sub_ig)))
})

test_that("fallback graph_delete_vertices matches igraph: correct vertices remain", {
  skip_if_not_installed("igraph")
  g_fb <- make_dm_graph_abc()
  g_ig <- make_graph_abc()
  r_fb <- graph_delete_vertices_fallback(g_fb, "b")
  r_ig <- graph_delete_vertices(g_ig, "b")
  expect_setequal(names(graph_vertices_fallback(r_fb)), names(graph_vertices(r_ig)))
  expect_equal(length(graph_edges_fallback(r_fb)), length(graph_edges(r_ig)))
})

test_that("fallback graph_neighbors matches igraph: mode='out'", {
  skip_if_not_installed("igraph")
  g_fb <- make_dm_graph_abc()
  g_ig <- make_graph_abc()
  fb <- graph_neighbors_fallback(g_fb, "b", mode = "out")
  ig <- graph_neighbors(g_ig, "b", mode = "out")
  expect_setequal(names(fb), names(ig))
})

test_that("fallback graph_neighbors matches igraph: mode='in'", {
  skip_if_not_installed("igraph")
  g_fb <- make_dm_graph_abc()
  g_ig <- make_graph_abc()
  fb <- graph_neighbors_fallback(g_fb, "b", mode = "in")
  ig <- graph_neighbors(g_ig, "b", mode = "in")
  expect_setequal(names(fb), names(ig))
})

test_that("fallback graph_girth: acyclic graph returns Inf", {
  skip_if_not_installed("igraph")
  fb <- graph_girth_fallback(make_dm_graph_abc())
  ig <- graph_girth(make_graph_abc())
  expect_true(is.infinite(fb$girth))
  expect_true(is.infinite(ig$girth))
  expect_equal(length(fb$circle), length(ig$circle))
})

test_that("fallback graph_girth: cycle detected matches igraph cycle length", {
  skip_if_not_installed("igraph")
  fb <- graph_girth_fallback(make_dm_graph_cycle())
  ig <- graph_girth(make_graph_cycle())
  expect_equal(fb$girth, ig$girth)
  expect_equal(length(fb$circle), length(ig$circle))
})

test_that("fallback graph_shortest_paths: predecessors count matches igraph", {
  skip_if_not_installed("igraph")
  g_fb <- make_dm_graph_abc(directed = FALSE)
  g_ig <- make_graph_abc(directed = FALSE)
  all_v <- c("a", "b", "c", "d")
  fb <- graph_shortest_paths_fallback(g_fb, "a", all_v, predecessors = TRUE)
  ig <- graph_shortest_paths(g_ig, "a", all_v, predecessors = TRUE)
  expect_equal(length(fb$predecessors), length(ig$predecessors))
  # source vertex predecessor is NA in both
  a_idx_fb <- which(names(graph_vertices_fallback(g_fb)) == "a")
  a_idx_ig <- which(names(graph_vertices(g_ig)) == "a")
  expect_true(is.na(names(fb$predecessors)[[a_idx_fb]]))
  expect_true(is.na(names(ig$predecessors)[[a_idx_ig]]))
})
