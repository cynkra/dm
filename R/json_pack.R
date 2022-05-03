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
#' @seealso [tidyr::pack()], [json_pack_join()]
#' @export
#' @examples
#' df <- tibble::tibble(x1 = 1:3, x2 = 4:6, x3 = 7:9, y = 1:3)
#' packed <- json_pack(df, x = c(x1, x2, x3), y = y)
#' packed
json_pack <- function(.data, ..., .names_sep = NULL) {
  UseMethod("json_pack")
}

#' @export
json_pack.data.frame <- function(.data, ..., .names_sep = NULL) {
  check_suggested("jsonlite", use = TRUE, top_level_fun = "json_pack")
  dot_nms <- ...names()
  tidyr::pack(.data, ..., .names_sep = .names_sep) %>%
    mutate(across(all_of(dot_nms), to_packed_json))
}

to_packed_json <- function(x) {
  con <- textConnection(NULL, open = "w")
  on.exit(close(con))
  jsonlite::stream_out(x, con, digits = NA, verbose = FALSE)
  textConnectionValue(con)
}

#' @export
json_pack.tbl_lazy <- function(.data, ..., .names_sep = NULL) {
  dots <- quos(...)
  if ("" %in% names2(dots)) {
    abort("All elements of `...` must be named.")
  }

  col_nms <- colnames(.data)
  pack_cols <- purrr::map(dots, ~ tidyselect::vars_select(col_nms, !!.x))
  id_cols <- setdiff(col_nms, unlist(unique(pack_cols)))

  sql_exprs <- purrr::imap(pack_cols, ~ sql_json_pack(
    dbplyr::remote_con(.data),
    cols = names(.x),
    names_sep = .names_sep,
    packed_col = .y,
    data = .data
  ))

  .data %>%
    transmute(!!!syms(id_cols), !!!sql_exprs)
}

sql_json_pack <- function(con, cols, names_sep, packed_col, data) {
  UseMethod("sql_json_pack")
}

#' @export
sql_json_pack.PqConnection <- function(con, cols, names_sep, packed_col, data) {
  inside_cols <- remove_prefix_and_sep(cols, prefix = packed_col, sep = names_sep)
  inside_cols_idented <- dbplyr::ident(inside_cols)
  exprs <- vctrs::vec_interleave(as.list(inside_cols_idented), syms(cols))
  dbplyr::translate_sql(JSON_BUILD_OBJECT(!!!exprs), con = con)
}

#' @export
`sql_json_pack.Microsoft SQL Server` <- function(con, cols, names_sep, packed_col, data) {
  inside_cols <- remove_prefix_and_sep(cols, prefix = packed_col, sep = names_sep)
  subquery <-
    data %>%
    select(!!!set_names(syms(cols), inside_cols)) %>%
    dbplyr::sql_render()
  subquery_trimmed <- sub('FROM "[^"]+"$', "", subquery)
  query <- glue("(SELECT value FROM OPENJSON(({subquery_trimmed} FOR JSON PATH)))")
  sql(query)
}


remove_prefix_and_sep <- function(x, prefix, sep) {
  if (is.null(sep)) return(x)
  prefix_and_sep <- paste0(prefix, sep)
  prefixed_lgl <- startsWith(x, prefix_and_sep)
  # `substr()` rather than `sub()` to avoid escaping special regex chars
  replacements <- substr(x[prefixed_lgl], nchar(prefix_and_sep) + 1, nchar(x[prefixed_lgl]))
  replace(x, prefixed_lgl, replacements)
}
