#' Modifying rows for multiple tables
#'
#' @description
#' `r lifecycle::badge("experimental")`
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
#' Therefore, in-place operation must be requested explicitly with `in_place = TRUE`.
#' By default, an informative message is given.
#'
#' @inheritParams ellipsis::dots_empty
#' @inheritParams dplyr::rows_insert
#' @param x Target `dm` object.
#' @param y `dm` object with new data.
#'
#' @return A dm object of the same [dm_ptype()] as `x`.
#'   If `in_place = TRUE`, the underlying data is updated as a side effect,
#'   and `x` is returned, invisibly.
#'
#' @name rows-dm
#' @examplesIf rlang::is_installed("RSQLite") && rlang::is_installed("nycflights13")
#' # Establish database connection:
#' sqlite <- DBI::dbConnect(RSQLite::SQLite())
#'
#' # Entire dataset with all dimension tables populated
#' # with flights and weather data truncated:
#' flights_init <-
#'   dm_nycflights13() %>%
#'   dm_zoom_to(flights) %>%
#'   filter(FALSE) %>%
#'   dm_update_zoomed() %>%
#'   dm_zoom_to(weather) %>%
#'   filter(FALSE) %>%
#'   dm_update_zoomed()
#'
#' # Target database:
#' flights_sqlite <- copy_dm_to(sqlite, flights_init, temporary = FALSE)
#' print(dm_nrow(flights_sqlite))
#'
#' # First update:
#' flights_jan <-
#'   dm_nycflights13() %>%
#'   dm_select_tbl(flights, weather) %>%
#'   dm_zoom_to(flights) %>%
#'   filter(month == 1) %>%
#'   dm_update_zoomed() %>%
#'   dm_zoom_to(weather) %>%
#'   filter(month == 1) %>%
#'   dm_update_zoomed()
#' print(dm_nrow(flights_jan))
#'
#' # Copy to temporary tables on the target database:
#' flights_jan_sqlite <- copy_dm_to(sqlite, flights_jan)
#'
#' # Dry run by default:
#' dm_rows_insert(flights_sqlite, flights_jan_sqlite)
#' print(dm_nrow(flights_sqlite))
#'
#' # Explicitly request persistence:
#' dm_rows_insert(flights_sqlite, flights_jan_sqlite, in_place = TRUE)
#' print(dm_nrow(flights_sqlite))
#'
#' # Second update:
#' flights_feb <-
#'   dm_nycflights13() %>%
#'   dm_select_tbl(flights, weather) %>%
#'   dm_zoom_to(flights) %>%
#'   filter(month == 2) %>%
#'   dm_update_zoomed() %>%
#'   dm_zoom_to(weather) %>%
#'   filter(month == 2) %>%
#'   dm_update_zoomed()
#'
#' # Copy to temporary tables on the target database:
#' flights_feb_sqlite <- copy_dm_to(sqlite, flights_feb)
#'
#' # Explicit dry run:
#' flights_new <- dm_rows_insert(
#'   flights_sqlite,
#'   flights_feb_sqlite,
#'   in_place = FALSE
#' )
#' print(dm_nrow(flights_new))
#' print(dm_nrow(flights_sqlite))
#'
#' # Check for consistency before applying:
#' flights_new %>%
#'   dm_examine_constraints()
#'
#' # Apply:
#' dm_rows_insert(flights_sqlite, flights_feb_sqlite, in_place = TRUE)
#' print(dm_nrow(flights_sqlite))
#'
#' DBI::dbDisconnect(sqlite)
NULL


#' dm_rows_insert
#'
#' `dm_rows_insert()` adds new records via [rows_insert()].
#' The primary keys must differ from existing records.
#' This must be ensured by the caller and might be checked by the underlying database.
#' Use `in_place = FALSE` and apply [dm_examine_constraints()] to check beforehand.
#' @rdname rows-dm
#' @export
dm_rows_insert <- function(x, y, ..., in_place = NULL) {
  check_dots_empty()

  dm_rows(x, y, rows_insert, top_down = TRUE, in_place, require_keys = FALSE)
}

#' dm_rows_update
#'
#' `dm_rows_update()` updates existing records via [rows_update()].
#' Primary keys must match for all records to be updated.
#'
#' @rdname rows-dm
#' @export
dm_rows_update <- function(x, y, ..., in_place = NULL) {
  check_dots_empty()

  dm_rows(x, y, rows_update, top_down = TRUE, in_place, require_keys = TRUE)
}

