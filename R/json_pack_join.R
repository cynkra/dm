#' JSON pack join
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' A wrapper around `pack_join()` which stores the joined data into a JSON column.
#' `json_pack_join()` returns all rows and columns in `x` with a new JSON columns that contains all packed matches from `y`.
#'
#' @inheritParams dplyr::nest_join
#' @param x,y A pair of data frames or data frame extensions (e.g. a tibble).
#' @seealso [pack_join], [json_nest_join]
#' @export
#' @examples
#' df1 <- tibble(x = 1:3)
#' df2 <- tibble(x = c(1, 1, 2), y = c("first", "second", "third"))
#' df3 <- json_pack_join(df1, df2)
#' df3
#' df3$df2
json_pack_join <- function(x, y, by = NULL, ..., copy = FALSE, keep = FALSE, name = NULL) {
  UseMethod("json_pack_join")
}

#' @export
json_pack_join.data.frame <- function(x, y, by = NULL, ..., copy = FALSE, keep = FALSE, name = NULL) {
  check_dots_empty()
  name_var <- name %||% as_label(enexpr(y))
  pack_join(x, y, by, copy, keep, name_var, ...) %>%
    mutate(
      !!name_var := map(
      unname(split(!!sym(name_var), seq.int(n()))),
      jsonlite::toJSON,
      digits = NA)
    )
}
