group_by.dm <- function(.data, ..., add = FALSE, .drop = group_by_drop_default(.data)) {
  abort_no_table_zoomed_dplyr("group_by")
}

group_by.zoomed_dm <- function(.data, ..., add = FALSE, .drop = group_by_drop_default(.data)) {
  tbl <- get_zoomed_tbl(.data)
  grouped_tbl <- group_by(tbl, ..., add = add, .drop = .drop)

  replace_zoomed_tbl(zoomed_dm, grouped_tbl)
}

ungroup.dm <- function(x, ...) {
  abort_no_table_zoomed_dplyr("ungroup")
}

ungroup.zoomed_dm <- function(x, ...) {
  tbl <- get_zoomed_tbl(x)
  ungrouped_tbl <- ungroup(tbl, ...)

  replace_zoomed_tbl(zoomed_dm, ungrouped_tbl)
}

summarise_.zoomed_dm <- function(.data, ...) {
  tbl <- get_zoomed_tbl(.data)
  summarized_tbl <- summarize(tbl, ...)

  replace_zoomed_tbl(zoomed_dm, summarized_tbl)
}

summarise_.dm <- function(.data, ...) {
  abort_no_table_zoomed_dplyr("summarise")
}

summarise.zoomed_dm <- function(.data, ...) {
  summarise_.zoomed_dm(.data, ...)
}

filter.dm <- function(.data, ..., .preserve = FALSE) {
  abort_no_table_zoomed_dplyr("filter")
}

filter.zoomed_dm <- function(.data, ..., .preserve = FALSE) {
  tbl <- get_zoomed_tbl(.data)
  filtered_tbl <- filter(tbl, ..., .preserve = .preserve)

  replace_zoomed_tbl(zoomed_dm, filtered_tbl)
}
