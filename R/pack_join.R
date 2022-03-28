#' Pack Join
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `pack_join()` returns all rows and columns in `x` with a new packed column
#' that contains all matches from `y`.
#' @inheritParams dplyr::nest_join
#'
#' @export
pack_join <- function(x, y, by = NULL, copy = FALSE, keep = FALSE, name = NULL, ...) {
  UseMethod("pack_join")
}

#' @export
pack_join.data.frame <- function(x, y, by = NULL, copy = FALSE, keep = FALSE, name = NULL, ...) {
  name_var <- name %||% as_label(enexpr(y))
  if (!copy && inherits(y, "tbl_lazy"))
    abort("`x` and `y` must share the same src, set `copy` = TRUE (may be slow)")
  y_local <- collect(y)
  # by2 is only used for `pack`, so we keep dplyr's messages for implicit `by`
  by2 <- by %||% intersect(names(x), names(y_local))
  x_nms <- colnames(x)
  name_var_unique <- last(make.unique(c(names(y_local), x_nms, name_var)))
  y_packed <- tidyr::pack(y_local, !!name_var_unique := -all_of(by2))
  joined <- left_join(x, y_packed, by = by, copy = copy, keep = keep, ...)
  # overwrite existing column silently in x if collision, not very safe but consistent with dplyr::nest_join
  if(name_var %in% x_nms) {
    joined[[name_var]] <- NULL
  }
  rename(joined, !!name_var := !!name_var_unique)
}
