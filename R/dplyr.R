#' @export
group_by.dm <- function(.data, ...) {
  abort_no_table_zoomed_dplyr("group_by")
}

#' @export
group_by.zoomed_dm <- function(.data, ...) {
  tbl <- get_zoomed_tbl(.data)
  grouped_tbl <- group_by(tbl, ...)

  replace_zoomed_tbl(.data, grouped_tbl)
}

#' @export
ungroup.dm <- function(x, ...) {
  abort_no_table_zoomed_dplyr("ungroup")
}

#' @export
ungroup.zoomed_dm <- function(x, ...) {
  tbl <- get_zoomed_tbl(x)
  ungrouped_tbl <- ungroup(tbl, ...)

  replace_zoomed_tbl(x, ungrouped_tbl)
}

#' @export
summarise.zoomed_dm <- function(.data, ...) {
  tbl <- get_zoomed_tbl(.data)
  # groups are "selected"; key tracking will continue for them
  groups <- set_names(map_chr(groups(tbl), as_string))
  summarized_tbl <- summarize(tbl, ...)
  new_tracked_keys_zoom <- new_tracked_keys(.data, groups)
  replace_zoomed_tbl(.data, summarized_tbl, new_tracked_keys_zoom)
}

#' @export
summarise.dm <- function(.data, ...) {
  abort_no_table_zoomed_dplyr("summarise")
}

#' @export
filter.dm <- function(.data, ...) {
  abort_no_table_zoomed_dplyr("filter")
}

#' @export
filter.zoomed_dm <- function(.data, ...) {
  filter_quos <- enquos(...)
  if (is_empty(filter_quos)) {
    return(.data)
  } # valid table and empty ellipsis provided

  tbl <- get_zoomed_tbl(.data)
  filtered_tbl <- filter(tbl, !!!filter_quos)

  # attribute filter expression to zoomed table. Needs to be flagged with `zoomed = TRUE`, since
  # in case of `cdm_insert_zoomed_tbl()` the filter exprs needs to be transferred
  set_filter_for_table(.data, orig_name_zoomed(.data), map(filter_quos, quo_get_expr), TRUE) %>%
    replace_zoomed_tbl(filtered_tbl)
}

#' @export
mutate.dm <- function(.data, ...) {
  abort_no_table_zoomed_dplyr("mutate")
}

#' @export
mutate.zoomed_dm <- function(.data, ...) {
  tbl <- get_zoomed_tbl(.data)
  mutated_tbl <- mutate(tbl, ...)
  # all columns that are not touched count as "selected"; names of "selected" are identical to "selected"
  selected <- set_names(setdiff(names(get_tracked_keys(.data)), names(enquos(..., .named = TRUE))))
  new_tracked_keys_zoom <- new_tracked_keys(.data, selected)
  replace_zoomed_tbl(.data, mutated_tbl, new_tracked_keys_zoom)
}

#' @export
transmute.dm <- function(.data, ...) {
  abort_no_table_zoomed_dplyr("transmute")
}

#' @export
transmute.zoomed_dm <- function(.data, ...) {
  tbl <- get_zoomed_tbl(.data)
  # groups are "selected"; key tracking will continue for them
  groups <- set_names(map_chr(groups(tbl), as_string))
  transmuted_tbl <- transmute(tbl, ...)
  new_tracked_keys_zoom <- new_tracked_keys(.data, groups)

  replace_zoomed_tbl(.data, transmuted_tbl, new_tracked_keys_zoom)
}

#' @export
select.dm <- function(.data, ...) {
  abort_no_table_zoomed_dplyr("select")
}

#' @export
select.zoomed_dm <- function(.data, ...) {
  tbl <- get_zoomed_tbl(.data)
  selected <- tidyselect::vars_select(colnames(tbl), ...)
  selected_tbl <- select(tbl, !!!selected)

  new_tracked_keys_zoom <- new_tracked_keys(.data, selected)

  replace_zoomed_tbl(.data, selected_tbl, new_tracked_keys_zoom)
}

#' @export
rename.dm <- function(.data, ...) {
  abort_no_table_zoomed_dplyr("rename")
}

#' @export
rename.zoomed_dm <- function(.data, ...) {
  tbl <- get_zoomed_tbl(.data)
  renamed <- tidyselect::vars_rename(colnames(tbl), ...)
  renamed_tbl <- rename(tbl, !!!renamed)

  new_tracked_keys_zoom <- new_tracked_keys(.data, renamed)

  replace_zoomed_tbl(.data, renamed_tbl, new_tracked_keys_zoom)
}

#' @export
distinct.dm <- function(.data, ...) {
  abort_no_table_zoomed_dplyr("distinct")
}

#' @export
distinct.zoomed_dm <- function(.data, ..., .keep_all = FALSE) {
  tbl <- get_zoomed_tbl(.data)
  distinct_tbl <- distinct(tbl, ..., .keep_all = .keep_all)
  # when keeping all columns or empty ellipsis (use all columns for distinct) all keys columns remain
  if (.keep_all || is_empty(enexprs(...))) return(replace_zoomed_tbl(.data, distinct_tbl))
  selected <- tidyselect::vars_select(colnames(tbl), ...)
  new_tracked_keys_zoom <- new_tracked_keys(.data, selected)
  replace_zoomed_tbl(.data, distinct_tbl, new_tracked_keys_zoom)
}

#' @export
arrange.dm <- function(.data, ...) {
  abort_no_table_zoomed_dplyr("arrange")
}

#' @export
arrange.zoomed_dm <- function(.data, ...) {
  replace_zoomed_tbl(.data, arrange(get_zoomed_tbl(.data), ...))
}

#' @export
slice.dm <- function(.data, ...) {
  abort_no_table_zoomed_dplyr("slice")
}

#' @export
slice.zoomed_dm <- function(.data, ...) {
  replace_zoomed_tbl(.data, slice(get_zoomed_tbl(.data), ...))
}

#' @export
pull.dm <- function(.data, ...) {
  abort_no_table_zoomed_dplyr("pull")
}

#' @export
pull.zoomed_dm <- function(.data, var = -1) {
  pull(get_zoomed_tbl(.data), !!enquo(var))
}
