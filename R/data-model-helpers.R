# helper function for updating the data model when adding a reference from one table to another
upd_data_model_reference <- function(data_model, table, column, ref_table, ref_column) {
  temp_data_model <- upd_references_reference(data_model, table, column, ref_table, ref_column)
  upd_columns_reference(temp_data_model, table, column, ref_table, ref_column)
}

# updates only the $references part of the data model with a reference
upd_references_reference <- function(data_model, table, column, ref_table, ref_column) {
  references <- data_model$references

  # ref_col_num needs to be always 1, otherwise drawing the schema of the data model will not show connecting arrows of the fk-relations
  if (!is_null(references)) {
    new_references <- add_row(
      references,
      table = table,
      column = column,
      ref = ref_table,
      ref_col = ref_column,
      ref_id = nrow(references) + 1,
      ref_col_num = 1)
  } else {
    new_references <- data.frame(
      table = table,
      column = column,
      ref = ref_table,
      ref_col = ref_column,
      ref_id = 1,
      ref_col_num = 1)
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

# removes one or more tables from a data model, taking key relations into consideration
rm_table_from_data_model <- function(data_model, tables) {
  ind_keep_tables <- !(data_model$tables$table %in% tables)
  data_model$tables <- data_model$tables[ind_keep_tables,]

  ind_keep_columns <- !(data_model$columns$table %in% tables)
  data_model$columns <- data_model$columns[ind_keep_columns,]

  ind_alter_columns <- !is.na(data_model$columns$ref) & data_model$columns$ref %in% tables
  if (any(ind_alter_columns)) {
    data_model$columns[ind_alter_columns,]$ref <- NA
    data_model$columns[ind_alter_columns,]$ref_col <- NA
  }

  ind_keep_references <-
    !(data_model$references$table %in% tables) &
    !(data_model$references$ref %in% tables)
  data_model$references <- data_model$references[ind_keep_references,]
  data_model$references$ref_id <- 1:length(data_model$references$ref_id)
  data_model
}
