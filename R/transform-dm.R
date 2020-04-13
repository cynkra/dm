#' Persisting data
#'
#' @description
#' \lifecycle{experimental}
#'
#' These functions provide a framework for updating data in existing tables.
#' Unlike [compute()], [copy_to()] or [copy_dm_to()], no new tables are created.
#' All operations expect that both existing and new data are presented
#' in two compatible dm objects on the same data source.
#'
#' The tables in the target dm are ordered topologically
#' so that parent (dimension) tables receive insertions
#' before child (fact) tables.
#' The order is reversed for delete operations.
#'
#' @param target_dm Target dm object.
#' @param dm dm object with new data.
#' @param ... Must be empty.
#' @param dry_run Set to `TRUE` for running the operation without persisting.
#'   In this mode, a modified version of `target_dm` is returned.
#'   This allows verifying the results of an operation before actually
#'   applying it.
#'
#' @return A dm object of the same [dm_ptype()] as `target_dm`,
#'   visible only if `dry_run = TRUE`, otherwise [invisible].
#'   Identical to `target_dm` when run on a database with `dry_run = FALSE`.
#'
#' @name persist
#' @examples
#' if (rlang::is_installed("RSQLite")) {
#'   # Entire dataset with all dimension tables populated
#'   # with flights and weather data truncated:
#'   flights_init <-
#'     dm_nycflights() %>%
#'     dm_zoom_to(flights) %>%
#'     filter(FALSE) %>%
#'     dm_update_zoomed() %>%
#'     dm_zoom_to(weather) %>%
#'     filter(FALSE) %>%
#'     dm_update_zoomed()
#'
#'   sqlite <- src_sqlite(":memory:", create = TRUE)
#'
#'   # Target database:
#'   flights_sqlite <- dm_copy_to(sqlite, flights_init, temporary = FALSE)
#'   print(dm_nrow(flights_sqlite))
#'
#'   # First update:
#'   flights_jan_1 <-
#'     dm_nycflights() %>%
#'     dm_select_tbl(flights) %>%
#'     dm_zoom_to(flights) %>%
#'     filter(month == 1, day == 1) %>%
#'     dm_update_zoomed() %>%
#'     dm_zoom_to(weather) %>%
#'     filter(month == 1, day == 1) %>%
#'     dm_update_zoomed()
#'   print(dm_nrow(flights_jan_1))
#'
#'   # Copy to temporary tables on the target database:
#'   flights_jan_1_sqlite <- dm_copy_to(sqlite, flights_jan_1)
#'   dm_insert(flights_sqlite, flights_jan_1_sqlite)
#'   print(dm_nrow(flights_sqlite))
#'
#'   # Second update:
#'   flights_jan_2 <-
#'     dm_nycflights() %>%
#'     dm_select_tbl(flights) %>%
#'     dm_zoom_to(flights) %>%
#'     filter(month == 1, day == 2) %>%
#'     dm_update_zoomed() %>%
#'     dm_zoom_to(weather) %>%
#'     filter(month == 1, day == 2) %>%
#'     dm_update_zoomed()
#'
#'   # Copy to temporary tables on the target database:
#'   flights_jan_2_sqlite <- dm_copy_to(sqlite, flights_jan_2)
#'
#'   # Dry run:
#'   flights_new <- dm_insert(
#'     flights_sqlite,
#'     flights_jan_2_sqlite,
#'     dry_run = TRUE
#'   )
#'   print(dm_nrow(flights_new))
#'   print(dm_nrow(flights_sqlite))
#'
#'   # Check for consistency before applying:
#'   flights_new %>%
#'     dm_examine_constraints()
#'
#'   # Apply:
#'   dm_insert(flights_sqlite, flights_jan_2_sqlite)
#'   print(dm_nrow(flights_sqlite))
#' }
NULL


#' dm_insert
#'
#' `dm_insert()` adds new records.
#' The primary keys must differ from existing records.
#' @rdname persist
#' @export
dm_insert <- function(target_dm, dm, ..., dry_run = FALSE) {
  check_dots_empty()

  dm_transform(target_dm, dm, tbl_insert, top_down = TRUE, dry_run)
}

# dm_update
#
# `dm_update()` updates existing records.
# Primary keys must match for all records to be updated.
#
# @rdname persist
# @export
dm_update <- function(target_dm, dm, ..., dry_run = FALSE) {
  check_dots_empty()

  dm_transform(target_dm, dm, tbl_update, top_down = TRUE, dry_run)
}

# dm_upsert
#
# `dm_upsert()` updates existing records and adds new records,
# based on the primary key.
#
# @rdname persist
# @export
dm_upsert <- function(target_dm, dm, ..., dry_run = FALSE) {
  check_dots_empty()

  dm_transform(target_dm, dm, tbl_upsert, top_down = TRUE, dry_run)
}

# dm_delete
#
# `dm_delete()` removes matching records, based on the primary key.
# The order in which the tables are processed is reversed.
#
# @rdname persist
# @export
dm_delete <- function(target_dm, dm, ..., dry_run = FALSE) {
  check_dots_empty()

  dm_transform(target_dm, dm, tbl_delete, top_down = FALSE, dry_run)
}

# dm_truncate
#
# `dm_truncate()` removes all records, only for tables in `dm`.
#
# @rdname persist
# @export
dm_truncate <- function(target_dm, dm, ..., dry_run = FALSE) {
  check_dots_empty()

  dm_transform(target_dm, dm, tbl_truncate, top_down = FALSE, dry_run)
}

dm_transform <- function(target_dm, dm, operation, top_down, dry_run = FALSE) {
  dm_check_transform(target_dm, dm)

  dm_run_transform(target_dm, dm, operation, top_down, dry_run)
}

dm_check_transform <- function(target_dm, dm) {
  check_not_zoomed(target_dm)
  check_not_zoomed(dm)

  check_same_src(target_dm, dm)
  walk2(dm_get_tables(target_dm), dm_get_tables(dm), check_columns_superset)
  check_keys_compatible(target_dm, dm)
}

dm_run_transform <- function(target_dm, dm, operation, top_down, dry_run) {
  # topologically sort tables
  # run operation(target_tbl, source_tbl, dry_run = dry_run) for each table
  # operation() returns NULL if no table is needed, otherwise a tbl
  # new_tables is list of non-NULL operation() values

  target_dm %>%
    dm_patch_tbl(!!!new_tables)
}

dm_patch_tbl <- function(dm, ...) {
  check_not_zoomed(dm)

  new_tables <- list2(...)

  # FIXME: Better error message for unknown tables

  def <- dm_get_def(dm)
  idx <- match(names(new_tables), def$table)
  def[idx, "data"] <- unname(new_tables)
  new_dm3(def)
}
