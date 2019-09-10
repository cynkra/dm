#' Avoid column name conflicts
#'
#' This function checks all tables for column names that are not unique and renames
#' those columns by prefixing the respective table name and a separator.
#' Key columns will not be renamed, since only one column should remain, when two tables
#' linked by a key relation are joined.
#'
#' @inheritParams cdm_add_pk
#' @param sep The character variable separating the table names and the ambiguous column names
#' @param quiet Boolean, if `TRUE`, will list the renamed columns in a message
#'
#' @examples
#' cdm_disambiguate_cols(cdm_nycflights13())
#'
#' @export
cdm_disambiguate_cols <- function(dm, sep = ".", quiet = FALSE) {
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

  if (!quiet && !is_empty(cols_for_disambiguation)) {
    names_for_disambiguation <- map(cols_for_disambiguation, names)
    msg_renamed_cols <- map2(cols_for_disambiguation, names_for_disambiguation, ~paste0(.x, " -> ", .y)) %>%
      map(~paste(., collapse = "\n"))
    msg_core <- paste0("Table: ", tables_for_disambiguation, "\n",
                       msg_renamed_cols, "\n", collapse = "\n")
    msg <- paste0("Renamed columns:\n", msg_core)
    message(msg)
  }

  reduce2(tables_for_disambiguation,
          cols_for_disambiguation,
          ~cdm_rename(..1, !!..2, !!!..3),
          .init = dm)
}
