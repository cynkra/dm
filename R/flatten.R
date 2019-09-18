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
cdm_flatten_to_tbl <- function(dm, start, ..., join = left_join) {
  cdm_flatten_to_tbl_impl(dm, start, ..., join = join)
}

cdm_flatten_to_tbl_impl <- function(dm, start, ..., join, join_name = NULL) {

  start <- as_name(ensym(start))
  check_correct_input(dm, start)
  list_of_pts <- as.character(enexprs(...))
  walk(list_of_pts, ~check_correct_input(dm, .))
  # in case ellipsis is empty, user probably wants all possible joins
  if (is_empty(list_of_pts)) list_of_pts <- src_tbls(dm)

  force(join)
  stopifnot(is_function(join))
  # early returns for some of the possible joins would be possible for "perfect" key relations,
  # but since it is possible to have imperfect FK relations, `semi_join` and `anti_join` might
  # produce results, that are of interest, e.g.
  # cdm_flatten_to_tbl(cdm_nycflights13(cycle = TRUE) %>% cdm_rm_fk(flights, origin, airports), flights, airports, join = anti_join)

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
    filter(!is.na(name), name %in% c(start, list_of_pts))

  # in case of `full_join` and `right_join` the filters need to be applied first
  if (join_name %in% c("full_join", "right_join")) {
    dm <- cdm_apply_filters(dm)
    if (join_name == "right_join" && nrow(order_df) > 2) warning(
      paste0("When using `cdm_flatten_to_tbl()` with `right_join()`, the result will generally ",
      "depend on which referred table is joined last.")
    )
  } else {
    # if the filters aren't empty, the disambiguation won't work
    dm <- cdm_reset_all_filters(dm)
  }
  # prepare `dm` by disambiguating columns (on a reduced dm)
  clean_dm <-
    # if we reduce the `dm` to the necessary tables here, since then the renaming
    # will be minimized
    cdm_select_tbl(dm, order_df$name) %>%
    cdm_disambiguate_cols_impl(order_df$name)

  # the column names of start_tbl need to be updated, since taken from `dm` and not `clean_dm`
  renames <- compute_disambiguate_cols_recipe(dm, order_df$name, sep = ".") %>%
    filter(table == !!start) %>% pull() %>% flatten_chr()
  # Only need to compute tbl(dm, start) (relevant filters will be applied) in case of left join
  # and then use the raw tables.
  start_tbl <- tbl(dm, start) %>% rename(
    !!!renames
    )

  # Drop first table in the list of join partners. (We have at least one table, `start`.)
  # (Working with `reduce2()` here and the `.init`-parameter is the first table)
  # in the case of only one table in the `dm` (table "start"), all code below is a no-op
  order_df <- order_df[-1, ]

  # list of join partners
  filtered_tables <- clean_dm %>% cdm_get_tables()
  ordered_table_list <- filtered_tables[order_df$name]
  by <- map2(order_df$pred, order_df$name, ~ get_by(dm, .x, .y))

  # perform the joins according to the list, starting with table `initial_LHS`
  reduce2(ordered_table_list, by, ~ join(..1, ..2, by = ..3), .init = start_tbl)
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
  join_name <- deparse(substitute(join))

  t1_name <- as_string(ensym(table_1))
  t2_name <- as_string(ensym(table_2))

  if (!are_neighbours(dm, t1_name, t2_name)) {
    abort_tables_not_neighbours(t1_name, t2_name)
  }
  start <- child_table(dm, {{ table_1 }}, {{ table_2 }})
  other <- setdiff(c(t1_name, t2_name), start)

  cdm_flatten_to_tbl_impl(dm, !!start, !!other, join = join, join_name = join_name)
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
