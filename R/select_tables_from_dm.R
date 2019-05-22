#' @export
cdm_select <- function(dm, ..., all_connected = FALSE) {

  quos <- enquos(...)
  if (is_empty(quos)) return(dm)

  table_names <- map_chr(quos, as_name)
  walk(table_names, ~ check_correct_input(dm, .))

  all_table_names <- src_tbls(dm)

  if (all_connected) {
    tables_keep <- cdm_find_conn_tbls(dm, ...)
  } else tables_keep <- all_table_names[all_table_names %in% table_names]

  list_of_removed_tables <- setdiff(all_table_names, tables_keep)

  new_data_model <- rm_table_from_data_model(cdm_get_data_model(dm), list_of_removed_tables)
  table_objs <- map(tables_keep, ~ tbl(dm, .)) %>% set_names(tables_keep)

  new_dm(
    src = cdm_get_src(dm),
    tables = table_objs,
    data_model = new_data_model
  )
}

#' @export
cdm_find_conn_tbls <- function(dm, ...) {
  if (!is_dm(dm)) abort("'dm' has to be of class 'dm'")
  g <- create_graph_from_dm(dm)
  V <- names(igraph::V(g))

  quos <- enquos(...)
  if (!length(quos)) return(src_tbls(dm))

  table_names <- map_chr(quos, as_name)
  walk(table_names, ~ check_correct_input(dm, .))

  if (!are_all_vertices_connected(g, table_names)) {
    abort("Not all of the selected tables of the 'dm'-object are connected.")
  }

  V_ids <- map_int(table_names, ~ which(V == .x))
  all_comb <- crossing(table_names, V_ids)
  ids_vec <- pull(all_comb, V_ids)
  names_vec <- pull(all_comb, table_names)

  result_table_names_unordered <-
    map2(
      ids_vec, names_vec, ~ igraph::shortest_paths(g, .x, .y) %>% pluck("vpath", 1) %>% names()
      ) %>%
    flatten_chr() %>%
    unique()

  all_table_names <- src_tbls(dm)
  all_table_names[all_table_names %in% result_table_names_unordered]
}
