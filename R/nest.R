nest_join_dm_zoomed <- function(x, ...) {
  dm_zoomed <- x
  src_dm <- dm_get_src_impl(dm_zoomed)
  if (!is.null(src_dm)) {
    abort_only_for_local_src(src_dm)
  }

  vars <- src_tbls_impl(dm_zoomed)
  selected <- eval_select_table(quo(c(...)), vars)
  if (is_empty(selected)) selected <- vars

  orig_table <- orig_name_zoomed(dm_zoomed)
  if (!dm_has_pk_impl(dm_zoomed, orig_table)) {
    message("The originally zoomed table didn't have a primary key, therefore `nest.dm_zoomed()` does nothing.")
    return(dm_zoomed)
  }

  orig_pk <- dm_get_pk_impl(dm_zoomed, orig_table)
  keys <- col_tracker_zoomed(dm_zoomed)
  if (!(orig_pk %in% keys)) {
    abort_pk_not_tracked(orig_table, orig_pk)
  }
  new_pk <- names(keys[keys == orig_pk])

  child_tables <-
    get_orig_in_fks(dm_zoomed, orig_table) %>%
    mutate(data = map(child_table, ~ dm_get_tables_impl(dm_zoomed)[[.x]])) %>%
    # FIXME: should we check and warn/message, if no child table is in selected?
    filter(child_table %in% selected) %>%
    # perform joins in the order given in the ellipsis
    arrange(match(child_table, selected))
  x <- tbl_zoomed(dm_zoomed)

  for (i in seq_len(nrow(child_tables))) {
    x <- nest_join(
      x,
      y = child_tables$data[[i]],
      by = set_names(child_tables$child_fk_cols[i], new_pk),
      name = child_tables$child_table[i]
    ) %>%
      # FIXME: why does `nest_join()` not produce a `list_of`?
      mutate(!!child_tables$child_table[i] := as_list_of(!!sym(child_tables$child_table[i])))
  }
  replace_zoomed_tbl(dm_zoomed, x)
}
