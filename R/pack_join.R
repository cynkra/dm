#' Pack Join
#'
#' `pack_join()` returns all rows and columns in `x` with a new packed column
#' that contains all matches from `y`.
#' @inheritParams dplyr::nest_join
#'
#' @export
pack_join <- function (x, y, by = NULL, copy = FALSE, keep = FALSE, name = NULL, ...) {
  UseMethod("pack_join")
}

#' @export
pack_join.data.frame <- function (x, y, by = NULL, copy = FALSE, keep = FALSE, name = NULL, ...) {
  name_var <- name %||% as_label(enexpr(y))
  # by2 is only used for `pack`, so we keep dplyr's messages for implicit `by`
  by2 <- by %||% intersect(names(x), names(y))
  y_packed <- tidyr::pack(y, !!name_var := -match(by2, names(y)))
  #FIXME: handle potential conflict between name_var and existing variables
  left_join(x, y_packed, by = by, copy = copy, keep = keep, ...)
}

# band_members %>% pack_join(band_instruments %>% mutate(a = 1))
