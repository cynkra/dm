#' Rename one or more columns of a [`dm`] table
#'
#' Rename columns of your [`dm`] with a similar syntax to `dplyr::rename()`.
#'
#' @inheritParams cdm_filter
#' @param ... One or more unquoted expressions separated by commas. You can treat
#' variable names like they are positions, so you can use expressions like x:y
#' to select ranges of variables.
#'
#' Use named arguments, e.g. new_name = old_name, to rename selected variables.
#'
#' The arguments in ... are automatically quoted and evaluated in a context where
#' column names represent column positions. They also support unquoting and splicing.
#' See `vignette("programming", package = "dplyr")` for an introduction to these concepts.
#'
#' See select helpers for more details and examples about tidyselect helpers such as starts_with(), everything(), ...
#'
#' @details If key columns are renamed the meta-information of the `dm` is updated accordingly
#'
#' @examples
#' cdm_nycflights13() %>%
#'   cdm_rename(airports, code = faa, altitude = alt)
#' @export
cdm_rename <- function(dm, table, ...) {
  if (nrow(cdm_get_filter(dm)) > 0) abort_only_possible_wo_filters("cdm_rename()")
  table_name <- as_name(enexpr(table))
  check_correct_input(dm, table_name)

  old_cols <- colnames(tbl(dm, table_name))
  renamed <- tidyselect::vars_rename(old_cols, ...)
  select_cols(dm, table_name, renamed, check_keys = FALSE)
}

#' Select and/or rename one or more columns of a [`dm`] table
#'
#' Select columns of your [`dm`] with a similar syntax to `dplyr::select()`.
#'
#' @inheritParams cdm_rename
#'
#' @examples
#' cdm_nycflights13() %>%
#'   cdm_select(airports, code = faa, altitude = alt)
#' @details If key columns are renamed the meta-information of the `dm` is updated accordingly.
#' If key columns would be removed, `cdm_select()` makes sure they are re-added to the table.
#'
#' @export
cdm_select <- function(dm, table, ...) {
  if (nrow(cdm_get_filter(dm)) > 0) abort_only_possible_wo_filters("cdm_select()")
  table_name <- as_name(enexpr(table))
  check_correct_input(dm, table_name)

  old_cols <- colnames(tbl(dm, table_name))
  selected <- tidyselect::vars_select(old_cols, ...)

  select_cols(dm, table_name, selected)
}

# need to take care of
# 1. adding key columns if they are deselected
# 2. updating renamed key columns in data model
select_cols <- function(dm, table_name, selected, check_keys = TRUE) {
  list_of_tables <- cdm_get_tables(dm)
  table <- list_of_tables[[table_name]]

  # check keys only necessary for `cdm_select()`, rename preserves all columns
  if (check_keys) {
    all_keys <- get_all_keys(dm, table_name)

    # if the selection does not contain all keys, add the missing ones and inform the user
    if (!all(all_keys %in% selected)) {
      keys_to_add <- setdiff(all_keys, selected) %>% set_names()
      message(paste0("Adding missing key columns: `", paste0(keys_to_add, collapse = ", "), "`"))
      selected <- c(keys_to_add, selected)
    }
  }

  # create new table using `dplyr::select()`
  new_table <- select(table, !!!selected)
  list_of_tables[[table_name]] <- new_table

  update_dm_after_rename(dm, list_of_tables, table_name, selected)
}

update_dm_after_rename <- function(dm, list_of_tables, table_name, list_of_renames) {
  pks_upd <-
    upd_pks_after_rename(
      cdm_get_data_model_pks(dm),
      table_name,
      list_of_renames
    )

  fks_upd <-
    upd_fks_after_rename(
      cdm_get_data_model_fks(dm),
      table_name,
      list_of_renames
    )

  new_dm2(
    tables = list_of_tables,
    pks = pks_upd,
    fks = fks_upd,
    base_dm = dm
  )
}
