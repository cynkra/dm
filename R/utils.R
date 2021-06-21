#' \pkg{utils} table manipulation methods for `zoomed_dm` objects
#'
#' Extract the first or last rows from a table.
#' Use these methods without the '.zoomed_dm' suffix (see examples).
#' The methods for regular `dm` objects extract the first or last tables.
#'
#' @param x object of class `zoomed_dm`
#' @inheritParams utils::head
#' @rdname utils_table_manipulation
#'
#' @return A `zoomed_dm` object.
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
head.zoomed_dm <- function(x, n = 6L, ...) { # dm method provided by utils
  replace_zoomed_tbl(x, head(tbl_zoomed(x), n, ...))
}

#' @rdname utils_table_manipulation
#' @export
tail.zoomed_dm <- function(x, n = 6L, ...) { # dm method provided by utils
  replace_zoomed_tbl(x, tail(tbl_zoomed(x), n, ...))
}
