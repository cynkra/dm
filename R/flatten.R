#' Flatten a part of a `dm` into a wide table
#'
#' `dm_flatten_to_tbl()` and `dm_squash_to_tbl()` gather all information of interest in one place in a wide table.
#' Both functions perform a disambiguation of column names and a cascade of joins.
#'
#' @inheritParams dm_join_to_tbl
#' @param start The table from which all outgoing foreign key relations are considered
#'   when establishing a processing order for the joins.
#'   An interesting choice could be
#'   for example a fact table in a star schema.
#' @param ...
#'   `r lifecycle::badge("experimental")`
#'
#'   Unquoted names of the tables to be included in addition to the `start` table.
#'   The order of the tables here determines the order of the joins.
#'   If the argument is empty, all tables that can be reached will be included.
#'   Only `dm_squash_to_tbl()` allows using tables that are not direct neighbors of `start`.
#'   `tidyselect` is supported, see [dplyr::select()] for details on the semantics.
#' @family flattening functions
#'
#' @details
#' With `...` left empty, this function will join together all the tables of your [`dm`]
#' object that can be reached from the `start` table, in the direction of the foreign key relations
#' (pointing from the child tables to the parent tables), using the foreign key relations to
#' determine the argument `by` for the necessary joins.
#' The result is one table with unique column names.
#' Use the `...` argument if you would like to control which tables should be joined to the `start` table.
#'
#' How does filtering affect the result?
#'
#' **Case 1**, either no filter conditions are set in the `dm`, or set only in the part that is unconnected to the `start` table:
#' The necessary disambiguations of the column names are performed first.
#' Then all involved foreign tables are joined to the `start` table successively, with the join function given in the `join` argument.
#'
#' **Case 2**, filter conditions are set for at least one table that is connected to `start`:
#' First, disambiguation will be performed if necessary. The `start` table is then calculated using `dm[[start]]`.
#' This implies
#' that the effect of the filters on this table is taken into account.
#' For `right_join`, `full_join` and `nest_join`, an error
#' is thrown if any filters are set because filters will not affect the right hand side tables and the result will therefore be
#' incorrect in general (calculating the effects on all RHS-tables would also be time-consuming, and is not supported;
#' if desired, call `dm_apply_filters()` first to achieve that effect).
#' For all other join types, filtering only the `start` table is enough because the effect is passed on by
#' successive joins.
#'
#' Mind that calling `dm_flatten_to_tbl()` with `join = right_join` and no table order determined in the `...` argument
#' will not lead to a well-defined result if two or more foreign tables are to be joined to `start`.
#' The resulting
#' table would depend on the order the tables that are listed in the `dm`.
#' Therefore, trying this will result in a warning.
#'
#' Since `join = nest_join()` does not make sense in this direction (LHS = child table, RHS = parent table: for valid key constraints
#' each nested column entry would be a tibble of one row), an error will be thrown if this method is chosen.
#'
#' The difference between `dm_flatten_to_tbl()` and `dm_squash_to_tbl()` is
#' the following (see the examples):
#'
#' - `dm_flatten_to_tbl()` allows only one level of hierarchy
#'   (i.e., direct neighbors to table `start`), while
#'
#' - `dm_squash_to_tbl()` will go through all levels of hierarchy while joining.
#'
#' Additionally, these functions differ from `dm_wrap_tbl()`, which always
#' returns a `dm` object.
#'
#' @return A single table that results from consecutively joining all affected tables to the `start` table.
#'
#' @examples
#'
#' dm_financial() %>%
#'   dm_select_tbl(-loans) %>%
#'   dm_flatten_to_tbl(start = cards)
#'
#' dm_financial() %>%
#'   dm_select_tbl(-loans) %>%
#'   dm_squash_to_tbl(start = cards)
#'
#' @export
dm_flatten_to_tbl <- function(dm, start, ..., join = left_join) {
  check_not_zoomed(dm)
  join_name <- as_label(enexpr(join))
  start <- dm_tbl_name(dm, {{ start }})
  dm_flatten_to_tbl_impl(dm, start, ..., join = join, join_name = join_name, squash = FALSE)
}

