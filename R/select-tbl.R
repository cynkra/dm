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
  cdm_restore_tbl(dm, table_list)
}

tidyselect_dm <- function(dm, ...) {
  all_table_names <- structure(
    src_tbls(dm),
    type = c("table", "tables")
  )

  table_names <- tidyselect::vars_select(all_table_names, ...)
  check_correct_input(dm, table_names)
  table_names
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
  table_list <- tidyrename_dm(dm, ...)
  cdm_restore_tbl(dm, table_list)
}

tidyrename_dm <- function(dm, ...) {
  all_table_names <- structure(
    src_tbls(dm),
    type = c("table", "tables")
  )

  table_names <- tidyselect::vars_rename(all_table_names, ...)
  check_correct_input(dm, table_names)
  table_names
}

cdm_restore_tbl <- function(dm, table_names) {
  table_names_recode <- set_names(names(table_names), table_names)

  def <-
    cdm_get_def(dm) %>%
    filter(name %in% !!table_names) %>%
    mutate(name = recode(name, !!!table_names_recode)) %>%
    mutate(fks = map(fks, ~ filter(.x, table %in% !!table_names))) %>%
    mutate(fks = map(fks, ~ mutate(.x, table = recode(table, !!!table_names_recode))))

  new_dm3(def)
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
