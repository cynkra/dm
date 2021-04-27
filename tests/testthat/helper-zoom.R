
# helper to check if key tracking works
get_all_keys <- function(dm, table_name) {
  # FIXME: Efficiency
  fks <- dm_get_all_fks2_impl(dm) %>%
    filter(child_table == table_name) %>%
    pull(child_fk_cols)
  pk <- dm_get_pk_impl(dm, table_name)
  new_keys(unique(c(pk, fks)))
}
