#' Flatten `dm` into a wide table
#'
#' This function joins all the tables of your `dm` object together and returns one
#' table containing all unique columns. This is especially useful in connection
#' with `cdm_select_tbl()` in order to reduce the number of tables in advance.
#'
#' @inheritParams cdm_join_tbl
#' @param sep In case there are columns with non-unique names, they will be renamed using
#' [`cdm_disambiguate_cols()`]. `sep` is the character variable separating the table
#' names and the ambiguous column names
#' @family Flattening functions
#'
#' @return A wide table resulting of consecutively joining all tables together.
#'
#' @examples
#' cdm_nycflights13() %>%
#' cdm_select_tbl(-weather) %>%
#' cdm_flatten()
#'
#' @export
cdm_flatten <- function(dm, join = left_join, sep = ".") {
  if (!are_all_vertices_connected(create_graph_from_dm(dm), src_tbls(dm))) {
    abort_vertices_not_connected("cdm_flatten")
  }
  clean_dm <- cdm_apply_filters(dm) %>%
      cdm_disambiguate_cols(sep = sep, quiet = TRUE) %>%
      adapt_fk_cols()
  g <- create_graph_from_dm(clean_dm, directed = TRUE)
  filtered_tables <- clean_dm %>% cdm_get_tables()

  # chose a "child table" (only outgoing FKs) as a start (otherwise we might
  # end up with empty rows, if "parent/dim table" contains PK values that are
  # not present in child table (we might anyway though, depending on `join`-type))
  initial_LHS_name <- g %>%
    igraph::topo_sort() %>%
    names() %>%
    pluck(1)
  initial_LHS <- filtered_tables[[initial_LHS_name]]

  # each next table needs to be accessible from the former table; this is not ensured by `topo_sort()`
  # we achieve this with a breadth-first-search (BFS)
  order <- igraph::bfs(g, initial_LHS_name) %>%
    extract2("order") %>%
    names()

  # early return in case of only one table...
  if (length(order) == 1) return(initial_LHS)
  # since we want to work with `reduce2()`, the `.init`-parameter is the first table
  # in `order` and the next table is always the join partner
  ordered_table_list <- filtered_tables[order] %>%
    extract(2:length(order))

  # get the right column names for each join (should all be adapted by `adapt_fk_cols()`)
  by <- get_by_for_flatten(clean_dm, order)

  # perform the joins according to the list, starting with table `initial_LHS`
  reduce2(ordered_table_list, by, ~join(..1, ..2, by = ..3), .init = initial_LHS)
}

get_by_for_flatten <- function(dm, order) {
  by <- character(0)
  for (i in 2:length(order)) {

    # use first table that has a relation with table `i`
    relation <- order[which(map2_lgl(order[1:i-1], order[i], ~relation_exists(dm, .x, .y)))[1]]

    by <- append(by, get_by(dm, relation, order[i]))
  }
  by
}

# key columns have to be adapted here (child table col needs to get the
# same name as the parent table primary key)
# FIXME: this function is very similar to `cdm_disambiguate_cols()`; maybe extract function?
adapt_fk_cols <- function(dm) {

  tbl_cols_for_disambiguation <-
    as_tibble(cdm_get_data_model(dm)[["columns"]]) %>%
    filter(!is.na(ref)) %>%
    select(table, ref_col, column) %>%
    nest(-table, .key = "renames") %>%
    mutate(renames = map(renames, deframe))

  tables_for_disambiguation <- pull(tbl_cols_for_disambiguation, table)
  cols_for_disambiguation <- pull(tbl_cols_for_disambiguation, renames)

  reduce2(tables_for_disambiguation,
          cols_for_disambiguation,
          ~cdm_rename(..1, !!..2, !!!..3),
          .init = dm)
  }

reunite_parent_child_2 <- function(child_table, parent_table, id_column, join = left_join) {
  id_col_q <- enexpr(id_column)

  id_col_chr <-
    as_name(id_col_q)

  child_table %>%
    join(parent_table, by = id_col_chr) %>%
    select(-!!id_col_q)
}

#' Perform a join between two tables of a [`dm`]
#'
#' @description A join of desired type is performed between table `lhs` and
#' table `rhs`.
#'
#' @param dm A [`dm`] object
#' @param lhs The table on the left hand side of the join
#' @param rhs The table on the right hand side of the join
#' @param join The type of join to be performed, see \code{\link[dplyr]{join}}
#'
#' @return The resulting table of the join
#'
#' @family Flattening functions
#'
#' @export
cdm_join_tbl <- function(dm, lhs, rhs, join = semi_join) {
  lhs_name <- as_name(enexpr(lhs))
  rhs_name <- as_name(enexpr(rhs))

  by <- get_by(dm, lhs_name, rhs_name)

  lhs_obj <- tbl(dm, lhs_name)
  rhs_obj <- tbl(dm, rhs_name)

  join(lhs_obj, rhs_obj, by = by)
}
