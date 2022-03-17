dm_disentangle <- function(dm) {
  # if not all tables are connected, the condition
  # length(E(g)) < length(V(g))
  # is not enough to determine that there is no cycle
  # we need to break up the graph into independent subgraphs using igraph::decompose()
  g <- create_graph_from_dm(dm, directed = TRUE) %>%
    igraph::decompose()
  # if there is no cycle in any of the components we don't need to do anything
  no_cycles <- map_lgl(g, ~length(E(.)) < length(V(.)))
  if (all(no_cycles)) {
    message("No cycle detected, returning original `dm`.")
    return(dm)
  }

  # get all incoming edges, recreate the vertices (parent tables) with more than 1 incoming edge
  # as often as there are incoming edges and use one foreign key relation per vertex
  all_edges_in <- map(
    g[!no_cycles], ~igraph::incident_edges(., V(.), mode = "in")
  ) %>%
    flatten()
  num_edges_in <- map_int(all_edges_in, length)
  multiple_edges_in <- all_edges_in[num_edges_in > 1]
  purrr::reduce(names(multiple_edges_in), make_in_edges_unique, .init = dm)
}

make_in_edges_unique <- function(dm, pt_name) {
  new_fks <- dm_get_all_fks(dm) %>%
    filter(parent_table == pt_name) %>%
    mutate(parent_table = paste0(parent_table, "_", row_number()))
  dm_new <- dm_get_def(dm) %>%
    mutate(fks = if_else(table == pt_name, list_of(new_fk()), fks)) %>%
    new_dm3() %>%
    reduce2(rep(pt_name, nrow(new_fks)), new_fks$parent_table, insert_new_pts, .init = .) %>%
    dm_rm_tbl(!!pt_name) %>%
    dm_add_new_fks(new_fks)
}

insert_new_pts <- function(dm, old_pt_name, new_pt_name) {
  dm_zoom_to(dm, !!old_pt_name) %>%
    dm_insert_zoomed(!!new_pt_name)
}

dm_add_new_fks <- function(dm, new_fks) {
  for (i in seq_len(nrow(new_fks))) {
    dm <- dm_add_fk(
      dm,
      table = !!new_fks$child_table[i],
      columns = !!unlist(new_fks$child_fk_cols[i]),
      ref_table = !!new_fks$parent_table[i],
      ref_columns = !!unlist(new_fks$parent_key_cols[i])
    )
  }
  dm
}
