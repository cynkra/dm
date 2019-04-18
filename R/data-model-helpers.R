# helper function for updating the data model when adding a reference from one table to another
upd_data_model_reference <- function(data_model, table, column, ref_table, ref_column) {
  temp_data_model <- upd_references_reference(data_model, table, column, ref_table, ref_column)
  upd_columns_reference(temp_data_model, table, column, ref_table, ref_column)
}

upd_references_reference <- function(data_model, table, column, ref_table, ref_column) {
  references <- data_model$references

  tbl_from_data_model_cols <- data_model$columns[data_model$columns$table == table,]
  new_ref_col_num <- which(tbl_from_data_model_cols$column == column)

  if (!is_null(references)) {
    new_references <- add_row(
      references,
      table = table,
      column = column,
      ref = ref_table,
      ref_col = ref_column,
      ref_id = nrow(references) + 1,
      ref_col_num = new_ref_col_num)
  } else {
    new_references <- data.frame(
      table = table,
      column = column,
      ref = ref_table,
      ref_col = ref_column,
      ref_id = 1,
      ref_col_num = new_ref_col_num)
  }

  data_model$references <- new_references
  data_model
}

upd_columns_reference <- function(data_model, table, column, ref_table, ref_column) {
  if (is_null(data_model$columns$ref_col)) data_model$columns$ref_col <- NA
  ind_columns_upd <- data_model$columns$column == column & data_model$columns$table == table

  data_model$columns$ref[ind_columns_upd] <- ref_table
  data_model$columns$ref_col[ind_columns_upd] <- ref_column
  data_model
}
