#' Get tables
#'
#' `dm_get_tables()` returns a named list of \pkg{dplyr} [tbl] objects
#' of a `dm` object.
#'
#' @param x A `dm` object.
#' @inheritParams rlang::args_dots_empty
#' @param keyed `r lifecycle::badge("experimental")`
#'   Set to `TRUE` to return objects of the internal class `"dm_keyed_tbl"`
#'   that will contain information on primary and foreign keys
#'   in the individual table objects.
#'   This allows using dplyr workflows on those tables and later reconstruct them
#'   into a `dm` object.
#'   See [dm_deconstruct()] for a function that generates corresponding code
#'   for an existing dm object, and `vignette("tech-dm-keyed")` for details.
#'
#' @return A named list with the tables (data frames or lazy tables)
#'   constituting the `dm`.
#'
#' @seealso [dm()] and [new_dm()] for constructing a `dm` object from tables.
#'
#' @export
#' @examples
#' dm_nycflights13() %>%
#'   dm_get_tables()
#'
#' dm_nycflights13() %>%
#'   dm_get_tables(keyed = TRUE)
#'
#' dm_nycflights13() %>%
#'   dm_get_tables(keyed = TRUE) %>%
#'   new_dm()
dm_get_tables <- function(x, ..., keyed = FALSE) {
  check_not_zoomed(x)
  if (isTRUE(keyed)) {
    dm_get_keyed_tables_impl(x)
  } else {
    dm_get_tables_impl(x)
  }
}

dm_get_tables_impl <- function(x, quiet = FALSE) {
  def <- dm_get_def(x, quiet)
  set_names(def$data, def$table)
}
