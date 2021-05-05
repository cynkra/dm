nest_join_zoomed_dm <- function(x, ...) {
  zoomed_dm <- x
  src_dm <- dm_get_src_impl(zoomed_dm)
  if (!is.null(src_dm)) {
    abort_only_for_local_src(src_dm)
  }

  vars <- src_tbls_impl(zoomed_dm)
  selected <- eval_select_table(quo(c(...)), vars)
  if (is_empty(selected)) selected <- vars

  orig_table <- orig_name_zoomed(zoomed_dm)
  if (!dm_has_pk_impl(zoomed_dm, orig_table)) {
    message("The originally zoomed table didn't have a primary key, therefore `nest.zoomed_dm()` does nothing.")
    return(zoomed_dm)
  }

  orig_pk <- dm_get_pk_impl(zoomed_dm, orig_table)
  keys <- col_tracker_zoomed(zoomed_dm)
  if (!(orig_pk %in% keys)) {
    abort_pk_not_tracked(orig_table, orig_pk)
  }
  new_pk <- names(keys[keys == orig_pk])

  child_tables <-
    get_orig_in_fks(zoomed_dm, orig_table) %>%
    mutate(data = map(child_table, ~ dm_get_tables_impl(zoomed_dm)[[.x]])) %>%
    # FIXME: should we check and warn/message, if no child table is in selected?
    filter(child_table %in% selected) %>%
    # perform joins in the order given in the ellipsis
    arrange(match(child_table, selected))
  x <- tbl_zoomed(zoomed_dm)

  for (i in seq_len(nrow(child_tables))) {
    x <- nest_join(
      x,
      y = child_tables$data[[i]],
      by = set_names(child_tables$child_fk_cols[i], new_pk),
      name = child_tables$child_table[i]
    ) %>%
      # FIXME: why does `nest_join()` not produce a `list_of`?
      mutate(!!child_tables$child_table[i] := vctrs::as_list_of(!!sym(child_tables$child_table[i])))
  }
  replace_zoomed_tbl(zoomed_dm, x)
}
