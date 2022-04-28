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

  tidyr::nest(.data, ..., .names_sep = .names_sep) %>%
    mutate(across(all_of(dot_nms), ~ map_chr(., jsonlite::toJSON, digits = NA)))
}

#' @export
json_nest.tbl_lazy <- function(.data, ..., .names_sep = NULL) {
  dots <- quos(...)
  if ("" %in% names2(dots)) {
    abort("All elements of `...` must be named.")
  }

  col_nms <- colnames(.data)
  nest_cols <- purrr::map(dots, ~ tidyselect::vars_select(col_nms, !!.x))
  id_cols <- setdiff(col_nms, unlist(unique(nest_cols)))

  sql_exprs <- purrr::imap(nest_cols, ~ sql_json_nest(
    dbplyr::remote_con(.data),
    cols = names(.x),
    names_sep = .names_sep,
    packed_col =.y))

  .data %>%
    group_by(across(all_of(id_cols))) %>%
    summarize(!!!sql_exprs) %>%
    ungroup()
}

sql_json_nest <- function(con, cols, names_sep, packed_col) {
  UseMethod("sql_json_nest")
}

sql_json_nest.PqConnection <- function(con, cols, names_sep, packed_col) {
  inside_cols <- remove_prefix_and_sep(cols, prefix = packed_col, sep = names_sep)
  inside_cols_idented <- dbplyr::ident(inside_cols)
  n <- length(inside_cols)
  # alternate names and expressions for `json_build_object`
  exprs <- c(syms(cols), inside_cols_idented)[rep(1:n, each = 2) + c(n, 0)]
  dbplyr::translate_sql(JSON_AGG(JSON_BUILD_OBJECT(!!!exprs)), con = con)
}

