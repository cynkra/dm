dm_disentangle <- function(dm, start, quiet = FALSE) {
  check_not_zoomed(dm)
  start <- dm_tbl_name(dm, {{ start }})
  recipes <- enumerate_all_paths(dm, start)
  changed <- arrange(recipes$table_mapping, table, new_table)

  if (!quiet) {
    msgs <-
      changed %>%
      group_by(table) %>%
      summarize(
        msg = glue::glue("Replaced table {tick(unique(table))} with {commas(tick(new_table))}.")
      ) %>%
      ungroup()

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
    mutate(fks = vctrs::as_list_of(map(fks, ~ .x %||% new_fk()))) %>%
    new_dm3()
}

dm_recycle <- function(dm, ptype) {
  all_tbls_source <- dm_get_tables(dm)
  all_tbls_target <- dm_get_tables(ptype)

  all_cols_source <- map(all_tbls_source, colnames)
  all_cols_target <- map(all_tbls_target, colnames)

  if (!setequal(all_cols_source, all_cols_target)) {
    # FIXME: abort_colnames_not_matching(all_cols_source, all_cols_target)
    stop("colnames not matching")
  }

  # compare classes of matched columns
  target_tables <- dm_get_def(ptype) %>%
    mutate(coltypes = map_chr(data, function(x) {
      paste0(map_chr(x, ~ class(.x)), collapse = "")
    })) %>%
    select(table, coltypes)

  source_tables <- dm_ptype(dm) %>%
    dm_get_def() %>%
    mutate(coltypes = map_chr(data, function(x) {
      paste0(map_chr(x, ~ class(.x)), collapse = "")
    })) %>%
    select(table, coltypes)

  fks_target_plus_cols <- dm_get_all_fks_impl(ptype) %>%
    mutate(
      child_table_cols = map_chr(child_table, ~ paste0(all_cols_target[[.x]], collapse = "")),
      parent_table_cols = map_chr(parent_table, ~ paste0(all_cols_target[[.x]], collapse = ""))
    ) %>%
    left_join(target_tables, by = c("child_table" = "table")) %>%
    rename(child_table_coltypes = coltypes) %>%
    left_join(target_tables, by = c("parent_table" = "table")) %>%
    rename(
      child_table_target = child_table,
      parent_table_target = parent_table,
      parent_table_coltypes = coltypes
    )

  fks_source_plus_cols <- dm_get_all_fks_impl(dm) %>%
    mutate(
      child_table_cols = map_chr(child_table, ~ paste0(all_cols_source[[.x]], collapse = "")),
      parent_table_cols = map_chr(parent_table, ~ paste0(all_cols_source[[.x]], collapse = ""))
    ) %>%
    left_join(source_tables, by = c("child_table" = "table")) %>%
    rename(child_table_coltypes = coltypes) %>%
    left_join(source_tables, by = c("parent_table" = "table")) %>%
    rename(
      child_table_source = child_table,
      parent_table_source = parent_table,
      parent_table_coltypes = coltypes
    )

  source_and_target <- left_join(
    fks_source_plus_cols,
    fks_target_plus_cols,
    by = c("child_fk_cols", "parent_key_cols", "on_delete", "child_table_cols", "parent_table_cols", "child_table_coltypes", "parent_table_coltypes"),
    # multiple means, that for one FK relation in the disentangled dm there's more than 1 match in
    # the ptype. Happens, when 2+ ptype-tables have the same column names in the same order with the same classes.
    # FIXME: need to catch this error and explain to the user
    multiple = "error"
  ) %>%
    select(
      child_table_target,
      child_table_source,
      parent_table_target,
      parent_table_source
    )

  map_source_to_target <-
    bind_rows(
      select(
        source_and_target,
        target_table = child_table_target,
        source_table = child_table_source
      ),
      select(
        source_and_target,
        target_table = parent_table_target,
        source_table = parent_table_source
      )
    ) %>%
    # FIXME: should we test, if all tables in source that are mapped to one table in target are identical?
    distinct(target_table, .keep_all = TRUE) %>%
    deframe()

  # insert the data from `dm` into `ptype`
  dm_get_def(ptype) %>%
    mutate(
      data = map(table, ~ all_tbls_source[[map_source_to_target[.x]]])
    ) %>%
    new_dm3()
}
