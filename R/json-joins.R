#' JSON joins
#'
#' These are wrappers around `pack_join()` and `dplyr::nest_join()` which store
#' the joined data into a json column.
#' `json_pack_join()` returns all rows and columns in x with a new json columns that contains all packed matches from y.
#' `json_nest_join()` returns all rows and columns in x with a new json columns that contains all nested matches from y.
#'
#' @inheritParams dplyr::nest_join
#' @export
json_nest_join <- function(x, y, by = NULL, copy = FALSE, keep = FALSE, name = NULL, ...) {
  UseMethod("json_nest_join")
}

#' @export
json_nest_join.data.frame <- function(x, y, by = NULL, copy = FALSE, keep = FALSE, name = NULL, ...) {
  name_var <- name %||% as_label(enexpr(y))
  dplyr::nest_join(x, y, by, copy, keep, name_var, ...) %>%
    mutate(!!name_var := map(!!sym(name_var), jsonlite::toJSON, digits = NA))
}

#' @export
#' @rdname json_nest_join
json_pack_join <- function(x, y, by = NULL, copy = FALSE, keep = FALSE, name = NULL, ...) {
  UseMethod("json_pack_join")
}

#' @export
json_pack_join.data.frame <- function(x, y, by = NULL, copy = FALSE, keep = FALSE, name = NULL, ...) {
  name_var <- name %||% as_label(enexpr(y))
  pack_join(x, y, by, copy, keep, name_var, ...) %>%
    mutate(!!name_var := map(
      unname(split(!!sym(name_var)), seq2(1, n())),
      jsonlite::toJSON,
      digits = NA)
    )
}
