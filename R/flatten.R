#' Flatten `dm` into a wide table
#'
#' This function joins all the tables of your `dm` object together and returns one
#' table with unique columns. Use
#' [cdm_select_tbl()] if necessary to reduce the number of tables before calling this function.
#'
#' @inheritParams cdm_join_tbl
#' @param start FIXME
#' @family Flattening functions
#'
#' @return A wide table resulting of consecutively joining all tables together.
#'
#' @examples
#' cdm_nycflights13() %>%
#' cdm_select_tbl(-weather) %>%
#' cdm_flatten_to_tbl(flights)
#'
#' @export
cdm_flatten_to_tbl <- function(dm, start, join = left_join) {
  start <- as_name(ensym(start))
  check_correct_input(dm, start)

  # prepare `dm` by applying all filters, disambiguate columns, and adapt FK-column names
  # to the respective PK-column names
  clean_dm <- cdm_apply_filters(dm) %>%
      cdm_disambiguate_cols() %>%
      adapt_fk_cols()

  # need to work with directed graph here, since we only want to go in the direction
  # the foreign key is pointing to
  g <- create_graph_from_dm(clean_dm, directed = TRUE)
  filtered_tables <- clean_dm %>% cdm_get_tables()

  # each next table needs to be accessible from the former table (note: directed relations)
  # we achieve this with a depth-first-search (DFS) with param `unreachable = FALSE`
  dfs <- igraph::dfs(g, start, unreachable = FALSE)

  # Drop first table in the list of join partners. (We have at least one table, `start`.)
  # (Working with `reduce2()` here and the `.init`-parameter is the first table)
  # in the case of only one table in the `dm` (table "start"), all code below is a no-op
  order <- names(dfs[["order"]])[-1]
  order <- order[!is.na(order)]
  by <- map_chr(order, ~cdm_get_pk(dm, !!.))

  # list of join partners
  ordered_table_list <- filtered_tables[order]

  # perform the joins according to the list, starting with table `initial_LHS`
  reduce2(ordered_table_list, by, ~join(..1, ..2, by = ..3), .init = filtered_tables[[start]])
}

# key columns have to be adapted here (child table col needs to get the
# same name as the parent table primary key)
adapt_fk_cols <- function(dm) {

  recipe <-
    as_tibble(cdm_get_data_model(dm)[["columns"]]) %>%
    filter(!is.na(ref)) %>%
    select(table, ref_col, column) %>%
    nest(-table, .key = "renames") %>%
    mutate(renames = map(renames, deframe))

  col_rename(dm, recipe, quiet = TRUE)
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
#' @param join The type of join to be performed, see \code{\link[dplyr]{join}}
#'
#' @return The resulting table of the join
#'
#' @family Flattening functions
#'
#' @export
cdm_join_tbl <- function(dm, table_1, table_2, join = semi_join) {
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
    filter((child_table == t1_name & parent_table == t2_name) |
             (child_table == t2_name & parent_table == t1_name) ) %>%
    pull(child_table)

}
