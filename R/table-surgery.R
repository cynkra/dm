#' Decompose a table into two linked tables
#'
#' @description
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
  new_col_name <- as_string(enexpr(new_key_column))

  split_data <- decompose_table_impl(.data, !!enexpr(new_col_name), table_name, sel_vars)

  old_primary_key <- dm_get_all_pks(dm) %>%
    filter(table == table_name) %>%
    pull(pk_col)
  if (has_length(old_primary_key) && old_primary_key %in% sel_vars$names) {
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

  # in case someone called the new table like the old one:
  table_name <- prep_recode(names_list$new_old_names)[table_name]

  parent_table <- split_data$parent_table
  child_table <- split_data$child_table

  old_foreign_keys <- dm_get_all_fks(dm) %>%
    filter(child_table == table_name)

  affected_fks <- filter(old_foreign_keys, child_fk_cols %in% sel_vars$names)
  on_delete = arg_match(on_delete)

  dm_get_def(dm) %>%
    mutate(
      data = if_else(table == table_name, list(child_table), data)
    ) %>%
    new_dm3() %>%
    dm_add_tbl_impl(list(parent_table), new_table_name) %>%
    dm_add_pk_impl(new_table_name, new_col_name, FALSE) %>%
    dm_add_fk_impl(table_name, list(new_col_name), new_table_name, list(new_col_name), on_delete = on_delete) %>%
    # remove FK-constraints from original table
    reduce2(
      affected_fks$child_fk_cols,
      affected_fks$parent_table,
      ~ dm_rm_fk(..1, !!table_name, !!..2, !!..3),
      .init = .
    ) %>%
    # add FK-constraints to new table
    reduce2(
      affected_fks$child_fk_cols,
      affected_fks$parent_table,
      ~ dm_add_fk_impl(..1, new_table_name, ..2, ..3),
      .init = .
    )
}

#' Merge two tables that are linked by a foreign key relation
#'
#' @description
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
#' @export
#' @examples
#' dm_nycflights13() %>%
#'   dm_unite_tbls(flights, planes)
#' @export
dm_unite_tbls <- function(dm, table_1, table_2, rm_key_col = TRUE) {
  table_1_name <- as_string(ensym(table_1))
  table_2_name <- as_string(ensym(table_2))
  check_not_zoomed(dm)
  check_no_filter(dm)

  rel <- parent_child_table(dm, {{ table_1 }}, {{ table_2 }})
  child <- rel$child_table
  parent <- rel$parent_table

  # rename cols if necessary
  temp_dm <- prepare_dm_for_flatten(dm, c(child, parent), TRUE, FALSE)

  # only FKs need to be transferred, because PK-column is lost anyway
  keys_to_transfer <- dm_get_all_fks(temp_dm) %>%
    filter(child_table == parent)

  tables_in_dm <- dm_get_tables_impl(temp_dm)
  child_data <- tables_in_dm[[child]]
  parent_data <- tables_in_dm[[parent]]
  by <- get_by(temp_dm, rel$child_table, rel$parent_table)
  res_tbl <- reunite_parent_child_impl(child_data, parent_data, by, rm_key_col)

  temp_dm %>%
    dm_rm_tbl(parent) %>%
    dm_get_def() %>%
    mutate(data = if_else(table == child, list(res_tbl), data)) %>%
    new_dm3() %>%
    reduce2(keys_to_transfer$child_fk_cols,
      keys_to_transfer$parent_table,
      ~ dm_add_fk_impl(..1, start, ..2, ..3),
      .init = .
    )
}

