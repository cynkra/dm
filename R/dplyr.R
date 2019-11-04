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
  if (nrow(cdm_get_filter(.data) %>% filter(table == !!orig_name_zoomed(.data)))) abort_no_filters_rename_select()
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
  quos <- enquos(...)
  if (is_empty(quos)) {
    return(.data)
  } # valid table and empty ellipsis provided

  set_filter_for_table(.data, orig_name_zoomed(.data), quos, TRUE)
}

#' @export
mutate.dm <- function(.data, ...) {
  abort_no_table_zoomed_dplyr("mutate")
}

#' @export
mutate.zoomed_dm <- function(.data, ...) {
  if (nrow(cdm_get_filter(.data) %>% filter(table == !!orig_name_zoomed(.data)))) abort_no_filters_rename_select()
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
  if (nrow(cdm_get_filter(.data) %>% filter(table == !!orig_name_zoomed(.data)))) abort_no_filters_rename_select()
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
  if (nrow(cdm_get_filter(.data) %>% filter(table == !!orig_name_zoomed(.data)))) abort_no_filters_rename_select()
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
  if (nrow(cdm_get_filter(.data) %>% filter(table == !!orig_name_zoomed(.data)))) abort_no_filters_rename_select()
  tbl <- get_zoomed_tbl(.data)
  renamed <- tidyselect::vars_rename(colnames(tbl), ...)
  renamed_tbl <- rename(tbl, !!!renamed)

  new_tracked_keys_zoom <- new_tracked_keys(.data, renamed)

  replace_zoomed_tbl(.data, renamed_tbl, new_tracked_keys_zoom)
}

#' @export
left_join.dm <- function(x, ...) {
  abort_no_table_zoomed_dplyr("left_join")
}

#' @export
left_join.zoomed_dm <- function(x, y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), select = NULL, ...) {
  if (nrow(cdm_get_filter(x) %>% filter(table == !!orig_name_zoomed(x)))) abort_no_filters_rename_select()
  y_name <- as_string(enexpr(y))
  join_data <- prepare_join(x, y_name, by, enexpr(select))
  if (copy) message("Tables in a `dm` are necessarily on the same `src`, setting `copy = FALSE`.")
  joined_tbl <- left_join(join_data$x_tbl, join_data$y_tbl, join_data$by, copy = FALSE, suffix = suffix, ...)
  replace_zoomed_tbl(x, joined_tbl)
}

#' @export
inner_join.dm <- function(x, ...) {
  abort_no_table_zoomed_dplyr("inner_join")
}

#' @export
inner_join.zoomed_dm <- function(x, y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), select = NULL, ...) {
  if (nrow(cdm_get_filter(x) %>% filter(table == !!orig_name_zoomed(x)))) abort_no_filters_rename_select()
  y_name <- as_string(enexpr(y))
  join_data <- prepare_join(x, y_name, by, enexpr(select))
  if (copy) message("Tables in a `dm` are necessarily on the same `src`, setting `copy = FALSE`.")
  joined_tbl <- inner_join(join_data$x_tbl, join_data$y_tbl, join_data$by, copy = FALSE, suffix = suffix, ...)
  replace_zoomed_tbl(x, joined_tbl)
}

#' @export
full_join.dm <- function(x, ...) {
  abort_no_table_zoomed_dplyr("inner_join")
}

#' @export
full_join.zoomed_dm <- function(x, y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), select = NULL, ...) {
  if (nrow(cdm_get_filter(x) %>% filter(table == !!orig_name_zoomed(x)))) abort_no_filters_rename_select()
  y_name <- as_string(enexpr(y))
  join_data <- prepare_join(x, y_name, by, enexpr(select))
  if (copy) message("Tables in a `dm` are necessarily on the same `src`, setting `copy = FALSE`.")
  joined_tbl <- full_join(join_data$x_tbl, join_data$y_tbl, join_data$by, copy = FALSE, suffix = suffix, ...)
  replace_zoomed_tbl(x, joined_tbl)
}

#' @export
semi_join.dm <- function(x, ...) {
  abort_no_table_zoomed_dplyr("inner_join")
}

#' @export
semi_join.zoomed_dm <- function(x, y, by = NULL, copy = FALSE, select = NULL, ...) {
  if (nrow(cdm_get_filter(x) %>% filter(table == !!orig_name_zoomed(x)))) abort_no_filters_rename_select()
  y_name <- as_string(enexpr(y))
  join_data <- prepare_join(x, y_name, by, enexpr(select))
  if (copy) message("Tables in a `dm` are necessarily on the same `src`, setting `copy = FALSE`.")
  joined_tbl <-semi_join(join_data$x_tbl, join_data$y_tbl, join_data$by, copy = FALSE, ...)
  replace_zoomed_tbl(x, joined_tbl)
}

#' @export
anti_join.dm <- function(x, ...) {
  abort_no_table_zoomed_dplyr("inner_join")
}

#' @export
anti_join.zoomed_dm <- function(x, y, by = NULL, copy = FALSE, select = NULL, ...) {
  if (nrow(cdm_get_filter(x) %>% filter(table == !!orig_name_zoomed(x)))) abort_no_filters_rename_select()
  y_name <- as_string(enexpr(y))
  join_data <- prepare_join(x, y_name, by, enexpr(select))
  if (copy) message("Tables in a `dm` are necessarily on the same `src`, setting `copy = FALSE`.")
  joined_tbl <-anti_join(join_data$x_tbl, join_data$y_tbl, join_data$by, copy = FALSE, ...)
  replace_zoomed_tbl(x, joined_tbl)
}

#' @export
right_join.dm <- function(x, ...) {
  abort_no_table_zoomed_dplyr("inner_join")
}

#' @export
right_join.zoomed_dm <- function(x, y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), select = NULL, ...) {
  if (nrow(cdm_get_filter(x) %>% filter(table == !!orig_name_zoomed(x)))) abort_no_filters_rename_select()
  y_name <- as_string(enexpr(y))
  join_data <- prepare_join(x, y_name, by, enexpr(select))
  if (copy) message("Tables in a `dm` are necessarily on the same `src`, setting `copy = FALSE`.")
  joined_tbl <-right_join(join_data$x_tbl, join_data$y_tbl, join_data$by, copy = FALSE, suffix = suffix, ...)
  replace_zoomed_tbl(x, joined_tbl)
}

prepare_join <- function(x, y_name, by, select_expr) {
  x_tbl <- get_zoomed_tbl(x)
  x_orig_name <- orig_name_zoomed(x)
  y_tbl <- cdm_get_tables(x)[[y_name]]
  all_cols_y <- colnames(y_tbl)
  selected <- if (is_null(select_expr))
    tidyselect::vars_select(all_cols_y, everything()) else
    tidyselect::vars_select(all_cols_y, !!select_expr)
  if (is_null(by)) {
    by <- get_by(x, x_orig_name, y_name)
    x_by <- names(by)
    names(by) <- names(get_tracked_keys(x)[get_tracked_keys(x) == x_by])
    if (is_na(names(by))) abort_fk_not_tracked(x_orig_name, y_name)
  }
  list(x_tbl = x_tbl, y_tbl = select(y_tbl, !!!selected), by = by)
}
