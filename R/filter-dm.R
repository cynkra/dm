#' Cascading filter of a [`dm`] object
#'
#' @description 'cdm_filter()' allows you to set one or more filter conditions for one table
#' of a [`dm`] object. If the [`dm`]'s tables are connected via key constrains, the
#' filtering will affect all other connected tables, leaving only the rows with
#' the corresponding key values.
#'
#' @name cdm_filter
#'
#' @inheritParams cdm_add_pk
#' @param ... Logical predicates defined in terms of the variables in .data.
#' Multiple conditions are combined with &. Only rows where the condition evaluates
#' to TRUE are kept.
#'
#' The arguments in ... are automatically quoted and evaluated in the context of
#' the data frame. They support unquoting and splicing. See vignette("programming")
#' for an introduction to these concepts.
#'
#' @examples
#' library(magrittr)
#' cdm_nycflights13(cycle = FALSE) %>%
#'   cdm_filter(airports, name == "John F Kennedy Intl")
#'
#' @export
cdm_filter <- function(dm, table, ...) {
  table_name <- as_name(enexpr(table))
  check_correct_input(dm, table_name)

  if (!...length()) {
    return(dm)
  } # valid table and empty ellipsis provided

  orig_tbl <- tbl(dm, table_name)

  # filter data
  filtered_tbl_pk_obj <- filter(orig_tbl, ...)

  # early return if no filtering was done
  if (pull(count(filtered_tbl_pk_obj)) == pull(count(orig_tbl))) {
    return(dm)
  }

  cdm_semi_join(dm, !!table_name, filtered_tbl_pk_obj)
}

#' Semi-join a [`dm`] object with one of its reduced tables
#'
#' @description 'cdm_semi_join()' performs a cascading "row reduction" of a [`dm`] object
#' by an inital semi-join of one of its tables with the same, but filtered table. Subsequently, the
#' key constraints are used to compute the remainders of the other tables of the [`dm`] object and
#' a new [`dm`] object is returned.
#'
#' @rdname cdm_filter
#'
#' @inheritParams cdm_add_pk
#' @param reduced_table The table indicated in argument `table`, but in a filtered state (cf, `dplyr::filter()`).
#'
#' @export
cdm_semi_join <- function(dm, table, reduced_table) {
  table_name <- as_name(enexpr(table))
  check_correct_input(dm, table_name)

  filtered_dm <- cdm_update_table(dm, table_name, reduced_table)

  join_list <- calculate_join_list(dm, table_name)
  perform_joins(filtered_dm, join_list)
}
