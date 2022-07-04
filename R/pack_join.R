#' Pack Join
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `pack_join()` returns all rows and columns in `x` with a new packed column
#' that contains all matches from `y`.
#' @inheritParams dplyr::nest_join
#' @param x,y A pair of data frames or data frame extensions (e.g. a tibble).
#'
#' @export
#' @seealso [dplyr::nest_join()], [tidyr::pack()]
#' @examples
#' df1 <- tibble::tibble(x = 1:3)
#' df2 <- tibble::tibble(x = c(1, 1, 2), y = c("first", "second", "third"))
#' pack_join(df1, df2)
pack_join <- function(x, y, by = NULL, ..., copy = FALSE, keep = FALSE, name = NULL) {
  UseMethod("pack_join")
}

#' @export
pack_join.dm <- function(x, ...) {
  check_zoomed(x)
}

#' @rdname pack_join
#' @export
pack_join.zoomed_dm <- function(x, y, by = NULL, ..., copy = FALSE, keep = FALSE, name = NULL) {
  y_name <- dm_tbl_name(x, {{ y }})
  zoomed <- dm_get_zoom(x, c("table", "zoom", "col_tracker_zoom"))
  x_tbl <- zoomed$zoom[[1]]
  y_tbl <- dm_get_tables_impl(x)[[y_name]]

  joined_tbl <- pack_join(x_tbl, y_tbl, by, ..., copy = copy, keep = keep, name = name)
  replace_zoomed_tbl(x, joined_tbl)
}

#' @export
pack_join.data.frame <- function(x, y, by = NULL, ..., copy = FALSE, keep = FALSE, name = NULL) {
  check_dots_empty()
  name_var <- name %||% as_label(enexpr(y))
  if (!copy && inherits(y, "tbl_lazy"))
    abort("`x` and `y` must share the same src, set `copy` = TRUE (may be slow)")
  y_local <- collect(y)
  # by2 is only used for `pack`, so we keep dplyr's messages for implicit `by`
  by2 <- by %||% intersect(names(x), names(y_local))
  x_nms <- colnames(x)
  name_var_unique <- last(make.unique(c(names(y_local), x_nms, name_var)))
  y_packed <- tidyr::pack(y_local, !!name_var_unique := -all_of(by2))
  joined <- left_join(x, y_packed, by = by, copy = copy, keep = keep)
  # overwrite existing column silently in x if collision, not very safe but consistent with dplyr::nest_join
  if (name_var %in% x_nms) {
    joined[[name_var]] <- NULL
  }
  rename(joined, !!name_var := !!name_var_unique)
}
