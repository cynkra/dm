#' inplaceing data for multiple tables
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
#' Therefore, inplaceence must be requested explicitly with `inplace = TRUE`.
#' By default, an informative message is given.
#'
#' @inheritParams rows_insert
#' @param x Target `dm` object.
#' @param y `dm` object with new data.
#' @param ... Must be empty.
#'
#' @return A dm object of the same [dm_ptype()] as `x`.
#'   If `inplace = TRUE`, [invisible] and identical to `x`.
#'
#' @name rows-dm
#' @example example/rows-dm.R
NULL


#' dm_rows_insert
#'
#' `dm_rows_insert()` adds new records.
#' The primary keys must differ from existing records.
#' This must be ensured by the caller and might be checked by the underlying database.
#' Use `inplace = FALSE` and apply [dm_rows_examine_constraints()] to check beforehand.
#' @rdname rows-dm
#' @export
dm_rows_insert <- function(x, y, ..., inplace = NULL) {
  check_dots_empty()

  dm_rows(x, y, rows_insert, top_down = TRUE, inplace)
}

# dm_rows_update
#
# `dm_rows_update()` updates existing records.
# Primary keys must match for all records to be updated.
#
# @rdname rows-dm
# @export
dm_rows_update <- function(x, y, ..., inplace = NULL) {
  check_dots_empty()

  dm_rows(x, y, tbl_update, top_down = TRUE, inplace)
}

# dm_rows_upsert
#
# `dm_rows_upsert()` updates existing records and adds new records,
# based on the primary key.
#
# @rdname rows-dm
# @export
dm_rows_upsert <- function(x, y, ..., inplace = NULL) {
  check_dots_empty()

  dm_rows(x, y, tbl_upsert, top_down = TRUE, inplace)
}

# dm_rows_delete
#
# `dm_rows_delete()` removes matching records, based on the primary key.
# The order in which the tables are processed is reversed.
#
# @rdname rows-dm
# @export
dm_rows_delete <- function(x, y, ..., inplace = NULL) {
  check_dots_empty()

  dm_rows(x, y, tbl_delete, top_down = FALSE, inplace)
}

# dm_rows_truncate
#
# `dm_rows_truncate()` removes all records, only for tables in `dm`.
# The order in which the tables are processed is reversed.
#
# @rdname rows-dm
# @export
dm_rows_truncate <- function(x, y, ..., inplace = NULL) {
  check_dots_empty()

  dm_rows(x, y, tbl_truncate, top_down = FALSE, inplace)
}

dm_rows <- function(x, y, operation, top_down, inplace = NULL) {
  dm_rows_check(x, y)

  if (is_null(inplace)) {
    message("Not persisting, use `inplace = FALSE` to turn off this message.")
    inplace <- FALSE
  }

  dm_rows_run(x, y, operation, top_down, inplace)
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



dm_rows_run <- function(x, y, tbl_op, top_down, inplace) {
  # topologically sort tables
  graph <- create_graph_from_dm(x, directed = TRUE)
  topo <- igraph::topo_sort(graph, mode = if (top_down) "in" else "out")
  tables <- intersect(names(topo), src_tbls(y))

  # extract keys
  target_tbls <- dm_get_tables_impl(x)[tables]
  tbls <- dm_get_tables_impl(y)[tables]

  # FIXME: Extract keys for upsert and delete
  # Use keyholder?

  # run operation(target_tbl, source_tbl, inplace = inplace) for each table
  op_results <- map2(target_tbls, tbls, tbl_op, inplace = inplace)

  if (identical(unname(op_results), unname(target_tbls))) {
    out <- x
  } else {
    out <-
      x %>%
      dm_patch_tbl(!!!op_results)
  }

  if (inplace) {
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
