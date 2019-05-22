#' @export
cdm_select_conn_tbls <- function(dm, ...) {
  if (!is_dm(dm)) abort("'dm' has to be of class 'dm'")
  g <- create_graph_from_dm(dm)
  V <- names(igraph::V(g))

  quos <- enquos(...)
  if (!length(quos)) {
    return(dm)
  }
  table_names <- map_chr(quos, as_name)

  all_table_names <- src_tbls(dm)
  walk(table_names, ~ check_correct_input(dm, .))

  if (!all(table_names %in% V)) {
    abort("Not all tables in your 'dm'-object are connected. 'dm_select_table()' currently only works for connected tables.")
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

  result_table_names <-
    all_table_names[all_table_names %in% result_table_names_unordered]

  if (identical(result_table_names, src_tbls(dm))) {
    return(dm)
  }

  list_of_removed_tables <- setdiff(src_tbls(dm), result_table_names)

  new_data_model <- rm_table_from_data_model(cdm_get_data_model(dm), list_of_removed_tables)
  table_objs <- map(result_table_names, ~ tbl(dm, .)) %>% set_names(result_table_names)

  new_dm(
    src = cdm_get_src(dm),
    tables = table_objs,
    data_model = new_data_model
  )
}
