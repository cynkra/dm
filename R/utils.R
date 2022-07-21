#' \pkg{utils} table manipulation methods for `dm_zoomed` objects
#'
#' @description
#' Extract the first or last rows from a table.
#' Use these methods without the '.dm_zoomed' suffix (see examples).
#' The methods for regular `dm` objects extract the first or last tables.
#'
#' @param x object of class `dm_zoomed`
#' @inheritParams utils::head
#' @rdname utils_table_manipulation
#'
#' @return A `dm_zoomed` object.
#'
#' @details see manual for the corresponding functions in \pkg{utils}.
#'
#' @examplesIf rlang::is_installed("nycflights13")
#' zoomed <- dm_nycflights13() %>%
#'   dm_zoom_to(flights) %>%
#'   head(4)
#' zoomed
#' dm_insert_zoomed(zoomed, new_tbl_name = "head_flights")
#' @export
head.dm_zoomed <- function(x, n = 6L, ...) {
  # dm method provided by utils
  replace_zoomed_tbl(x, head(tbl_zoomed(x), n, ...))
}

#' @rdname utils_table_manipulation
#' @export
tail.dm_zoomed <- function(x, n = 6L, ...) {
  # dm method provided by utils
  replace_zoomed_tbl(x, tail(tbl_zoomed(x), n, ...))
}
