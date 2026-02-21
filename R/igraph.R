# Wrappers for igraph functions used internally.
# Graphs are stored as objects of class c("dm_igraph", "dm_graph") wrapping
# an igraph object.  igraph is assumed to always be available.

# Wrap an igraph object in the unified dm_graph class hierarchy.
new_dm_igraph <- function(ig) {
  structure(
    list(igraph = ig),
    class = c("dm_igraph", "dm_graph")
  )
}

print.dm_graph <- function(x, ...) {
  ig <- x$igraph
  directed <- igraph::is_directed(ig)
  vnames <- names(igraph::V(ig))
  from <- as.integer(igraph::tail_of(ig, igraph::E(ig)))
  to <- as.integer(igraph::head_of(ig, igraph::E(ig)))

  n_v <- length(vnames)
  n_e <- length(from)
  directed_str <- if (directed) "directed" else "undirected"
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
    cat("Vertices:", paste(vnames, collapse = ", "), "\n")
  }
  if (n_e > 0L) {
    edge_strs <- paste(vnames[from], vnames[to], sep = "|")
    cat("Edges:", paste(edge_strs, collapse = ", "), "\n")
  }
  invisible(x)
}

# graph_from_data_frame -------------------------------------------------------

graph_from_data_frame <- function(d, directed, vertices = NULL) {
  ig <- igraph::graph_from_data_frame(d, directed = directed, vertices = vertices)
  new_dm_igraph(ig)
}

# V: vertex accessor -----------------------------------------------------------

graph_vertices <- function(g) {
  igraph::V(g$igraph)
}

# E: edge accessor -------------------------------------------------------------

graph_edges <- function(g) {
  igraph::E(g$igraph)
}

# dfs -------------------------------------------------------------------------

graph_dfs <- function(g, root, unreachable = TRUE, parent = FALSE, dist = FALSE) {
  igraph::dfs(g$igraph, root, unreachable = unreachable, parent = parent, dist = dist)
}

# topo_sort -------------------------------------------------------------------

graph_topo_sort <- function(g, mode = "out") {
  igraph::topo_sort(g$igraph, mode = mode)
}

# distances -------------------------------------------------------------------

graph_distances <- function(g, v = NULL) {
  igraph::distances(g$igraph, v)
}

# induced_subgraph ------------------------------------------------------------

graph_induced_subgraph <- function(g, vids) {
  sub <- igraph::induced_subgraph(g$igraph, vids)
  new_dm_igraph(sub)
}

# shortest_paths --------------------------------------------------------------

graph_shortest_paths <- function(g, from, to, predecessors = FALSE) {
  igraph::shortest_paths(g$igraph, from, to, predecessors = predecessors)
}

# delete_vertices -------------------------------------------------------------

graph_delete_vertices <- function(g, v) {
  sub <- igraph::delete_vertices(g$igraph, v)
  new_dm_igraph(sub)
}

# neighbors -------------------------------------------------------------------

graph_neighbors <- function(g, v, mode = "all") {
  igraph::neighbors(g$igraph, v, mode = mode)
}

# vcount ----------------------------------------------------------------------

graph_vcount <- function(g) {
  igraph::vcount(g$igraph)
}

# girth -----------------------------------------------------------------------

graph_girth <- function(g) {
  igraph::girth(g$igraph)
}
