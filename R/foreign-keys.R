#' Add a reference from one table of a [`dm`] to another
#'
#' @inheritParams cdm_add_pk
#' @param column The column of `table` which is to become the foreign key column
#' referencing the primary key of `ref_table`.
#' @param ref_table The table which `table` is referencing. This table needs to have
#' a primary key set.
#' @param check Boolean, if `TRUE` (default), a check is performed, if the values of
#' `column` are a subset of the values of the primary key column of `ref_table`.
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

  tbl_obj <- cdm_get_tables(dm)[[table_name]]
  ref_tbl_obj <- cdm_get_tables(dm)[[ref_table_name]]

  if (check && !is_subset(tbl_obj, !!column_name, ref_tbl_obj, !!ref_column_name)) {
    abort_not_subset_of(table_name, column_name, ref_table_name, ref_column_name)
  }

  cdm_add_fk_impl(dm, table_name, column_name, ref_table_name, ref_column_name)
})


cdm_add_fk_impl <- function(dm, table, column, ref_table, ref_column) {
  cdm_data_model <- cdm_get_data_model(dm)

  new_data_model <- upd_data_model_reference(cdm_data_model, table, column, ref_table, ref_column)

  new_dm(cdm_get_tables(dm), new_data_model)
}

#' Does a reference from one table of a `dm` to another exist?
#'
#' @inheritParams cdm_add_fk
#' @param ref_table The table which `table` is potentially referencing.
#'
#' @return A boolean value: `TRUE`, if a reference from `table` to `ref_table` exists, `FALSE` otherwise.
#'
#' @family foreign key functions
#'
#' @export
cdm_has_fk <- function(dm, table, ref_table) {
  has_length(cdm_get_fk(dm, {{ table }}, {{ ref_table }}))
}

#' Retrieve the name of the column marked as foreign key, pointing from one table of a [`dm`] to another
#'
#' @inheritParams cdm_has_fk
#' @param ref_table The table which is referenced from `table`.
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
#' @description Get an overview about all foreign key relations in a [`dm`]
#'
#' @return A tibble with columns:
#'
#' "child_table": child table,
#' "child_fk_col": foreign key column in child table,
#' "parent_table": parent table,
#'
#' @inheritParams cdm_has_fk
#'
#' @family foreign key functions
#'
#' @export
cdm_get_all_fks <- nse_function(c(dm), ~ {
  cdm_get_data_model_fks(dm) %>%
    select(child_table = table, child_fk_col = column, parent_table = ref)
})


#' Remove reference(s) from one table of a [`dm`] to another
#'
#' @description Can either remove one reference between the two tables or all at once if parameter `column = NULL`.
#' All parameters can be provided unquoted or quoted.
#'
#' @inheritParams cdm_add_fk
#' @param column The column of `table` which should no longer be referencing the primary
#'   key of `ref_table`.
#'   If `NULL`, all columns will be considered.
#' @param ref_table The table which `table` was referencing.
#'
#' @family foreign key functions
#'
#' @export
cdm_rm_fk <- function(dm, table, column, ref_table) {
  table_name <- as_name(ensym(table))
  ref_table_name <- as_name(ensym(ref_table))

  check_correct_input(dm, eval_tidy(table_name))
  check_correct_input(dm, eval_tidy(ref_table_name))

  fk_cols <- cdm_get_fk(dm, !!table_name, !!ref_table_name)
  if (is_empty(fk_cols)) {
    return(dm)
  }

  column_quo <- enquo(column)

  if (quo_is_null(column_quo)) {
    col_names <- fk_cols
  } else if (quo_is_missing(column_quo)) {
    abort_rm_fk_col_missing()
  } else {
    # FIXME: Add tidyselect support
    col_names <- as_name(ensym(column))
    if (!all(col_names %in% fk_cols)) {
      abort_is_not_fkc(table_name, col_names, ref_table_name, fk_cols)
    }
  }

  new_dm(
    cdm_get_tables(dm),
    rm_data_model_reference(
      cdm_get_data_model(dm),
      table_name,
      col_names,
      ref_table_name
    )
  )
}

