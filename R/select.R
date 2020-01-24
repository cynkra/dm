#' Rename columns
#'
#' Rename the columns of your [`dm`] using syntax that is similar to `dplyr::rename()`.
#'
#' @inheritParams dm_filter
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
#' @examples
#' dm_nycflights13() %>%
#'   dm_rename(airports, code = faa, altitude = alt)
#' @export
dm_rename <- function(dm, table, ...) {
  check_not_zoomed(dm)
  table_name <- as_string(ensym(table))
  dm_zoom_to(dm, !!table_name) %>%
    rename(...) %>%
    dm_update_zoomed()
}

#' Select columns
#'
#' Select columns of your [`dm`] using syntax that is similar to `dplyr::select()`.
#'
#' @inheritParams dm_rename
#' @details If key columns are renamed, then the meta-information of the `dm` is updated accordingly.
#' If key columns are removed, then all related relations are dropped as well.
#'
#' @return An updated `dm` with the columns of `table` reduced and/or renamed.
#'
#' @examples
#' dm_nycflights13() %>%
#'   dm_select(airports, code = faa, altitude = alt)
#' @export
dm_select <- function(dm, table, ...) {
  check_not_zoomed(dm)
  table_name <- as_string(ensym(table))

  dm_zoom_to(dm, !!table_name) %>%
    select(...) %>%
    dm_update_zoomed()
}

get_all_keys <- function(dm, table_name) {
  fks <- dm_get_all_fks_impl(dm) %>%
    filter(child_table == table_name) %>%
    pull(child_fk_cols)
  pk <- dm_get_pk_impl(dm, table_name)
  set_names(unique(c(pk, fks)))
}
