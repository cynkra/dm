cdm_disambiguate <- function(dm, sep = ".", quiet = FALSE) {
  tbl_cols_for_disambiguation <-
    as_tibble(cdm_get_data_model(dm)[["columns"]]) %>%
    # key columns are supposed to remain unchanged, even if they are identical
    # in case of flattening, only one column will remains for pk-fk-relations
    add_count(column) %>%
    filter(key == 0, is.na(ref), n > 1) %>%
    mutate(new_name = paste0(table, sep, column)) %>%
    select(table, new_name, column) %>%
    nest(-table, .key = "renames") %>%
    mutate(renames = map(renames, deframe))

  tables_for_disambiguation <- pull(tbl_cols_for_disambiguation, table)
  cols_for_disambiguation <- pull(tbl_cols_for_disambiguation, renames)

  if (!quiet) {
    names_for_disambiguation <- map(cols_for_disambiguation, names)
    msg_renamed_cols <- map2(cols_for_disambiguation, names_for_disambiguation, ~paste0(.x, " -> ", .y)) %>%
      map(~paste(., collapse = "\n"))
    msg_core <- paste0("Table: ", tables_for_disambiguation, "\n",
                       msg_renamed_cols, "\n", collapse = "\n")
    msg <- paste0("Renamed columns:\n", msg_core)
    message(msg)
  }
  paste(cols_for_disambiguation, " -> ", names_for_disambiguation, collapse = "\n")

  reduce2(tables_for_disambiguation,
          cols_for_disambiguation,
          ~cdm_rename(..1, !!..2, !!!..3),
          .init = dm)
}