#' dm_rows_patch
#'
#' `dm_rows_patch()` updates missing values in existing records
#' via [rows_patch()].
#' Primary keys must match for all records to be patched.
#'
#' @rdname rows-dm
#' @export
dm_rows_patch <- function(x, y, ..., in_place = NULL) {
  check_dots_empty()

  dm_rows(x, y, rows_patch, top_down = TRUE, in_place, require_keys = TRUE)
}

#' dm_rows_upsert
#'
#' `dm_rows_upsert()` updates existing records and adds new records,
#' based on the primary key, via [rows_upsert()].
#'
#' @rdname rows-dm
#' @export
dm_rows_upsert <- function(x, y, ..., in_place = NULL) {
  check_dots_empty()

  dm_rows(x, y, rows_upsert, top_down = TRUE, in_place, require_keys = TRUE)
}

#' dm_rows_delete
#'
#' `dm_rows_delete()` removes matching records via [rows_delete()],
#' based on the primary key.
#' The order in which the tables are processed is reversed.
#'
#' @rdname rows-dm
#' @export
dm_rows_delete <- function(x, y, ..., in_place = NULL) {
  check_dots_empty()

  dm_rows(x, y, rows_delete, top_down = FALSE, in_place, require_keys = TRUE)
}

#' dm_rows_truncate
#'
#' `dm_rows_truncate()` removes all records via [rows_truncate()],
#' only for tables in `dm`.
#' The order in which the tables are processed is reversed.
#'
#' @rdname rows-dm
#' @export
dm_rows_truncate <- function(x, y, ..., in_place = NULL) {
  check_dots_empty()

  dm_rows(x, y, rows_truncate, top_down = FALSE, in_place, require_keys = FALSE)
}

dm_rows <- function(x, y, operation, top_down, in_place, require_keys) {
  dm_rows_check(x, y)

  if (is_null(in_place)) {
    message("Not persisting, use `in_place = FALSE` to turn off this message.")
    in_place <- FALSE
  }

  dm_rows_run(x, y, operation, top_down, in_place, require_keys)
}

dm_rows_check <- function(x, y) {
  check_not_zoomed(x)
  check_not_zoomed(y)

  check_same_src(x, y)
  check_tables_superset(x, y)
  tables <- dm_get_tables_impl(y)
  walk2(dm_get_tables_impl(x)[names(tables)], tables, check_columns_superset)
  check_keys_compatible(x, y)
}

check_same_src <- function(x, y) {
  tables <- c(dm_get_tables_impl(x), dm_get_tables_impl(y))
  if (!all_same_source(tables)) {
    abort_not_same_src()
  }
}

check_tables_superset <- function(x, y) {
  tables_missing <- setdiff(src_tbls_impl(y), src_tbls_impl(x))
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

check_keys_compatible <- function(x, y) {
  # FIXME
}



dm_rows_run <- function(x, y, rows_op, top_down, in_place, require_keys) {
  # topologically sort tables
  graph <- create_graph_from_dm(x, directed = TRUE)
  topo <- igraph::topo_sort(graph, mode = if (top_down) "in" else "out")
  tables <- intersect(names(topo), src_tbls_impl(y))

  # Use tables and keys
  target_tbls <- dm_get_tables_impl(x)[tables]
  tbls <- dm_get_tables_impl(y)[tables]

  if (require_keys) {
    # FIXME: Better error message if keys not found
    keys <- deframe(dm_get_all_pks(x))[tables]
  } else {
    keys <- rep_along(tables, list(NULL))
  }

  # FIXME: Use keyholder?

  # run operation(target_tbl, source_tbl, in_place = in_place) for each table
  op_results <- pmap(
    list(x = target_tbls, y = tbls, by = keys),
    rows_op,
    in_place = in_place
  )

  if (identical(unname(op_results), unname(target_tbls))) {
    out <- x
  } else {
    out <-
      x %>%
      dm_patch_tbl(!!!op_results)
  }

  if (in_place) {
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


# Errors ------------------------------------------------------------------

abort_columns_missing <- function(...) {
  # FIXME
  abort("")
}

error_txt_columns_missing <- function(...) {
  # FIXME
}

abort_tables_missing <- function(...) {
  # FIXME
  abort("")
}

error_txt_tables_missing <- function(...) {
  # FIXME
}
