#' Persisting data for multiple tables
#'
#' @description
#' \lifecycle{experimental}
#'
#' These functions provide a framework for updating data in existing tables.
#' Unlike [compute()], [copy_to()] or [copy_dm_to()], no new tables are created
#' on the database.
#' All operations expect that both existing and new data are presented
#' in two compatible [dm] objects on the same data source.
#'
#' The functions make sure that the tables in the target dm
#' are processed in topological order so that parent (dimension)
#' tables receive insertions before child (fact) tables.
#'
#' These operations, in contrast to all other operations,
#' may lead to irreversible changes to the underlying database.
#' Therefore, persistence must be requested explicitly with `persist = TRUE`.
#' By default, an informative message is given.
#'
#' @param target_dm Target `dm` object.
#' @param dm `dm` object with new data.
#' @param ... Must be empty.
#' @param persist
#'   Set to `TRUE` for running the operation without persisting.
#'   In this mode, a modified version of `target_dm` is returned.
#'   This allows verifying the results of an operation before actually
#'   applying it.
#'   Set to `FALSE` to perform the update on the database table.
#'   By default, an informative message is shown.
#'
#' @return A dm object of the same [dm_ptype()] as `target_dm`.
#'   If `persist = TRUE`, [invisible] and identical to `target_dm`.
#'
#' @name rows-dm
#' @examples
#' if (rlang::is_installed("RSQLite")) {
#'   # Entire dataset with all dimension tables populated
#'   # with flights and weather data truncated:
#'   flights_init <-
#'     dm_nycflights13() %>%
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
#'   flights_sqlite <- copy_dm_to(sqlite, flights_init, temporary = FALSE)
#'   print(dm_nrow(flights_sqlite))
#'
#'   # First update:
#'   flights_jan <-
#'     dm_nycflights13() %>%
#'     dm_select_tbl(flights, weather) %>%
#'     dm_zoom_to(flights) %>%
#'     filter(month == 1) %>%
#'     dm_update_zoomed() %>%
#'     dm_zoom_to(weather) %>%
#'     filter(month == 1) %>%
#'     dm_update_zoomed()
#'   print(dm_nrow(flights_jan))
#'
#'   # Copy to temporary tables on the target database:
#'   flights_jan_sqlite <- copy_dm_to(sqlite, flights_jan, unique_table_names = TRUE)
#'
#'   # Dry run by default:
#'   dm_insert(flights_sqlite, flights_jan_sqlite)
#'   print(dm_nrow(flights_sqlite))
#'
#'   # Explicitly request persistence:
#'   dm_insert(flights_sqlite, flights_jan_sqlite, persist = TRUE)
#'   print(dm_nrow(flights_sqlite))
#'
#'   # Second update:
#'   flights_feb <-
#'     dm_nycflights13() %>%
#'     dm_select_tbl(flights, weather) %>%
#'     dm_zoom_to(flights) %>%
#'     filter(month == 2) %>%
#'     dm_update_zoomed() %>%
#'     dm_zoom_to(weather) %>%
#'     filter(month == 2) %>%
#'     dm_update_zoomed()
#'
#'   # Copy to temporary tables on the target database:
#'   flights_feb_sqlite <- copy_dm_to(sqlite, flights_feb, unique_table_names = TRUE)
#'
#'   # Explicit dry run:
#'   flights_new <- dm_insert(
#'     flights_sqlite,
#'     flights_feb_sqlite,
#'     persist = FALSE
#'   )
#'   print(dm_nrow(flights_new))
#'   print(dm_nrow(flights_sqlite))
#'
#'   # Check for consistency before applying:
#'   flights_new %>%
#'     dm_examine_constraints()
#'
#'   # Apply:
#'   dm_insert(flights_sqlite, flights_feb_sqlite, persist = TRUE)
#'   print(dm_nrow(flights_sqlite))
#' }
NULL


#' dm_insert
#'
#' `dm_insert()` adds new records.
#' The primary keys must differ from existing records.
#' This must be ensured by the caller and might be checked by the underlying database.
#' Use `persist = FALSE` and apply [dm_examine_constraints()] to check beforehand.
#' @rdname rows-dm
#' @export
dm_insert <- function(target_dm, dm, ..., persist = NULL) {
  check_dots_empty()

  dm_persist(target_dm, dm, tbl_insert, top_down = TRUE, persist)
}

