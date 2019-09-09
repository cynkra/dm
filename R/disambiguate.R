cdm_disambiguate <- function(dm, sep = ".", quiet = FALSE) {
  tbl_cols_for_disambiguation <-
    as_tibble(cdm_get_data_model(dm)[["columns"]]) %>%
    # key columns are supposed to remain unchanged, even if they are identical
    # in case of flattening, only one column will remains for pk-fk-relations
    filter(key == 0, is.na(ref)) %>%
    add_count(column) %>%
    filter(n > 1) %>%
    mutate(new_name = paste0(table, sep, column)) %>%
    select(table, new_name, column) %>%
    nest(-table, .key = "renames") %>%
    mutate(renames = map(renames, deframe))

  tables_for_disambiguation <- pull(tbl_cols_for_disambiguation, table)
  cols_for_disambiguation <- pull(tbl_cols_for_disambiguation, renames)

  reduce2(tables_for_disambiguation,
          cols_for_disambiguation,
          ~cdm_rename(..1, !!..2, !!!..3),
          .init = dm)
}
