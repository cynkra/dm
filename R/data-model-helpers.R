# helper function for updating the data model when adding a reference from one table to another
upd_data_model_reference <- function(data_model, table, column, ref_table, ref_column) {
  temp_data_model <- upd_references_reference(data_model, table, column, ref_table, ref_column)
  upd_columns_reference(temp_data_model, table, column, ref_table, ref_column)
}

# updates only the $references part of the data model with a reference
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

# updates only the $columns part of the data model with a reference
upd_columns_reference <- function(data_model, table, column, ref_table, ref_column) {
  if (is_null(data_model$columns$ref_col)) data_model$columns$ref_col <- NA
  ind_columns_upd <- data_model$columns$column == column & data_model$columns$table == table

  data_model$columns$ref[ind_columns_upd] <- ref_table
  data_model$columns$ref_col[ind_columns_upd] <- ref_column
  data_model
}


# helper function for removing one or more references from one table to another in the data model
rm_data_model_reference <- function(data_model, table, cols, ref_table) {
  temp_data_model <- rm_references_reference(data_model, table, cols, ref_table)
  rm_columns_reference(temp_data_model, table, cols, ref_table)
}


# removes one or more references only from the $references part of the data model
rm_references_reference <- function(data_model, table, cols, ref_table) {
  references <- data_model$references

  lines_to_keep <- references$table != table |
    !(references$column %in% cols) |
    references$ref != ref_table

  if (sum(lines_to_keep) == 0) {
    new_references <- NULL
  } else {
    new_references <- references[lines_to_keep,]
  }

  data_model$references <- new_references
  data_model
}

# removes one or more references only from the $columns part of the data model
rm_columns_reference <- function(data_model, table, cols, ref_table) {
  cols_data_model <- data_model$columns

  lines_to_modify <- cols_data_model$column %in% cols &
    cols_data_model$table == table &
    cols_data_model$ref == ref_table

  cols_data_model[lines_to_modify,]$ref <- NA
  cols_data_model[lines_to_modify,]$ref_col <- NA

  data_model$columns <- cols_data_model
  data_model
}