# dm_update
#
# `dm_update()` updates existing records.
# Primary keys must match for all records to be updated.
#
# @rdname rows-dm
# @export
dm_update <- function(target_dm, dm, ..., persist = NULL) {
  check_dots_empty()

  dm_persist(target_dm, dm, tbl_update, top_down = TRUE, persist)
}

# dm_upsert
#
# `dm_upsert()` updates existing records and adds new records,
# based on the primary key.
#
# @rdname rows-dm
# @export
dm_upsert <- function(target_dm, dm, ..., persist = NULL) {
  check_dots_empty()

  dm_persist(target_dm, dm, tbl_upsert, top_down = TRUE, persist)
}

# dm_delete
#
# `dm_delete()` removes matching records, based on the primary key.
# The order in which the tables are processed is reversed.
#
# @rdname rows-dm
# @export
dm_delete <- function(target_dm, dm, ..., persist = NULL) {
  check_dots_empty()

  dm_persist(target_dm, dm, tbl_delete, top_down = FALSE, persist)
}

# dm_truncate
#
# `dm_truncate()` removes all records, only for tables in `dm`.
# The order in which the tables are processed is reversed.
#
# @rdname rows-dm
# @export
dm_truncate <- function(target_dm, dm, ..., persist = NULL) {
  check_dots_empty()

  dm_persist(target_dm, dm, tbl_truncate, top_down = FALSE, persist)
}

dm_persist <- function(target_dm, dm, operation, top_down, persist = NULL) {
  dm_check_persist(target_dm, dm)

  if (is_null(persist)) {
    warn("Not persisting, use `persist = FALSE` to turn off this warning.")
    persist <- FALSE
  }

  dm_run_persist(target_dm, dm, operation, top_down, persist)
}

dm_check_persist <- function(target_dm, dm) {
  check_not_zoomed(target_dm)
  check_not_zoomed(dm)

  check_same_src(target_dm, dm)
  check_tables_superset(target_dm, dm)
  tables <- dm_get_tables(dm)
  walk2(dm_get_tables(target_dm)[names(tables)], tables, check_columns_superset)
  check_keys_compatible(target_dm, dm)
}

check_same_src <- function(target_dm, dm) {
  tables <- c(dm_get_tables_impl(target_dm), dm_get_tables_impl(dm))
  if (!all_same_source(tables)) {
    abort_not_same_src()
  }
}

check_tables_superset <- function(target_dm, dm) {
  tables_missing <- setdiff(src_tbls_impl(dm), src_tbls_impl(target_dm))
  if (has_length(tables_missing)) {
    abort_tables_missing(tables_missing)
  }
}

check_columns_superset <- function(target_tbl, tbl) {
  columns_missing <- setdiff(colnames(tbl), colnames(target_tbl))
  if (has_length(columns_missing)) {
    abort_columns_missing(columns_missing)
  }
}

check_keys_compatible <- function(target_dm, dm) {
  # FIXME
}



dm_run_persist <- function(target_dm, dm, tbl_op, top_down, persist) {
  # topologically sort tables
  graph <- dm::create_graph_from_dm(target_dm, directed = TRUE)
  topo <- igraph::topo_sort(graph, mode = if (top_down) "in" else "out")
  tables <- intersect(names(topo), src_tbls(dm))

  # extract keys
  target_tbls <- dm_get_tables_impl(target_dm)[tables]
  tbls <- dm_get_tables_impl(dm)[tables]

  # FIXME: Extract keys for upsert and delete
  # Use keyholder?

  # run operation(target_tbl, source_tbl, persist = persist) for each table
  op_results <- map2(target_tbls, tbls, tbl_op, persist = persist)

  # operation() returns NULL if no table is needed, otherwise a tbl
  new_tables <- compact(op_results)

  out <-
    target_dm %>%
    dm_patch_tbl(!!!new_tables)

  if (persist) {
    invisible(out)
  } else {
    out
  }
}

dm_patch_tbl <- function(dm, ...) {
  check_not_zoomed(dm)

  new_tables <- list2(...)

  # FIXME: Better error message for unknown tables

  def <- dm_get_def(dm)
  idx <- match(names(new_tables), def$table)
  def[idx, "data"] <- list(unname(new_tables))
  new_dm3(def)
}