#' @rdname dm_flatten_to_tbl
#' @export
dm_squash_to_tbl <- function(dm, start, ..., join = left_join) {
  check_not_zoomed(dm)
  join_name <- as_label(enexpr(join))
  if (!(join_name %in% c("left_join", "full_join", "inner_join"))) abort_squash_limited()
  start <- dm_tbl_name(dm, {{ start }})
  dm_flatten_to_tbl_impl(dm, start, ..., join = join, join_name = join_name, squash = TRUE)
}


dm_flatten_to_tbl_impl <- function(dm, start, ..., join, join_name, squash) {
  vars <- setdiff(src_tbls_impl(dm), start)
  list_of_pts <- eval_select_table(quo(c(...)), vars)

  if (join_name == "nest_join") abort_no_flatten_with_nest_join()

  force(join)
  stopifnot(is_function(join))

  # in case of `semi_join()` and `anti_join()` no renaming necessary
  gotta_rename <- !(join_name %in% c("semi_join", "anti_join"))

  # early returns for some of the possible joins would be possible for "perfect" key relations,
  # but since it is generally possible to have imperfect FK relations, `semi_join` and `anti_join` might
  # produce results, that are of interest, e.g.
  # dm_flatten_to_tbl(dm_nycflights13(cycle = TRUE) %>% dm_rm_fk(flights, origin, airports), flights, airports, join = anti_join)

  # need to work with directed graph here, since we only want to go in the direction
  # the foreign key is pointing to
  g <- create_graph_from_dm(dm, directed = TRUE)

  # If no tables are given, we use all reachable tables
  auto_detect <- is_empty(list_of_pts)
  if (auto_detect) {
    list_of_pts <- get_names_of_connected(g, start, squash)
  }
  # We use the induced subgraph right away
  g <- igraph::induced_subgraph(g, c(start, list_of_pts))

  # each next table needs to be accessible from the former table (note: directed relations)
  # we achieve this with a depth-first-search (DFS) with param `unreachable = FALSE`
  dfs <- igraph::dfs(g, start, unreachable = FALSE, father = TRUE, dist = TRUE)

  # compute all table names
  order_df <-
    tibble(
      name = names(dfs[["order"]]),
      pred = names(V(g))[unclass(dfs[["father"]])[name]]
    )

  # function to detect any reason for abort()
  check_flatten_to_tbl(
    join_name,
    (nrow(dm_get_filters_impl(dm)) > 0) && !is_empty(list_of_pts),
    anyNA(order_df$name),
    g,
    auto_detect,
    nrow(order_df) > 2,
    any(dfs$dist > 1),
    squash
  )

  # rename dm and replace table `start` by its filtered, renamed version
  prep_dm <- prepare_dm_for_flatten(dm, order_df$name, gotta_rename)

  # Drop the first table in the list of join partners. (We have at least one table, `start`.)
  # (Working with `reduce2()` here and the `.init`-argument is the first table)
  # in the case of only one table in the `dm` (table "start"), all code below is a no-op
  order_df <- order_df[-1, ]
  # the order given in the ellipsis determines the join-list; if empty ellipsis, this is a no-op.
  # `unname()` to avoid warning (tibble version ‘2.99.99.9012’ retains names in column vectors)
  order_df <- left_join(tibble(name = unname(list_of_pts)), order_df, by = "name")

  # list of join partners
  ordered_table_list <-
    prep_dm %>%
    dm_get_tables() %>%
    extract(order_df$name)
  by <- map2(order_df$pred, order_df$name, ~ get_by(prep_dm, .x, .y))

  # perform the joins according to the list, starting with table `initial_LHS`
  reduce2(ordered_table_list, by, ~ join(..1, ..2, by = ..3), .init = tbl_impl(prep_dm, start))
}

