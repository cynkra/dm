group_by.dm <- function(dm, ..., add = FALSE, .drop = group_by_drop_default(.data)) {
  abort_no_table_zoomed_dplyr("group_by")
}

group_by.zoomed_dm <- function(zoomed_dm, ..., add = FALSE, .drop = group_by_drop_default(.data)) {
  tbl <- get_zoomed_tbl(zoomed_dm)
  grouped_tbl <- group_by(tbl, ..., add = add, .drop = .drop)

  replace_zoomed_tbl(zoomed_dm, grouped_tbl)
}
