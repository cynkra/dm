dm_disentangle <- function(dm, start, quiet = FALSE) {
  check_not_zoomed(dm)
  start <- dm_tbl_name_null(dm, {{ start }})
  recipes <- enumerate_all_paths(dm, start)
  changed <- arrange(recipes$table_mapping, table, new_table)
  if (!quiet) {
    msgs <- group_by(changed, table) %>%
      summarize(
        msg = glue::glue("Replaced table {tick(unique(table))} with {commas(tick(new_table))}.")
      )
    walk(msgs$msg, message)
  }
  fk_table <- fk_table_to_def_fks(
    recipes$new_fks,
    child_table = "new_child_table",
    child_fk_cols = "child_cols",
    parent_table = "new_parent_table",
    parent_key_cols = "parent_cols"
  ) %>%
    rename(new_fks = fks)
  dm_get_def(dm) %>%
    left_join(changed, by = "table") %>%
    mutate(table = coalesce(new_table, table)) %>%
    select(-new_table) %>%
    left_join(fk_table, by = c("table" = "new_parent_table")) %>%
    select(-fks) %>%
    relocate(fks = new_fks, .after = pks) %>%
    new_dm3()
}
