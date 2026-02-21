#' \pkg{tidyr} table manipulation methods for zoomed dm objects
#'
#' @description
#' Use these methods without the '.dm_zoomed' suffix (see examples).
#' @param data object of class `dm_zoomed`
#' @param ... For `unite.dm_zoomed`: see [tidyr::unite()]
#'
#' For `separate.dm_zoomed`: see [tidyr::separate()]
#' @inheritParams tidyr::unite
#' @inheritParams tidyr::separate
#' @name tidyr_table_manipulation
#' @examplesIf rlang::is_installed("nycflights13")
#' zoom_united <- dm_nycflights13() %>%
#'   dm_zoom_to(flights) %>%
#'   select(year, month, day) %>%
#'   unite("month_day", month, day)
#' zoom_united
#' zoom_united %>%
#'   separate(month_day, c("month", "day"))
NULL
#' @export
unite.dm <- function(data, col, ..., sep = "_", remove = TRUE, na.rm = FALSE) {
  check_zoomed(data)
}

#' @rdname tidyr_table_manipulation
#' @export
unite.dm_zoomed <- function(data, col, ..., sep = "_", remove = TRUE, na.rm = FALSE) {
  tbl <- tbl_zoomed(data)
  united_tbl <- unite(tbl, col = !!col, ..., sep = sep, remove = remove, na.rm = na.rm)
  replace_zoomed_tbl(data, united_tbl)
}

#' @rdname tidyr_table_manipulation
#' @export
unite.dm_keyed_tbl <- function(data, col, ..., sep = "_", remove = TRUE, na.rm = FALSE) {
  keys_info <- keyed_get_info(data)
  tbl <- unclass_keyed_tbl(data)
  out <- unite(tbl, col = {{ col }}, ..., sep = sep, remove = remove, na.rm = na.rm)
  keys_info <- keyed_drop_missing_key_cols(keys_info, colnames(out))
  new_keyed_tbl_from_keys_info(out, keys_info)
}

#' @export
separate.dm <- function(
  data,
  col,
  into,
  sep = "[^[:alnum:]]+",
  remove = TRUE,
  convert = FALSE,
  extra = "warn",
  fill = "warn",
  ...
) {
  check_zoomed(data)
}

#' @rdname tidyr_table_manipulation
#' @export
separate.dm_zoomed <- function(
  data,
  col,
  into,
  sep = "[^[:alnum:]]+",
  remove = TRUE,
  convert = FALSE,
  extra = "warn",
  fill = "warn",
  ...
) {
  tbl <- tbl_zoomed(data)
  separated_tbl <- separate(
    tbl,
    col = {{ col }},
    into = into,
    sep = sep,
    remove = remove,
    convert = convert,
    extra = extra,
    fill = fill,
    ...
  )
  replace_zoomed_tbl(data, separated_tbl)
}

#' @rdname tidyr_table_manipulation
#' @export
separate.dm_keyed_tbl <- function(
  data,
  col,
  into,
  sep = "[^[:alnum:]]+",
  remove = TRUE,
  convert = FALSE,
  extra = "warn",
  fill = "warn",
  ...
) {
  keys_info <- keyed_get_info(data)
  tbl <- unclass_keyed_tbl(data)
  out <- separate(
    tbl,
    col = {{ col }},
    into = into,
    sep = sep,
    remove = remove,
    convert = convert,
    extra = extra,
    fill = fill,
    ...
  )
  keys_info <- keyed_drop_missing_key_cols(keys_info, colnames(out))
  new_keyed_tbl_from_keys_info(out, keys_info)
}
