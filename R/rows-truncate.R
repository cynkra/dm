#' Truncate all rows
#'
#' `rows_truncate()` removes all rows.
#' This operation corresponds to `TRUNCATE` in SQL.
#' `...` is ignored.
#'
#' @inheritParams dplyr::rows_insert
#' @inheritParams rlang::args_dots_used
#' @param x A data frame or data frame extension (e.g. a tibble).
#' @export
rows_truncate <- function(x, ..., in_place = FALSE) {
  check_dots_used(action = warn)
  UseMethod("rows_truncate", x)
}
# For dm_rows_truncate
rows_truncate_ <- function(x, y, ..., in_place = FALSE) {
  UseMethod("rows_truncate", x)
}

#' @export
rows_truncate.data.frame <- function(x, ..., in_place = NULL) {
  stopifnot(is.null(in_place) || !in_place)
  x[0, ]
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
  check_dots_used()
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

target_table_name <- function(x, in_place) {
  name <- dbplyr::remote_name(x)

  # Only write if requested
  if (!is_null(name) && is_true(in_place)) {
    return(name)
  }

  # Abort if requested but can't write
  if (is_null(name) && is_true(in_place)) {
    abort("Can't determine name for target table. Set `in_place = FALSE` to return a lazy table.")
  }

  # Verbose by default
  if (is_null(in_place)) {
    if (is_null(name)) {
      inform("Result is returned as lazy table, because `x` does not correspond to a table that can be updated. Use `in_place = FALSE` to mute this message.")
    } else {
      inform("Result is returned as lazy table. Use `in_place = FALSE` to mute this message, or `in_place = TRUE` to write to the underlying table.")
    }
  }

  # Never write unless handled above
  NULL
}
