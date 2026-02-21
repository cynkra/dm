# Wrappers for igraph functions used internally.
# When igraph is installed, graphs are stored as objects of class
# c("dm_igraph", "dm_graph") wrapping an igraph object.
# When igraph is not installed, graphs are stored as plain "dm_graph" objects
# using a pure R representation.
#
# All wrapper functions accept and return "dm_graph" objects, abstracting away
# whether igraph is used under the hood.

igraph_available <- function() {
  rlang::is_installed("igraph")
}

rlang::on_load({
  if (!memoise::is.memoized(igraph_available)) {
    igraph_available <<- memoise::memoise(igraph_available)
  }
})

# Minimal graph representation for when igraph is not available.
# A dm_graph has:
#   directed: logical(1)
#   vnames:   character vector of vertex names (in order)
#   from:     integer vector of edge source indices (1-indexed into vnames)
#   to:       integer vector of edge destination indices (1-indexed into vnames)
new_dm_graph <- function(directed, vnames, from, to) {
  structure(
    list(directed = directed, vnames = vnames, from = from, to = to),
    class = "dm_graph"
  )
}

# Wrap an igraph object in the unified dm_graph class hierarchy.
# Only call this when igraph is installed (i.e., inside an `inherits(g, "dm_igraph")`
# guard or immediately after `graph_from_data_frame()` with igraph available).
# Returns an object of class c("dm_igraph", "dm_graph") that mirrors the igraph
# data in $vnames, $from, $to for use by wrapper functions without igraph.
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

print.dm_igraph <- function(x, ...) {
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
  if (igraph_available()) {
    ig <- igraph::graph_from_data_frame(d, directed = directed, vertices = vertices)
    return(new_dm_igraph(ig))
  }

  if (is.null(vertices)) {
    vnames <- unique(c(as.character(d[[1]]), as.character(d[[2]])))
  } else {
    vnames <- as.character(vertices)
  }
  vidx <- set_names(seq_along(vnames), vnames)
  from <- unname(vidx[as.character(d[[1]])])
  to <- unname(vidx[as.character(d[[2]])])
  new_dm_graph(directed = directed, vnames = vnames, from = from, to = to)
}

# V: vertex accessor -----------------------------------------------------------
# Returns a named integer vector: values are 1-based indices, names are vertex names.

graph_vertices <- function(g) {
  if (inherits(g, "dm_igraph")) {
    return(igraph::V(g$igraph))
  }

  set_names(seq_along(g$vnames), g$vnames)
}

# E: edge accessor -------------------------------------------------------------
# Returns an integer vector with a "vnames" attribute (e.g. "from|to").

graph_edges <- function(g) {
  if (inherits(g, "dm_igraph")) {
    return(igraph::E(g$igraph))
  }

  out <- seq_along(g$from)
  attr(out, "vnames") <- paste(g$vnames[g$from], g$vnames[g$to], sep = "|")
  out
}

# dfs -------------------------------------------------------------------------
# Returns a list with $order (named integer), $dist (named numeric), $parent (named integer).

graph_dfs <- function(g, root, unreachable = TRUE, parent = FALSE, dist = FALSE) {
  if (inherits(g, "dm_igraph")) {
    return(igraph::dfs(g$igraph, root, unreachable = unreachable, parent = parent, dist = dist))
  }

  n <- length(g$vnames)
  vidx <- set_names(seq_along(g$vnames), g$vnames)
  root_idx <- vidx[[root]]

  visited <- logical(n)
  visit_order <- integer(0)
  parent_vec <- set_names(rep(NA_integer_, n), g$vnames)
  dist_vec <- set_names(rep(Inf, n), g$vnames)

  dfs_visit <- function(v, d) {
    visited[v] <<- TRUE
    visit_order <<- c(visit_order, v)
    dist_vec[v] <<- d
    nbrs <- if (g$directed) g$to[g$from == v] else unique(c(g$to[g$from == v], g$from[g$to == v]))
    for (nbr in nbrs) {
      if (!visited[nbr]) {
        parent_vec[nbr] <<- v
        dfs_visit(nbr, d + 1)
      }
    }
  }

  dfs_visit(root_idx, 0)

  n_visited <- length(visit_order)
  n_unvisited <- n - n_visited
  order_result <- set_names(
    c(visit_order, rep(NA_integer_, n_unvisited)),
    c(g$vnames[visit_order], rep(NA_character_, n_unvisited))
  )

  result <- list(order = order_result)
  if (dist) {
    result$dist <- dist_vec
  }
  if (parent) {
    result$parent <- parent_vec
  }
  result
}

