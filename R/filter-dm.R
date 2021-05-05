#' Filtering
#'
#' @description
#' `r lifecycle::badge("questioning")`
#'
#' Filtering a table of a [`dm`] object may affect other tables that are connected to it
#' directly or indirectly via foreign key relations.
#'
#' `dm_filter()` can be used to define filter conditions for tables using syntax that is similar to [dplyr::filter()].
#' These conditions will be stored in the [`dm`], and executed immediately for the tables that they are referring to.
#'
#' With `dm_apply_filters()`, all tables will be updated according to the filter conditions and the foreign key relations.
#'
#' `dm_apply_filters_to_tbl()` retrieves one specific table of the `dm` that is updated according to the filter conditions and the foreign key relations.
#'
#' @details The effect of the stored filter conditions on the tables related to the filtered ones is only evaluated
#' in one of the following scenarios:
#'
#' 1. Calling `dm_apply_filters()` or `compute()` (method for `dm` objects) on a `dm`: each filtered table potentially
#' reduces the rows of all other tables connected to it by foreign key relations (cascading effect), leaving only the rows
#' with corresponding key values.
#' Tables that are not connected to any table with an active filter are left unchanged.
#' This results in a new `dm` class object without any filter conditions.
#'
#' 1. Calling `dm_apply_filters_to_tbl()`: the remaining rows of the requested table are calculated by performing a sequence
#' of semi-joins ([`dplyr::semi_join()`]) starting from each table that has been filtered to the requested table
#' (similar to 1. but only for one table).
#'
#' Several functions of the {dm} package will throw an error if filter conditions exist when they are called.
#'
#' @section Life cycle:
#' These functions are marked "questioning" because it feels wrong
#' to tightly couple filtering with the data model.
#' On the one hand, an overview of active filters is useful
#' when specifying the base data set for an analysis in terms of column selections
#' and row filters.
#' However, these filter condition should be only of informative nature
#' and never affect the results of other operations.
#' We are working on formalizing the semantics of the underlying operations
#' in order to present them in a cleaner interface.
#'
#' Use [dm_zoom_to()] and [dplyr::filter()] to filter rows without registering
#' the filter.
#'
#' @rdname dm_filter
#'
#' @inheritParams dm_add_pk
#' @param ... Logical predicates defined in terms of the variables in `.data`, passed on to [dplyr::filter()].
#'   Multiple conditions are combined with `&` or `,`.
#'   Only the rows where the condition evaluates
#'   to `TRUE` are kept.
#'
#'   The arguments in ... are automatically quoted and evaluated in the context of
#'   the data frame. They support unquoting and splicing.
#'   See `vignette("programming", package = "dplyr")`
#'   for an introduction to these concepts.
#'
#' @return For `dm_filter()`: an updated `dm` object (filter executed for given table, and condition stored).
#'
#' @examplesIf rlang::is_installed("nycflights13")
#' dm_nyc <- dm_nycflights13()
#' dm_nyc_filtered <-
#'   dm_nycflights13() %>%
#'   dm_filter(airports, name == "John F Kennedy Intl")
#'
#' dm_apply_filters_to_tbl(dm_nyc_filtered, flights)
#'
#' dm_nyc_filtered %>%
#'   dm_apply_filters()
#'
#' # If you want to keep only those rows in the parent tables
#' # whose primary key values appear as foreign key values in
#' # `flights`, you can set a `TRUE` filter in `flights`:
#' dm_nyc %>%
#'   dm_filter(flights, 1 == 1) %>%
#'   dm_apply_filters() %>%
#'   dm_nrow()
#' # note that in this example, the only affected table is
#' # `airports` because the departure airports in `flights` are
#' # only the three New York airports.
#' @export
dm_filter <- function(dm, table, ...) {
  check_not_zoomed(dm)
  dm %>%
    dm_zoom_to({{ table }}) %>%
    dm_filter_impl(..., set_filter = TRUE) %>%
    dm_update_zoomed()
}

dm_filter_impl <- function(zoomed_dm, ..., set_filter) {
  # valid table and empty ellipsis provided
  filter_quos <- enquos(...)
  if (is_empty(filter_quos)) {
    return(zoomed_dm)
  }

  tbl <- get_zoomed_tbl(zoomed_dm)
  filtered_tbl <- filter(tbl, ...)

  # attribute filter expression to zoomed table. Needs to be flagged with `zoomed = TRUE`, since
  # in case of `dm_insert_zoomed()` the filter exprs needs to be transferred
  if (set_filter) {
    zoomed_dm <-
      zoomed_dm %>%
      set_filter_for_table(orig_name_zoomed(zoomed_dm), map(filter_quos, quo_get_expr), TRUE)
  }

  replace_zoomed_tbl(zoomed_dm, filtered_tbl)
}

