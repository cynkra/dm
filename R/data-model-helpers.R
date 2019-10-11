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

datamodel_columns_from_overview <- nse_function(c(overview), ~ {
  overview %>%
    select(column, type, table, key, ref, ref_col) %>%
    mutate(key = as.numeric(key)) %>%
    as.data.frame(stringsAsFactors = FALSE)
})

datamodel_references_from_overview <- nse_function(c(overview), ~ {
  overview %>%
    filter(!is.na(ref)) %>%
    select(table, column, ref, ref_col) %>%
    mutate(ref_id = as.numeric(row_number())) %>%
    add_column(ref_col_num = 1) %>%
    as.data.frame(stringsAsFactors = FALSE)
})

data_model_db_types_to_R_types <- function(data_model) {
  type <- data_model$columns$type
  new_type <- if_else(str_detect(type, "char"), "character", type)
  new_type <- if_else(str_detect(new_type, "int"), "integer", new_type)
  new_type <- if_else(str_detect(new_type, "text"), "character", new_type)
  data_model$columns$type <- new_type
  data_model
}
