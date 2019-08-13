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
#' @family Foreign key functions
#'
#' @export
cdm_add_fk <- nse_function(c(dm, table, column, ref_table, check = TRUE), ~ {
  table_name <- as_name(enquo(table))
  ref_table_name <- as_name(enquo(ref_table))

  column_name <- as_name(enexpr(column))

  check_correct_input(dm, table_name)
  check_correct_input(dm, ref_table_name)

  check_col_input(dm, table_name, column_name)
  if (!cdm_has_pk(dm, !!ref_table_name)) {
    abort_ref_tbl_has_no_pk(
      ref_table_name,
      cdm_enum_pk_candidates(dm, !!ref_table_name) %>%
        filter(candidate == TRUE) %>%
        pull(column)
    )
  }
  ref_column_name <- cdm_get_pk(dm, !!ref_table_name)

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

  new_dm(cdm_get_src(dm), cdm_get_tables(dm), new_data_model)
}

#' Does a reference from one table of a `dm` to another exist?
#'
#' @inheritParams cdm_add_fk
#' @param ref_table The table which `table` is potentially referencing.
#'
#' @return A boolean value: `TRUE`, if a reference from `table` to `ref_table` exists, `FALSE` otherwise.
#'
#' @family Foreign key functions
#'
#' @export
cdm_has_fk <- function(dm, table, ref_table) {
  table_name <- as_name(enquo(table))
  ref_table_name <- as_name(enquo(ref_table))

  check_correct_input(dm, table_name)
  check_correct_input(dm, ref_table_name)

  fks <- cdm_get_data_model_fks(dm)
  any(fks$table == table_name & fks$ref == ref_table_name)
}

#' Retrieve the name of the column marked as foreign key, pointing from one table of a [`dm`] to another
#'
#' @inheritParams cdm_has_fk
#' @param ref_table The table which is referenced from `table`.
#'
#' @family Foreign key functions
#'
#' @export
cdm_get_fk <- function(dm, table, ref_table) {
  table_name <- as_name(enquo(table))
  ref_table_name <- as_name(enquo(ref_table))

  check_correct_input(dm, table_name)
  check_correct_input(dm, ref_table_name)

  dm_data_model <- cdm_get_data_model(dm)
  fk_ind <- dm_data_model$references$table == table_name & dm_data_model$references$ref == ref_table_name

  as.character(dm_data_model$references$column[fk_ind]) # FIXME: maybe something nicer?
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
#' @family Foreign key functions
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
#' key of `ref_table`.
#' @param ref_table The table which `table` was referencing.
#'
#' @family Foreign key functions
#'
#' @export
cdm_rm_fk <- function(dm, table, column, ref_table) {
  table_name <- as_name(enquo(table))
  ref_table_name <- as_name(enquo(ref_table))

  check_correct_input(dm, eval_tidy(table_name))
  check_correct_input(dm, eval_tidy(ref_table_name))

  if (!cdm_has_fk(dm, !!table_name, !!ref_table_name)) {
    return(dm)
  }

  if (quo_is_null(enquo(column))) {
    col_names <- cdm_get_fk(dm, !!table_name, !!ref_table_name)
  } else {
    col_names <- as_name(enexpr(column))
    if (col_names == "") {
      abort_rm_fk_col_missing()
    }
  }

  if (!(all(col_names %in% cdm_get_fk(dm, !!table_name, !!ref_table_name)))) {
    abort_is_not_fkc(
      table_name, col_names, ref_table_name, cdm_get_fk(dm, !!table_name, !!ref_table_name)
    )
  }

  new_dm(
    cdm_get_src(dm),
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
#' @inheritParams cdm_add_fk
#' @param table The table whose columns should be tested for foreign key candidate potential
#' @param ref_table A table with a primary key.
#'
#' @description Which columns are foreign candidates of a table, referencing the primary key column of another [`dm`] object's table?
#' `cdm_enum_fk_candidates()` checks first, if `ref_table` has a primary key set. Then it determines
#' for each column of `table`, if this column contains only a subset of values of the primary key column of
#' `ref_table` and is therefore a candidate for a foreign key from `table` to `ref_table`.
#'
#' @family Foreign key functions
#'
#' @examples
#' library(dplyr)
#'
#' nycflights_dm <- cdm_nycflights13(cycle = TRUE)
#'
#' nycflights_dm %>%
#'   cdm_enum_fk_candidates(flights, airports)
#' @export
cdm_enum_fk_candidates <- nse_function(c(dm, table, ref_table), ~ {
  table_name <- as_name(enquo(table))
  ref_table_name <- as_name(enquo(ref_table))

  check_correct_input(dm, table_name)
  check_correct_input(dm, ref_table_name)

  if (!cdm_has_pk(dm, !!ref_table_name)) {
    abort_ref_tbl_has_no_pk(
      ref_table_name,
      cdm_enum_pk_candidates(dm, !!ref_table_name) %>%
        filter(candidate == TRUE) %>%
        pull(column)
    )
  }

  tbl <- cdm_get_tables(dm)[[table_name]]
  tbl_colnames <- colnames(tbl)

  ref_tbl <- cdm_get_tables(dm)[[ref_table_name]]
  ref_tbl_pk <- cdm_get_pk(dm, !!ref_table_name)

  subsets <- map_lgl(
    tbl_colnames,
    ~ is_subset(tbl, !!.x, ref_tbl, !!ref_tbl_pk)
  )

  tibble(
    ref_table = ref_table_name,
    ref_table_pk = ref_tbl_pk,
    table = table_name,
    column = tbl_colnames,
    candidate = subsets,
    why = if_else(subsets, "", paste0("not a subset of ", ref_table, "$", ref_table_pk))
  )
})
