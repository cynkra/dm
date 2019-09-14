#' Flatten part of a `dm` into a wide table
#'
#' This function joins all the tables of your [`dm`] object together, that can be reached
#' from table `start` in the direction that the foreign keys are pointing, using the
#' foreign key relations to determine the parameter `by` for the necessary joins.
#' It returns one table with unique columns. Use [cdm_select_tbl()] if necessary to
#' reduce the number of tables before calling this function.
#'
#' @inheritParams cdm_join_to_tbl
#' @param start Table to start from. From this table all outgoing foreign key relations are
#' considered to establish a processing order for the joins. An interesting choice could be
#' for example a fact table in a star schema.
#' @family flattening functions
#'
#' @details Uses [`cdm_apply_filters()`] and [`cdm_disambiguate_cols()`] first, to
#' get a "clean" [`dm`]. Subsequently renames all foreign key columns to the names of
#' the primary key columns they are pointing to. Then the order of the joins is determined
#' and the joins are performed.
#'
#' @return A wide table resulting of consecutively joining all tables together.
#'
#' @examples
#' cdm_nycflights13() %>%
#'   cdm_select_tbl(-weather) %>%
#'   cdm_flatten_to_tbl(flights)
#' @export
cdm_flatten_to_tbl <- function(dm, start, join = left_join) {
  start <- as_name(ensym(start))
  check_correct_input(dm, start)

  force(join)
  stopifnot(is_function(join))

  # need to work with directed graph here, since we only want to go in the direction
  # the foreign key is pointing to
  g <- create_graph_from_dm(dm, directed = TRUE)

  # each next table needs to be accessible from the former table (note: directed relations)
  # we achieve this with a depth-first-search (DFS) with param `unreachable = FALSE`
  dfs <- igraph::dfs(g, start, unreachable = FALSE, father = TRUE)

  # compute all table names
  order_df <-
    tibble(
      name = names(dfs[["order"]]),
      pred = names(V(g))[ unclass(dfs[["father"]])[name] ]
    ) %>%
    filter(!is.na(name))

  # FIXME: Don't need to apply all filters on all tables!
  # Only need to compute tbl(dm, start) and then use the raw tables.

  # prepare `dm` by applying all filters, disambiguate columns, and adapt FK-column names
  # to the respective PK-column names
  clean_dm <-
    cdm_apply_filters(dm) %>%
    cdm_disambiguate_cols_impl(order_df$name)

  # Drop first table in the list of join partners. (We have at least one table, `start`.)
  # (Working with `reduce2()` here and the `.init`-parameter is the first table)
  # in the case of only one table in the `dm` (table "start"), all code below is a no-op
  order_df <- order_df[-1, ]

  # list of join partners
  filtered_tables <- clean_dm %>% cdm_get_tables()
  ordered_table_list <- filtered_tables[order_df$name]
  by <- map2(order_df$pred, order_df$name, ~ get_by(dm, .x, .y))

  # perform the joins according to the list, starting with table `initial_LHS`
  reduce2(ordered_table_list, by, ~ join(..1, ..2, by = ..3), .init = filtered_tables[[start]])
}

#' Perform a join between two tables of a [`dm`]
#'
#' @description A join of desired type is performed between table `table_1` and
#' table `table_2`. The two tables need to be directly connected by a foreign key
#' relation. Since this function is a wrapper around `cdm_flatten_to_tbl()`, the LHS of
#' the join will always be the "child table", the table referencing the other table.
#'
#' @param dm A [`dm`] object
#' @param table_1 One of the tables involved in the join
#' @param table_2 The second table of the join
#' @param join The type of join to be performed, see [dplyr::join()]
#'
#' @return The resulting table of the join.
#'
#' @family flattening functions
#'
#' @export
cdm_join_to_tbl <- function(dm, table_1, table_2, join = left_join) {
  force(join)
  stopifnot(is_function(join))

  red_dm <- cdm_select_tbl(dm, {{ table_1 }}, {{ table_2 }})

  if (!is_dm_connected(red_dm)) {
    abort_tables_not_neighbours(as_string(ensym(table_1)), as_string(ensym(table_2)))
  }
  start <- child_table(dm, {{ table_1 }}, {{ table_2 }})
  cdm_flatten_to_tbl(red_dm, !!start, join = join)
}

child_table <- function(dm, table_1, table_2) {
  t1_name <- as_string(ensym(table_1))
  t2_name <- as_string(ensym(table_2))
  cdm_get_all_fks(dm) %>%
    filter(
      (child_table == t1_name & parent_table == t2_name) |
        (child_table == t2_name & parent_table == t1_name)
    ) %>%
    pull(child_table)
}