#' Join two tables
#'
#' `dm_join_to_tbl()` is deprecated in favor of [dm_flatten_to_tbl()].
#'
#' @param dm A [`dm`] object.
#' @param table_1 One of the tables involved in the join.
#' @param table_2 The second table of the join.
#' @param join The type of join to be performed, see [dplyr::join()].
#'
#' @rdname deprecated
#' @export
dm_join_to_tbl <- function(dm, table_1, table_2, join = left_join) {
  deprecate_soft("0.3.0", "dm::dm_join_to_tbl()", "dm::dm_flatten_to_tbl()")

  check_not_zoomed(dm)
  force(join)
  stopifnot(is_function(join))
  join_name <- deparse(substitute(join))

  t1_name <- dm_tbl_name(dm, {{ table_1 }})
  t2_name <- dm_tbl_name(dm, {{ table_2 }})

  rel <- parent_child_table(dm, {{ table_1 }}, {{ table_2 }})
  start <- rel$child_table
  other <- rel$parent_table

  dm_flatten_to_tbl_impl(dm, start, !!other, join = join, join_name = join_name, squash = FALSE)
}

parent_child_table <- function(dm, table_1, table_2) {
  t1_name <- dm_tbl_name(dm, {{ table_1 }})
  t2_name <- dm_tbl_name(dm, {{ table_2 }})

  rel <-
    dm_get_all_fks(dm) %>%
    filter(
      (child_table == t1_name & parent_table == t2_name) |
        (child_table == t2_name & parent_table == t1_name)
    )

  if (nrow(rel) == 0) {
    abort_tables_not_neighbors(t1_name, t2_name)
  }

  if (nrow(rel) > 1) {
    abort_no_cycles(create_graph_from_dm(dm))
  }

  rel
}

check_flatten_to_tbl <- function(join_name,
                                 part_cond_abort_filters,
                                 any_not_reachable,
                                 g,
                                 auto_detect,
                                 more_than_1_pt,
                                 has_grandparent,
                                 squash) {
  # argument checking, or filter and recompute induced subgraph
  # for subsequent check
  if (any_not_reachable) {
    abort_tables_not_reachable_from_start()
  }

  # Cycles not yet supported
  if (length(V(g)) - 1 != length(E(g))) {
    abort_no_cycles(g)
  }
  if (join_name == "nest_join") abort_no_flatten_with_nest_join()
  if (part_cond_abort_filters && join_name %in% c("full_join", "right_join")) abort_apply_filters_first(join_name)
  # the result for `right_join()` depends on the order of the dim-tables in the `dm`
  # if 2 or more of them are joined to the fact table and ellipsis is empty.


  # If called by `dm_join_to_tbl()` or `dm_flatten_to_tbl()`, the argument `squash = FALSE`.
  # Then only one level of hierarchy is allowed (direct neighbors to table `start`).
  if (!squash && has_grandparent) {
    abort_only_parents()
  }

  if (join_name == "right_join" && auto_detect && more_than_1_pt) {
    warning(
      paste0(
        "Result for `dm_flatten_to_tbl()` with `right_join()` dependend on order of tables in `dm`, when ",
        "more than 2 tables involved and no explicit order given in `...`."
      )
    )
  }
}

prepare_dm_for_flatten <- function(dm, tables, gotta_rename) {
  start <- tables[1]
  # filters need to be empty, for the disambiguation to work
  # renaming will be minimized if we reduce the `dm` to the necessary tables here
  red_dm <-
    dm_reset_all_filters(dm) %>%
    dm_select_tbl(!!!tables)
  # Only need to compute `dm[[start]]`, `dm_apply_filters()` not necessary
  # Need to use `dm` and not `clean_dm` here, because of possible filter conditions.
  start_tbl <- dm_get_filtered_table(dm, start)

  if (gotta_rename) {
    table_colnames <- get_table_colnames(red_dm)
    recipe <- compute_disambiguate_cols_recipe(table_colnames, sep = ".")
    explain_col_rename(recipe)
    # prepare `dm` by disambiguating columns (on a reduced dm)
    clean_dm <-
      col_rename(red_dm, recipe)
    # the column names of start_tbl need to be updated, since taken from `dm` and not `clean_dm`,
    # therefore we need a named variable containing the new and old names
    renames <-
      pluck(recipe$renames[recipe$table == start], 1)
    start_tbl <- start_tbl %>% rename(!!!renames)
  } else {
    # for `anti_join()` and `semi_join()` no renaming necessary
    clean_dm <- red_dm
    renames <- character(0)
  }

  def <- dm_get_def(clean_dm)
  def$data[[which(def$table == start)]] <- start_tbl
  new_dm3(def)
}
