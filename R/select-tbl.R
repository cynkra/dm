#' Select and rename tables
#'
#' @description
#' `cdm_select_tbl()` keeps the selected tables and their relationships,
#' optionally renaming them.
#'
#' @return The input `dm` with tables renamed or removed.
#'
#' @param dm A [`dm`] object
#' @param ... One or more table names of the [`dm`] object's tables.
#'   See [tidyselect::vars_select()] and [tidyselect::vars_rename()]
#'   for details on the semantics.
#'
#' @export
cdm_select_tbl <- function(dm, ...) {
  if (nrow(cdm_get_filter(dm)) > 0) {
    abort_only_possible_wo_filters("cdm_select_tbl()")
  }
  table_list <- tidyselect_dm(dm, ...)

  all_table_names <- table_list[[1]]
  old_table_names <- table_list[[2]]
  # named vector of tables; names are later used for renaming

  list_of_removed_tables <- setdiff(all_table_names, old_table_names)

  new_data_model <- rm_table_from_data_model(cdm_get_data_model(dm), list_of_removed_tables)
  table_objs <- map(set_names(old_table_names), ~ tbl(dm, .))

  new_dm(
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

#' Change names of tables in a `dm`
#'
#' @description
#' `cdm_rename_tbl()` renames tables.
#'
#' @rdname cdm_select_tbl
#' @export
cdm_rename_tbl <- function(dm, ...) {
  if (nrow(cdm_get_filter(dm)) > 0) {
    abort_only_possible_wo_filters("cdm_rename_tbl()")
  }
  table_list <- tidyselect_dm(dm, ...)

  old_table_names <- table_list[[2]]
  new_table_names <- names(old_table_names)

  reduce2(
    old_table_names,
    new_table_names,
    rename_table_of_dm,
    .init = dm
  )
}

rename_table_of_dm <- function(dm, old_name, new_name) {
  old_name_q <- as_name(ensym(old_name))
  check_correct_input(dm, old_name_q)

  new_name_q <- as_name(ensym(new_name))
  tables <- cdm_get_tables(dm)
  table_names <- names(tables)
  table_names[table_names == old_name_q] <- new_name_q
  new_tables <- set_names(tables, table_names)

  new_dm(
    tables = new_tables,
    data_model = datamodel_rename_table(
      cdm_get_data_model(dm), old_name_q, new_name_q
    )
  )
}

datamodel_rename_table <- nse_function(c(data_model, old_name, new_name), ~ {
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
