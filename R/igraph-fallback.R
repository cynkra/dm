# Pure R fallback implementations of all graph_* wrapper functions.
# These are assigned to the graph_* names in .onLoad() if igraph is not installed.
# Each function takes a dm_graph object (not dm_igraph) and returns a dm_graph.

# dm_graph: minimal pure R graph representation.
# Fields: directed (logical), vnames (character), from (integer), to (integer).
new_dm_graph <- function(directed, vnames, from, to) {
  structure(
    list(directed = directed, vnames = vnames, from = from, to = to),
    class = "dm_graph"
  )
}

graph_from_data_frame_fallback <- function(d, directed, vertices = NULL) {
  if (is.null(vertices)) {
    vnames <- unique(c(as.character(d[[1]]), as.character(d[[2]])))
  } else {
    vnames <- as.character(vertices)
  }
  vidx <- set_names(seq_along(vnames), vnames)
  from <- unname(vidx[as.character(d[[1]])])
  to <- unname(vidx[as.character(d[[2]])])
  # For undirected graphs, normalize so the lower-indexed vertex is always
  # "from" and the higher-indexed is "to", matching igraph's behavior.
  if (!directed) {
    swap <- from > to
    tmp <- from[swap]
    from[swap] <- to[swap]
    to[swap] <- tmp
  }
  new_dm_graph(directed = directed, vnames = vnames, from = from, to = to)
}

# Returns a named integer vector: values are 1-based indices, names are vertex names.
graph_vertices_fallback <- function(g) {
  set_names(seq_along(g$vnames), g$vnames)
}

# Returns an integer vector with a "vnames" attribute (e.g. "from|to").
graph_edges_fallback <- function(g) {
  out <- seq_along(g$from)
  attr(out, "vnames") <- paste(g$vnames[g$from], g$vnames[g$to], sep = "|")
  out
}

# Returns a list with $order (named integer), $dist (named numeric),
# $parent (named integer).
graph_dfs_fallback <- function(g, root, unreachable = TRUE, parent = FALSE, dist = FALSE) {
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

# Returns a named integer vector (vertex indices, vertex names as names).
# mode = "out": for edge u→v, u comes before v.
# mode = "in":  for edge u→v, v comes before u.
graph_topo_sort_fallback <- function(g, mode = "out") {
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

# Returns a matrix: rows = sources, columns = all vertices.
graph_distances_fallback <- function(g, v = NULL) {
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

# Returns a new dm_graph containing only the specified vertices and their edges.
graph_induced_subgraph_fallback <- function(g, vids) {
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

# Returns a list with $predecessors: named integer vector of predecessor vertex indices.
# names(result$predecessors) are the predecessor vertex names (NA for source vertex).
graph_shortest_paths_fallback <- function(g, from, to, predecessors = FALSE) {
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
    pred_names <- ifelse(is.na(pred_idx), NA_character_, g$vnames[pred_idx])
    result$predecessors <- set_names(pred_idx, pred_names)
  }
  result
}

# Returns a new dm_graph with the specified vertices (and incident edges) removed.
graph_delete_vertices_fallback <- function(g, v) {
  graph_induced_subgraph_fallback(g, setdiff(g$vnames, v))
}

# Returns a named integer vector of neighbor vertex indices.
# mode = "in": vertices with edges pointing TO v
# mode = "out": vertices with edges FROM v
# mode = "all": both
graph_neighbors_fallback <- function(g, v, mode = "all") {
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

# Returns the number of vertices in the graph.
graph_vcount_fallback <- function(g) {
  length(g$vnames)
}

# Returns a list with $girth (numeric) and $circle (named integer vector).
graph_girth_fallback <- function(g) {
  n <- length(g$vnames)
  if (n == 0L) {
    return(list(girth = Inf, circle = set_names(integer(0), character(0))))
  }

  # Build adjacency list (always undirected, matching igraph::girth which
  # treats directed graphs as undirected)
  adj <- vector("list", n)
  for (i in seq_along(g$from)) {
    adj[[g$from[[i]]]] <- c(adj[[g$from[[i]]]], g$to[[i]])
    adj[[g$to[[i]]]] <- c(adj[[g$to[[i]]]], g$from[[i]])
  }

  # BFS-based girth algorithm (matches igraph's igraph_girth implementation)
  mincirc <- .Machine$integer.max
  minvertex <- 1L
  t1 <- 0L
  t2 <- 0L
  stoplevel <- n + 1L
  triangle <- FALSE

  for (node in seq_len(n)) {
    if (triangle) break

    level <- integer(n)
    level[[node]] <- 1L
    queue <- node

    while (length(queue) > 0L) {
      actnode <- queue[[1L]]
      queue <- queue[-1L]
      actlevel <- level[[actnode]]

      if (actlevel >= stoplevel) break

      neis <- adj[[actnode]]
      if (is.null(neis)) next

      for (nei in neis) {
        neilevel <- level[[nei]]
        if (neilevel != 0L) {
          if (neilevel == actlevel - 1L) {
            # Parent edge, skip
          } else {
            # Found cycle
            stoplevel <- neilevel
            if (actlevel < mincirc) {
              mincirc <- actlevel + neilevel - 1L
              minvertex <- node
              t1 <- actnode
              t2 <- nei
              if (neilevel == 2L) {
                triangle <- TRUE
              }
            }
            if (neilevel == actlevel) break
          }
        } else {
          queue <- c(queue, nei)
          level[[nei]] <- actlevel + 1L
        }
      }
    }
  }

  if (mincirc >= .Machine$integer.max) {
    return(list(girth = Inf, circle = set_names(integer(0), character(0))))
  }

  # Reconstruct cycle via BFS from minvertex
  circle <- integer(mincirc)
  parent <- integer(n)
  parent[[minvertex]] <- minvertex
  queue <- minvertex

  while (parent[[t1]] == 0L || parent[[t2]] == 0L) {
    actnode <- queue[[1L]]
    queue <- queue[-1L]
    neis <- adj[[actnode]]
    if (!is.null(neis)) {
      for (nei in neis) {
        if (parent[[nei]] == 0L) {
          parent[[nei]] <- actnode
          queue <- c(queue, nei)
        }
      }
    }
  }

  # Trace path from t1 to minvertex
  idx <- 1L
  curr <- t1
  while (curr != minvertex) {
    circle[[idx]] <- curr
    idx <- idx + 1L
    curr <- parent[[curr]]
  }
  circle[[idx]] <- minvertex

  # Trace path from t2 to minvertex (fill from the end)
  idx <- mincirc
  curr <- t2
  while (curr != minvertex) {
    circle[[idx]] <- curr
    idx <- idx - 1L
    curr <- parent[[curr]]
  }

  list(girth = mincirc, circle = set_names(circle, g$vnames[circle]))
}
