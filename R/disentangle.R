#' @autoglobal
dm_disentangle <- function(dm, start, quiet = FALSE) {
  check_not_zoomed(dm)
  start <- dm_tbl_name(dm, {{ start }})
  recipes <- enumerate_all_paths(dm, start)
  changed <- dplyr::arrange(recipes$table_mapping, table, new_table)

  if (!quiet) {
    msgs <-
      changed %>%
      dplyr::group_by(table) %>%
      dplyr::summarize(
        msg = glue::glue("Replaced table {tick(unique(table))} with {commas(tick(new_table))}.")
      ) %>%
      dplyr::ungroup()

    walk(msgs$msg, message)
  }
  fk_table <- fk_table_to_def_fks(
    recipes$new_fks,
    child_table = "new_child_table",
    child_fk_cols = "child_cols",
    parent_table = "new_parent_table",
    parent_key_cols = "parent_cols"
  ) %>%
    dplyr::rename(new_fks = fks)

  dm_get_def(dm) %>%
    dplyr::left_join(changed, by = "table", multiple = "all") %>%
    dplyr::mutate(table = dplyr::coalesce(new_table, table)) %>%
    dplyr::select(-new_table) %>%
    dplyr::left_join(fk_table, by = c("table" = "new_parent_table")) %>%
    dplyr::select(-fks) %>%
    dplyr::relocate(fks = new_fks, .after = uks) %>%
    dplyr::mutate(fks = vctrs::as_list_of(map(fks, ~ .x %||% new_fk()))) %>%
    dm_from_def()
}
