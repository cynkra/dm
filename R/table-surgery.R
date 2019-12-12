dm_separate_tbl <- function(
  dm, table, new_key_column, ..., new_table_name = NULL, repair = "check_unique", quiet = FALSE) {
  table_name <- as_string(ensym(table))
  check_correct_input(dm, table_name)
  check_no_filter(dm)
  check_not_zoomed(dm)

  .data <- tbl(dm, table_name)

  new_table_name <- if (is_null(enexpr(new_table_name))) {
    paste0(table_name, "_lookup")
  } else {
    as_string(enexpr(new_table_name))
  }
  old_names <- src_tbls(dm)
  names_list <- repair_table_names(old_names, new_table_name, repair, quiet)
  # rename old tables in case name repair changed their names
  dm <- dm_select_tbl_impl(dm, names_list$new_old_names)
  new_table_name <- names_list$new_names

  new_col_name <- as_string(enexpr(new_key_column))

  avail_cols <- colnames(.data)
  id_col_q <- ensym(new_key_column)

  if (as_string(id_col_q) %in% avail_cols) {
    abort_dupl_new_id_col_name(table_name)
  }

  sel_vars <- tidyselect::vars_select(avail_cols, ...)

  old_primary_key <- dm_get_pk(dm, !!table_name)
  if (has_length(old_primary_key) && old_primary_key %in% sel_vars) {
    abort_no_pk_in_separate_tbl(old_primary_key, table_name)
  }

  parent_table <-
    select(.data, !!!sel_vars) %>%
    distinct() %>%
    # Without as.integer(), RPostgres creates integer64 column (#15)
    arrange(!!!syms(names(sel_vars))) %>%
    mutate(!!id_col_q := as.integer(row_number())) %>%
    select(!!id_col_q, everything())

  non_key_names <-
    setdiff(avail_cols, sel_vars)

  child_table <-
    .data %>%
    left_join(
      parent_table,
      by = prep_recode(sel_vars)
    ) %>%
    select(non_key_names, !!id_col_q)

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


#' Decompose a table into two linked tables
#'
#' @description Perform table surgery by extracting a 'parent table' from a table, linking the original table and the new table by a key, and returning both tables.
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
#' @family table surgery functions
#'
#' @return A named list of length two:
#'   - entry "child_table": the child table with column `new_id_column` referring to the same column in `parent_table`,
#'   - entry "parent_table": the "lookup table" for `child_table`.
#'
#' @examples
#' decomposed_table <- decompose_table(mtcars, new_id, am, gear, carb)
#' decomposed_table$child_table
#' decomposed_table$parent_table
#' @export
decompose_table <- function(.data, new_id_column, ...) {
  table_name <- deparse(substitute(.data))
  avail_cols <- colnames(.data)
  id_col_q <- ensym(new_id_column)

  if (as_string(id_col_q) %in% avail_cols) {
    abort_dupl_new_id_col_name(table_name)
  }

  sel_vars <- tidyselect::vars_select(avail_cols, ...)

  parent_table <-
    select(.data, !!!sel_vars) %>%
    distinct() %>%
    # Without as.integer(), RPostgres creates integer64 column (#15)
    arrange(!!!syms(names(sel_vars))) %>%
    mutate(!!id_col_q := as.integer(row_number())) %>%
    select(!!id_col_q, everything())

  non_key_names <-
    setdiff(avail_cols, sel_vars)

  child_table <-
    .data %>%
    left_join(
      parent_table,
      by = prep_recode(sel_vars)
    ) %>%
    select(non_key_names, !!id_col_q)
  # FIXME: Think about a good place for the target column,
  # perhaps if this operation is run in a data model?

  list("child_table" = child_table, "parent_table" = parent_table)
}

#' Merge two tables that are linked by a foreign key relation
#'
#' @description Perform table fusion by combining two tables by a common (key) column, and then removing this column.
#'
#' `reunite_parent_child()`: After joining the two tables by the column `id_column`, this column will be removed.
#' The transformation is roughly the
#' inverse of what `decompose_table()` does.
#'
#' @param child_table Table (possibly created by `decompose_table()`) that references `parent_table`
#' @param parent_table Table (possibly created by `decompose_table()`).
#' @param id_column Identical name of referencing / referenced column in `child_table`/`parent_table`.
#'
#' @family table surgery functions
#'
#' @return A wide table produced by joining the two given tables.
#'
#' @examples
#' decomposed_table <- decompose_table(mtcars, new_id, am, gear, carb)
#' ct <- decomposed_table$child_table
#' pt <- decomposed_table$parent_table
#'
#' reunite_parent_child(ct, pt, new_id)
#' reunite_parent_child_from_list(decomposed_table, new_id)
#' @name reunite_parent_child
#' @export
reunite_parent_child <- function(child_table, parent_table, id_column) {
  id_col_q <- ensym(id_column)

  id_col_chr <-
    as_name(id_col_q)

  child_table %>%
    left_join(parent_table, by = id_col_chr) %>%
    select(-!!id_col_q)
}

#' Merge two tables that are linked by a foreign key relation
#'
#' @description `reunite_parent_child_from_list()`: After joining the two tables
#' by the column `id_column`, `id_column` is removed.
#'
#' This function is almost exactly the inverse of `decompose_table()` (the order
#' of the columns is not retained, and the original row names are lost).
#'
#' @param list_of_parent_child_tables Cf arguments `child_table` and `parent_table` from
#'   `reunite_parent_child()`, but both in a named list (as created by `decompose_table()`).
#'
#' @family table surgery functions
#'
#' @rdname reunite_parent_child
#' @export
reunite_parent_child_from_list <- function(list_of_parent_child_tables, id_column) {
  id_col_q <- ensym(id_column)

  id_col_chr <-
    as_name(id_col_q)

  child_table <- list_of_parent_child_tables %>%
    extract2("child_table")

  parent_table <- list_of_parent_child_tables %>%
    extract2("parent_table")

  child_table %>%
    left_join(parent_table, by = id_col_chr) %>%
    select(-!!id_col_q)
}

dm_unite_tbls <- function(dm, table_1, table_2) {
  table_1_name <- as_string(ensym(table_1))
  table_2_name <- as_string(ensym(table_2))

  check_not_zoomed(dm)
  check_correct_input(dm, c(table_1_name, table_2_name), 2L)
  check_no_filter(dm)

  rel <- parent_child_table(dm, {{ table_1 }}, {{ table_2 }})
  start <- rel$child_table
  other <- rel$parent_table
  key_col <- rel$child_fk_col
  # only FKs need to be transferred, because PK-column is lost anyway
  keys_to_transfer <- dm_get_all_fks(dm) %>%
    filter(child_table == other)

  res_tbl <- dm_flatten_to_tbl_impl(
    dm, start, !!other,
    join = left_join, join_name = "left_join", squash = FALSE
  ) %>%
    select(-!!key_col)

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
