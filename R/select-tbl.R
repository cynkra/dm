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

  selected <- tidyselect_dm(dm, ...)
  cdm_select_tbl_impl(dm, selected)
}

tidyselect_dm <- function(dm, ...) {
  all_table_names <- structure(
    src_tbls(dm),
    type = c("table", "tables")
  )

  tidyselect::vars_select(all_table_names, ...)
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

  selected <- tidyrename_dm(dm, ...)
  cdm_select_tbl_impl(dm, selected)
}

tidyrename_dm <- function(dm, ...) {
  all_table_names <- structure(
    src_tbls(dm),
    type = c("table", "tables")
  )

  tidyselect::vars_rename(all_table_names, ...)
}

cdm_select_tbl_impl <- function(dm, selected) {
  check_correct_input(dm, selected)

  def <-
    cdm_get_def(dm) %>%
    filter_recode_table(selected) %>%
    mutate(fks = map(fks, filter_recode_table, selected = selected))

  new_dm3(def)
}

filter_recode_table <- function(data, selected) {
  selected_recode <- set_names(names(selected), selected)

  data %>%
    filter(table %in% !!selected) %>%
    mutate(table = recode(table, !!!selected_recode))
}
