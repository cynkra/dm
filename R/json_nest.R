#' JSON nest
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' A wrapper around [tidyr::nest()] which stores the nested data into JSON columns.
#'
#' @param .data A data frame, a data frame extension (e.g. a tibble), or  a lazy data frame (e.g. from dbplyr or dtplyr).
#' @param .names_sep If `NULL`, the default, the names will be left as is.
#' @param ... <[`tidy-select`][tidyr_tidy_select]> Columns to pack, specified
#'   using name-variable pairs of the form `new_col = c(col1, col2, col3)`.
#'   The right hand side can be any valid tidy select expression.
#' @seealso [tidyr::nest()], [json_nest_join()]
#' @export
#' @examples
#' df <- tibble::tibble(x = c(1, 1, 1, 2, 2, 3), y = 1:6, z = 6:1)
#' nested <- json_nest(df, data = c(y, z))
#' nested
json_nest <- function(.data, ..., .names_sep = NULL) {
  UseMethod("json_nest")
}

#' @export
json_nest.data.frame <- function(.data, ..., .names_sep = NULL) {
  check_suggested("jsonlite", use = TRUE, top_level_fun = "json_nest")
  dot_nms <- ...names()
  # `{tidyr}` only warns but since we don't need backward compatibility we're
  #   better off failing
  if (is_null(dot_nms) || "" %in% dot_nms) {
    abort("All elements of `...` must be named.")
  }
  tidyr::nest(.data, ..., .names_sep = .names_sep) %>%
    mutate(across(all_of(dot_nms), ~ map_chr(., jsonlite::toJSON, digits = NA)))
}

#' @export
json_nest.tbl_lazy <- function(.data, ..., .names_sep = NULL) {
  dots <- enquos(...)
  tidyselect_env <- set_names(colnames(.data))
  all_cols_to_nest <- tidyselect::eval_select(
    expr = expr(c(!!!unname(dots))),
    data = tidyselect_env
  ) %>%
    names()
  group_cols <- setdiff(tidyselect_env, all_cols_to_nest)

  packed_data <- json_pack_tbl_lazy_impl(.data, dots, tidyselect_env, group_cols, .names_sep)

  nested_data <- packed_data %>%
    group_by(across(!!group_cols)) %>%
    summarize(across(!!names(dots), JSON_AGG))

  nested_data
}
