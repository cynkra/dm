dm_disentangle <- function(dm, start) {
  recipe <- enumerate_all_paths(dm, start)
  changed <- get_changed(recipe)

  new_dm <- dm_rm_all_fk_for_changed_child(dm, changed$table) %>%
    dm_get_def() %>%
    mutate(fks = if_else(table %in% unique(changed$table), list_of(new_fk()), fks)) %>%
    new_dm3() %>%
    reduce2(
      changed$table,
      changed$new_table,
      insert_new_pts,
      .init = .
    ) %>%
    dm_rm_tbl(unique(changed$table))

  for (i in seq_len(nrow(recipe))) {
    new_dm <- dm_add_fk(
      new_dm,
      !!recipe$new_child_table[i],
      !!get_key_cols(recipe$child_cols[i]),
      !!recipe$new_parent_table[i],
      !!get_key_cols(recipe$parent_cols[i]),
      on_delete = recipe$on_delete[i]
    )
  }
  new_dm
}

get_changed <- function(recipe) {
  bind_rows(
    select(recipe, table = child_table, new_table = new_child_table),
    select(recipe, table = parent_table, new_table = new_parent_table)
  ) %>%
    filter(table != new_table) %>%
    distinct()
}

get_new_pks <- function(dm, recipe) {
  browser()
  changed <- get_changed(recipe) %>%
    mutate(pks = map(table, function(table) {
      browser(); dm_get_pk_impl(dm, table)
    }))
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
      table = all_changed_children$child_table[i],
      cols = get_key_cols(all_changed_children$child_fk_cols[i]),
      ref_table_name = all_changed_children$parent_table[i],
      ref_cols = get_key_cols(all_changed_children$parent_key_cols[i])
    )
  }
  dm
}
