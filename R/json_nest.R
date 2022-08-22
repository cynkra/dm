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

#' @export
`json_nest_aggregate.Microsoft SQL Server` <- function(con, data, id_cols, sql_exprs) {
  query <-
    json_nest_aggregate.default(con, data, id_cols, sql_exprs) %>%
    dbplyr::sql_render()
  # fetch subquery alias and use in place of the placeholder
  select_subquery_alias <- sub('.* "(.*)"[[:space:]]+GROUP BY "[^"]+"$', "\\1", query)
  query <- gsub('" = PLACEHOLDER\\."', glue('" = "{select_subquery_alias}"."'), query)
  tbl(dbplyr::remote_con(data), sql(query))
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
`sql_json_nest.Microsoft SQL Server` <- function(con, cols, names_sep, packed_col, id_cols, data) {
  inside_cols <- remove_prefix_and_sep(cols, prefix = packed_col, sep = names_sep)
  join_subquery <- glue_collapse(glue('"{id_cols}" = PLACEHOLDER."{id_cols}"'), " AND ")
  filter_select_subquery <-
    data %>%
    filter(sql(join_subquery)) %>%
    select(!!!set_names(syms(cols), inside_cols)) %>%
    dbplyr::sql_render()
  query <- glue("({filter_select_subquery} FOR JSON PATH)")
  sql(query)
}

#' @export
`json_nest.tbl_Microsoft SQL Server` <- function(.data, ..., .names_sep = NULL) {
  # FIXME: we may not need json_nest.tbl_lazy if we implement json_nest methods for each DBMS
  # FIXME: The old code is still there, just not called
  # FIXME: `DBI::dbQuoteLiteral()` uses simple quotes for mssql, this seems wrong,
  #   queries work if double quotes are used. should we implement our own fix ?
  # FIXME: We need a table alias and we use `*tmp*`, can we leverage the mechanism
  #   in `dbplyr` to increment the `q*` aliases ?

  dots <- quos(...)
  if ("" %in% names2(dots)) {
    abort("All elements of `...` must be named.")
  }
  con <- dbplyr::remote_con(.data)

  # define and protect column names, table name and alias
  tbl_name <-
    dbplyr::remote_name(.data) %>%
    DBI::dbQuoteLiteral(con, .)
  col_nms <- colnames(.data)
  nest_cols <- purrr::map(dots, ~ tidyselect::vars_select(col_nms, !!.x))
  id_cols <-
    setdiff(col_nms, unlist(nest_cols)) %>%
    DBI::dbQuoteLiteral(con, .)
  col_nms <- DBI::dbQuoteLiteral(con, col_nms)
  temp_alias <- DBI::dbQuoteLiteral(con, "*tmp*")

  # build joining clause to use in final query
  joins <- glue("{id_cols} = {temp_alias}.{id_cols}") %>%
    glue_collapse(" AND ")

  # compute subqueries for each nested column
  nest_col_queries <- imap_chr(nest_cols, ~ {
    cols <- toString(DBI::dbQuoteLiteral(con, .x))
    alias <- DBI::dbQuoteLiteral(con, .y)
    glue::glue("(SELECT {cols} FROM {tbl_name} WHERE ({joins}) FOR JSON PATH) AS {alias}")
  })

  # build final query
  query <- glue::glue(
    'SELECT {toString(id_cols)}, {toString(nest_col_queries)} ',
    'FROM (SELECT {toString(col_nms)} FROM {tbl_name}) {temp_alias} GROUP BY {id_cols}'
  )

  # HACK! see FIXME at top
  query <- gsub("'", '"', query)

  tbl(con, sql(query))
}
