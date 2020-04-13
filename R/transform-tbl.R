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
#' @param target Target table object.
#' @param source Source table object.
#' @param ... Must be empty.
#' @param dry_run Set to `TRUE` for running the operation without persisting.
#'   In this mode, a modified version of `target` is returned.
#'   This allows verifying the results of an operation before actually
#'   applying it.
#'
#' @return A tbl object of the same structure as `target`,
#'   visible only if `dry_run = TRUE`, otherwise [invisible].
#'   Identical to `target_dm` when run on a database with `dry_run = FALSE`.
#'
#' @name persist-tbl
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
#'   tbl_insert(flights_sqlite, flights_jan_1_sqlite)
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
#'   # Dry run:
#'   flights_new <- tbl_insert(
#'     flights_sqlite,
#'     flights_jan_2_sqlite,
#'     dry_run = TRUE
#'   )
#'   print(count(flights_new))
#'   print(count(flights_sqlite))
#'
#'   # Check for consistency before applying:
#'   flights_new %>%
#'     dplyr::count(year, month, day)
#'
#'   # Apply:
#'   tbl_insert(flights_sqlite, flights_jan_2_sqlite)
#'   print(count(flights_sqlite))
#' }
NULL


#' tbl_insert
#'
#' `tbl_insert()` adds new records.
#' @rdname persist-tbl
#' @export
tbl_insert <- function(target, source, ..., dry_run = FALSE) {
  ellipsis::check_dots_used(action = warn)
  UseMethod("tbl_insert", target)
}

#' @export
tbl_insert.data.frame <- function(target, source, ..., dry_run = FALSE) {
  vctrs::vec_rbind(target, source)
}

#' @export
tbl_insert.tbl_dbi <- function(target, source, ..., dry_run = FALSE) {
  # Also in dry-run mode, for early notification of problems
  # Already quoted
  name <- target_table_name(target, dry_run)

  if (dry_run) {
    union_all(target, source)
  } else {
    sql <- paste0(
      "INSERT INTO ", name, "\n",
      sql_render(source)
    )
    dbExecute(target$con, sql)
    invisible(NULL)
  }
}

target_table_name <- function(x, dry_run) {
  if (!inherits(x$ops, "op_base_remote")) {
    raise <- if (dry_run) warn else abort
    raise("Can't determine name for target table.")
  } else {
    x$ops$x
  }
}
