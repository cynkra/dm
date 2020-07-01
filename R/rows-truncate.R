#' Truncate all rows
#'
#' `rows_truncate()` removes all rows.
#' This operation corresponds to `TRUNCATE` in SQL.
#' `...` is ignored.
#'
#' @inheritParams dplyr::rows_insert
#' @param x A data frame or data frame extension (e.g. a tibble).
#' @export
rows_truncate <- function(x, ..., copy = FALSE, in_place = FALSE) {
  ellipsis::check_dots_used(action = "warn")
  UseMethod("rows_truncate", x)
}
