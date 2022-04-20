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

  enumerate_in_paths_impl(start, all_fks = all_fks, helper_env = helper_env)
  enumerate_out_paths_impl(start, all_fks = all_fks, helper_env = helper_env)

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
                                     edge_id,
                                     path,
                                     all_fks,
                                     helper_env) {
  # increase tbl_node[[node]] by 1, return this index in a suffix
  usage_idx <- inc_tbl_node(node, helper_env)
  new_node <- paste0(node, usage_idx)
  add_path_to_all_paths(
    all_fks,
    edge_id,
    node,
    new_node,
    new_former_node = names(path)[[length(path)]],
    helper_env
  )

  path <- c(path, set_names(node, new_node))
  enumerate_in_paths_impl(node, path, all_fks, helper_env)
  enumerate_out_paths_impl(node, path, all_fks, helper_env)
}

enumerate_in_paths_impl <- function(node, path = set_names(node), all_fks, helper_env) {
  out <-
    all_fks %>%
    filter(parent_table == !!node) %>%
    filter(!(child_table %in% !!path)) %>%
    select(node = child_table, edge_id)

  pwalk(out, enumerate_all_paths_impl, path, all_fks, helper_env)
}

enumerate_out_paths_impl <- function(node, path = set_names(node), all_fks, helper_env) {
  out <-
    all_fks %>%
    filter(child_table == !!node) %>%
    filter(!(parent_table %in% !!path)) %>%
    select(node = parent_table, edge_id)

  pwalk(out, enumerate_all_paths_impl, path, all_fks, helper_env)
}

rename_unique <- function(all_paths) {
  all_names <- bind_rows(
    select(all_paths, table = child_table, new_table = new_child_table),
    select(all_paths, table = parent_table, new_table = new_parent_table)
  ) %>%
    distinct() %>%
    arrange(table, new_table) %>%
    count(table)
  left_join(all_paths, rename(all_names, n_c = n), by = c("child_table" = "table")) %>%
    left_join(rename(all_names, n_p = n), by = c("parent_table" = "table")) %>%
    mutate(
      new_child_table = if_else(n_c == 1, child_table, new_child_table),
      new_parent_table = if_else(n_p == 1, parent_table, new_parent_table)
    ) %>%
    select(-n_c, -n_p)
}

inc_tbl_node <- function(node, helper_env) {
  tbl_node <- helper_env$tbl_node
  out <- (tbl_node[[node]] %||% 0) + 1
  tbl_node[[node]] <- out
  helper_env$tbl_node <- tbl_node
  paste0("-", out)
}

add_path_to_all_paths <- function(all_fks,
                                  edge_id,
                                  node,
                                  new_node,
                                  new_former_node,
                                  helper_env) {
  all_paths <- helper_env$all_paths
  path_element <-
    all_fks %>%
    filter(edge_id == !!edge_id)

  helper_env$all_paths <- bind_rows(
    all_paths,
    path_element %>%
      mutate(
        new_child_table = if_else(child_table == node, !!new_node, !!new_former_node),
        new_parent_table = if_else(parent_table == node, !!new_node, !!new_former_node)
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
