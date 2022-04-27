enumerate_all_paths <- function(dm, start) {
  all_fks <-
    dm %>%
    dm_get_all_fks() %>%
    rename(child_cols = child_fk_cols, parent_cols = parent_key_cols) %>%
    mutate(edge_id = row_number())

  helper_env <- new_environment()
  helper_env$tbl_node <- list()
  helper_env$all_paths <- tibble(
    child_table = character(),
    child_cols = new_keys(),
    parent_table = character(),
    parent_cols = new_keys(),
    new_child_table = character(),
    new_parent_table = character()
  )

  enumerate_all_paths_impl(start, all_fks = all_fks, helper_env = helper_env)

  all_paths <- helper_env$all_paths
  # need to take into account FKs from unconnected components (graph representation)
  fks_from_unconnected <- anti_join(
    all_fks,
    all_paths,
    by = c("child_table", "parent_table")
  ) %>%
    mutate(new_child_table = child_table, new_parent_table = parent_table)
  all_paths %>%
    rename_unique() %>%
    bind_rows(fks_from_unconnected) %>%
    split_to_list()
}

enumerate_all_paths_impl <- function(node,
                                     edge_id = NULL,
                                     path = set_names(node),
                                     all_fks,
                                     helper_env) {
  if (!is.null(edge_id)) {
    # increase tbl_node[[node]] by 1, return this index in a suffix
    usage_idx <- inc_tbl_node(node, helper_env)
    new_node <- paste0(node, "-", usage_idx)
    # new nodes appended to the front
    path <- c(set_names(node, new_node), path)
    # the first two elements serve as (reverse) lookup for new table names
    node_lookup <- prep_recode(path[1:2])

    add_path_to_all_paths(all_fks, edge_id, node_lookup, helper_env)
  }

  in_edges <-
    all_fks %>%
    filter(parent_table == !!node) %>%
    filter(!(child_table %in% !!path)) %>%
    select(node = child_table, edge_id)

  out_edges <-
    all_fks %>%
    filter(child_table == !!node) %>%
    filter(!(parent_table %in% !!path)) %>%
    select(node = parent_table, edge_id)

  bind_rows(in_edges, out_edges) %>%
    pwalk(enumerate_all_paths_impl, path, all_fks, helper_env)
}

rename_unique <- function(all_paths) {
  node_lookup <-
    bind_rows(
      select(all_paths, new_table = new_child_table, table = child_table),
      select(all_paths, new_table = new_parent_table, table = parent_table)
    ) %>%
    distinct() %>%
    arrange(table, new_table) %>%
    add_count(table) %>%
    mutate(table = if_else(n == 1L, table, new_table)) %>%
    select(new_table, table) %>%
    deframe()

  all_paths %>%
    mutate(
      new_child_table = (!!node_lookup)[new_child_table],
      new_parent_table = (!!node_lookup)[new_parent_table]
    )
}

inc_tbl_node <- function(node, helper_env) {
  tbl_node <- helper_env$tbl_node
  out <- (tbl_node[[node]] %||% 0) + 1
  tbl_node[[node]] <- out
  helper_env$tbl_node <- tbl_node
  out
}

add_path_to_all_paths <- function(all_fks,
                                  edge_id,
                                  node_lookup,
                                  helper_env) {
  all_paths <- helper_env$all_paths
  path_element <-
    all_fks %>%
    filter(edge_id == !!edge_id)

  helper_env$all_paths <- bind_rows(
    all_paths,
    path_element %>%
      mutate(
        new_child_table = (!!node_lookup)[child_table],
        new_parent_table = (!!node_lookup)[parent_table]
      )
  )
}

split_to_list <- function(all_paths) {
  table_mapping <- bind_rows(
    select(all_paths, new_table = new_child_table, table = child_table),
    select(all_paths, new_table = new_parent_table, table = parent_table)
  ) %>%
    filter(new_table != table) %>%
    distinct() %>%
    mutate(new_table = unname(new_table)) %>%
    arrange()

  new_fks <- select(
    all_paths,
    new_child_table,
    child_cols,
    new_parent_table,
    parent_cols,
    on_delete
  )
  list(table_mapping = table_mapping, new_fks = new_fks)
}
