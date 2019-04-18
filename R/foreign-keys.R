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
    if (is_empty(cdm_get_pk(dm, table_name)) ||
        !(cdm_get_pk(dm, table_name) == ref_column_name)) {
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
