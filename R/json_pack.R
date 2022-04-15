#' JSON pack
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' A wrapper around [tidyr::pack()] which stores the packed data into JSON columns.
#'
#' @param .data A data frame, a data frame extension (e.g. a tibble), or  a lazy data frame (e.g. from dbplyr or dtplyr).
#' @param .names_sep If `NULL`, the default, the names will be left as is.
#' @param ... <[`tidy-select`][tidyr_tidy_select]> Columns to pack, specified
#'   using name-variable pairs of the form `new_col = c(col1, col2, col3)`.
#'   The right hand side can be any valid tidy select expression.
#' @seealso [tidyr::pack], [json_pack_join]
#' @export
#' @examples
#' df <- tibble::tibble(x1 = 1:3, x2 = 4:6, x3 = 7:9, y = 1:3)
#' packed <- json_pack(df, x = c(x1, x2, x3), y = y)
#' packed
json_pack <- function(.data, ..., .names_sep = NULL) {
  UseMethod("json_nest")
}

#' @export
json_pack.data.frame <- function(.data, ..., .names_sep = NULL) {
  dot_nms <- ...names()
  tidyr::pack(.data, ..., .names_sep = .names_sep) %>%
    mutate(across(all_of(dot_nms), ~ map_chr(., sonlite::toJSON, digits = NA)))
}
