dm_bind_impl <- function(dms, repair, quiet, repair_arg = "", caller = caller_env()) {
  if (length(dms) == 0) {
    return(new_dm_def())
  }

  walk(dms, check_dm)
  walk(dms, check_not_zoomed)
  if (!all_same_source(map(dms, dm_get_tables_impl) %>% flatten())) {
    abort_not_same_src(dm_bind = TRUE)
  }

  # repair table names
  table_names <- map(dms, src_tbls_impl) %>% flatten_chr()
  new_table_names <- vec_as_names(
    table_names,
    repair = repair,
    quiet = quiet,
    repair_arg = repair_arg,
    call = caller
  )
  # need to individually rename tables for each `dm`
  ntables_dms <- map(dms, length)
  dms_indices <- map(ntables_dms, seq_len)
  renaming_recipe <- map2(
    dms_indices,
    lag(cumsum(ntables_dms), default = 0),
    ~ set_names(.x, new_table_names[.x + .y])
  )

  dms_renamed <- map2(dms, renaming_recipe, bind_rename_tbl)

  new_defs <- map(dms_renamed, dm_get_def)
  vec_rbind(!!!new_defs)
}

bind_rename_tbl <- function(dm, renamed) {
  if (length(dm) == 0) {
    return(dm)
  }

  def <- dm_get_def(dm)

  renamed_names <- set_names(def$table[renamed], names(renamed))

  def %>%
    bind_filter_recode_table_def(renamed) %>%
    filter_recode_table_fks(renamed_names) %>%
    new_dm3()
}

bind_filter_recode_table_def <- function(def, renamed) {
  def$table[renamed] <- names(renamed)
  def
}
