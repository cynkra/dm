#' \pkg{tidyr} table manipulation methods for zoomed dm objects
#'
#' @description
#' Use these methods without the '.dm_zoomed' suffix (see examples).
#' @param data object of class `dm_zoomed`
#' @param ... For `unite.dm_zoomed`: see [tidyr::unite()]
#'
#' For `separate.dm_zoomed`: see [tidyr::separate()]
#' @inheritParams tidyr::unite
#' @inheritParams tidyr::separate
#' @name tidyr_table_manipulation
#' @examplesIf rlang::is_installed("nycflights13")
#' zoom_united <- dm_nycflights13() %>%
#'   dm_zoom_to(flights) %>%
#'   select(year, month, day) %>%
#'   unite("month_day", month, day)
#' zoom_united
#' zoom_united %>%
#'   separate(month_day, c("month", "day"))
NULL
#' @exportS3Method tidyr::unite
unite.dm <- function(data, col, ..., sep = "_", remove = TRUE, na.rm = FALSE) {
  check_zoomed(data)
}

#' @rdname tidyr_table_manipulation
#' @exportS3Method tidyr::unite
unite.dm_zoomed <- function(data, col, ..., sep = "_", remove = TRUE, na.rm = FALSE) {
  tbl <- tbl_zoomed(data)
  united_tbl <- tidyr::unite(tbl, col = !!col, ..., sep = sep, remove = remove, na.rm = na.rm)

  # all columns that are not not removed count as "selected"; names of "selected" are identical to "selected"
  if (remove) {
    deselected <- eval_select_both(quo(c(...)), colnames(tbl))
  } else {
    deselected <- eval_select_both(quo(c()), colnames(tbl))
  }
  selected <- set_names(setdiff(names(col_tracker_zoomed(data)), deselected$names))
  new_tracked_cols_zoom <- new_tracked_cols(data, selected)

  replace_zoomed_tbl(data, united_tbl, new_tracked_cols_zoom)
}

#' @rdname tidyr_table_manipulation
#' @exportS3Method tidyr::unite
unite.dm_keyed_tbl <- function(data, col, ..., sep = "_", remove = TRUE, na.rm = FALSE) {
  keys_info <- keyed_get_info(data)
  tbl <- unclass_keyed_tbl(data)
  out <- tidyr::unite(tbl, col = {{ col }}, ..., sep = sep, remove = remove, na.rm = na.rm)
  new_keyed_tbl_from_keys_info(out, keys_info)
}

#' @exportS3Method tidyr::separate
separate.dm <- function(
  data,
  col,
  into,
  sep = "[^[:alnum:]]+",
  remove = TRUE,
  convert = FALSE,
  extra = "warn",
  fill = "warn",
  ...
) {
  check_zoomed(data)
}

#' @rdname tidyr_table_manipulation
#' @exportS3Method tidyr::separate
separate.dm_zoomed <- function(
  data,
  col,
  into,
  sep = "[^[:alnum:]]+",
  remove = TRUE,
  convert = FALSE,
  extra = "warn",
  fill = "warn",
  ...
) {
  tbl <- tbl_zoomed(data)
  col <- tidyselect::vars_pull(names(tbl), !!enquo(col))
  separated_tbl <- tidyr::separate(
    tbl,
    col = !!col,
    into = into,
    sep = sep,
    remove = remove,
    convert = convert,
    extra = extra,
    fill = fill,
    ...
  )
  # all columns that are not removed count as "selected"; names of "selected" are identical to "selected"
  deselected <- if (remove) col else character()
  selected <- set_names(setdiff(names(col_tracker_zoomed(data)), deselected))
  new_tracked_cols_zoom <- new_tracked_cols(data, selected)
  replace_zoomed_tbl(data, separated_tbl, new_tracked_cols_zoom)
}

#' @rdname tidyr_table_manipulation
#' @exportS3Method tidyr::separate
separate.dm_keyed_tbl <- function(
  data,
  col,
  into,
  sep = "[^[:alnum:]]+",
  remove = TRUE,
  convert = FALSE,
  extra = "warn",
  fill = "warn",
  ...
) {
  keys_info <- keyed_get_info(data)
  tbl <- unclass_keyed_tbl(data)
  out <- tidyr::separate(
    tbl,
    col = {{ col }},
    into = into,
    sep = sep,
    remove = remove,
    convert = convert,
    extra = extra,
    fill = fill,
    ...
  )
  new_keyed_tbl_from_keys_info(out, keys_info)
}
