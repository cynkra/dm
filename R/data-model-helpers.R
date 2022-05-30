new_data_model <- function(tables, columns, references) {
  empty_tables <- setdiff(tables$table, columns$table)
  if (length(empty_tables)) {
    empty_table_columns <- tibble(table = empty_tables, column = "", key = 0)
    columns <- bind_rows(columns, empty_table_columns)
  }
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