#' Find foreign key candidates in a table
#'
#' Which columns are good candidates as a foreign key of a table, referencing
#' the primary key column of another [`dm`] object's table?
#'
#' @inheritParams cdm_add_fk
#' @param table The table whose columns should be tested for foreign key candidate potential
#' @param ref_table A table with a primary key.
#'
#' @details `cdm_enum_fk_candidates()` checks first, if `ref_table` has a primary key set.
#' For each column of `table` a join operation is then tried, with parameter `by` matching
#' the respective column with the primary key of `ref_table`. This tests implicitly for
#' type compatibility (on most sources). Based on the result of the join, the
#' entry in the result column `why` is:
#'
#' - an empty entry, if the column is a candidate
#' - the total percentage and individual numbers of missing matches between the entries of the
#' respective column in table `table` and the primary column entries in table `ref_table`.
#' - the error message triggered by the error (often stating the mismatched column types)
#'
#' @return A table with an overview which columns of `table` would be suitable candidates as
#' foreign key columns referencing `ref_table` and which columns would not.
#'
#' @family foreign key functions
#'
#' @examples
#' cdm_enum_fk_candidates(cdm_nycflights13(), flights, airports)
#'
#' @export
cdm_enum_fk_candidates <- nse_function(c(dm, table, ref_table), ~ {
  if (nrow(cdm_get_filter(dm)) > 0) {
    abort_only_possible_wo_filters("cdm_enum_pk_candidates()")
  }
  table_name <- as_string(ensym(table))
  ref_table_name <- as_string(ensym(ref_table))

  check_correct_input(dm, table_name)
  check_correct_input(dm, ref_table_name)

  ref_tbl_pk <- cdm_get_pk(dm, !!ref_table_name)
  if (is_empty(ref_tbl_pk)) {
    abort_ref_tbl_has_no_pk(ref_table_name)
  }
  ref_tbl <- tbl(dm, ref_table_name)
  tbl <- tbl(dm, table_name)
  tbl_colnames <- colnames(tbl)

  tibble(
    column = tbl_colnames,
    why = map_chr(column, ~check_fk(dm, tbl, table_name, .x, ref_tbl, ref_table_name, ref_tbl_pk))
  ) %>%
    mutate(candidate = ifelse(why == "", TRUE, FALSE)) %>%
    select(column, candidate, why) %>%
    mutate(arrange_col = as.integer(str_extract(why, "^[0-9]*"))) %>%
    arrange(desc(candidate), arrange_col, column) %>%
    select(-arrange_col)
})

check_fk <- function(dm, t1, t1_name, colname, t2, t2_name, pk) {

  t1_join <- t1 %>% select(value = !!sym(colname))
  t2_join <- t2 %>% select(value = !!sym(pk)) %>% mutate(match = 1L)

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
    error = identity)

  # return error message if error occurred (possibly types didn't match etc.)
  if (is_condition(res_tbl)) return(conditionMessage(res_tbl))
  n_mismatch <- pull(head(res_tbl, 1), n_mismatch)
  # return empty character if candidate
  if (is_empty(n_mismatch)) return("")
  # calculate percentage and compose detailed description for missing values
  n_total <- pull(head(res_tbl, 1), n_total)

  percentage_missing <- as.character(round((n_mismatch / n_total) * 100, 1))
  vals_extended <- res_tbl %>%
    mutate(num_mismatch = paste0(mismatch_or_null, " (", n, ")")) %>%
    # FIXME: this fails on SQLite, why?
    # mutate(num_mismatch = glue("{as.character(mismatch_or_null)} ({as.character(n)})")) %>%
    pull()
  vals_formatted <- commas(format(vals_extended, trim = TRUE, justify = "none"))
  glue("{as.character(n_mismatch)} entries ({percentage_missing}%) of ",
       "{tick(glue('{t1_name}${colname}'))} not in {tick(glue('{t2_name}${pk}'))}: {vals_formatted}")
}
