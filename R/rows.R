#' Persisting data for single tables
#'
#' @description
#' \lifecycle{experimental}
#'
#' These methods provide a framework for updating data in existing tables.
#' Unlike [compute()], [copy_to()] or [copy_dm_to()], no new tables are created
#' on the database.
#' All operations expect that both existing and new data are presented
#' in two compatible [tbl] objects on the same data source.
#'
#' These operations, in contrast to all other operations,
#' may lead to irreversible changes to the underlying database.
#' Therefore, persistence must be requested explicitly with `persist = TRUE`.
#' By default, an informative message is given.
#'
#' @param target Target table object.
#' @param source Source table object.
#' @param ... Must be empty.
#' @param persist
#'   Set to `TRUE` for running the operation without persisting.
#'   In this mode, a modified version of `target` is returned.
#'   This allows verifying the results of an operation before actually
#'   applying it.
#'   Set to `FALSE` to perform the update on the database table.
#'   By default, an informative message is shown.
#'
#' @return A tbl object of the same structure as `target`.
#'   If `persist = TRUE`, [invisible] and identical to `target_dm`.
#'
#' @name rows
#' @examples
#' if (rlang::is_installed("RSQLite")) {
#'   # Truncated table:
#'   flights_init <- nycflights13::flights[0, ]
#'
#'   sqlite <- src_sqlite(":memory:", create = TRUE)
#'
#'   # Target database:
#'   flights_sqlite <- copy_to(sqlite, flights_init, temporary = FALSE)
#'   print(count(flights_sqlite))
#'
#'   # First update:
#'   flights_jan_1 <-
#'     nycflights13::flights %>%
#'     filter(month == 1, day == 1)
#'   print(count(flights_jan_1))
#'
#'   # Copy to temporary tables on the target database:
#'   flights_jan_1_sqlite <- copy_to(sqlite, flights_jan_1)
#'
#'   # Dry run by default:
#'   tbl_insert(flights_sqlite, flights_jan_1_sqlite)
#'   print(count(flights_sqlite))
#'
#'   # Explicitly request persistence:
#'   tbl_insert(flights_sqlite, flights_jan_1_sqlite, persist = TRUE)
#'   print(count(flights_sqlite))
#'
#'   # Second update:
#'   flights_jan_2 <-
#'     nycflights13::flights %>%
#'     filter(month == 1, day == 2)
#'
#'   # Copy to temporary tables on the target database:
#'   flights_jan_2_sqlite <- copy_to(sqlite, flights_jan_2)
#'
#'   # Explicit dry run:
#'   flights_new <- tbl_insert(
#'     flights_sqlite,
#'     flights_jan_2_sqlite,
#'     persist = FALSE
#'   )
#'   print(count(flights_new))
#'   print(count(flights_sqlite))
#'
#'   # Check for consistency before applying:
#'   flights_new %>%
#'     dplyr::count(year, month, day)
#'
#'   # Apply:
#'   tbl_insert(flights_sqlite, flights_jan_2_sqlite, persist = TRUE)
#'   print(count(flights_sqlite))
#' }
NULL


#' tbl_insert
#'
#' `tbl_insert()` adds new records.
#' @rdname rows
#' @export
tbl_insert <- function(target, source, ..., persist = NULL) {
  ellipsis::check_dots_used(action = warn)
  UseMethod("tbl_insert", target)
}

#' @export
tbl_insert.data.frame <- function(target, source, ..., persist = NULL) {
  vctrs::vec_rbind(target, source)
}

#' @export
tbl_insert.tbl_dbi <- function(target, source, ..., persist = NULL) {
  # Also in dry-run mode, for early notification of problems
  # Already quoted
  name <- target_table_name(target, persist)

  if (is_null(persist)) {
    warn("Not persisting, use `persist = FALSE` to turn off this warning.")
    persist <- FALSE
  }

  if (persist) {
    sql <- paste0(
      "INSERT INTO ", name, "\n",
      dbplyr::remote_query(source)
    )
    dbExecute(dbplyr::remote_con(target), sql)
    invisible(NULL)
  } else {
    union_all(target, source)
  }
}

target_table_name <- function(x, persist) {
  name <- dbplyr::remote_name(x)
  if (is.null(name)) {
    raise <- if (persist) abort else warn
    raise("Can't determine name for target table.")
  }
  name
}
