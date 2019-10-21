#' Is a [`dm`]'s table referenced by another table?
#'
#' @inheritParams cdm_add_pk
#'
#' @return `TRUE`, if at least one foreign key exists, pointing to the primary
#' key of parameter `table`, `FALSE` otherwise.
#'
#' @family functions utilizing foreign key relations
#'
#' @export
cdm_is_referenced <- function(dm, table) {
  has_length(cdm_get_referencing_tables(dm, table))
}

is_referenced_data_model <- function(data_model, table_name) {
  which_ind <- data_model$references$ref == table_name
  any(which_ind)
}

#' Get the names of a [`dm`]'s tables referencing a given table.
#'
#' @inheritParams cdm_is_referenced
#'
#' @return Character vector of the names of the tables pointing to the primary
#' key of parameter `table`.
#'
#' @family functions utilizing foreign key relations
#'
#' @export
cdm_get_referencing_tables <- function(dm, table) {
  table <- as_name(ensym(table))
  check_correct_input(dm, table_name)

  def <- cdm_get_def()
  i <- which(def$table == table)
  def$fks[[i]]$table
}

calculate_join_list <- function(dm, table_name) {
  g <- create_graph_from_dm(dm)

  if (!table_name %in% names(V(g))) {
    return(tibble(
      lhs = character(), rhs = character(), rank = integer(), has_father = logical()
    ))
  }

  bfs <- igraph::bfs(g, table_name, father = TRUE, rank = TRUE, unreachable = FALSE)

  nodes <- names(V(g))

  has_father <- !is.na(bfs$father)

  res <-
    tibble(lhs = nodes, rhs = nodes[bfs$father], rank = bfs$rank, has_father) %>%
    filter(has_father) %>%
    arrange(rank)

  subgraph_nodes <- union(res$lhs, res$rhs)
  subgraph <- igraph::induced_subgraph(g, subgraph_nodes)
  if (length(V(subgraph)) - 1 < length(E(subgraph))) {
    abort_no_cycles()
  }

  res
}

create_graph_from_dm <- function(dm, directed = FALSE) {
  def <- cdm_get_def(dm)
  def %>%
    select(ref_table = table, fks) %>%
    unnest(fks) %>%
    select(table, ref_table) %>%
    igraph::graph_from_data_frame(directed = directed, vertices = def$table)
}

get_names_of_connected <- function(g, start, squash) {
  dfs <- igraph::dfs(g, start, unreachable = FALSE, dist = TRUE)
  # `purrr::discard()` in case `list_of_pts` is `NA`
  if (squash) {
    setdiff(names(dfs[["order"]]), start) %>% discard(is.na)
  } else {
    # FIXME: Enumerate outgoing edges
    setdiff(names(dfs[["order"]]), c(start, names(dfs$dist[dfs$dist > 1]))) %>% discard(is.na)
  }
}
