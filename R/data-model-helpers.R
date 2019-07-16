new_data_model <- function(tables, columns, references) {
  stopifnot(nrow(tables) > 0)
  stopifnot(nrow(columns) > 0)

  structure(
    list(
      tables = tables,
      columns = columns,
      references = references
    ),
    class = "data_model"
  )
}

# helper function for updating the data model when adding a reference from one table to another
upd_data_model_reference <- function(data_model, table, column, ref_table, ref_column) {
  new_data_model(
    tables = data_model$tables,
    columns = upd_columns_reference(data_model, table, column, ref_table, ref_column),
    references = upd_references_reference(data_model, table, column, ref_table, ref_column)
  )
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
      ref_col_num = 1
    )
  } else {
    new_references <- data.frame(
      table = table,
      column = column,
      ref = ref_table,
      ref_col = ref_column,
      ref_id = 1,
      ref_col_num = 1,
      stringsAsFactors = FALSE
    )
  }

  new_references
}

# updates only the $columns part of the data model with a reference
upd_columns_reference <- function(data_model, table, column, ref_table, ref_column) {
  columns <- data_model$columns
  new_columns <- columns
  if (is_null(columns$ref_col)) new_columns$ref_col <- NA
  ind_columns_upd <- columns$column == column & columns$table == table

  new_columns$ref[ind_columns_upd] <- ref_table
  new_columns$ref_col[ind_columns_upd] <- ref_column
  new_columns
}


# helper function for removing one or more references from one table to another in the data model
rm_data_model_reference <- function(data_model, table, cols, ref_table) {
  new_data_model(
    tables = data_model$tables,
    columns = rm_columns_reference(data_model, table, cols, ref_table),
    references = rm_references_reference(data_model, table, cols, ref_table)
  )
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
    new_references <- references[lines_to_keep, ]
  }

  new_references
}

# removes one or more references only from the $columns part of the data model
rm_columns_reference <- function(data_model, table, cols, ref_table) {
  cols_data_model <- data_model$columns

  lines_to_modify <- cols_data_model$column %in% cols &
    cols_data_model$table == table &
    cols_data_model$ref == ref_table

  cols_data_model[lines_to_modify, ]$ref <- NA
  cols_data_model[lines_to_modify, ]$ref_col <- NA

  cols_data_model
}

# removes one or more tables from a data model, taking key relations into consideration
rm_table_from_data_model <- function(data_model, tables) {
  ind_keep_tables <- !(data_model$tables$table %in% tables)
  new_tables <- data_model$tables[ind_keep_tables, ]

  ind_keep_columns <- !(data_model$columns$table %in% tables)
  new_columns <- data_model$columns[ind_keep_columns, ]

  ind_alter_columns <- !is.na(new_columns$ref) & new_columns$ref %in% tables
  if (any(ind_alter_columns)) {
    new_columns[ind_alter_columns, ]$ref <- NA
    new_columns[ind_alter_columns, ]$ref_col <- NA
  }

  references <- data_model$references
  if (!is.null(references)) {
    ind_keep_references <-
      !(references$table %in% tables) &
      !(references$ref %in% tables)
    new_references <- references[ind_keep_references, ]
    new_references$ref_id <- seq_along(new_references$ref_id)
  } else {
    new_references <- NULL
  }

  new_data_model(
    tables = new_tables,
    columns = new_columns,
    references = new_references
  )
}

get_class_of_table_col <- function(data_model, table_name, col_name) {
  stopifnot(table_name %in% data_model$tables$table) # FIXME: need proper abort_...()
  stopifnot(col_name %in% data_model$columns[data_model$columns["table"] == table_name, ]$column) # FIXME: need proper abort_...()
  data_model$columns[data_model$columns["table"] == table_name & data_model$columns["column"] == col_name, ]$type
}

add_table_to_data_model <- function(data_model, table_name, col_names, col_types) {
  stopifnot(!(table_name %in% data_model$tables$table)) # FIXME: need proper abort_...()

  new_data_model(
    tables = add_table_to_tables(data_model, table_name),
    columns = add_table_to_columns(data_model, table_name, col_names, col_types),
    references = data_model$references
  )
}

add_table_to_tables <- function(data_model, table_name) {
  data_model$tables %>%
    add_row(table = table_name, segment = NA, display = NA)
}

add_table_to_columns <- function(data_model, table_name, col_names, col_types) {
  reduce2(col_names,
    col_types,
    add_column_row,
    table_name = table_name,
    .init = data_model$columns
  )
}

add_column_row <- function(.data, col_name, col_type, table_name) {
  add_row(.data, column = col_name, type = col_type, table = table_name, key = FALSE, ref = NA)
}

cdm_colnames <- function(dm) { # maybe better as dm-method for function `colnames()`
  data_model <- cdm_get_data_model(dm)
  data_model %>%
    extract2("columns") %>%
    pull("column")
}

get_datamodel_from_overview <- function(overview) {
  new_data_model(
    tables = datamodel_tables_from_overview(overview),
    columns = datamodel_columns_from_overview(overview),
    references = datamodel_references_from_overview(overview)
  )
}

datamodel_tables_from_overview <- function(overview) {
  distinct(overview, table) %>%
    add_column(segment = NA, display = NA) %>%
    as.data.frame(stringsAsFactors = FALSE)
}

datamodel_columns_from_overview <- function(overview) h(~ {
    overview %>%
      select(column, type, table, key, ref, ref_col) %>%
      mutate(key = as.numeric(key)) %>%
      as.data.frame(stringsAsFactors = FALSE)
  })

datamodel_references_from_overview <- function(overview) h(~ {
    overview %>%
      filter(!is.na(ref)) %>%
      select(table, column, ref, ref_col) %>%
      mutate(ref_id = as.numeric(row_number())) %>%
      add_column(ref_col_num = 1) %>%
      as.data.frame(stringsAsFactors = FALSE)
  })

datamodel_rename_table <- function(data_model, old_name, new_name) h(~ {
  tables <- data_model$tables
  ind_tables <- tables$table == old_name
  tables$table[ind_tables] <- new_name

  columns <- data_model$columns
  ind_columns_table <- columns$table == old_name
  columns$table[ind_columns_table] <- new_name

  ind_columns_ref <-
    if_else(are_na(columns$ref == old_name), FALSE, columns$ref == old_name)
  columns$ref[ind_columns_ref] <- new_name

  references <- data_model$references
  if (!is.null(references)) {
    ind_references_table <- references$table == old_name
    references$table[ind_references_table] <- new_name

    ind_references_ref <- references$ref == old_name
    references$ref[ind_references_ref] <- new_name
  }

  new_data_model(
    tables = tables,
    columns = columns,
    references = references
  )
})

data_model_db_types_to_R_types <- function(data_model) {
  type <- data_model$columns$type
  new_type <- if_else(str_detect(type, "char"), "character", type)
  new_type <- if_else(str_detect(new_type, "int"), "integer", new_type)
  new_type <- if_else(str_detect(new_type, "text"), "character", new_type)
  data_model$columns$type <- new_type
  data_model
}
