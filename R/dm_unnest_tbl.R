#' Unnest columns from a wrapped table
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `dm_unnest_tbl()` target a specific column to unnest
#' from the given table in a given dm.
#' A ptype or a set of keys should be given, not both.
#'
#' @details
#' [dm_nest_tbl()] is an inverse operation to `dm_unnest_tbl()`
#' if differences in row and column order are ignored.
#' The opposite is true if referential constraints between both tables
#' are satisfied.
#'
#' @inheritParams dm_unwrap_tbl
#' @param parent_table A table in the dm with nested columns.
#' @param col The column to unnest (unquoted).
#'
#' @return A dm.
#' @seealso [dm_unwrap_tbl()], [dm_unpack_tbl()],
#'   [dm_nest_tbl()], [dm_pack_tbl()], [dm_wrap_tbl()],
#'   [dm_examine_constraints()], [dm_examine_cardinalities()],
#'   [dm_ptype()].
#' @export
#'
#' @examples
#' airlines_wrapped <-
#'   dm_nycflights13() %>%
#'   dm_wrap_tbl(airlines)
#'
#' # The ptype is required for reconstruction.
#' # It can be an empty dm, only primary and foreign keys are considered.
#' ptype <- dm_ptype(dm_nycflights13())
#'
#' airlines_wrapped %>%
#'   dm_unnest_tbl(airlines, flights, ptype)
dm_unnest_tbl <- function(dm, parent_table, col, ptype) {
  # process args and build names
  parent_table_name <- dm_tbl_name(dm, {{ parent_table }})
  table <- dm_get_tables_impl(dm)[[parent_table_name]]
  col_expr <- enexpr(col)
  nested_col_name <- names(eval_select_indices(col_expr, colnames(table)))

  parent_pk_names <-
    dm_get_all_pks(dm) %>%
    filter(table == parent_table_name) %>%
    pull(pk_col) %>%
    unlist()

  # extract nested table
  new_table <- vctrs::vec_c(!!!table[[nested_col_name]]) %>%
    distinct()
  raw_names <- names(new_table)

  child_fk_names <- guess_fks(table, new_table, parent_pk_names)
  child_pk_names <- guess_pk(new_table)

  # update the dm by adding new table, removing nested col and setting keys
  dm <- dm(dm, !!nested_col_name := new_table)
  dm <- dm_select(dm, !!parent_table_name, -all_of(nested_col_name))
  if (length(parent_pk_names)) {
    dm <- dm_add_fk(dm, !!nested_col_name, !!child_fk_names, !!parent_table_name, !!parent_pk_names)
  }
  if (length(child_pk_names)) {
    dm <- dm_add_pk(dm, !!nested_col_name, !!child_pk_names)
  }

  dm
}

#' Unpack columns from a wrapped table
#'
#' #' @description
#' `r lifecycle::badge("experimental")`
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
#' @inheritParams dm_unwrap_tbl
#' @param child_table A table in the dm with packed columns.
#' @param col The column to unpack (unquoted).
#'
#' @seealso [dm_unwrap_tbl()], [dm_unnest_tbl()],
#'   [dm_nest_tbl()], [dm_pack_tbl()], [dm_wrap_tbl()],
#'   [dm_examine_constraints()], [dm_examine_cardinalities()],
#'   [dm_ptype()].
#' @export
#' @examples
#' flights_wrapped <-
#'   dm_nycflights13() %>%
#'   dm_wrap_tbl(flights)
#'
#' # The ptype is required for reconstruction.
#' # It can be an empty dm, only primary and foreign keys are considered.
#' ptype <- dm_ptype(dm_nycflights13())
#'
#' flights_wrapped %>%
#'   dm_unpack_tbl(flights, airlines, ptype)
dm_unpack_tbl <- function(dm, child_table, col, ptype) {
  # process args and build names
  child_table_name <- dm_tbl_name(dm, {{ child_table }})
  table <- dm_get_tables_impl(dm)[[child_table_name]]
  col_expr <- enexpr(col)
  new_parent_table_name <- names(eval_select_indices(col_expr, colnames(table)))

  packed_col_name <- names(eval_select_indices(col_expr, colnames(table)))
  new_table <- table[[packed_col_name]] %>%
    distinct()
  raw_names <- names(new_table)

  parent_pk_names <- guess_pk(new_table)
  child_fk_names <- guess_fks(new_table, table, parent_pk_names)

  # update the dm by adding new table, removing packed col and setting keys
  dm <- dm(dm, !!packed_col_name := new_table)
  dm <- dm_select(dm, !!child_table_name, -all_of(packed_col_name))
  if (length(child_fk_names)) {
    dm <- dm_add_fk(
      dm,
      !!child_table_name,
      !!child_fk_names,
      !!packed_col_name,
      !!parent_pk_names
    )
  }
  if (length(parent_pk_names)) {
    dm <- dm_add_pk(dm, !!packed_col_name, !!parent_pk_names)
  }

  dm
}

guess_fks <- function(parent_table, child_table, parent_pk_names) {
  names_by_type <-
    child_table %>%
    map_chr(type_of) %>%
    split.default(child_table, .) %>%
    map(names)
  pk1_candidates <- names_by_type[[typeof(parent_table[[parent_pk_names[1]]])]]
  combos_df <- reduce(parent_pk_names[-1], .init = tibble(pk1_candidates), function(acc, nxt) {
    new_candidates <- names_by_type[[typeof(parent_table[[nxt]])]]
    tidyr::expand_grid(acc, new_candidates) %>%
      rowwise() %>%
      filter(n_distinct(c_across()) == ncol(.)) %>%
      ungroup()
  })
  for (i in seq_len(nrow(combos_df))) {
    combo <- unname(unlist(combos_df[i,]))
    combo_is_subset <-
      nrow(child_table) ==
      child_table[combo] %>%
      set_names(parent_pk_names) %>%
      semi_join(parent_table[parent_pk_names], by = parent_pk_names) %>%
      nrow()
    if (combo_is_subset) break
  }
  combo
}

guess_pk <- function(table) {
  for (i in seq_len(ncol(table))) {
    if (!anyDuplicated(table[1:i])) {
      child_pk_names <- names(table)[1:i]
      break
    }
  }
  child_pk_names
}
