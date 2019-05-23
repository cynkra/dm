#' @export
cdm_is_referenced <- function(dm, table_name) {
  data_model <- cdm_get_data_model(dm)
  is_referenced_data_model(data_model, table_name)
}

is_referenced_data_model <- function(data_model, table_name) {
  which_ind <- data_model$references$ref == table_name
  any(which_ind)
}

is_referencing_data_model <- function(data_model, table_name) {
  which_ind <- data_model$references$table == table_name
  any(which_ind)
}

#' @export
cdm_get_referencing_tables <- function(dm, table_name) {
  data_model <- cdm_get_data_model(dm)
  references <- data_model$references
  which_ind <- references$ref == table_name
  as.character(references$table[which_ind])
}

# assumes that the natural order works (fork-less)
# FIXME #16: implement for arbitrary graph of connections
calculate_join_list <- function(dm, table_name) {
  g <- create_graph_from_dm(dm)

  bfs <- igraph::bfs(g, table_name, father = TRUE, rank = TRUE, unreachable = FALSE)

  nodes <- names(igraph::V(g))

  has_father <- !is.na(bfs$father)

  res <-
    tibble(lhs = nodes, rhs = nodes[bfs$father], rank = bfs$rank, has_father) %>%
    filter(has_father) %>%
    arrange(rank)

  subgraph_nodes <- union(res$lhs, res$rhs)
  subgraph <- igraph::induced_subgraph(g, subgraph_nodes)
  if (length(igraph::V(subgraph)) - 1 < length(igraph::E(subgraph))) {
    abort_no_cycles()
  }

  res
}

create_graph_from_dm <- function(dm) {
  tables <- src_tbls(dm)
  ref_tables <- map(tables, ~ cdm_get_referencing_tables(dm, .))

  tibble(tables, ref_tables) %>%
    unnest() %>%
    igraph::graph_from_data_frame(directed = FALSE)

}

are_all_vertices_connected <- function(g, vertex_names) {
  V <- names(igraph::V(g))

  vertex_names[1] %in% V &&
    igraph::bfs(g, vertex_names[1], father = TRUE, rank = TRUE, unreachable = FALSE) %>%
    extract2("order") %>%
    names() %>%
    is_in(vertex_names, .) %>%
    all()
}
