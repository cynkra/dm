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
    packed_col = .y,
    id_cols = id_cols,
    data = .data
  ))

  json_nest_aggregate(dbplyr::remote_con(.data), .data, id_cols, sql_exprs)
}

json_nest_aggregate <- function(con, data, id_cols, sql_exprs) {
  UseMethod("json_nest_aggregate")
}

#' @export
json_nest_aggregate.default <- function(con, data, id_cols, sql_exprs) {
  data %>%
    group_by(across(!!!syms(id_cols))) %>%
    summarize(!!!sql_exprs) %>%
    ungroup()
}

sql_json_nest <- function(con, cols, names_sep, packed_col, id_cols, data) {
  UseMethod("sql_json_nest")
}

#' @export
sql_json_nest.PqConnection <- function(con, cols, names_sep, packed_col, id_cols, data) {
  inside_cols <- remove_prefix_and_sep(cols, prefix = packed_col, sep = names_sep)
  inside_cols_idented <- dbplyr::ident(inside_cols)
  exprs <- vctrs::vec_interleave(as.list(inside_cols_idented), syms(cols))
  dbplyr::translate_sql(JSON_AGG(JSON_BUILD_OBJECT(!!!exprs)), con = con)
}

#' @export
`json_nest.tbl_Microsoft SQL Server` <- function(.data, ..., .names_sep = NULL) {
  # FIXME: we may not need json_nest.tbl_lazy if we implement json_nest methods for each DBMS
  # FIXME: We need a table alias and we use `*tmp*`, can we leverage the mechanism
  #   in `dbplyr` to increment the `q*` aliases ?

  dots <- quos(...)
  if ("" %in% names2(dots)) {
    abort("All elements of `...` must be named.")
  }
  con <- dbplyr::remote_con(.data)
  in_query <- dbplyr::sql_render(.data)

  col_nms <- colnames(.data)
  nest_cols <- purrr::map(dots, ~ tidyselect::vars_select(col_nms, !!.x))
  id_cols <- setdiff(col_nms, unlist(nest_cols))
  temp_alias <- "*tmp*"

  # build joining clause to use in final query
  joins <- glue_sql("{`id_cols`} = {`temp_alias`}.{`id_cols`}", .con = con) %>%
    glue_collapse(" AND ")

  # compute subqueries for each nested column
  nest_col_queries <- imap_chr(nest_cols, ~{
    alias <- sprintf("*tmp_%s*", .y)
    glue::glue_sql(
      "(SELECT {`.x`*} FROM (",
      in_query,
      ") {`alias`} WHERE (",
      joins,
      ") FOR JSON PATH) AS {`.y`}",
      .con = con)
  }) %>%
    glue_collapse(" ,")

  # build final query
  query <- glue_sql(
    "SELECT {`id_cols`*}, ",
    nest_col_queries,
    " FROM (",
    in_query,
    ") {`temp_alias`} GROUP BY {`id_cols`*}",
    .con = con
  )

  tbl(con, sql(query), vars = c(id_cols, names(nest_cols)))

}
