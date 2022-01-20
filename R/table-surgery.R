#' Decompose a table into two linked tables
#'
#' @description
#' `r lifecycle::badge("questioning")`
#'
#' Extract a lookup table from a table in a `dm`, linking the original table and the new table by a key.
#'
#' `dm_separate_table()` accepts a `dm`, an unquoted table name, a name for the new column
#' which will be created to link the two tables and the names of the columns that will be
#' used in order to form the new table.
#'
#' In addition you can specify the name of the newly created table and how possible
#' conflicts with existing table names should be handled.
#'
#' @inheritParams dm_add_pk
#' @param new_key_column Name of the identifier column (primary key column) for the
#' newly created lookup (parent) table. A column of this name is also added in `table`.
#' @param ... The columns to be extracted from `table`. `tidyselect` is supported, see
#' [`dplyr::select()`] for details on the semantics.
#' @param new_table_name Unquoted name for the new table. If `NULL`, the name will be
#' `table` with the suffix `_lookup`.
#' @inheritParams dm_add_tbl
#' @inheritParams dm_add_fk
#'
#' @family normalization
#'
#' @return A `dm` with one of its tables split into two tables which are linked by
#' a foreign key relation.
#'
#' @section Life cycle:
#' This function is marked "questioning" because it feels more useful
#' when applied to a table in a dm object.
#'
#' @examples
#' dm_nycflights13() %>%
#'   dm_separate_tbl(flights, ymd, year, month, day)
#' @export
dm_separate_tbl <- function(dm, table, new_key_column, ..., new_table_name = NULL, repair = "check_unique", quiet = FALSE, on_delete = c("no_action", "cascade")) {
  table_name <- as_string(ensym(table))
  check_no_filter(dm)
  check_not_zoomed(dm)

  .data <- dm[[table_name]]
  avail_cols <- colnames(.data)
  sel_vars <- eval_select_both(quo(c(...)), avail_cols)

  old_primary_key <- dm_get_all_pks(dm) %>% filter(table == table_name) %>% pull(pk_col)
  if (has_length(old_primary_key) && old_primary_key %in% sel_vars) {
    abort_no_pk_in_separate_tbl(old_primary_key, table_name)
  }

  new_table_name <- if (is_null(enexpr(new_table_name))) {
    paste0(table_name, "_lookup")
  } else {
    as_string(enexpr(new_table_name))
  }
  old_names <- dm_get_def(dm)$table
  names_list <- repair_table_names(old_names, new_table_name, repair, quiet)
  # rename old tables in case name repair changed their names
  dm <- dm_select_tbl_impl(dm, names_list$new_old_names)
  new_table_name <- names_list$new_names

  new_col_name <- as_string(enexpr(new_key_column))

  id_col_q <- ensym(new_key_column)

  if (as_string(id_col_q) %in% avail_cols) {
    abort_dupl_new_id_col_name(table_name)
  }

  # in case someone called the new table like the old one:
  table_name <- prep_recode(names_list$new_old_names)[table_name]

  parent_table <-
    select(.data, !!!sel_vars$indices) %>%
    distinct() %>%
    # Without as.integer(), RPostgres creates integer64 column (#15)
    mutate(!!id_col_q := as.integer(coalesce(row_number(!!sym(names(sel_vars$indices)[[1]])), 0L))) %>%
    relocate(!!id_col_q)

  non_key_indices <-
    setdiff(seq_along(avail_cols), sel_vars$indices)

  child_table <-
    .data %>%
    left_join(
      parent_table,
      by = prep_recode(sel_vars$names)
    ) %>%
    select(!!!non_key_indices, !!id_col_q)
  # FIXME: Think about a good place for the target column,
  # perhaps if this operation is run in a data model?

  old_foreign_keys <- dm_get_all_fks(dm) %>%
    filter(child_table == table_name)

  affected_fks <- filter(old_foreign_keys, child_fk_col %in% sel_vars)

  dm_get_def(dm) %>%
    mutate(
      data = if_else(table == table_name, list(child_table), data)
    ) %>%
    new_dm3() %>%
    dm_add_tbl_impl(list(parent_table), new_table_name) %>%
    dm_add_pk_impl(new_table_name, new_col_name, FALSE) %>%
    dm_add_fk_impl(table_name, new_col_name, new_table_name) %>%
    # remove FK-constraints from original table
    reduce2(
      affected_fks$child_fk_col,
      affected_fks$parent_table,
      ~ dm_rm_fk(..1, !!table_name, !!..2, !!..3),
      .init = .
    ) %>%
    # add FK-constraints to new table
    reduce2(
      affected_fks$child_fk_col,
      affected_fks$parent_table,
      ~ dm_add_fk_impl(..1, new_table_name, ..2, ..3),
      .init = .
    )
}

#' Merge two tables that are linked by a foreign key relation
#'
#' @description
#' `r lifecycle::badge("questioning")`
#'
#' Join two tables together by their foreign key and update the
#' `dm` accordingly. This is similar to `dm_join_to_tbl()`, only that the resulting
#' table will be part of the `dm`. The name of the child table (the table with the
#' foreign key relation pointing away from it) will be used for the resulting table.
#'
#' Foreign key relations are kept whenever possible.
#'
#' @inheritParams dm_add_pk
#' @param table_1 A table of the `dm` that is directly linked to `table_2`
#' @param table_2 A table of the `dm` that is directly linked to `table_1`
#' @param rm_key_col Boolean, if `TRUE` (default), the FK column is removed after
#' joining the two tables. Otherwise the key column of the child table is kept.
#'
#' @family normalization
#'
#' @return The original `dm` with two of its tables merged into one.
#'
#' @section Life cycle:
#' These functions are marked "questioning" because they feel more useful
#' when applied to a table in a dm object.
#'
#' @export
#' @examples
#' dm_nycflights13() %>%
#'   dm_unite_tbls(flights, planes)
#' @export
dm_unite_tbls <- function(dm, table_1, table_2, rm_key_col = TRUE) {
  table_1_name <- as_string(ensym(table_1))
  table_2_name <- as_string(ensym(table_2))

  check_not_zoomed(dm)
  check_correct_input(dm, c(table_1_name, table_2_name), 2L)
  check_no_filter(dm)

  rel <- parent_child_table(dm, {{ table_1 }}, {{ table_2 }})
  start <- rel$child_table
  other <- rel$parent_table
  # only FKs need to be transferred, because PK-column is lost anyway
  keys_to_transfer <- dm_get_all_fks(dm) %>%
    filter(child_table == other)

  res_tbl <- dm_flatten_to_tbl_impl(
    dm, start, !!other,
    join = left_join, join_name = "left_join", squash = FALSE
  )

  if (rm_key_col) {
    key_col <- rel$child_fk_col
    res_tbl <- select(res_tbl, -!!key_col)
  }

  dm %>%
    dm_rm_tbl(!!other) %>%
    dm_get_def() %>%
    mutate(data = if_else(table == start, list(res_tbl), data)) %>%
    new_dm3() %>%
    reduce2(keys_to_transfer$child_fk_col,
      keys_to_transfer$parent_table,
      ~ dm_add_fk_impl(..1, start, ..2, ..3),
      .init = .
    )
}
