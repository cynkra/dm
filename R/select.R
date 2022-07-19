#' Rename columns
#'
#' @description
#' Rename the columns of your [`dm`] using syntax that is similar to `dplyr::rename()`.
#'
#' @inheritParams dm_zoom_to
#' @param ... One or more unquoted expressions separated by commas.
#'   You can treat
#'   variable names as if they were positions, and use expressions like x:y
#'   to select the ranges of variables.
#'
#'   Use named arguments, e.g. new_name = old_name, to rename the selected variables.
#'
#'   The arguments in ... are automatically quoted and evaluated in a context where
#'   column names represent column positions.
#'   They also support unquoting and splicing.
#'   See `vignette("programming", package = "dplyr")` for an introduction to those concepts.
#'
#'   See select helpers for more details, and the examples about tidyselect helpers, such as starts_with(), everything(), ...
#'
#' @details If key columns are renamed, then the meta-information of the `dm` is updated accordingly.
#'
#' @return An updated `dm` with the columns of `table` renamed.
#'
#' @examplesIf rlang::is_installed("nycflights13")
#' dm_nycflights13() %>%
#'   dm_rename(airports, code = faa, altitude = alt)
#' @export
dm_rename <- function(dm, table, ...) {
  check_not_zoomed(dm)
  table_name <- dm_tbl_name(dm, {{ table }})

  dm %>%
    dm_zoom_to(!!table_name) %>%
    rename(...) %>%
    dm_update_zoomed()
}

#' Select columns
#'
#' @description
#' Select columns of your [`dm`] using syntax that is similar to `dplyr::select()`.
#'
#' @inheritParams dm_rename
#' @details If key columns are renamed, then the meta-information of the `dm` is updated accordingly.
#' If key columns are removed, then all related relations are dropped as well.
#'
#' @return An updated `dm` with the columns of `table` reduced and/or renamed.
#'
#' @examplesIf rlang::is_installed("nycflights13")
#' dm_nycflights13() %>%
#'   dm_select(airports, code = faa, altitude = alt)
#' @export
dm_select <- function(dm, table, ...) {
  check_not_zoomed(dm)
  table_name <- dm_tbl_name(dm, {{ table }})

  dm %>%
    dm_zoom_to(!!table_name) %>%
    select(...) %>%
    dm_update_zoomed()
}
