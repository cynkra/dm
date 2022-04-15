# FIXME: once tbl_lazy method is implemented, update doc of `.data` arg

#' JSON pack
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' A wrapper around `tidyr::pack()` which stores the packed data into JSON columns.
#'
#' @inheritParams tidyr::pack
#' @seealso [tidyr::pack], [json_pack_join]
#' @export
#' @examples
#' df <- tibble::tibble(x1 = 1:3, x2 = 4:6, x3 = 7:9, y = 1:3)
#' packed <- json_pack(df, x = c(x1, x2, x3), y = y)
#' packed
#' packed$x
json_pack <- function(.data, ..., .names_sep = NULL) {
  UseMethod("json_nest")
}

#' @export
json_pack.data.frame <- function(.data, ..., .names_sep = NULL) {
  dot_nms <- ...names()
  tidyr::pack(.data, ..., .names_sep = .names_sep) %>%
    mutate(across(all_of(dot_nms), ~ map(., jsonlite::toJSON, digits = NA)))
}
