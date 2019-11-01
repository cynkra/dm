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
#' @details If key columns are renamed the meta-information of the `dm` is updated accordingly.
#'
#' @examples
#' cdm_nycflights13() %>%
#'   cdm_rename(airports, code = faa, altitude = alt)
#' @export
cdm_rename <- function(dm, table, ...) {
  check_no_filter(dm)

  table_name <- as_string(ensym(table))

  cdm_zoom_to_tbl(dm, !!table_name) %>%
    rename(...) %>%
    cdm_update_zoomed_tbl()
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
#' If key columns are removed, all related relations are dropped as well.
#'
#' @export
cdm_select <- function(dm, table, ...) {
  check_no_filter(dm)

  table_name <- as_string(ensym(table))

  cdm_zoom_to_tbl(dm, !!table_name) %>%
    select(...) %>%
    cdm_update_zoomed_tbl()
}

get_all_keys <- function(dm, table_name) {
  fks <- cdm_get_all_fks(dm) %>%
    filter(child_table == !!table_name) %>%
    pull(child_fk_col)
  pk <- cdm_get_pk(dm, !!table_name)
  set_names(c(pk, fks))
}
