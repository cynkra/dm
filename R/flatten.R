#' Flatten part of a `dm` into a wide table
#'
#' Gather all information of interest in one place in a wide table (on a database-[`dm`] a
#' temporary table will be created).
#' If referential integrity is given among the tables of the data model, the resulting
#' table of this function will contain as many rows as the table `start` does (exceptions are
#' `join = anti_join` (result is empty table with same columns as `start`) and `join = right_join` (
#' number of rows equal to those of the join-partner of `start`)).
#' For more information please refer to `vignette("dm-joining")`.
#'
#' @inheritParams cdm_join_to_tbl
#' @param start Table to start from. From this table all outgoing foreign key relations are
#' considered to establish a processing order for the joins. An interesting choice could be
#' for example a fact table in a star schema.
#' @param ... Unquoted table names to include in addition to `start`. If empty, all tables that can
#' be reached are included.
#' @family flattening functions
#'
#' @details With the `...` left empty, this function joins all the tables of your [`dm`]
#' object together, that can be reached from table `start` in the direction of the foreign
#' key relations (pointing from child table to parent table), using the foreign key relations to
#' determine the parameter `by` for the necessary joins.
#' The result is one table with unique column names.
#' Use the `...` if you want to control which tables should be joined to table `start`.
#'
#' How does filtering affect the result?
#'
#' **Case 1**, either no filter conditions are set in the `dm`, or only in a part unconnected to
#' table `start`:
#' The necessary disambiguations of the column names are performed first. Then all
#' involved foreign tables are joined to table `start` successively with the join function given in
#' parameter `join`.
#'
#' **Case 2**, filter conditions are set for at least one table connected to `start`:
#' The result of filtering a `dm` object is necessarily a data model conforming to referential integrity.
#' Consequently, there is no difference between `left_join`, `right_join`, `inner_join` and `full_join`.
#' In this case, `left_join` is being used. Using `semi_join` in `cdm_flatten_to_tbl()` on a filtered `dm`
#' is identical to `tbl(dm, start)`, and `anti_join` is identical to `tbl(dm, start) %>% filter(1 == 0)`.
#' Disambiguation is performed initially if necessary.
#'
#' Mind, that calling `cdm_flatten_to_tbl()` on an unfiltered `dm` with `join = right_join` would not lead
#' to a well-defined result, if two or more foreign tables are to be joined to `start`. The resulting
#' table would depend on the order the tables are listed in the `dm`. Therefore trying this results
#' in an error.
#'
#' Currently, it is not possible to use `semi_join` or `anti_join` as join-methods in the case of an
#' unfiltered `dm`, when not all involved foreign tables are directly connected to table `start`.
#'
#' @return A wide table resulting of consecutively joining all tables involved to table `start`.
#'
#' @examples
#' cdm_nycflights13() %>%
#'   cdm_select_tbl(-weather) %>%
#'   cdm_flatten_to_tbl(flights)
#' @export
cdm_flatten_to_tbl <- function(dm, start, ..., join = left_join) {
  join_name <- deparse(substitute(join))
  start <- as_string(ensym(start))
  cdm_flatten_to_tbl_impl(dm, start, ..., join = join, join_name = join_name, squash = FALSE)
}


cdm_squash_to_tbl <- function(dm, start, ..., join = left_join) {
  join_name <- deparse(substitute(join))
  if (!(join_name %in% c("left_join", "full_join", "inner_join"))) abort_squash_limited()
  start <- as_string(ensym(start))
  cdm_flatten_to_tbl_impl(dm, start, ..., join = join, join_name = join_name, squash = TRUE)
}


