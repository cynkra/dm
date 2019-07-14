#' Get a [`dm`] only containing the indicated tables and the connecting ones
#'
#' @description Is a wrapper around `cdm_find_conn_tbls()`. It returns a reduced [`dm`] object,
#' containing only the indicated tables plus the ones in between them (unless `all_connected = FALSE`).
#'
#' @param dm A [`dm`] object
#' @param ... Two or more table names of the [`dm`] object's tables.
#'   See [tidyselect::vars_select()] for details on the semantics.
#'
#' @param all_connected Boolean, if `TRUE` (default), all the connecting tables will
#' be part of the resulting [`dm`] in addition to the indicated tables. If `FALSE`,
#' exclusively the indicated tables will be selected.
#'
#' @family Functions utilizing foreign key relations
#'
#' @export
cdm_select_tbl <- function(dm, ..., all_connected = TRUE) {

  all_table_names <- structure(
    src_tbls(dm),
    type = c("table", "tables")
  )

  table_names <- tidyselect::vars_select(all_table_names, ...)
  walk(table_names, ~ check_correct_input(dm, .))

  if (all_connected) {
    tables_keep <- cdm_find_conn_tbls(dm, !!!table_names)
  } else {
    tables_keep <- table_names
  }

  list_of_removed_tables <- setdiff(all_table_names, tables_keep)

  new_data_model <- rm_table_from_data_model(cdm_get_data_model(dm), list_of_removed_tables)
  table_objs <- map(tables_keep, ~ tbl(dm, .)) %>% set_names(tables_keep)

  new_dm(
    src = cdm_get_src(dm),
    tables = table_objs,
    data_model = new_data_model
  )
}


#' Find the tables connecting two or more tables in a [`dm`]
#'
#' @description Find all tables that need to be passed when traversing the [`dm`] object
#' between the indicated tables along the foreign
#' key relations. Result includes the given tables.
#'
#' @param dm A [`dm`] object
#' @param ... Two or more table names of the [`dm`] object's tables.
#'
#' @family Functions utilizing foreign key relations
#'
#' @return Character vector with the names of the connecting tables.
#'
#' @export
cdm_find_conn_tbls <- function(dm, ...) {
  if (!is_dm(dm)) abort("'dm' has to be of class 'dm'")
  g <- create_graph_from_dm(dm)
  V <- names(igraph::V(g))

  quos <- enquos(...)
  if (is_empty(quos)) return(src_tbls(dm))

  table_names <- map_chr(quos, as_name)
  walk(table_names, ~ check_correct_input(dm, .))

  if (!are_all_vertices_connected(g, table_names)) {
    abort_vertices_not_connected()
  }

  V_ids <- map_int(table_names, ~ which(V == .x))
  all_comb <- crossing(table_names, V_ids)
  ids_vec <- pull(all_comb, V_ids)
  names_vec <- pull(all_comb, table_names)

  result_table_names_unordered <-
    map2(
      ids_vec, names_vec, ~ igraph::shortest_paths(g, .x, .y) %>%
        pluck("vpath", 1) %>%
        names()
    ) %>%
    flatten_chr() %>%
    unique()

  all_table_names <- src_tbls(dm)
  all_table_names[all_table_names %in% result_table_names_unordered]
}
