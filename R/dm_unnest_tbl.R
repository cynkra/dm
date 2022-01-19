#' Unnest or unpack columns from a wrapped table
#'
#' `dm_unnest_tbl()` target a specific column to unnest
#' from the given table in a given dm.
#' A ptype or a set of keys should be given, not both.
#'
#' [dm_nest_tbl()] is an inverse operation to `dm_unnest_tbl()`
#' if differences in row and column order are ignored.
#' The opposite is true if referential constraints between both tables
#' are satisfied.
#'
#' @inheritParams dm_unwrap
#' @param table A table.
#' @param col The column to unpack or unnest (unquoted).
#'
#' @return A dm.
#' @seealso [dm_unwrap()], [dm_nest_tbl()], [dm_pack_tbl()], [dm_wrap()],
#'   [dm_examine_constraints()], [dm_examine_cardinality()],
#'   [dm_ptype()].
#' @export
#'
#' @examples
#' airlines_wrapped <-
#'   dm_nycflights13() %>%
#'   dm_wrap(airlines)
#'
#' # The ptype is required for reconstruction.
#' # It can be an empty dm, only primary and foreign keys are considered.
#' ptype <- dm_ptype(dm_nycflights13())
#'
#' airlines_wrapped %>%
#'   dm_unnest_tbl(airlines, flights, ptype) %>%
#'   dm_unpack_tbl(flights, weather, ptype) %>%
#'   dm_unpack_tbl(flights, planes, ptype) %>%
#'   dm_unpack_tbl(flights, airports, ptype)
dm_unnest_tbl <- function(dm, table, col, ptype) {
  # process args and build names
  parent_table_name <- dm_tbl_name(dm, {{ table }})
  table <- dm_get_tables_impl(dm)[[parent_table_name]]
  col_expr <- enexpr(col)
  new_child_table_name <- names(eval_select_indices(col_expr, colnames(table)))

  child_pk_names <-
    dm_get_all_pks(ptype) %>%
    filter(table == new_child_table_name) %>%
    pull(pk_col) %>%
    unlist()
  fk <-
    dm_get_all_fks(ptype) %>%
    filter(child_table == new_child_table_name, parent_table == parent_table_name)
  parent_fk_names <- unlist(fk$parent_key_cols)
  child_fk_names <- unlist(fk$child_fk_cols)

  # extract nested table
  new_table <-
    table %>%
    select(!!!set_names(parent_fk_names, child_fk_names), !!new_child_table_name) %>%
    unnest(!!new_child_table_name) %>%
    distinct()

  # update the dm by adding new table, removing nested col and setting keys
  dm <- dm_add_tbl(dm, !!new_child_table_name := new_table)
  dm <- dm_select(dm, !!parent_table_name, -all_of(new_child_table_name))
  if (length(parent_fk_names)) {
    dm <- dm_add_fk(dm, !!new_child_table_name, !!child_fk_names, !!parent_table_name, !!parent_fk_names)
  }
  if (length(child_pk_names)) {
    dm <- dm_add_pk(dm, !!new_child_table_name, !!child_pk_names)
  }

  dm
}

#' dm_unpack_tbl()
#'
#' `dm_unpack_tbl()` targets a specific column to unpack
#' from the given table in a given dm.
#' A ptype or a set of keys should be given,
#' not both.
#'
#' [dm_pack_tbl()] is an inverse operation to `dm_unpack_tbl()`
#' if differences in row and column order are ignored.
#' The opposite is true if referential constraints between both tables
#' are satisfied
#' and if all rows in the parent table have at least one child row,
#' i.e. if the relationship is of cardinality 1:n or 1:1.
#'
#' @export
#' @rdname dm_unnest_tbl
dm_unpack_tbl <- function(dm, table, col, ptype) {
  # process args and build names
  child_table_name <- dm_tbl_name(dm, {{ table }})
  table <- dm_get_tables_impl(dm)[[child_table_name]]
  col_expr <- enexpr(col)
  new_parent_table_name <- names(eval_select_indices(col_expr, colnames(table)))

  parent_pk_names <- dm_get_all_pks(ptype) %>%
    filter(table == new_parent_table_name) %>%
    pull(pk_col) %>%
    unlist()
  fk <- dm_get_all_fks(ptype) %>%
    filter(child_table == child_table_name, parent_table == new_parent_table_name)
  child_fk_names <- unlist(fk$child_fk_cols)
  parent_fk_names <- unlist(fk$parent_key_cols)

  # extract packed table
  new_table <-
    table %>%
    select(!!!set_names(child_fk_names, parent_fk_names), !!new_parent_table_name) %>%
    unpack(!!new_parent_table_name) %>%
    distinct()

  # update the dm by adding new table, removing packed col and setting keys
  dm <- dm_add_tbl(dm, !!new_parent_table_name := new_table)
  dm <- dm_select(dm, !!child_table_name, -all_of(new_parent_table_name))
  if (length(child_fk_names)) {
    dm <- dm_add_fk(
      dm,
      !!child_table_name,
      !!child_fk_names,
      !!new_parent_table_name,
      !!parent_fk_names
    )
  }
  if (length(parent_pk_names)) {
    dm <- dm_add_pk(dm, !!new_parent_table_name, !!parent_pk_names)
  }

  dm
}
