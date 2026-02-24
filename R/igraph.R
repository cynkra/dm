# Graph abstraction layer.
# When igraph is installed, graph_* functions use igraph for best performance.
# When igraph is not installed, all graph_* functions are overwritten at load
# time with pure R fallbacks from R/igraph-fallback.R.
# All functions accept and return "dm_graph" objects (or the "dm_igraph" subclass).

rlang::on_load({
  setup_graph_functions(getNamespace("dm"))
})

# dm_igraph: wraps an igraph object; used when igraph is installed.
new_dm_igraph <- function(ig) {
  structure(
    list(igraph = ig),
    class = c("dm_igraph", "dm_graph")
  )
}

print.dm_graph <- function(x, ...) {
  n_v <- length(x$vnames)
  n_e <- length(x$from)
  directed_str <- if (isTRUE(x$directed)) "directed" else "undirected"
  cat(
    sprintf(
      "<dm_graph> %s, %d %s, %d %s\n",
      directed_str,
      n_v,
      if (n_v == 1L) "vertex" else "vertices",
      n_e,
      if (n_e == 1L) "edge" else "edges"
    )
  )
  if (n_v > 0L) {
    cat("Vertices:", paste(x$vnames, collapse = ", "), "\n")
  }
  if (n_e > 0L) {
    edge_strs <- paste(x$vnames[x$from], x$vnames[x$to], sep = "|")
    cat("Edges:", paste(edge_strs, collapse = ", "), "\n")
  }
  invisible(x)
}

# Forward to print.dm_graph by creating a plain dm_graph from igraph data.
print.dm_igraph <- function(x, ...) {
  ig <- x$igraph
  fallback <- new_dm_graph(
    directed = igraph::is_directed(ig),
    vnames = names(igraph::V(ig)),
    from = as.integer(igraph::tail_of(ig, igraph::E(ig))),
    to = as.integer(igraph::head_of(ig, igraph::E(ig)))
  )
  print.dm_graph(fallback, ...)
}

# graph_from_data_frame -------------------------------------------------------

graph_from_data_frame <- function(d, directed, vertices = NULL) {
  ig <- igraph::graph_from_data_frame(d, directed = directed, vertices = vertices)
  new_dm_igraph(ig)
}

# V: vertex accessor -----------------------------------------------------------
# Returns a named integer vector: values are 1-based indices, names are vertex names.

graph_vertices <- function(g) {
  igraph::V(g$igraph)
}

# E: edge accessor -------------------------------------------------------------
# Returns an integer vector with a "vnames" attribute (e.g. "from|to").

graph_edges <- function(g) {
  igraph::E(g$igraph)
}

# dfs -------------------------------------------------------------------------
# Returns a list with $order (named integer), $dist (named numeric), $parent (named integer).

graph_dfs <- function(g, root, unreachable = TRUE, parent = FALSE, dist = FALSE) {
  igraph::dfs(g$igraph, root, unreachable = unreachable, parent = parent, dist = dist)
}

# topo_sort -------------------------------------------------------------------
# Returns a named integer vector (vertex indices with vertex names as names).

graph_topo_sort <- function(g, mode = "out") {
  igraph::topo_sort(g$igraph, mode = mode)
}

# distances -------------------------------------------------------------------
# Returns a matrix: rows = sources, columns = all vertices.

graph_distances <- function(g, v = NULL) {
  igraph::distances(g$igraph, v)
}

# induced_subgraph ------------------------------------------------------------
# Returns a new dm_igraph containing only the specified vertices.

graph_induced_subgraph <- function(g, vids) {
  new_dm_igraph(igraph::induced_subgraph(g$igraph, vids))
}

# shortest_paths --------------------------------------------------------------
# Returns a list with $predecessors.

graph_shortest_paths <- function(g, from, to, predecessors = FALSE) {
  igraph::shortest_paths(g$igraph, from, to, predecessors = predecessors)
}

# delete_vertices -------------------------------------------------------------
# Returns a new dm_igraph with the specified vertices removed.

graph_delete_vertices <- function(g, v) {
  new_dm_igraph(igraph::delete_vertices(g$igraph, v))
}

# neighbors -------------------------------------------------------------------
# Returns the neighbors of vertex v.

graph_neighbors <- function(g, v, mode = "all") {
  igraph::neighbors(g$igraph, v, mode = mode)
}

# vcount ----------------------------------------------------------------------
# Returns the number of vertices in the graph.

graph_vcount <- function(g) {
  igraph::vcount(g$igraph)
}

# girth -----------------------------------------------------------------------
# Returns a list with $circle: vertices forming the shortest cycle.

graph_girth <- function(g) {
  igraph::girth(g$igraph)
}
