#' Cascading filter of a [`dm`] object
#'
#' @description 'cdm_filter()' allows you to set one or more filter conditions for one table
#' of a [`dm`] object. If the [`dm`]'s tables are connected via key constrains, the
#' filtering will affect all other connected tables, leaving only the rows with
#' the corresponding key values.
#'
#' @name cdm_filter
#'
#' @inheritParams cdm_add_pk
#' @param ... Logical predicates defined in terms of the variables in .data.
#' Multiple conditions are combined with &. Only rows where the condition evaluates
#' to TRUE are kept.
#'
#' The arguments in ... are automatically quoted and evaluated in the context of
#' the data frame. They support unquoting and splicing. See vignette("programming")
#' for an introduction to these concepts.
#'
#' @examples
#' library(magrittr)
#' cdm_nycflights13(cycle = FALSE) %>%
#'   cdm_filter(airports, name == "John F Kennedy Intl")
#' @export
cdm_filter <- function(dm, table, ...) {
  table_name <- as_name(enexpr(table))
  check_correct_input(dm, table_name)

  exprs <- enexprs(...)
  if (is_empty(exprs)) {
    return(dm)
  } # valid table and empty ellipsis provided

  set_filter_for_table(dm, table_name, exprs)
}

set_filter_for_table <- function(dm, table_name, exprs) {
  raw_dm <- unclass(dm)
  filter <- raw_dm[["filter"]]
  if (is_null(filter)) {
    raw_dm[["filter"]] <- tibble(table = table_name, filter = exprs)
  } else {
    raw_dm[["filter"]] <-
      bind_rows(filter, tibble(table = table_name, filter = exprs)) %>%
      arrange(table)
  }

  structure(
    raw_dm,
    class = "dm"
  )
}


#' Semi-join a [`dm`] object with one of its reduced tables
#'
#' @description 'cdm_semi_join()' performs a cascading "row reduction" of a [`dm`] object
#' by an inital semi-join of one of its tables with the same, but filtered table. Subsequently, the
#' key constraints are used to compute the remainders of the other tables of the [`dm`] object and
#' a new [`dm`] object is returned.
#'
#' @rdname cdm_filter
#'
#' @inheritParams cdm_add_pk
#' @param reduced_table The table indicated in argument `table`, but in a filtered state (cf, `dplyr::filter()`).
#'
#' @export
cdm_semi_join <- function(dm, table, reduced_table) {
  table_name <- as_name(enexpr(table))
  check_correct_input(dm, table_name)

  filtered_dm <- cdm_update_table(dm, table_name, reduced_table)

  join_list <- calculate_join_list(dm, table_name)
  perform_joins(filtered_dm, join_list)
}

cdm_get_filtered_table <- function(dm, from) {

  filter_exprs <- cdm_get_filter(dm)
  if (is_null(filter_exprs)) return(cdm_get_tables(dm)[[from]])

  # If at least one filter is set, we need to consider potential cascades:
  all_filterered_plus_connected <- get_all_filtered_connected(dm, from) %>%
    left_join(filter_exprs, by = c("node" = "table")) %>%
    nest(-node, -parent, -child, .key = "filter")

  tables <- cdm_get_tables(dm) %>%
    extract(pull(all_filterered_plus_connected, node) %>% unique()) %>%
    enframe(name = "table", value = "tbl")

  all_filterered_plus_connected %>%
    left_join(tables, by = c("node" = "table"))

  browser()
  # FIXME: implement logic of filtering / semi-joining and the final union
}

get_all_filtered_connected <- function(dm, table) {
  filtered_tables <- unique(cdm_get_filter(dm)$table)
  graph <- create_graph_from_dm(dm)

  # Computation of distances and shortest paths uses the same algorithm
  # internally, but s.p. doesn't return distances and distances don't return
  # the predecessor.
  distances <- igraph::distances(graph, table)[1, ]
  finite_distances <- distances[is.finite(distances)]

  # Using only nodes with finite distances (=in the same connected component)
  # as target. This avoids a warning.
  target_tables <- names(finite_distances)
  paths <- igraph::shortest_paths(graph, table, target_tables, predecessors = TRUE)

  # All edges with finite distance as tidy data frame
  all_edges <-
    tibble(
      node = names(V(graph)),
      parent = names(paths$predecessors),
      distance = distances
    ) %>%
    filter(is.finite(distance))

  # Edges of interest, will be grown until source node `table` is reachable
  # from all nodes
  edges <-
    all_edges %>%
    filter(node %in% !!c(filtered_tables, table))

  # Recursive join
  repeat {
    missing <- setdiff(edges$parent, edges$node)
    if (is_empty(missing)) break

    edges <- bind_rows(edges, filter(all_edges, node %in% !!missing))
  }

  # Keeping the sentinel row (node == parent) to simplify further processing
  # and testing
  edges %>%
    arrange(-distance)
}
