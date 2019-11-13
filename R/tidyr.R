#' @export
unite.dm <- function(.data, ...) {
  abort_no_table_zoomed_dplyr("pull")
}

#' @export
unite.zoomed_dm <- function(data, col, ..., sep = "_", remove = TRUE, na.rm = FALSE) {
  tbl <- get_zoomed_tbl(data)
  united_tbl <- unite(tbl, col = !!col, ..., sep = sep, remove = remove, na.rm = na.rm)
  # all columns that are not not removed count as "selected"; names of "selected" are identical to "selected"
  if (remove) deselected <- tidyselect::vars_select(colnames(tbl), ...) else deselected <- character()
  selected <- set_names(setdiff(names(get_tracked_keys(data)), deselected))
  new_tracked_keys_zoom <- new_tracked_keys(data, selected)
  replace_zoomed_tbl(data, united_tbl, new_tracked_keys_zoom)
}

#' @export
separate.dm <- function(.data, ...) {
  abort_no_table_zoomed_dplyr("pull")
}

#' @export
separate.zoomed_dm <- function(data, col, into, sep = "[^[:alnum:]]+", remove = TRUE, ...) {
  tbl <- get_zoomed_tbl(data)
  col <- tidyselect::vars_pull(names(tbl), !!enquo(col))
  separated_tbl <- separate(tbl, col = !!col, into = into, sep = sep, remove = remove, ...)
  # all columns that are not removed count as "selected"; names of "selected" are identical to "selected"
  deselected <- if (remove) col else character()
  selected <- set_names(setdiff(names(get_tracked_keys(data)), deselected))
  new_tracked_keys_zoom <- new_tracked_keys(data, selected)
  replace_zoomed_tbl(data, separated_tbl, new_tracked_keys_zoom)
}
