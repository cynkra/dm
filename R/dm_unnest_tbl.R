#' Unnest or unpack columns from a wrapped table
#'
#' `dm_unnest_tbl()` target a specific column to unnest
#' from the given table in a given dm.
#' A prototype or a set of keys should be given, not both.
#'
#' [dm_nest_tbl()] is an inverse operation to `dm_unnest_tbl()`
#' if differences in row and column order are ignored.
#' The opposite is true if referential constraints between both tables
#' are satisfied.
#'
#' @param dm A dm.
#' @param table A table.
#' @param col The column to unpack or unnest (unquoted).
#' @param parent_fk Columns in the table to unnest that the unnested child's foreign keys point to
#' @param child_pk_names Names of the unnested child's primary keys
#' @param child_fk_names Names of the unnested child's foreign keys
#' @param child_fk Foreign key columns of the table to unpack
#' @param parent_pk_names Names of the unpacked parent's primary keys
#' @param parent_fk_names Names of the unpacked parent's foreign keys
#' @param prototype A dm
#'
#' @return A dm.
#' @seealso [dm_nest_tbl()], [dm_pack_tbl()], [dm_wrap()], [dm_unwrap()],
#'   [dm_examine_constraints()], [dm_examine_cardinality()].
#' @export
#'
#' @examples
#' airlines_wrapped <- dm_wrap(dm_nycflights13(), "airlines")
#'
#' airlines_wrapped %>%
#'   dm_unnest_tbl(airlines, flights, parent_fk = carrier, child_fk_names = "carrier") %>%
#'   dm_unpack_tbl(
#'     flights, weather,
#'     child_fk = c(origin, time_hour),
#'     parent_fk_names = c("origin", "time_hour"),
#'     parent_pk_names = c("origin", "time_hour")
#'   ) %>%
#'   dm_unpack_tbl(
#'     flights, planes,
#'     child_fk = tailnum, parent_fk_names = "tailnum",
#'     parent_pk_names = "tailnum"
#'   ) %>%
#'   dm_unpack_tbl(
#'     flights, airports,
#'     child_fk = origin, parent_fk_names = "faa",
#'     parent_pk_names = "faa"
#'   )
#'
#' airlines_wrapped %>%
#'   dm_unnest_tbl(airlines, flights, prototype = dm_nycflights13()) %>%
#'   dm_unpack_tbl(flights, weather, prototype = dm_nycflights13()) %>%
#'   dm_unpack_tbl(flights, planes, prototype = dm_nycflights13()) %>%
#'   dm_unpack_tbl(flights, airports, prototype = dm_nycflights13())
dm_unnest_tbl <- function(dm, table, col, parent_fk = NULL, child_pk_names = NULL, child_fk_names = NULL, prototype = NULL) {
  parent_fk_expr <- enexpr(parent_fk)
  all_keys_null <-
    is_null(parent_fk_expr) && is_null(child_pk_names) && is_null(child_fk_names)

  # process args and build names
  parent_table_name <- dm_tbl_name(dm, {{ table }})
  table <- dm_get_tables_impl(dm)[[parent_table_name]]
  col_expr <- enexpr(col)
  new_child_table_name <- names(eval_select_indices(col_expr, colnames(table)))

  if (is_null(prototype)) {
    if (all_keys_null) abort("Provide either keys or a prototype, you provided none")
    parent_fk_names <- names(eval_select_indices(parent_fk_expr, colnames(table)))
  } else {
    if (!all_keys_null) abort("Provide either keys or a prototype, you provided both")
    child_pk_names <-
      dm_get_all_pks(prototype) %>%
      filter(table == new_child_table_name) %>%
      pull(pk_col) %>%
      unlist()
    fk <-
      dm_get_all_fks(prototype) %>%
      filter(child_table == new_child_table_name, parent_table == parent_table_name)
    parent_fk_names <- unlist(fk$parent_key_cols)
    child_fk_names <- unlist(fk$child_fk_cols)
  }

  # extract nested table
  new_table <- table %>%
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
#' A prototype or a set of keys should be given,
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
dm_unpack_tbl <- function(dm, table, col, child_fk = NULL, parent_pk_names = NULL, parent_fk_names = NULL, prototype = NULL) {
  child_fk_expr <- enexpr(child_fk)
  all_keys_null <-
    is_null(parent_pk_names) && is_null(parent_fk_names) && is_null(child_fk_expr)

  # process args and build names
  child_table_name <- dm_tbl_name(dm, {{ table }})
  table <- dm_get_tables_impl(dm)[[child_table_name]]
  col_expr <- enexpr(col)
  new_parent_table_name <- names(eval_select_indices(col_expr, colnames(table)))

  if (is_null(prototype)) {
    if (all_keys_null) abort("Provide either keys or a prototype, you provided none")
    child_fk_names <- names(eval_select_indices(child_fk_expr, colnames(table)))
  } else {
    if (!all_keys_null) abort("Provide either keys or a prototype, you provided both")
    parent_pk_names <- dm_get_all_pks(prototype) %>%
      filter(table == new_parent_table_name) %>%
      pull(pk_col) %>%
      unlist()
    fk <- dm_get_all_fks(prototype) %>%
      filter(child_table == child_table_name, parent_table == new_parent_table_name)
    child_fk_names <- unlist(fk$child_fk_cols)
    parent_fk_names <- unlist(fk$parent_key_cols)
  }

  # extract packed table
  new_table <- table %>%
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