cdm_flatten_to_tbl_impl <- function(dm, start, ..., join, join_name, squash) {

  check_correct_input(dm, start)
  list_of_pts <- as.character(enexprs(...))
  walk(list_of_pts, ~check_correct_input(dm, .))

  force(join)
  stopifnot(is_function(join))

  # in case of `semi_join()` and `anti_join()` no renaming necessary
  gotta_rename <- !(join_name %in% c("semi_join", "anti_join"))

  # early returns for some of the possible joins would be possible for "perfect" key relations,
  # but since it is generally possible to have imperfect FK relations, `semi_join` and `anti_join` might
  # produce results, that are of interest, e.g.
  # cdm_flatten_to_tbl(cdm_nycflights13(cycle = TRUE) %>% cdm_rm_fk(flights, origin, airports), flights, airports, join = anti_join)

  # need to work with directed graph here, since we only want to go in the direction
  # the foreign key is pointing to
  g <- create_graph_from_dm(dm, directed = TRUE)

  # If no tables are given, we use all reachable tables
  auto_detect <- is_empty(list_of_pts)
  if (auto_detect) {
    # `purrr::discard()` in case `list_of_pts` is `NA`
    list_of_pts <- get_names_of_connected(g, start) %>% discard(is.na)
  }
  # We use the induced subgraph right away
  g <- igraph::induced_subgraph(g, c(start, list_of_pts))

  has_filters <- nrow(cdm_get_filter(dm)) > 0
  if (has_filters && join_name %in% c("full_join", "right_join", "nest_join") && length(igraph::V(g)) > 1) {
    abort_apply_filters_first(join_name)
  }

  # each next table needs to be accessible from the former table (note: directed relations)
  # we achieve this with a depth-first-search (DFS) with param `unreachable = FALSE`
  dfs <- igraph::dfs(g, start, unreachable = FALSE, father = TRUE)

  # compute all table names
  order_df <-
    tibble(
      name = names(dfs[["order"]]),
      pred = names(V(g))[ unclass(dfs[["father"]])[name] ]
    )

  # argument checking, or filter and recompute induced subgraph
  # for subsequent check
  if (anyNA(order_df$name)) {
    abort_tables_not_reachable_from_start()
  }

  # Cycles not yet supported
  if (length(V(g)) - 1 != length(E(g))) {
    abort_no_cycles()
  }

  # the result for `right_join()` depends on the order of the dim-tables in the `dm`
  # if 2 or more of them are joined to the fact table and ellipsis is empty.
  if (join_name == "right_join" && auto_detect && nrow(order_df) > 2) warning(
    paste0("Result for `cdm_flatten_to_tbl()` with `right_join()` dependend on order of tables in `dm`, when ",
             "more than 2 tables involved and no explicit order given in `...`."))

  # filters need to be empty, for the disambiguation to work
  # the renaming will be minimized, if we reduce the `dm` to the necessary tables here
  red_dm <- cdm_reset_all_filters(dm) %>% cdm_select_tbl(order_df$name)

  if (gotta_rename) {
    recipe <- compute_disambiguate_cols_recipe(red_dm, order_df$name, sep = ".")
    explain_col_rename(recipe)
    # prepare `dm` by disambiguating columns (on a reduced dm)
    clean_dm <-
      col_rename(red_dm, recipe)
    # the column names of start_tbl need to be updated, since taken from `dm` and not `clean_dm`,
    # therefore we need a named variable containing the new and old names
    renames <- recipe %>% filter(table == !!start) %>% pull() %>% flatten_chr()
  } else { # for `anti_join()` and `semi_join()` no renaming necessary
    clean_dm <- red_dm
    renames <- character(0)
  }

  # Drop first table in the list of join partners. (We have at least one table, `start`.)
  # (Working with `reduce2()` here and the `.init`-parameter is the first table)
  # in the case of only one table in the `dm` (table "start"), all code below is a no-op
  order_df <- order_df[-1, ]
  # the order given in the ellipsis determines the join-list
  if (!auto_detect) {
    pt_names <- order_df$name
    pt_indices <- match(pt_names, list_of_pts)
    order_df <- slice(order_df, pt_indices)
  }

  # If called by `cdm_join_to_tbl()` or `cdm_flatten_to_tbl()`, the parameter `squash = FALSE`.
  # Then only one level of hierarchy is allowed (direct neighbours to table `start`).
  if (!squash && !all(map_lgl(order_df$name, ~{
    cdm_has_fk(clean_dm, !!start, !!.) || cdm_has_fk(clean_dm, !!., !!start)}))) {
    abort_only_parents()
  }

  # Only need to compute `tbl(dm, start)`, `cdm_apply_filters()` not necessary
  # Need to use `dm` and not `clean_dm` here, cause of possible filter conditions.
  start_tbl <- tbl(dm, start) %>% rename(!!!renames)

  # list of join partners
  ordered_table_list <- clean_dm %>% cdm_get_tables() %>% extract(order_df$name)
  by <- map2(order_df$pred, order_df$name, ~ get_by(clean_dm, .x, .y))

  # perform the joins according to the list, starting with table `initial_LHS`
  reduce2(ordered_table_list, by, ~ join(..1, ..2, by = ..3), .init = start_tbl)
}

#' Perform a join between two tables of a [`dm`]
#'
#' @description A join of desired type is performed between table `table_1` and
#' table `table_2`. The two tables need to be directly connected by a foreign key
#' relation. Since this function is a wrapper around [cdm_flatten_to_tbl()], the LHS of
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

  rel <- parent_child_table(dm, {{ table_1 }}, {{ table_2 }})
  start <- rel$child_table
  other <- rel$parent_table

  cdm_flatten_to_tbl_impl(dm, start, !!other, join = join, join_name = join_name, squash = FALSE)
}

parent_child_table <- function(dm, table_1, table_2) {
  t1_name <- as_string(ensym(table_1))
  t2_name <- as_string(ensym(table_2))

  rel <-
    cdm_get_all_fks(dm) %>%
    filter(
      (child_table == t1_name & parent_table == t2_name) |
        (child_table == t2_name & parent_table == t1_name)
    )

  if (nrow(rel) == 0) {
    abort_tables_not_neighbours(t1_name, t2_name)
  }

  if (nrow(rel) > 1) {
    abort_no_cycles()
  }

  rel
}
