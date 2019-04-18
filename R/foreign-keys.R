

cdm_add_fk_impl <- function(dm, table, column, ref_table, ref_column) {
  cdm_data_model <- cdm_get_data_model(dm)

  new_data_model <- upd_data_model_reference(cdm_data_model, table, column, ref_table, ref_column)

  new_dm(cdm_get_src(dm), cdm_get_tables(dm), new_data_model)
}
