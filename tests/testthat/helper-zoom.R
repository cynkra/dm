
# helper to check if key tracking works
get_all_keys <- function(dm, table_name) {
  fks <-
    dm_get_all_fks_impl(dm) %>%
    filter(child_table %in% table_name) %>%
    select(child_fk_cols, parent_table, parent_pk_cols)
  pks <-
    dm_get_all_pks_impl(dm) %>%
    filter(table %in% table_name)

  list(
    pks = pks,
    fks = fks
  )
}
