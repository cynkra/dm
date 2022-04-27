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
  jsonlite::stream_out(x, con, digits = NA)
  textConnectionValue(con)
}

json_pack_tbl_lazy_impl <- function(.data, dots, tidyselect_env, group_cols, .names_sep) {
  con <- dbplyr::remote_con(.data)
  if (is_mssql(con)) {
    dbms <- "mssql"
  } else if (is_postgres(con)) {
    dbms <- "postgres"
  } else {
    abort("Unsupported DBMS")
  }
  # FIXME: move dot checking in generic (also for df methods), that's what `nest` does
  dot_nms <- names2(dots)
  if ("" %in% dot_nms) {
    abort("All elements of `...` must be named.")
  }

  # go through sets of columns to nest
  packed_data <- .data
  for (i in seq_along(dots)) {
    # columns to nest for current `...` arg
    cols_to_pack <- names(tidyselect::eval_select(dots[[i]], tidyselect_env))

    # FIXME: should we escape names using dbplyr functions ? `sql()` ? not sure how to do it here
    if (dbms == "postgres") {
      if (is.null(.names_sep)) {
        select_subquery <- paste("SELECT", toString(paste0('"', cols_to_pack, '"')))
      } else {
        prefix <- paste0(dot_nms[[i]], .names_sep)
        prefixed_lgl <- startsWith(cols_to_pack, prefix)
        # `substr()` rather than `sub()` to avoid escaping special regex chars
        cols_to_pack_new <- replace(
          cols_to_pack,
          prefixed_lgl,
          substr(cols_to_pack[prefixed_lgl], nchar(prefix) + 1, nchar(cols_to_pack[prefixed_lgl]))
        )
        select_subquery <- paste("SELECT", toString(paste(
          paste0('"', cols_to_pack, '"'), " AS ", paste0('"', cols_to_pack_new, '"')
        )))
      }
      to_json_subquery <- sprintf("TO_JSON((SELECT d FROM (%s) d))", select_subquery)
      packed_data <-
        packed_data %>%
        mutate(!!dot_nms[[i]] := sql(to_json_subquery)) %>%
        # don't remove cols that have or will be overwritten
        select(-all_of(setdiff(cols_to_pack, dot_nms)))
    } else if (dbms == "mssql") {
      abort("mssql not implemented yet")
      # to_json_subquery <- paste0("(", query, " FOR JSON PATH)")
    }
  }
  packed_data
}


#' @export
json_pack.tbl_lazy <- function(.data, ..., .names_sep = NULL) {
  dots <- enquos(...)
  tidyselect_env <- set_names(colnames(.data))
  all_cols_to_pack <- tidyselect::eval_select(
    expr = expr(c(!!!unname(dots))),
    data = tidyselect_env
  ) %>%
    names()
  group_cols <- setdiff(tidyselect_env, all_cols_to_pack)

  json_pack_tbl_lazy_impl(.data, dots, tidyselect_env, group_cols, .names_sep)
}
