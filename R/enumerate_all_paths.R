enumerate_all_paths <- function(dm, start) {
  all_fks <-
    dm %>%
    dm_get_all_fks() %>%
    rename(child_cols = child_fk_cols, parent_cols = parent_key_cols)

  graph_df_ud <-
    all_fks %>%
    rename(
      child_table = parent_table,
      child_cols = parent_cols,
      parent_table = child_table,
      parent_cols = child_cols,
    ) %>%
    bind_rows(all_fks, .)

  helper_env <- new_environment()
  assign("tbl_node", list(), envir = helper_env)
  assign("all_paths", tibble(
    child_table = character(),
    child_cols = new_keys(),
    parent_table = character(),
    parent_cols = new_keys(),
    new_child_table = character(),
    new_parent_table = character()
  ), envir = helper_env)
  enumerate_all_paths_impl(start, graph_df_ud = graph_df_ud, helper_env = helper_env)
  get("all_paths", envir = helper_env) %>%
    rename_unique() %>%
    split_to_list()
}

enumerate_all_paths_impl <- function(node,
                                     node_key_cols = character(),
                                     former_node = character(),
                                     former_key_cols = character(),
                                     path = character(),
                                     graph_df_ud,
                                     helper_env) {
  if (length(path) > 0) {
    # increase tbl_node[[node]] by 1, return this index in a suffix
    usage_idx <- inc_tbl_node(node, helper_env)
    add_path_to_all_paths(
      graph_df_ud,
      node,
      node_key_cols,
      former_node,
      former_key_cols,
      new_former_node = names(path)[[length(path)]],
      usage_idx,
      helper_env
    )
  } else {
    usage_idx <- ""
  }

  path <- c(path, set_names(node, paste0(node, usage_idx)))
  out <-
    graph_df_ud %>%
    filter(child_table == !!node) %>%
    filter(!(parent_table %in% path)) %>%
    rename(node = parent_table, node_key_cols = parent_cols, former_node = child_table, former_key_cols = child_cols) %>%
    select(-on_delete)

  if (nrow(out) == 0) {
    return()
  }

  pwalk(out, enumerate_all_paths_impl, path, graph_df_ud, helper_env)
}

rename_unique <- function(all_paths) {
  all_names <- bind_rows(
    select(all_paths, table = child_table, new_table = new_child_table),
    select(all_paths, table = parent_table, new_table = new_parent_table)
  ) %>%
    distinct() %>%
    arrange(table, new_table) %>%
    group_by(table) %>%
    count()
  left_join(all_paths, rename(all_names, n_c = n), by = c("child_table" = "table")) %>%
    left_join(rename(all_names, n_p = n), by = c("parent_table" = "table")) %>%
    mutate(
      new_child_table = if_else(n_c == 1, child_table, new_child_table),
      new_parent_table = if_else(n_p == 1, parent_table, new_parent_table)
    ) %>%
    select(-n_c, -n_p)
}

inc_tbl_node <- function(node, helper_env) {
  tbl_node <- get("tbl_node", envir = helper_env)
  tbl_node[[node]] <- (tbl_node[[node]] %||% 0) + 1
  assign("tbl_node", tbl_node, envir = helper_env)
  paste0("-", tbl_node[[node]])
}

add_path_to_all_paths <- function(graph_df_ud,
                                  node,
                                  node_key_cols,
                                  former_node,
                                  former_key_cols,
                                  new_former_node,
                                  usage_idx,
                                  helper_env) {
  all_paths <- get("all_paths", helper_env)
  path_element <- graph_df_ud %>% filter(
    (
      child_table == node &
        map_lgl(child_cols, ~ identical(sort(.x), sort(node_key_cols))) &
        parent_table == former_node &
        map_lgl(parent_cols, ~ identical(sort(.x), sort(former_key_cols)))
    ) |
      (
        parent_table == node &
          map_lgl(parent_cols, ~ identical(sort(.x), sort(node_key_cols))) &
          child_table == former_node &
          map_lgl(child_cols, ~ identical(sort(.x), sort(former_key_cols)))
      )
  )
  assign("all_paths",
    bind_rows(
      all_paths,
      slice(path_element, 1) %>%
        mutate(
          new_child_table = if_else(child_table == node, paste0(node, usage_idx), new_former_node),
          new_parent_table = if_else(parent_table == node, paste0(node, usage_idx), new_former_node)
        )
    ),
    envir = helper_env
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
    on_delete)
  list(table_mapping = table_mapping, new_fks = new_fks)
}
