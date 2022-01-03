
dm_examine_cardinalities <- function(dm) {
  fks <- dm_get_all_fks_impl(dm) %>%
    select(
      parent_table,
      pk_column = parent_key_cols,
      child_table,
      fk_column = child_fk_cols
    )
  dm_def <- dm_get_def(dm, TRUE) %>%
    select(table, data) %>%
    deframe()
  fks_data <- fks %>%
    mutate(
      fks,
      parent_table = dm_def[parent_table],
      child_table =  dm_def[child_table]
    )
  out <- fks %>%
    mutate(
      cardinality = pmap_chr(
        fks_data,
        examine_cardinality
      )
    )
  out
}
