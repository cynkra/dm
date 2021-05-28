#' \pkg{tidyr} table manipulation methods for zoomed dm objects
#'
#' Use these methods without the '.zoomed_dm' suffix (see examples).
#' @param data object of class `zoomed_dm`
#' @param col For `unite.zoomed_dm`: see [`tidyr::unite`]
#'
#' For `separate.zoomed_dm`: see [`tidyr::separate`]
#' @param ... For `unite.zoomed_dm`: see [`tidyr::unite`]
#'
#' For `separate.zoomed_dm`: see [`tidyr::separate`]
#' @param col For `unite.zoomed_dm`: see [`tidyr::unite`]
#'
#' For `separate.zoomed_dm`: see [`tidyr::separate`]
#' @param sep For `unite.zoomed_dm`: see [`tidyr::unite`]
#'
#' For `separate.zoomed_dm`: see [`tidyr::separate`]
#' @param remove For `unite.zoomed_dm`: see [`tidyr::unite`]
#'
#' For `separate.zoomed_dm`: see [`tidyr::separate`]
#' @param na.rm see [`tidyr::unite`]
#' @param into see [`tidyr::separate`]
#' @name tidyr_table_manipulation
#' @examplesIf rlang::is_installed("nycflights13")
#' zoom_united <- dm_nycflights13() |>
#'   dm_zoom_to(flights) |>
#'   select(year, month, day) |>
#'   unite("month_day", month, day)
#' zoom_united
#' zoom_united |>
#'   separate(month_day, c("month", "day"))
NULL
#' @export
unite.dm <- function(data, ...) {
  check_zoomed(data)
}

#' @rdname tidyr_table_manipulation
#' @export
unite.zoomed_dm <- function(data, col, ..., sep = "_", remove = TRUE, na.rm = FALSE) {
  tbl <- tbl_zoomed(data)
  united_tbl <- unite(tbl, col = !!col, ..., sep = sep, remove = remove, na.rm = na.rm)

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

#' @export
separate.dm <- function(data, ...) {
  check_zoomed(data)
}

#' @rdname tidyr_table_manipulation
#' @export
separate.zoomed_dm <- function(data, col, into, sep = "[^[:alnum:]]+", remove = TRUE, ...) {
  tbl <- tbl_zoomed(data)
  col <- tidyselect::vars_pull(names(tbl), !!enquo(col))
  separated_tbl <- separate(tbl, col = !!col, into = into, sep = sep, remove = remove, ...)
  # all columns that are not removed count as "selected"; names of "selected" are identical to "selected"
  deselected <- if (remove) col else character()
  selected <- set_names(setdiff(names(col_tracker_zoomed(data)), deselected))
  new_tracked_cols_zoom <- new_tracked_cols(data, selected)
  replace_zoomed_tbl(data, separated_tbl, new_tracked_cols_zoom)
}