#' Decompose a table into two linked tables
#'
#' @description
#' `r lifecycle::badge("questioning")`
#'
#' Perform table surgery by extracting a 'parent table' from a table, linking the original table and the new table by a key, and returning both tables.
#'
#' `decompose_table()` accepts a data frame, a name for the 'ID column' that will be newly created, and the names
#' of the columns that will be extracted into the new data frame.
#'
#' It creates a 'parent table', which consists of the columns specified in the ellipsis, and a new 'ID column'.
#' Then it removes those
#' columns from the original table, which is now called the 'child table, and adds the 'ID column'.
#'
#' @param .data Data frame from which columns `...` are to be extracted.
#' @param new_id_column Name of the identifier column (primary key column) for the parent table.
#'   A column of this name is also added in 'child table'.
#' @param ... The columns to be extracted from the `.data`.
#'
#'   One or more unquoted expressions separated by commas.
#'   You can treat variable names as if they were positions, so you
#'   can use expressions like x:y to select ranges of variables.
#'
#'   The arguments in ... are automatically quoted and evaluated in a context where column names represent column positions.
#'   They also support
#'   unquoting and splicing.
#'   See vignette("programming") for an introduction to those concepts.
#'
#'   See select helpers for more details, and the examples about tidyselect helpers, such as starts_with(), everything(), ...
#'
#' @family normalization
#'
#' @return A named list of length two:
#'   - entry "child_table": the child table with column `new_id_column` referring to the same column in `parent_table`,
#'   - entry "parent_table": the "lookup table" for `child_table`.
#'
#' @section Life cycle:
#' This function is marked "questioning" because it feels more useful
#' when applied to a table in a dm object.
#'
#' @examples
#' decomposed_table <- decompose_table(mtcars, new_id, am, gear, carb)
#' decomposed_table$child_table
#' decomposed_table$parent_table
#' @export
decompose_table <- function(.data, new_id_column, ...) {
  table_name <- deparse(substitute(.data))
  avail_cols <- colnames(.data)
  sel_vars <- eval_select_both(quo(c(...)), avail_cols)
  decompose_table_impl(.data, !!enexpr(new_id_column), table_name, sel_vars)
}

#' Merge two tables that are linked by a foreign key relation
#'
#' @description
#' `r lifecycle::badge("questioning")`
#'
#' Perform table fusion by combining two tables by a common (key) column, and then removing this column.
#'
#' `reunite_parent_child()`: After joining the two tables by the column `id_column`, this column will be removed.
#' The transformation is roughly the
#' inverse of what `decompose_table()` does.
#'
#' @param child_table Table (possibly created by `decompose_table()`) that references `parent_table`
#' @param parent_table Table (possibly created by `decompose_table()`).
#' @param id_column Identical name of referencing / referenced column in `child_table`/`parent_table`.
#'
#' @family normalization
#'
#' @return A wide table produced by joining the two given tables.
#'
#' @section Life cycle:
#' These functions are marked "questioning" because they feel more useful
#' when applied to a table in a dm object.
#'
#' @name reunite_parent_child
#'
#' @export
#' @examples
#' decomposed_table <- decompose_table(mtcars, new_id, am, gear, carb)
#' ct <- decomposed_table$child_table
#' pt <- decomposed_table$parent_table
#'
#' reunite_parent_child(ct, pt, new_id)
#' reunite_parent_child_from_list(decomposed_table, new_id)
reunite_parent_child <- function(child_table, parent_table, id_column) {
  id_col_name <- as_string(ensym(id_column))
  reunite_parent_child_impl(child_table, parent_table, by = set_names(id_col_name), TRUE)
}


#' @description `reunite_parent_child_from_list()`: After joining the two tables
#' by the column `id_column`, `id_column` is removed.
#'
#' This function is almost exactly the inverse of `decompose_table()` (the order
#' of the columns is not retained, and the original row names are lost).
#'
#' @param list_of_parent_child_tables Cf arguments `child_table` and `parent_table` from
#'   `reunite_parent_child()`, but both in a named list (as created by `decompose_table()`).
#'
#' @rdname reunite_parent_child
#' @export
reunite_parent_child_from_list <- function(list_of_parent_child_tables, id_column) {
  id_col_name <- as_string(ensym(id_column))
  reunite_parent_child_impl(
    list_of_parent_child_tables$child_table,
    list_of_parent_child_tables$parent_table,
    by = set_names(id_col_name),
    TRUE
  )
}

decompose_table_impl <- function(.data, new_id_column, table_name, sel_vars) {
  avail_cols <- colnames(.data)
  id_col_q <- ensym(new_id_column)

  if (as_string(id_col_q) %in% avail_cols) {
    abort_dupl_new_id_col_name(table_name)
  }

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

  list("child_table" = child_table, "parent_table" = parent_table)
}

reunite_parent_child_impl <- function(child_table, parent_table, by, rm_key_col) {
  res_tbl <- child_table %>%
    left_join(parent_table, by = by)

  if (rm_key_col) {
    res_tbl <- select(res_tbl, -names(by))
  }

  res_tbl
}
