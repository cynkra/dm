#' JSON nest join
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' A wrapper around `dplyr::nest_join()` which stores the joined data into a JSON column.
#' `json_nest_join()` returns all rows and columns in `x` with a new JSON columns that contains all nested matches from `y`.
#'
#' @inheritParams dplyr::nest_join
#' @param x,y A pair of data frames or data frame extensions (e.g. a tibble).
#' @seealso [dplyr::nest_join], [json_pack_join]
#' @export
#' @examples
#' df1 <- tibble::tibble(x = 1:3)
#' df2 <- tibble::tibble(x = c(1, 1, 2), y = c("first", "second", "third"))
#' df3 <- json_nest_join(df1, df2)
#' df3
#' df3$df2
json_nest_join <- function(x, y, by = NULL, ..., copy = FALSE, keep = FALSE, name = NULL) {
  UseMethod("json_nest_join")
}

#' @export
json_nest_join.data.frame <- function(x, y, by = NULL, ..., copy = FALSE, keep = FALSE, name = NULL) {
  check_dots_empty()
  name_var <- name %||% as_label(enexpr(y))
  dplyr::nest_join(x, y, by, copy = copy, keep = keep, name = name_var, ...) %>%
    mutate(!!name_var := map(!!sym(name_var), jsonlite::toJSON, digits = NA))
}
