#' Add one or more tables to a [`dm`]
#'
#' @description
#' Add one or more tibbles to a [`dm`], using tidyverse syntax.
#'
#' @return The inital `dm` with the additional table(s).
#'
#' @param dm A [`dm`] object
#' @param ... One or more tibbles to add to the `dm`. If not named, the tables will retain their name within the `dm`
#' (does not work in a pipe or in `map()`-style functions). Explicit naming is supported with the syntax `new_table_name = tbl`.
#'
#' @export
cdm_add_tbls <- function(dm, ...) {
  # FIXME: following line needs to be replaced using check_dm() after PR 86 merged
  if (!is_dm(dm)) abort("First parameter in `cdm_add_tbls()` needs to be of class `dm`")

  orig_tbls <- src_tbls(dm)

  new_names <- names(exprs(..., .named = TRUE))
  new_tables <- list(...)
  # this function has a secondary effect and returns a value; generally not good style, but it is more convenient
  new_names <- check_new_tbls(dm, new_tables, new_names)
  if (any(new_names %in% src_tbls(dm))) abort_table_already_exists(new_names[new_names %in% src_tbls(dm)])
  reduce2(
    rev(new_tables),
    rev(new_names),
    ~ cdm_add_tbl_impl(cdm_get_def(..1), ..2, ..3),
    .init = dm
    )
}

#' Add a table to a [`dm`]
#'
#' @rdname cdm_select_tbl
#' @description
#' Add a tibble to a [`dm`].
#'
#' @return The inital `dm` with the additional table.
#'
#' @param dm A [`dm`] object
#' @param table A tibble
#' @param table_name The name for the new table. If left `NULL`, the new table will retain its original name
#' (does not work in a pipe or in `map()`-style functions)
#'
#' @export
cdm_add_tbl <- function(dm, table, table_name = NULL) {
  # FIXME: following line needs to be replaced using check_dm() after PR 86 merged
  if (!is_dm(dm)) abort("First parameter in `cdm_add_tbl()` needs to be of class `dm`")

  if (!is_symbol(enexpr(table_name)) && !is_character(enexpr(table_name))) {
    table_name <- as_string(ensym(table))
  } else table_name <- as_string(ensym(table_name))
  # this function has a secondary effect and returns a value; generally not good style, but it is more convenient
  table_name <- check_new_tbls(dm, table, table_name)
  if (table_name %in% src_tbls(dm)) abort_table_already_exists(table_name)

  cdm_add_tbl_impl(cdm_get_def(dm), table, table_name)
}

cdm_add_tbl_impl <- function(def, tbl, table_name) {
  def_0 <- tibble(
    table = table_name,
    data = list(tbl),
    segment = NA,
    display = NA_character_,
    pks = vctrs::list_of(tibble(column = list())),
    fks = vctrs::list_of(tibble(table = character(), column = list())),
    name = NA_character_,
    filters = vctrs::list_of(tibble(filter_quo = list()))
    )

  new_dm3(vctrs::vec_rbind(def_0, def))
}


cdm_rm_tbls <- function(dm, ...) {
  # FIXME: following line needs to be replaced using check_dm() after PR 86 merged
  if (!is_dm(dm)) abort("First parameter in `cdm_add_tbl()` needs to be of class `dm`")
  table_names <- names(exprs(..., .named = TRUE))
  check_correct_input(dm, table_names)

  cdm_select_tbl(dm, -one_of(!!!table_names))

}


check_new_tbls <- function(dm, tbls, name) {
  orig_tbls <- cdm_get_tables(dm)
  # are all new tables on the same source as the original ones?
  if (!all_same_source(flatten(list(cdm_get_tables(dm), tbls)))) abort_not_same_src()
  # test if a name "." is part of the new names, indicating a piped table that is not explicitly named
  # or if table names of the kind ".x" or "..1" are present, which would indicate a `map()`-type operation
  if ("." %in% name || any(str_detect(name, "^\\.[x-z]$")) || any(str_detect(name, "^\\.\\.[0-9][0-9]?$"))) {
    if (length(name) > 1) abort("Please don't give names to your tables of the sort `.`, `.x`, `..1`.")
    warning("New table called `new_table` introduced by adding table to `dm` in a pipe without giving it an explicit name.")
    "new_table"
  } else name
}

