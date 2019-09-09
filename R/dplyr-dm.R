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
#' @examples
#' cdm_nycflights13() %>%
#'   cdm_rename(airports, code = faa, altitude = alt)
#'
#' @export
cdm_rename <- function(dm, table, ...) {
  table_name <- as_name(enexpr(table))
  check_correct_input(dm, table_name)

  quos <- enquos(...)
  if (is_empty(quos)) {
    return(dm)
  } # valid table and empty ellipsis provided

  rename_cols(dm, table_name, quos)
}

rename_cols <- function(dm, table_name, quos) {
  list_of_tables <- cdm_get_tables(dm)
  table <- list_of_tables[[table_name]]
  new_table <- rename(table, !!!quos)

  list_of_tables[[table_name]] <- new_table

  list_of_renames <- map_chr(quos, as_name)

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
