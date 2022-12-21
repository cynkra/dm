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
#' @inheritParams rlang::args_dots_empty
#' @inheritParams dplyr::rows_insert
#' @inheritParams dm_examine_constraints
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
#' dm_rows_append(flights_sqlite, flights_jan_sqlite)
#' print(dm_nrow(flights_sqlite))
#'
#' # Explicitly request persistence:
#' dm_rows_append(flights_sqlite, flights_jan_sqlite, in_place = TRUE)
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
#' flights_new <- dm_rows_append(
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
#' dm_rows_append(flights_sqlite, flights_feb_sqlite, in_place = TRUE)
#' print(dm_nrow(flights_sqlite))
#'
#' DBI::dbDisconnect(sqlite)
NULL


#' dm_rows_insert
#'
#' `dm_rows_insert()` adds new records via [rows_insert()] with `conflict = "ignore"`.
#' Duplicate records will be silently discarded.
#' This operation requires primary keys on all tables, use `dm_rows_append()`
#' to insert unconditionally.
#' @rdname rows-dm
#' @aliases dm_rows_...
#' @export
dm_rows_insert <- function(x, y, ..., in_place = NULL, progress = NA) {
  check_dots_empty()

  dm_rows(x, y, "insert", top_down = TRUE, in_place, require_keys = TRUE, progress = progress)
}

#' dm_rows_append
#'
#' `dm_rows_append()` adds new records via [rows_append()].
#' The primary keys must differ from existing records.
#' This must be ensured by the caller and might be checked by the underlying database.
#' Use `in_place = FALSE` and apply [dm_examine_constraints()] to check beforehand.
#' @rdname rows-dm
#' @export
dm_rows_append <- function(x, y, ..., in_place = NULL, progress = NA) {
  check_dots_empty()

  dm_rows(x, y, "append", top_down = TRUE, in_place, require_keys = FALSE, progress = progress)
}

#' dm_rows_update
#'
#' `dm_rows_update()` updates existing records via [rows_update()].
#' Primary keys must match for all records to be updated.
#'
#' @rdname rows-dm
#' @export
dm_rows_update <- function(x, y, ..., in_place = NULL, progress = NA) {
  check_dots_empty()

  dm_rows(x, y, "update", top_down = TRUE, in_place, require_keys = TRUE, progress = progress)
}

#' dm_rows_patch
#'
#' `dm_rows_patch()` updates missing values in existing records
#' via [rows_patch()].
#' Primary keys must match for all records to be patched.
#'
#' @rdname rows-dm
#' @export
dm_rows_patch <- function(x, y, ..., in_place = NULL, progress = NA) {
  check_dots_empty()

  dm_rows(x, y, "patch", top_down = TRUE, in_place, require_keys = TRUE, progress = progress)
}

#' dm_rows_upsert
#'
#' `dm_rows_upsert()` updates existing records and adds new records,
#' based on the primary key, via [rows_upsert()].
#'
#' @rdname rows-dm
#' @export
dm_rows_upsert <- function(x, y, ..., in_place = NULL, progress = NA) {
  check_dots_empty()

  dm_rows(x, y, "upsert", top_down = TRUE, in_place, require_keys = TRUE, progress = progress)
}

#' dm_rows_delete
#'
#' `dm_rows_delete()` removes matching records via [rows_delete()],
#' based on the primary key.
#' The order in which the tables are processed is reversed.
#'
#' @rdname rows-dm
#' @export
dm_rows_delete <- function(x, y, ..., in_place = NULL, progress = NA) {
  check_dots_empty()

  dm_rows(x, y, "delete", top_down = FALSE, in_place, require_keys = TRUE, progress = progress)
}

