#' Flatten part of a `dm` into a wide table
#'
#' With the `...` left empty, this function joins all the tables of your [`dm`]
#' object together, that can be reached from table `start` in the direction of the foreign
#' key relations (pointing from child table to parent table), using the foreign key relations to
#' determine the parameter `by` for the necessary joins.
#' The result is one table with unique column names.
#' Use the `...` if you want to control which tables should be joined to table `start`.
#'
#' @inheritParams cdm_join_to_tbl
#' @param start Table to start from. From this table all outgoing foreign key relations are
#' considered to establish a processing order for the joins. An interesting choice could be
#' for example a fact table in a star schema.
#' @param ... Unquoted table names to include in addition to `start`. If empty, all tables that can
#' be reached are included.
#' @family flattening functions
#'
#' @details **Case 1**, either no filter conditions are set in the `dm`, or only in a part unconnected to
#' table `start`:
#' The necessary disambiguations of the column names are performed first. Then all
#' involved foreign tables are joined to table `start` successively with the join function given in
#' parameter `join`.
#'
#' **Case 2**, filter conditions are set for at least one table connected to `start`:
#' The result of filtering a `dm` object is necessarily a data model conforming to referential integrity.
#' Consequently, there is no difference between `left_join`, `right_join`, `inner_join` and `full_join`.
#' In this case, `left_join` is being used. Using `semi_join` in `cdm_flatten_to_tbl()` on a filtered `dm`
#' is identical to `tbl(dm, start)`, and `anti_join` is identical to `tbl(dm, start) %>% filter(FALSE)`.
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
  cdm_flatten_to_tbl_impl(dm, start, ..., join = join, join_name = join_name)
}

cdm_flatten_to_tbl_impl <- function(dm, start, ..., join, join_name) {

  check_correct_input(dm, start)
  list_of_pts <- as.character(enexprs(...))
  walk(list_of_pts, ~check_correct_input(dm, .))
  # in case ellipsis is empty, user probably wants all possible joins
  if (is_empty(list_of_pts)) list_of_pts <- src_tbls(dm)

  force(join)
  stopifnot(is_function(join))

  # in case of `semi_join()` and `anti_join()` no renaming necessary
  gotta_rename <- !(join_name %in% c("semi_join", "anti_join"))

  # if filters are set and at least one of them is connected to the table `start`,
  # the user expects referential integrity. This has several implications:
  # 1. left_join(), right_join(), full_join(), inner_join() will produce the same results
  # 2. semi_join() will be equal to `tbl(dm, start)`
  # 3. anti_join() will be equal to `tbl(dm, start) %>% filter(FALSE)`
  any_filter_in_conn_comp <- any(
    map_lgl(pull(cdm_get_filter(dm), table), ~are_tables_connected(dm, start, .x))
    )

  if (any_filter_in_conn_comp) {
    if (join_name == "semi_join") return(tbl(dm, start))
    if (join_name == "anti_join") return(cdm_get_tables(dm)[[start]] %>% filter(1 == 0))
    message("Using default `left_join()`, since filter conditions are set and `join` ",
            "neither `semi_join()` nor `anti_join()`.")
    join <- left_join
  }
  # early returns for some of the possible joins would be possible for "perfect" key relations,
  # but since it is generally possible to have imperfect FK relations, `semi_join` and `anti_join` might
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
    filter(name %in% c(start, list_of_pts))

  # the result for `right_join()` depends on the order of the dim-tables in the `dm`
  # if 2 or more of them are joined to the fact table. If filter conditions are set,
  # and at least one of them is in the same connected component of the graph representation of the `dm`,
  # it does not play a role.
  if (join_name == "right_join" && nrow(order_df) > 2 && !any_filter_in_conn_comp) abort_rj_not_wd()

  # filters need to be empty, for the disambiguation to work
  # the renaming will be minimized, if we reduce the `dm` to the necessary tables here
  red_dm <- cdm_reset_all_filters(dm) %>% cdm_select_tbl(order_df$name)
  if (gotta_rename) {
    recipe <- compute_disambiguate_cols_recipe(red_dm, order_df$name, sep = ".")
    explain_col_rename(recipe)
    # prepare `dm` by disambiguating columns (on a reduced dm)
    clean_dm <-
      col_rename(red_dm, recipe)
    # the column names of start_tbl need to be updated, since taken from `dm` and not `clean_dm`
    renames <- recipe %>% filter(table == !!start) %>% pull() %>% flatten_chr()
  } else { # for `anti_join()` and `semi_join()` no renaming necessary
    clean_dm <- red_dm
    renames <- character(0)
  }

  # Only need to compute `tbl(dm, start)`, `cdm_apply_filters()` not necessary
  # Need to use `dm` and not `clean_dm` here, cause of possible filter conditions.
  start_tbl <- tbl(dm, start) %>% rename(!!!renames)

  # Drop first table in the list of join partners. (We have at least one table, `start`.)
  # (Working with `reduce2()` here and the `.init`-parameter is the first table)
  # in the case of only one table in the `dm` (table "start"), all code below is a no-op
  order_df <- order_df[-1, ]

  # FIXME: so far there is a problem with `semi_join` and `anti_join`, when one of the
  # included tables has a distance of 2 or more to `start`, because then the required
  # column for `by` on the LHS is missing
  if (!gotta_rename && !all(map_lgl(order_df$name, ~{
    cdm_has_fk(clean_dm, !!start, !!.) || cdm_has_fk(clean_dm, !!., !!start)}))) {
    abort_semi_anti_nys()
  }

  # list of join partners
  ordered_table_list <- clean_dm %>% cdm_get_tables() %>% extract(order_df$name)
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

  if (!(cdm_has_fk(dm, {{ t1_name }}, {{ t2_name }}) || cdm_has_fk(dm, {{ t2_name }}, {{ t1_name }}))) {
    abort_tables_not_neighbours(t1_name, t2_name)
  }
  start <- child_table(dm, {{ table_1 }}, {{ table_2 }})
  other <- setdiff(c(t1_name, t2_name), start)

  cdm_flatten_to_tbl_impl(dm, start, !!other, join = join, join_name = join_name)
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