# topo_sort -------------------------------------------------------------------
# Returns a named integer vector (vertex indices with vertex names as names).
# mode = "out": for edge u→v, u comes before v (children before parents in FK graph).
# mode = "in":  for edge u→v, v comes before u (parents before children in FK graph).

graph_topo_sort <- function(g, mode = "out") {
  if (inherits(g, "dm_igraph")) {
    return(igraph::topo_sort(g$igraph, mode = mode))
  }

  n <- length(g$vnames)
  if (mode == "in") {
    from <- g$to
    to <- g$from
  } else {
    from <- g$from
    to <- g$to
  }

  # Kahn's algorithm for topological sort
  in_degree <- tabulate(to, nbins = n)
  queue <- which(in_degree == 0L)
  result <- integer(0)

  while (length(queue) > 0L) {
    v <- queue[[1L]]
    queue <- queue[-1L]
    result <- c(result, v)
    for (u in to[from == v]) {
      in_degree[[u]] <- in_degree[[u]] - 1L
      if (in_degree[[u]] == 0L) {
        queue <- c(queue, u)
      }
    }
  }

  set_names(result, g$vnames[result])
}

# distances -------------------------------------------------------------------
# Returns a matrix: rows = sources, columns = all vertices.
# graph_distances(g, v)[1, ] gives distances from v to all vertices.

graph_distances <- function(g, v = NULL) {
  if (inherits(g, "dm_igraph")) {
    return(igraph::distances(g$igraph, v))
  }

  n <- length(g$vnames)

  # Build adjacency list (undirected: use both directions)
  adj <- vector("list", n)
  for (i in seq_along(g$from)) {
    adj[[g$from[[i]]]] <- c(adj[[g$from[[i]]]], g$to[[i]])
    adj[[g$to[[i]]]] <- c(adj[[g$to[[i]]]], g$from[[i]])
  }

  bfs_dist <- function(start_idx) {
    d <- rep(Inf, n)
    d[[start_idx]] <- 0
    queue <- start_idx
    while (length(queue) > 0L) {
      curr <- queue[[1L]]
      queue <- queue[-1L]
      for (nbr in adj[[curr]]) {
        if (is.infinite(d[[nbr]])) {
          d[[nbr]] <- d[[curr]] + 1
          queue <- c(queue, nbr)
        }
      }
    }
    d
  }

  vidx <- set_names(seq_along(g$vnames), g$vnames)
  start_indices <- vidx[v]
  dist_mat <- t(vapply(start_indices, bfs_dist, numeric(n)))
  rownames(dist_mat) <- v
  colnames(dist_mat) <- g$vnames
  dist_mat
}

# induced_subgraph ------------------------------------------------------------
# Returns a new graph containing only the specified vertices and edges between them.

graph_induced_subgraph <- function(g, vids) {
  if (inherits(g, "dm_igraph")) {
    sub <- igraph::induced_subgraph(g$igraph, vids)
    return(new_dm_igraph(sub))
  }

  keep_mask <- g$vnames %in% vids
  new_vnames <- g$vnames[keep_mask]
  old_indices <- which(keep_mask)
  # Map old integer indices to new integer indices
  idx_map <- set_names(seq_along(old_indices), as.character(old_indices))
  keep_edges <- g$from %in% old_indices & g$to %in% old_indices
  new_from <- unname(idx_map[as.character(g$from[keep_edges])])
  new_to <- unname(idx_map[as.character(g$to[keep_edges])])
  new_dm_graph(directed = g$directed, vnames = new_vnames, from = new_from, to = new_to)
}

# shortest_paths --------------------------------------------------------------
# Returns a list with $predecessors: a named character/integer sequence giving the
# predecessor of each vertex on the BFS shortest path from `from`.
# names(result$predecessors) are the predecessor vertex names (NA for source vertex).

