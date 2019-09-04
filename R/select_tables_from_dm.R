#' Get a [`dm`] only containing the indicated tables
#'
#' @description Returns a reduced [`dm`] object, taking care of the key relations
#'
#' @param dm A [`dm`] object
#' @param ... Two or more table names of the [`dm`] object's tables.
#'   See [tidyselect::vars_select()] for details on the semantics.
#'
#' @export
cdm_select_tbl <- function(dm, ...) {

  table_list <- tidyselect_dm(dm, ...)

  all_table_names <- table_list[[1]]
  old_table_names <- table_list[[2]]
  # named vector of tables; names are later used for renaming

  list_of_removed_tables <- setdiff(all_table_names, old_table_names)

  new_data_model <- rm_table_from_data_model(cdm_get_data_model(dm), list_of_removed_tables)
  table_objs <- map(set_names(old_table_names), ~ tbl(dm, .))

  new_dm(
    src = cdm_get_src(dm),
    tables = table_objs,
    data_model = new_data_model
  ) %>%
    cdm_rename_tbl(., old_table_names)
}

tidyselect_dm <- function(dm, ...) {

  all_table_names <- structure(
    src_tbls(dm),
    type = c("table", "tables")
  )

  table_names <- tidyselect::vars_select(all_table_names, ...)
  walk(table_names, ~ check_correct_input(dm, .))
  list(all_table_names, table_names)
}
