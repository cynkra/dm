#' Add a reference from one table of a [`dm`] to another
#'
#' @inheritParams cdm_add_pk
#' @param column The column of `table` which is to become the foreign key column and
#'   reference the primary key of `ref_table`.
#' @param ref_table The table which `table` is referencing.
#'   This table needs to have a primary key set.
#' @param check Boolean, if `TRUE`, a check will be performed to determine if the values of
#'   `column` are a subset of the values of the primary key column of `ref_table`.
#'
#' @family foreign key functions
#'
#' @export
cdm_add_fk <- nse_function(c(dm, table, column, ref_table, check = FALSE), ~ {
  table_name <- as_name(ensym(table))
  check_correct_input(dm, table_name)

  column_name <- as_name(ensym(column))
  check_col_input(dm, table_name, column_name)

  ref_table_name <- as_name(ensym(ref_table))
  check_correct_input(dm, ref_table_name)

  ref_column_name <- cdm_get_pk(dm, !!ref_table_name)
  if (is_empty(ref_column_name)) {
    abort_ref_tbl_has_no_pk(ref_table_name)
  }

  if (check) {
    tbl_obj <- cdm_get_tables(dm)[[table_name]]
    ref_tbl_obj <- cdm_get_tables(dm)[[ref_table_name]]

    if (!is_subset(tbl_obj, !!column_name, ref_tbl_obj, !!ref_column_name)) {
      abort_not_subset_of(table_name, column_name, ref_table_name, ref_column_name)
    }
  }

  cdm_add_fk_impl(dm, table_name, column_name, ref_table_name)
})


cdm_add_fk_impl <- function(dm, table, column, ref_table) {
  def <- cdm_get_def(dm)

  i <- which(def$table == ref_table)
  def$fks[[i]] <- vctrs::vec_rbind(
    def$fks[[i]],
    new_fk(table, list(column))
  )

  new_dm3(def)
}

#' Does there exist a reference from one table of a `dm` to another?
#'
#' @inheritParams cdm_add_fk
#' @param ref_table The table that `table` is potentially referencing.
#'
#' @return A boolean value: `TRUE` if a reference from `table` to `ref_table` exists, `FALSE` otherwise.
#'
#' @family foreign key functions
#'
#' @export
cdm_has_fk <- function(dm, table, ref_table) {
  has_length(cdm_get_fk(dm, {{ table }}, {{ ref_table }}))
}

#' Retrieve the name of the column marked as a foreign key, pointing from one table of a [`dm`] to another table.
#'
#' @inheritParams cdm_has_fk
#' @param ref_table The table that is referenced from `table`.
#'
#' @family foreign key functions
#'
#' @export
cdm_get_fk <- function(dm, table, ref_table) {
  table_name <- as_name(ensym(table))
  ref_table_name <- as_name(ensym(ref_table))

  check_correct_input(dm, table_name)
  check_correct_input(dm, ref_table_name)

  fks <- cdm_get_data_model_fks(dm)
  fks$column[fks$table == table_name & fks$ref == ref_table_name]
}

#' Retrieve all foreign key constraints in a [`dm`]
#'
#' @description Get a summary of all foreign key relations in a [`dm`]
#'
#' @return A tibble with columns:
#'
#' "child_table": child table,
#' "child_fk_col": foreign key column in child table,
#' "parent_table": parent table
#'
#' @inheritParams cdm_has_fk
#'
#' @family foreign key functions
#'
#' @export
cdm_get_all_fks <- nse_function(c(dm), ~ {
  cdm_get_data_model_fks(dm) %>%
    select(child_table = table, child_fk_col = column, parent_table = ref) %>%
    arrange(child_table, child_fk_col)
})


#' Remove the reference(s) from one [`dm`] table to another
#'
#' @description This function can remove either one reference between two tables, or all references at once, if argument `column = NULL`.
#' All arguments may be provided quoted or unquoted.
#'
#' @inheritParams cdm_add_fk
#' @param column The column of `table` that should no longer be referencing the primary key of `ref_table`.
#'   If `NULL`, all columns will be evaluated.
#' @param ref_table The table that `table` was referencing.
#'
#' @family foreign key functions
#'
#' @export
cdm_rm_fk <- function(dm, table, column, ref_table) {
  table <- as_name(ensym(table))
  ref_table <- as_name(ensym(ref_table))

  check_correct_input(dm, table)
  check_correct_input(dm, ref_table)

  fk_cols <- cdm_get_fk(dm, !!table, !!ref_table)
  if (is_empty(fk_cols)) {
    return(dm)
  }

  column_quo <- enquo(column)

  if (quo_is_missing(column_quo)) {
    abort_rm_fk_col_missing()
  }

  if (quo_is_null(column_quo)) {
    cols <- fk_cols
  } else {
    # FIXME: Add tidyselect support
    cols <- as_name(ensym(column))
    if (!all(cols %in% fk_cols)) {
      abort_is_not_fkc(table, cols, ref_table, fk_cols)
    }
  }

  # FIXME: compound keys
  cols <- as.list(cols)

  def <- cdm_get_def(dm)
  i <- which(def$table == ref_table)

  fks <- def$fks[[i]]
  fks <- fks[fks$table != table | is.na(vctrs::vec_match(fks$column, cols)), ]
  def$fks[[i]] <- fks

  new_dm3(def)
}

