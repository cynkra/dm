# FIXME: once tbl_lazy method is implemented, update doc of `.data` arg

#' JSON nest
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' A wrapper around `tidyr::nest()` which stores the nested data into JSON columns.
#'
#' @inheritParams tidyr::nest
#' @seealso [tidyr::nest], [json_nest_join]
#' @export
#' @examples
#' df <- tibble::tibble(x = c(1, 1, 1, 2, 2, 3), y = 1:6, z = 6:1)
#' nested <- json_nest(df, data = c(y, z))
#' nested
#' nested$data
json_nest <- function(.data, ..., .names_sep = NULL) {
  UseMethod("json_nest")
}

#' @export
json_nest.data.frame <- function(.data, ..., .names_sep = NULL) {
  dot_nms <- ...names()
  # `{tidyr}` only warns but since we don't need backward compatibility we're
  #   better off failing
  if (is_null(dot_nms) || "" %in% dot_nms) {
    abort("All elements of `...` must be named.")
  }
  tidyr::nest(.data, ..., .names_sep = .names_sep) %>%
    mutate(across(all_of(dot_nms), ~ map(., jsonlite::toJSON, digits = NA)))
}

