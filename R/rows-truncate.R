#' Truncate all rows
#'
#' `rows_truncate()` removes all rows.
#' This operation corresponds to `TRUNCATE` in SQL.
#' `...` is ignored.
#'
#' @inheritParams dplyr::rows_insert
#' @inheritParams ellipsis::dots_used
#' @param x A data frame or data frame extension (e.g. a tibble).
#' @export
rows_truncate <- function(x, ..., in_place = FALSE) {
  ellipsis::check_dots_used(action = "warn")
  UseMethod("rows_truncate", x)
}

#' @export
rows_truncate.tbl_sql <- function(x, ...,
                                  in_place = NULL) {
  name <- target_table_name(x, in_place)

  if (!is_null(name)) {
    con <- dbplyr::remote_con(x)
    sql <- sql_rows_truncate(x)
    dbExecute(con, sql, immediate = TRUE)
    invisible(x)
  } else {
    x %>%
      filter(0L == 1L)
  }
}

#' @export
#' @rdname rows_truncate
sql_rows_truncate <- function(x, ...) {
  ellipsis::check_dots_used()
  UseMethod("sql_rows_truncate")
}

#' @export
sql_rows_truncate.tbl_sql <- function(x, ...) {
  name <- dbplyr::remote_name(x)
  paste0("TRUNCATE TABLE ", name)
}

#' @export
sql_rows_truncate.tbl_SQLiteConnection <- function(x, ...) {
  name <- dbplyr::remote_name(x)
  paste0("DELETE FROM ", name)
}

#' @export
sql_rows_truncate.tbl_duckdb_connection <- sql_rows_truncate.tbl_SQLiteConnection
