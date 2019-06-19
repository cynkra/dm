#' Cascading filter of a `dm`-object
#'
#' @description 'cdm_filter()' allows you to set one or more filter conditions for one table
#' of a `dm`-object. If the `dm`'s tables are connected via key constrains, the
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
#' @export
cdm_filter <- function(dm, table, ...) {
  table_name <- as_name(enexpr(table))
  check_correct_input(dm, table_name)

  if (!...length()) return(dm) # valid table and empty ellipsis provided

  orig_tbl <- tbl(dm, table_name)

  if (!cdm_has_pk(dm, !!table_name)) {
    abort_pk_for_filter_missing(table_name)
  }

  # get remote tibble of pk-values after filtering
  pk_name_orig <- cdm_get_pk(dm, !!table_name)
  filtered_tbl_pk_obj <- filter(orig_tbl, ...) %>%
    compute( unique_indexes = pk_name_orig)

  if (pull(count(filtered_tbl_pk_obj)) == pull(count(orig_tbl))) return(dm) # early return if no filtering was done

  cdm_semi_join(dm, !!table_name, filtered_tbl_pk_obj)
}

#' @export
cdm_semi_join <- function(dm, table, filter) {
  table_name <- as_name(enexpr(table))
  check_correct_input(dm, table_name)

  filtered_dm <- cdm_update_table(dm, table_name, filter)

  join_list <- calculate_join_list(dm, table_name)
  perform_joins(filtered_dm, join_list)
}
