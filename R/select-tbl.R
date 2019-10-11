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
  check_no_filter(dm)

  vars <- tidyselect_table_names(dm)
  selected <- tidyselect::vars_select(vars, ...)
  cdm_select_tbl_impl(dm, selected)
}

#' Change names of tables in a `dm`
#'
#' @description
#' `cdm_rename_tbl()` renames tables.
#'
#' @rdname cdm_select_tbl
#' @export
cdm_rename_tbl <- function(dm, ...) {
  check_no_filter(dm)

  vars <- tidyselect_table_names(dm)
  selected <- tidyselect::vars_rename(vars, ...)
  cdm_select_tbl_impl(dm, selected)
}

tidyrename_dm <- function(dm, ...) {
  tidyselect::vars_rename(tidyselect_table_names(dm), ...)
}

tidyselect_table_names <- function(dm) {
  structure(
    src_tbls(dm),
    type = c("table", "tables")
  )
}

cdm_select_tbl_impl <- function(dm, selected) {
  check_correct_input(dm, selected)

  def <-
    cdm_get_def(dm) %>%
    filter_recode_table(selected) %>%
    mutate(fks = map(fks, filter_recode_table, selected = selected)) %>%
    # this is needed, so that column `fks` doesn't become a normal list
    mutate(fks = vctrs::as_list_of(fks))

  new_dm3(def)
}

filter_recode_table <- function(data, selected) {
  data %>%
    filter(table %in% !!selected) %>%
    mutate(table = recode(table, !!!prep_recode(selected)))
}

prep_recode <- function(x) {
  set_names(names(x), x)
}
