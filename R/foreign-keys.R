#' Add a reference from one table of a `dm` to another
#'
#' @export
cdm_add_fk <- function(dm, table, column, ref_table, ref_column, set_ref_pk = FALSE) {
  table_name <- as_name(enquo(table))
  ref_table_name <- as_name(enquo(ref_table))

  column_name <- as_name(enexpr(column))
  ref_column_name <- as_name(enexpr(ref_column))

  check_correct_input(dm, table_name)
  check_correct_input(dm, ref_table_name)

  check_col_input(dm, table_name, column_name)
  check_col_input(dm, ref_table_name, ref_column_name)

  # ref_column has to be primary key of ref_table
  if (!set_ref_pk) {
    if (is_empty(cdm_get_pk(dm, ref_table_name)) ||
        !(cdm_get_pk(dm, ref_table_name) == ref_column_name)) {
      abort(paste0(
        "'", ref_column_name, "' needs to be primary key of '", ref_table_name,
        "' but isn't. You can set parameter 'set_ref_pk = TRUE', or use function",
        " cdm_add_pk() to set it as primary key.")
      )
    }
  } else {
    if (is_empty(cdm_get_pk(dm, table_name)) ||
        !(cdm_get_pk(dm, table_name) == ref_column_name)) {
      dm <- cdm_add_pk(dm, ref_table_name, eval_tidy(ref_column_name))
    }
  }

  cdm_add_fk_impl(dm, table_name, column_name, ref_table_name, ref_column_name)
}


cdm_add_fk_impl <- function(dm, table, column, ref_table, ref_column) {
  cdm_data_model <- cdm_get_data_model(dm)

  new_data_model <- upd_data_model_reference(cdm_data_model, table, column, ref_table, ref_column)

  new_dm(cdm_get_src(dm), cdm_get_tables(dm), new_data_model)
}

#' Does a reference from one table of a `dm` to another exist?
#'
#' @export
cdm_has_fk <- function(dm, table, ref_table) {
  table_name <- as_name(enquo(table))
  ref_table_name <- as_name(enquo(ref_table))

  check_correct_input(dm, table_name)
  check_correct_input(dm, ref_table_name)

  dm_data_model <- cdm_get_data_model(dm)
  any(dm_data_model$references$table == table_name & dm_data_model$references$ref == ref_table_name)
}

#' Retrieve the name of the column marked as foreign key, pointing from one table of a `dm` to another
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

#' Remove reference(s) from one table of a `dm` to another
#'
#' @details Can either remove one reference between the two tables or all at once if parameter `column = NULL`.
#' All parameters can be provided unquoted or quoted.'
#'
#' @export
cdm_rm_fk <- function(dm, table, column, ref_table) {

  table_name <- as_name(enquo(table))
  ref_table_name <- as_name(enquo(ref_table))

  check_correct_input(dm, eval_tidy(table_name))
  check_correct_input(dm, eval_tidy(ref_table_name))

  if (!cdm_has_fk(dm, !! table_name, !! ref_table_name)) {
    return(dm)
  }

  if (is_null(eval_tidy(enexprs(column)) %>% extract2(1))) { # FIXME: there must be a nicer way of checking if NULL, without running into problems, when column is a symbol (I tried is_symbol() without success)
      col_names <- cdm_get_fk(dm, !! table_name, !! ref_table_name)
  } else {
    col_names <- as_name(enexpr(column))
    if (col_names == "") {
      abort("Parameter 'column' has to be set. 'NULL' for removing all references.")
    }
  }

  if (!(all(col_names %in% cdm_get_fk(dm, !! table_name, !! ref_table_name)))) {
    abort(paste0("The given column '",
                 paste0(col_names, collapse = ", "),
                 "' is not a foreign key column of table '",
                 table_name,
                 "' with regards to ref_table '",
                 ref_table_name,
                 "'. Foreign key columns are: '",
                 paste0(cdm_get_fk(dm, !! table_name, !! ref_table_name), collapse = ", "), "'.")
          )
  }

  dm$data_model <-
    rm_data_model_reference(
      cdm_get_data_model(dm),
      table_name,
      col_names,
      ref_table_name
      )

  dm
}
