#' Filtering
#'
#' @description
#' `r lifecycle::badge("stable")`
#'
#' Filtering a table of a [`dm`] object may affect other tables that are connected to it
#' directly or indirectly via foreign key relations.
#'
#' `dm_filter()` can be used to define filter conditions for tables using syntax that is similar to [dplyr::filter()].
#' The filters work across related tables:
#' The resulting `dm` object only contains rows that are related
#' (directly or indirectly) to rows that remain after applying the filters
#' on all tables.
#'
#' @details
#' As of dm 1.0.0, these conditions are no longer stored in the `dm` object,
#' instead they are applied to all tables during the call to `dm_filter()`.
#' Calling `dm_apply_filters()` or `dm_apply_filters_to_tbl()` is no longer necessary.
#'
#' Use [dm_zoom_to()] and [dplyr::filter()] to filter rows without affecting related tables.
#'
#' @inheritParams dm_examine_constraints
#' @param ...
#'   Named logical predicates.
#'   The names correspond to tables in the `dm` object.
#'   The predicates are defined in terms of the variables in the corresponding table,
#'   they are passed on to [dplyr::filter()].
#'
#'   Multiple conditions are combined with `&`.
#'   Only the rows where the condition evaluates
#'   to `TRUE` are kept.
#'
#' @return An updated `dm` object with filters executed across all tables.
#'
#' @examplesIf rlang::is_installed("nycflights13")
#' dm_nyc <- dm_nycflights13()
#' dm_nyc %>%
#'   dm_nrow()
#'
#' dm_nyc_filtered <-
#'   dm_nycflights13() %>%
#'   dm_filter(airports = (name == "John F Kennedy Intl"))
#'
#' dm_nyc_filtered %>%
#'   dm_nrow()
#'
#' # If you want to keep only those rows in the parent tables
#' # whose primary key values appear as foreign key values in
#' # `flights`, you can set a `TRUE` filter in `flights`:
#' dm_nyc %>%
#'   dm_filter(flights = (1 == 1)) %>%
#'   dm_nrow()
#' # note that in this example, the only affected table is
#' # `airports` because the departure airports in `flights` are
#' # only the three New York airports.
#' @export
dm_filter <- function(.dm, ...) {
  dm_filter_api0({{ .dm }}, ..., target = dm_filter_impl0, apply_target = dm_apply_filters_impl)
}

dm_filter_api0 <- function(..., dm = NULL,
                           call = caller_env(), user_env = caller_env(2),
                           target = make_dm_filter_api_call,
                           apply_target = make_dm_apply_filters_call) {

  if (!is.null(dm)) {
    deprecate_soft("1.0.0", "dm_filter(dm = )", "dm_filter(.dm = )", user_env = user_env)
    dm_filter_api1(
      dm, ...,
      call = call, user_env = user_env, target = target, apply_target = apply_target
    )
  } else {
    dm_filter_api1(
      ...,
      call = call, user_env = user_env, target = target, apply_target = apply_target
    )
  }
}

dm_filter_api1 <- function(.dm, ..., table = NULL,
                           call, user_env, target, apply_target) {
  quos <- enquos(...)
  table <- enquo(table)

  if (is_named2(quos)) {
    # New-style API: apply immediately
    out <- reduce2(names(quos), quos, dm_filter_api, .init = .dm, target = target)
    apply_target(out)
  } else {
    # deprecate_soft("1.0.0", "dm_filter(table = )", user_env = user_env,
    #   details = "`dm_filter()` now takes named filter expressions, the names correspond to the tables to be filtered. Call `dm_apply_filters()` to materialize the filters."
    # )

    if (quo_is_null(table)) {
      table_idx <- match("", names2(quos))
      if (is.na(table_idx)) {
        abort_table_missing("table")
      }
      table <- quos[[table_idx]]
      quos <- quos[-table_idx]
    }

    stopifnot(quo_is_symbol(table))

    reduce(quos, dm_filter_api, table = as_name(table), .init = .dm, target = target)
  }
}

dm_filter_api <- function(dm, table, expr, target) {
  target(dm, {{ table }}, {{ expr }})
}

make_dm_filter_api_call <- function(dm, table, expr) {
  call2("%>%", dm, call2("dm_filter_api", table, expr))
}

make_dm_apply_filters_call <- function(dm) {
  call2("%>%", dm, call2("dm_apply_filters"))
}

dm_filter_impl0 <- function(dm, table, expr) {
  check_not_zoomed(dm)
  dm %>%
    dm_zoom_to(!!table) %>%
    dm_filter_impl({{ expr }}, set_filter = TRUE) %>%
    dm_update_zoomed()
}

dm_filter_impl <- function(zoomed_dm, ..., set_filter) {
  # valid table and empty ellipsis provided
  filter_quos <- enquos(...)
  if (is_empty(filter_quos)) {
    return(zoomed_dm)
  }

  tbl <- tbl_zoomed(zoomed_dm)
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
  def$filters[[i]] <- vec_rbind(def$filters[[i]], new_filter(filter_exprs, zoomed))
  new_dm3(def, zoomed = zoomed)
}


#' @rdname deprecated
#' @export
dm_apply_filters <- function(dm) {
  check_not_zoomed(dm)
  dm_apply_filters_impl(dm)
}

dm_apply_filters_impl <- function(dm) {
  def <- dm_get_def(dm)

  def$data <- map(def$table, ~ dm_get_filtered_table(dm, .))

  dm_reset_all_filters(new_dm3(def))
}

#' @rdname deprecated
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


#' Get filter expressions
#'
#' `dm_get_filters()` returns the filter expressions that have been applied to a `dm` object.
#' These filter expressions are not intended for evaluation, only for
#' information.
#'
#' @section Life cycle:
#' This function is marked "questioning" because it feels wrong
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
#' @seealso [dm_filter()], [dm_apply_filters()]
#'
#' @return A tibble with the following columns:
#'   \describe{
#'     \item{`table`}{table that was filtered,}
#'     \item{`filter`}{the filter expression,}
#'     \item{`zoomed`}{logical, does the filter condition relate to the zoomed table.}
#'   }
#'
#' @examplesIf rlang::is_installed("nycflights13") && rlang::is_installed("dbplyr")
#' dm_nycflights13() %>%
#'   dm_get_filters()
#' @noRd
NULL

#' @rdname deprecated
#' @export
dm_get_filters <- function(dm) {
  check_not_zoomed(dm)

  filter_df <-
    dm_get_def(dm) %>%
    select(table, filters) %>%
    unnest_list_of_df("filters")

  # FIXME: Should work better with dplyr 0.9.0
  # if (!("filter_expr" %in% names(filter_df))) {
  #   filter_df$filter_expr <- list()
  # }

  filter_df %>%
    rename(filter = filter_expr) %>%
    mutate(filter = unname(filter))
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

  if (detect_index(def$filters, ~ vec_size(.) > 0) == 0) {
    return()
  }

  fun_name <- as_string(sys.call(-1)[[1]])
  abort_only_possible_wo_filters(fun_name)
}
