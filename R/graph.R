#' @export
cdm_is_referenced <- function(dm, table_name) {
  data_model <- cdm_get_data_model(dm)
  is_referenced_data_model(data_model, table_name)
}

is_referenced_data_model <- function(data_model, table_name) {
  which_ind <- data_model$references$ref == table_name
  any(which_ind)
}

is_referencing_data_model <- function(data_model, table_name) {
  which_ind <- data_model$references$table == table_name
  any(which_ind)
}

#' @export
cdm_get_referencing_tables <- function(dm, table_name) {
  data_model <- cdm_get_data_model(dm)
  references <- data_model$references
  which_ind <- references$ref == table_name
  as.character(references$table[which_ind])
}

# assumes that the natural order works (fork-less)
# FIXME #16: implement for arbitrary graph of connections
calculate_join_list <- function(dm, table_name) {
  tables <- src_tbls(dm)

  map2(tables, lag(tables), ~ list(lhs_table = .x, rhs_table = .y))[-1]
}