#' Find foreign key candidates in a table
#'
#' Determine which columns would be good candidates to be used as foreign keys of a table,
#' to reference the primary key column of another table of the [`dm`] object.
#'
#' @inheritParams cdm_add_fk
#' @param table The table whose columns should be tested for suitability as foreign keys.
#' @param ref_table A table with a primary key.
#'
#' @details `cdm_enum_fk_candidates()` first checks if `ref_table` has a primary key set,
#' if not, an error is thrown.
#'
#' If `ref_table` does have a primary key, then a join operation will be tried using
#' that key as the `by` argument of join() to match it to each column of `table`.
#' Attempting to join incompatible columns triggers an error.
#'
#' The outcome of the join operation determines the value of the `why` column in the result:
#'
#' - an empty value for a column of `table` that is a suitable foreign key candidate
#' - the count and percentage of missing matches for a column that is not suitable
#' - the error message triggered for unsuitable candidates that may include the types of mismatched columns
#'
#' @return A table that lists which columns of `table` would be suitable candidates for
#' foreign key columns to reference `ref_table`, which columns would not be suitable,
#' and the reason `why`.
#'
#' @family foreign key functions
#'
#' @examples
#' cdm_enum_fk_candidates(cdm_nycflights13(), flights, airports)
#' @export
cdm_enum_fk_candidates <- nse_function(c(dm, table, ref_table), ~ {
  # FIXME: with "direct" filter maybe no check necessary: but do we want to check
  # for tables retrieved with `tbl()` or with `cdm_get_tables()[[table_name]]`
  check_no_filter(dm)
  table_name <- as_string(ensym(table))
  ref_table_name <- as_string(ensym(ref_table))

  check_correct_input(dm, table_name)
  check_correct_input(dm, ref_table_name)

  ref_tbl_pk <- cdm_get_pk(dm, !!ref_table_name)

  ref_tbl <- tbl(dm, ref_table_name)
  tbl <- tbl(dm, table_name)

  enum_fk_candidates_impl(table_name, tbl, ref_table_name, ref_tbl, ref_tbl_pk)
})

#' @details `enum_fk_candidates()` works like `cdm_enum_fk_candidates()` with the zoomed table as `table`.
#'
#' @rdname cdm_enum_fk_candidates
#' @param zoomed_dm A `dm` with a zoomed table.
#' @export
enum_fk_candidates <- function(zoomed_dm, ref_table) {
  check_dm(zoomed_dm)
  check_zoomed(zoomed_dm)

  table_name <- orig_name_zoomed(zoomed_dm)
  ref_table_name <- as_string(ensym(ref_table))
  check_correct_input(zoomed_dm, ref_table_name)

  ref_tbl_pk <- cdm_get_pk(zoomed_dm, !!ref_table_name)

  ref_tbl <- cdm_get_filtered_table(zoomed_dm, ref_table_name)
  enum_fk_candidates_impl(table_name, get_zoomed_tbl(zoomed_dm), ref_table_name, ref_tbl, ref_tbl_pk)
}

enum_fk_candidates_impl <- function(table_name, tbl, ref_table_name, ref_tbl, ref_tbl_pk) {
  if (is_empty(ref_tbl_pk)) {
    abort_ref_tbl_has_no_pk(ref_table_name)
  }
  tbl_colnames <- colnames(tbl)
  tibble(
    column = tbl_colnames,
    why = map_chr(column, ~ check_fk(tbl, table_name, .x, ref_tbl, ref_table_name, ref_tbl_pk))
  ) %>%
    mutate(candidate = ifelse(why == "", TRUE, FALSE)) %>%
    select(column, candidate, why) %>%
    mutate(arrange_col = as.integer(gsub("(^[0-9]*).*$", "\\1", why))) %>%
    arrange(desc(candidate), arrange_col, column) %>%
    select(-arrange_col)
}

check_fk <- function(t1, t1_name, colname, t2, t2_name, pk) {
  t1_join <- t1 %>% select(value = !!sym(colname))
  t2_join <- t2 %>%
    select(value = !!sym(pk)) %>%
    mutate(match = 1L)

  res_tbl <- tryCatch(
    left_join(t1_join, t2_join, by = "value") %>%
      # if value is NULL, this also counts as a match -- consistent with fk semantics
      mutate(mismatch_or_null = if_else(is.na(match), value, NULL)) %>%
      count(mismatch_or_null) %>%
      ungroup() %>% # dbplyr problem?
      mutate(n_mismatch = sum(if_else(is.na(mismatch_or_null), 0L, n), na.rm = TRUE)) %>%
      mutate(n_total = sum(n, na.rm = TRUE)) %>%
      arrange(desc(n)) %>%
      filter(!is.na(mismatch_or_null)) %>%
      head(MAX_COMMAS + 1L) %>%
      collect(),
    error = identity
  )

  # return error message if error occurred (possibly types didn't match etc.)
  if (is_condition(res_tbl)) {
    return(conditionMessage(res_tbl))
  }
  n_mismatch <- pull(head(res_tbl, 1), n_mismatch)
  # return empty character if candidate
  if (is_empty(n_mismatch)) {
    return("")
  }
  # calculate percentage and compose detailed description for missing values
  n_total <- pull(head(res_tbl, 1), n_total)

  percentage_missing <- as.character(round((n_mismatch / n_total) * 100, 1))
  vals_extended <- res_tbl %>%
    mutate(num_mismatch = paste0(mismatch_or_null, " (", n, ")")) %>%
    # FIXME: this fails on SQLite, why?
    # mutate(num_mismatch = glue("{as.character(mismatch_or_null)} ({as.character(n)})")) %>%
    pull()
  vals_formatted <- commas(format(vals_extended, trim = TRUE, justify = "none"))
  glue(
    "{as.character(n_mismatch)} entries ({percentage_missing}%) of ",
    "{tick(glue('{t1_name}${colname}'))} not in {tick(glue('{t2_name}${pk}'))}: {vals_formatted}"
  )
}
