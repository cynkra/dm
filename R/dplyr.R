group_by.dm <- function(.data, ..., add = FALSE, .drop = group_by_drop_default(.data)) {
  abort_no_table_zoomed_dplyr("group_by")
}

group_by.zoomed_dm <- function(.data, ..., add = FALSE, .drop = group_by_drop_default(.data)) {
  tbl <- get_zoomed_tbl(.data)
  grouped_tbl <- group_by(tbl, ..., add = add, .drop = .drop)

  replace_zoomed_tbl(.data, grouped_tbl)
}

ungroup.dm <- function(x, ...) {
  abort_no_table_zoomed_dplyr("ungroup")
}

ungroup.zoomed_dm <- function(x, ...) {
  tbl <- get_zoomed_tbl(x)
  ungrouped_tbl <- ungroup(tbl, ...)

  replace_zoomed_tbl(x, ungrouped_tbl)
}

summarise.zoomed_dm <- function(.data, ...) {
  tbl <- get_zoomed_tbl(.data)
  summarized_tbl <- summarize(tbl, ...)

  replace_zoomed_tbl(.data, summarized_tbl)
}

summarise.dm <- function(.data, ...) {
  abort_no_table_zoomed_dplyr("summarise")
}

filter.dm <- function(.data, ..., .preserve = FALSE) {
  abort_no_table_zoomed_dplyr("filter")
}

filter.zoomed_dm <- function(.data, ..., .preserve = FALSE) {
  tbl <- get_zoomed_tbl(.data)
  filtered_tbl <- filter(tbl, ..., .preserve = .preserve)

  replace_zoomed_tbl(.data, filtered_tbl)
}

mutate.dm <- function(.data, ...) {
  abort_no_table_zoomed_dplyr("mutate")
}

mutate.zoomed_dm <- function(.data, ...) {
  tbl <- get_zoomed_tbl(.data)
  mutated_tbl <- mutate(tbl, ...)

  replace_zoomed_tbl(.data, mutated_tbl)
}

transmute.dm <- function(.data, ...) {
  abort_no_table_zoomed_dplyr("transmute")
}

transmute.zoomed_dm <- function(.data, ...) {
  tbl <- get_zoomed_tbl(.data)
  transmuted_tbl <- transmute(tbl, ...)

  replace_zoomed_tbl(.data, transmuted_tbl)
}

select.dm <- function(.data, ...) {
  abort_no_table_zoomed_dplyr("select")
}

select.zoomed_dm <- function(.data, ...) {
  tbl <- get_zoomed_tbl(.data)
  selected <- tidyselect::vars_select(colnames(tbl), ...)
  selected_tbl <- select(tbl, !!!selected)

  new_tracked_keys_zoom <- new_tracked_keys(.data, selected)

  replace_zoomed_tbl(.data, selected_tbl, new_tracked_keys_zoom)
}

rename.dm <- function(.data, ...) {
  abort_no_table_zoomed_dplyr("rename")
}

rename.zoomed_dm <- function(.data, ...) {
  tbl <- get_zoomed_tbl(.data)
  renamed <- tidyselect::vars_rename(colnames(tbl), ...)
  renamed_tbl <- rename(tbl, !!!renamed)

  new_tracked_keys_zoom <- new_tracked_keys(.data, renamed)

  replace_zoomed_tbl(.data, renamed_tbl, new_tracked_keys_zoom)
}