graph_shortest_paths <- function(g, from, to, predecessors = FALSE) {
  if (inherits(g, "dm_igraph")) {
    return(igraph::shortest_paths(g$igraph, from, to, predecessors = predecessors))
  }

  n <- length(g$vnames)
  vidx <- set_names(seq_along(g$vnames), g$vnames)
  start_idx <- vidx[[from]]

  # Build adjacency list (undirected)
  adj <- vector("list", n)
  for (i in seq_along(g$from)) {
    adj[[g$from[[i]]]] <- c(adj[[g$from[[i]]]], g$to[[i]])
    adj[[g$to[[i]]]] <- c(adj[[g$to[[i]]]], g$from[[i]])
  }

  pred_idx <- set_names(rep(NA_integer_, n), g$vnames)
  visited <- logical(n)
  visited[[start_idx]] <- TRUE
  queue <- start_idx

  while (length(queue) > 0L) {
    curr <- queue[[1L]]
    queue <- queue[-1L]
    for (nbr in adj[[curr]]) {
      if (!visited[[nbr]]) {
        visited[[nbr]] <- TRUE
        pred_idx[[nbr]] <- curr
        queue <- c(queue, nbr)
      }
    }
  }

  result <- list()
  if (predecessors) {
    # predecessors is a named integer vector:
    # - names are the predecessor vertex names (NA for source vertex)
    # - values are the predecessor vertex indices (NA for source vertex)
    pred_names <- ifelse(is.na(pred_idx), NA_character_, g$vnames[pred_idx])
    result$predecessors <- set_names(pred_idx, pred_names)
  }
  result
}

# delete_vertices -------------------------------------------------------------
# Returns a new graph with the specified vertices (and their incident edges) removed.

graph_delete_vertices <- function(g, v) {
  if (inherits(g, "dm_igraph")) {
    sub <- igraph::delete_vertices(g$igraph, v)
    return(new_dm_igraph(sub))
  }

  graph_induced_subgraph(g, setdiff(g$vnames, v))
}

# neighbors -------------------------------------------------------------------
# Returns the neighbors of vertex v (as a named integer vector of vertex indices).
# mode = "in":  vertices with edges pointing TO v
# mode = "out": vertices with edges FROM v
# mode = "all": both

graph_neighbors <- function(g, v, mode = "all") {
  if (inherits(g, "dm_igraph")) {
    return(igraph::neighbors(g$igraph, v, mode = mode))
  }

  v_idx <- if (is.character(v)) {
    set_names(seq_along(g$vnames), g$vnames)[[v]]
  } else {
    as.integer(v)
  }
  incoming <- if (mode %in% c("in", "all")) g$from[g$to == v_idx] else integer(0)
  outgoing <- if (mode %in% c("out", "all")) g$to[g$from == v_idx] else integer(0)
  nbrs <- unique(c(incoming, outgoing))
  set_names(nbrs, g$vnames[nbrs])
}

# vcount ----------------------------------------------------------------------
# Returns the number of vertices in the graph.

graph_vcount <- function(g) {
  if (inherits(g, "dm_igraph")) {
    return(igraph::vcount(g$igraph))
  }

  length(g$vnames)
}

# girth -----------------------------------------------------------------------
# Returns a list with $circle: a named integer vector of vertices forming the shortest cycle.
# names($circle) are vertex names.

graph_girth <- function(g) {
  if (inherits(g, "dm_igraph")) {
    return(igraph::girth(g$igraph))
  }

  n <- length(g$vnames)
  if (n == 0L) {
    return(list(girth = Inf, circle = set_names(integer(0), character(0))))
  }

  # Build adjacency list (directed)
  adj <- vector("list", n)
  for (i in seq_along(g$from)) {
    adj[[g$from[[i]]]] <- c(adj[[g$from[[i]]]], g$to[[i]])
    if (!g$directed) {
      adj[[g$to[[i]]]] <- c(adj[[g$to[[i]]]], g$from[[i]])
    }
  }

  # DFS-based cycle detection
  color <- rep(0L, n) # 0=unvisited, 1=in-progress, 2=done
  pred <- rep(NA_integer_, n)
  cycle <- NULL

  dfs_visit <- function(v) {
    if (!is.null(cycle)) {
      return()
    }
    color[[v]] <<- 1L
    for (u in adj[[v]]) {
      if (!is.null(cycle)) {
        return()
      }
      if (color[[u]] == 1L) {
        # Found a back edge v→u: reconstruct cycle
        path <- v
        curr <- v
        while (curr != u) {
          curr <- pred[[curr]]
          path <- c(path, curr)
        }
        cycle <<- rev(path)
        return()
      } else if (color[[u]] == 0L) {
        pred[[u]] <<- v
        dfs_visit(u)
      }
    }
    color[[v]] <<- 2L
  }

  for (v in seq_len(n)) {
    if (color[[v]] == 0L) {
      dfs_visit(v)
    }
    if (!is.null(cycle)) break
  }

  if (is.null(cycle)) {
    list(girth = Inf, circle = set_names(integer(0), character(0)))
  } else {
    list(girth = length(cycle), circle = set_names(cycle, g$vnames[cycle]))
  }
}
