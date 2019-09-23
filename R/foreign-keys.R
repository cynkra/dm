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
  ref_table_name <- as_name(ensym(ref_table))

  column_name <- as_name(ensym(column))

  check_correct_input(dm, table_name)
  check_correct_input(dm, ref_table_name)

  check_col_input(dm, table_name, column_name)
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
#' Which columns are candidates for a foreign key of a table, referencing
#' the primary key column of another [`dm`] object's table?
#'
#' @inheritParams cdm_add_fk
#' @param table The table whose columns should be tested for foreign key candidate potential
#' @param ref_table A table with a primary key.
#'
#' @details `cdm_enum_fk_candidates()` checks first, if `ref_table` has a primary key set. Then
#' it determines for each column of `table`, if it has the same class as the primary key of `ref_table`.
#' If this is the case a check is performed, if the column contains only a subset of values of the
#' primary key column of `ref_table`. If this is `TRUE`, this column is a candidate for a foreign key
#' from `table` to `ref_table`.
#'
#' @return A table with an overview which columns of `table` would be suitable candidates as
#' foreign key columns referencing `ref_table`
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
    why = map_chr(column, ~why(dm, tbl, .x, ref_tbl, ref_table_name, ref_tbl_pk))
  ) %>%
    mutate(candidate = ifelse(why == "", TRUE, FALSE)) %>%
    select(column, candidate, why) %>%
    mutate(arrange_col = str_sub(why, 1, 3)) %>%
    arrange(desc(candidate), desc(arrange_col), column) %>%
    select(-arrange_col)
})

why <- function(dm, t1, colname, t2, t2_name, pk) {
  names(pk) <- colname
  test <- tryCatch(anti_join(
    select(t1, !!sym(colname)), select(t2, !!sym(pk)), by = pk) %>%
      utils::head(MAX_COMMAS + 1) %>%
      pull(), error = identity)
  if (is_condition(test)) {
    return(conditionMessage(test))
  }
  if (is_empty(test)) return("") else {
    test_formatted <- commas(format(test, trim = TRUE, justify = "none"))
    glue("values not in {tick(glue('{t2_name}${pk}'))}: {test_formatted}")
  }
}