dm_rows <- function(x, y, operation_name, top_down, in_place, require_keys, progress = NA) {
  dm_rows_check(x, y)

  if (is_null(in_place)) {
    inform("Result is returned as a dm object with lazy tables. Use `in_place = FALSE` to mute this message, or `in_place = TRUE` to write to the underlying tables.")
    in_place <- FALSE
  }

  dm_rows_run(x, y, operation_name, top_down, in_place, require_keys, progress = progress)
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

get_dm_rows_op <- function(operation_name) {
  switch(operation_name,
    "insert"   = list(fun = do_rows_insert, pb_label = "inserting rows"),
    "append"   = list(fun = do_rows_append, pb_label = "appending rows"),
    "update"   = list(fun = do_rows_update, pb_label = "updating rows"),
    "patch"    = list(fun = do_rows_patch, pb_label = "patching rows"),
    "upsert"   = list(fun = do_rows_upsert, pb_label = "upserting rows"),
    "delete"   = list(fun = do_rows_delete, pb_label = "deleting rows"),
    "truncate" = list(fun = rows_truncate_, pb_label = "truncating rows")
  )
}

do_rows_insert <- function(x, y, by = NULL, ...) {
  rows_insert(x, y, by = by, ..., conflict = "ignore")
}

do_rows_append <- function(x, y, by = NULL, ...) {
  rows_append(x, y, ...)
}

do_rows_update <- function(x, y, by = NULL, ...) {
  rows_update(x, y, by = by, ..., unmatched = "ignore")
}

do_rows_patch <- function(x, y, by = NULL, ...) {
  rows_patch(x, y, by = by, ..., unmatched = "ignore")
}

do_rows_upsert <- function(x, y, by = NULL, ...) {
  rows_upsert(x, y, by = by, ...)
}

do_rows_delete <- function(x, y, by = NULL, ...) {
  rows_delete(x, y, by = by, ..., unmatched = "ignore")
}

dm_rows_run <- function(x, y, rows_op_name, top_down, in_place, require_keys, progress = NA) {
  # topologically sort tables
  graph <- create_graph_from_dm(x, directed = TRUE)
  topo <- igraph::topo_sort(graph, mode = if (top_down) "in" else "out")
  tables <- intersect(names(topo), src_tbls_impl(y))

  # Use tables and keys
  target_tbls <- dm_get_tables_impl(x)[tables]
  tbls <- dm_get_tables_impl(y)[tables]

  if (require_keys) {
    all_pks <- dm_get_all_pks(x)
    if (!(all(tables %in% all_pks$table))) {
      abort(glue("`dm_rows_{rows_op_name}()` requires the 'dm' object to have primary keys for all target tables."))
    }
    keys <- all_pks$pk_col[match(tables, all_pks$table)]
  } else {
    keys <- rep_along(tables, list(NULL))
  }

  # FIXME: Use keyholder?

  rows_op <- get_dm_rows_op(rows_op_name)
  ticker <- new_ticker(rows_op$pb_label, length(tables), progress)
  # run operation(target_tbl, source_tbl, in_place = in_place) for each table

  autoinc_pks <- get_autoinc(x, y)
  # FIXME: extend for c("insert", "upsert")
  if (rows_op_name %in% c("append") && nrow(autoinc_pks) > 0) {
    op_ticker <- ticker(rows_op$fun)

    fks_ai <-
      x %>%
      dm_get_all_fks_impl() %>%
      filter(parent_table %in% autoinc_pks$table) %>%
      filter(parent_table %in% src_tbls_impl(y), child_table %in% src_tbls_impl(y)) %>%
      # Parent key cols have length 1, since it's an autoincrement column
      # child_fk_cols must have the same length.
      # Is the referred `parent_key_cols` actually the autoinc-PK?
      semi_join(autoinc_pks, by = c("parent_table" = "table", "parent_key_cols" = "pk_col"))

    op_results <- list()
    for (i in seq_along(y)) {
      autoinc_col_prel <-
        autoinc_pks %>%
        filter(table == names(y[i])) %>%
        pull(pk_col)

      if (length(autoinc_col_prel) == 1) {
        autoinc_col <- get_key_cols(autoinc_col_prel)
      } else {
        autoinc_col <- character()
      }

      if (!is_empty(autoinc_col)) {
        res <- op_ticker(
          x = target_tbls[[i]],
          y = select(pull_tbl(y, !!sym(tables[i])), setdiff(colnames(tbls[[i]]), autoinc_col)),
          by = keys[[i]],
          returning = !!sym(autoinc_col),
          in_place = in_place
        )
        # need to create matching table between newly created values and original values
        matched_cols <-
          dbplyr::get_returned_rows(res) %>%
          rename(remote = 1) %>%
          # FIXME: is it guaranteed that the order of select(tbls[[i]], original = !!sym(autoinc_col)) is the same
          # as it was during inserting of the new rows?
          bind_cols(collect(select(tbls[[i]], original = !!sym(autoinc_col)))) %>%
          dbplyr::copy_inline(dm_get_con(x), .)
        y <- upd_dm_w_autoinc(y, filter(fks_ai, parent_table == names(tbls[i])), matched_cols)
      } else {
        res <- op_ticker(
          x = target_tbls[[i]],
          y = pull_tbl(y, !!sym(tables[i])),
          by = keys[[i]],
          in_place = in_place
        )
      }
      op_results <- append(op_results, set_names(list(res), names(y[i])))
    }
  } else {
    op_results <- pmap(
      list(x = target_tbls, y = tbls, by = keys),
      ticker(rows_op$fun),
      in_place = in_place
    )
  }

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

get_autoinc <- function(x, y) {
  dm_select_tbl(x, !!!src_tbls_impl(y)) %>%
    dm_get_all_pks() %>%
    filter(autoincrement) %>%
    select(-autoincrement)
}

upd_dm_w_autoinc <- function(dm, fks_ai, res) {
  if (nrow(fks_ai) == 0) return(dm)
  res_dm <- reduce2(
    fks_ai$child_table,
    fks_ai$child_fk_cols,
    ~ dm_zoom_to(..1, !!sym(..2)) %>%
      left_join(res, by = set_names("original", ..3)) %>%
      mutate(!!..3 := remote) %>%
      select(-remote) %>%
      dm_update_zoomed(),
    # left_join.zoomed_dm needs y to be part of the dm
    .init = dm(dm, res)
  )
  res_dm %>% dm_select_tbl(-res)
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