set_filter_for_table <- function(dm, table, filter_exprs, zoomed) {
  def <- dm_get_def(dm)

  i <- which(def$table == table)
  def$filters[[i]] <- vctrs::vec_rbind(def$filters[[i]], new_filter(filter_exprs, zoomed))
  new_dm3(def, zoomed = zoomed)
}


#' @rdname dm_filter
#'
#' @inheritParams dm_add_pk
#'
#' @return For `dm_apply_filters()`: an updated `dm` object (filter effects evaluated for all tables).
#'
#' @examplesIf rlang::is_installed("nycflights13")
#'
#' dm_nyc %>%
#'   dm_filter(planes, engine %in% c("Reciprocating", "4 Cycle")) %>%
#'   compute()
#' @export
dm_apply_filters <- function(dm) {
  check_not_zoomed(dm)
  def <- dm_get_def(dm)

  def$data <- map(def$table, ~ dm_get_filtered_table(dm, .))

  dm_reset_all_filters(new_dm3(def))
}

# FIXME: 'dm_apply_filters()' should get an own doc-page which 'dm_apply_filters_to_tbl()' should share (cf. #145)
#' @rdname dm_filter
#'
#' @inheritParams dm_add_pk
#'
#' @return For `dm_apply_filters_to_tbl()`, a table.
#' @export
dm_apply_filters_to_tbl <- function(dm, table) {
  check_not_zoomed(dm)
  table_name <- dm_tbl_name(dm, {{ table }})

  dm_get_filtered_table(dm, table_name)
}

# calculates the necessary semi-joins from all tables that were filtered to
# the requested table
dm_get_filtered_table <- function(dm, from) {
  filters <- dm_get_filters(dm)
  # Shortcut for speed, not really necessary
  if (nrow(filters) == 0) {
    return(dm_get_tables(dm)[[from]])
  }

  fc <- get_all_filtered_connected(dm, from)

  fc_children <-
    fc %>%
    filter(node != parent) %>%
    select(-distance) %>%
    nest(semi_join = -parent) %>%
    rename(table = parent)

  recipe <-
    fc %>%
    select(table = node) %>%
    left_join(fc_children, by = "table")

  list_of_tables <- dm_get_tables(dm)

  for (i in seq_len(nrow(recipe))) {
    table_name <- recipe$table[i]
    table <- list_of_tables[[table_name]]

    semi_joins <- recipe$semi_join[[i]]
    if (!is_null(semi_joins)) {
      semi_joins <- pull(semi_joins)
      semi_joins_tbls <- list_of_tables[semi_joins]
      table <-
        reduce2(semi_joins_tbls,
          semi_joins,
          ~ semi_join(..1, ..2, by = get_by(dm, table_name, ..3)),
          .init = table
        )
    }
    list_of_tables[[table_name]] <- table
  }
  list_of_tables[[from]]
}

get_all_filtered_connected <- function(dm, table) {
  filtered_tables <- unique(dm_get_filters(dm)$table)
  graph <- create_graph_from_dm(dm)

  # Computation of distances and shortest paths uses the same algorithm
  # internally, but s.p. doesn't return distances and distances don't return
  # the predecessor.
  distances <- igraph::distances(graph, table)[1, ]
  finite_distances <- distances[is.finite(distances)]

  # Using only nodes with finite distances (=in the same connected component)
  # as target. This avoids a warning.
  target_tables <- names(finite_distances)

  if (is_empty(intersect(target_tables, filtered_tables))) {
    return(new_filtered_edges(table))
  }

  # use only subgraph to
  # 1. speed things up
  # 2. make it possible to easily test for a cycle (cycle if: N(E) >= N(V))
  graph <- igraph::induced_subgraph(graph, target_tables)
  if (length(E(graph)) >= length(V(graph))) abort_no_cycles(graph)
  paths <- igraph::shortest_paths(graph, table, target_tables, predecessors = TRUE)

  # All edges with finite distance as tidy data frame
  all_edges <-
    new_filtered_edges(
      node = names(V(graph)),
      parent = names(paths$predecessors),
      # all of `graph`, `paths` and `finite_distances` are based on the same subset of tables,
      # hence the resulting tibble is correct
      distance = finite_distances
    )

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

new_filtered_edges <- function(node, parent = node, distance = 0) {
  tibble(node, parent, distance)
}

check_no_filter <- function(dm) {
  def <-
    dm_get_def(dm)

  if (detect_index(def$filters, ~ vctrs::vec_size(.) > 0) == 0) {
    return()
  }

  fun_name <- as_string(sys.call(-1)[[1]])
  abort_only_possible_wo_filters(fun_name)
}

get_filter_for_table <- function(dm, table_name) {
  dm %>%
    dm_get_def() %>%
    filter(table == table_name) %>%
    pull(filters) %>%
    pluck(1)
}
