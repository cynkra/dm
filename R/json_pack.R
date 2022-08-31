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

sql_json_pack <- function(con, cols, names_sep, packed_col, data, ...) {
  UseMethod("sql_json_pack")
}

#' @export
sql_json_pack.PqConnection <- function(con, cols, names_sep, packed_col, data, ...) {
  inside_cols <- remove_prefix_and_sep(cols, prefix = packed_col, sep = names_sep)
  inside_cols_idented <- dbplyr::ident(inside_cols)
  exprs <- vctrs::vec_interleave(as.list(inside_cols_idented), syms(cols))
  dbplyr::translate_sql(JSON_BUILD_OBJECT(!!!exprs), con = con)
}

remove_prefix_and_sep <- function(x, prefix, sep) {
  if (is.null(sep)) return(x)
  prefix_and_sep <- paste0(prefix, sep)
  prefixed_lgl <- startsWith(x, prefix_and_sep)
  # `substr()` rather than `sub()` to avoid escaping special regex chars
  replacements <- substr(x[prefixed_lgl], nchar(prefix_and_sep) + 1, nchar(x[prefixed_lgl]))
  replace(x, prefixed_lgl, replacements)
}


#' @export
sql_json_nest.PqConnection <- function(con, cols, names_sep, packed_col, id_cols, data, ...) {
  inside_cols <- remove_prefix_and_sep(cols, prefix = packed_col, sep = names_sep)
  inside_cols_idented <- dbplyr::ident(inside_cols)
  exprs <- vctrs::vec_interleave(as.list(inside_cols_idented), syms(cols))
  dbplyr::translate_sql(JSON_AGG(JSON_BUILD_OBJECT(!!!exprs)), con = con)
}

#' @export
`json_pack.tbl_Microsoft SQL Server` <- function(.data, ..., .names_sep = NULL) {
  dots <- quos(...)
  if ("" %in% names2(dots)) {
    abort("All elements of `...` must be named.")
  }
  con <- dbplyr::remote_con(.data)
  in_query <- dbplyr::sql_render(.data)

  col_nms <- colnames(.data)

  # packing_plan contains information and subqueries, one row for each packing column
  packing_plan <- purrr::imap_dfr(dots, function(quo_selection, packing_name) {
    packed_names <- tidyselect::vars_select(col_nms, !!quo_selection)
    if (!is.null(.names_sep)) {
      new_packed_names <-
        remove_prefix_and_sep(packed_names, prefix = packing_name, sep = .names_sep)
      selected <-
        paste(
          glue_sql("{`packed_names`}", .con = con),
          glue_sql("{`new_packed_names`}", .con = con)
        ) %>%
        glue_collapse(", ")
    } else {
      new_packed_names <- packed_names
      selected <- glue_sql("{`packed_names`*}", .con = con)
    }

    for_json_path_query <- glue_sql(
      "(SELECT value FROM OPENJSON((SELECT ", selected, " FOR JSON PATH))) AS {`packing_name`}",
      .con = con
    )

    tibble::tibble_row(
      packing_name = packing_name,
      packed_names = list(packed_names),
      new_packed_names = list(new_packed_names),
      selected = selected,
      for_json_path_query = for_json_path_query,
    )
  })

  id_cols <- setdiff(col_nms, unlist(packing_plan$packed_names))
  temp_alias <- "*tmp*"

  # build final query
  out_query <- glue_sql(
    "SELECT {`id_cols`*}, ",
    glue_collapse(packing_plan$for_json_path_query, ", "),
    " FROM (",
    in_query,
    ") {`temp_alias`}",
    .con = con
  )

  tbl(con, sql(out_query), vars = c(id_cols, packing_plan$packing_name))
}
