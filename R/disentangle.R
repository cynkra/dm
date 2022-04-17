dm_disentangle <- function(dm, start) {
  check_not_zoomed(dm)
  start <- dm_tbl_name_null(dm, {{ start }})
  recipes <- enumerate_all_paths(dm, start)
  changed <- arrange(recipes$table_mapping, table, new_table)
  fk_table <- fk_table_to_class_key(
    recipes$new_fks,
    child_table = "new_child_table",
    child_fk_cols = "child_cols",
    parent_table = "new_parent_table",
    parent_key_cols = "parent_cols"
  ) %>%
    rename(new_fks = fks)
  dm_get_def(dm) %>%
    full_join(changed, by = "table") %>%
    mutate(table = coalesce(new_table, table)) %>%
    select(-new_table) %>%
    left_join(fk_table, by = c("table" = "new_parent_table")) %>%
    select(-fks) %>%
    relocate(fks = new_fks, .after = pks) %>%
    new_dm3()
}

get_changed <- function(recipe) {
  bind_rows(
    select(recipe, table = child_table, new_table = new_child_table),
    select(recipe, table = parent_table, new_table = new_parent_table)
  ) %>%
    filter(table != new_table) %>%
    distinct()
}

insert_new_pts <- function(dm, old_pt_name, new_pt_name) {
  dm_zoom_to(dm, !!old_pt_name) %>%
    dm_insert_zoomed(!!new_pt_name)
}

dm_rm_all_fk_for_changed_child <- function(dm, changed_tables) {
  all_changed_children <- dm_get_all_fks_impl(dm) %>%
    filter(child_table %in% changed_tables)
  for (i in seq_len(nrow(all_changed_children))) {
    dm <- dm_rm_fk_impl(
      dm,
      table_name = all_changed_children$child_table[i],
      cols = get_key_cols(all_changed_children$child_fk_cols[i]),
      ref_table_name = all_changed_children$parent_table[i],
      ref_cols = get_key_cols(all_changed_children$parent_key_cols[i])
    )
  }
  dm
}
