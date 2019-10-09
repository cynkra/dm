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
  if (nrow(cdm_get_filter(dm)) > 0) {
    abort_only_possible_wo_filters("cdm_select_tbl()")
  }
  table_list <- tidyselect_dm(dm, ...)
  cdm_restore_tbl(dm, table_list)
}

tidyselect_dm <- function(dm, ...) {
  all_table_names <- structure(
    src_tbls(dm),
    type = c("table", "tables")
  )

  table_names <- tidyselect::vars_select(all_table_names, ...)
  check_correct_input(dm, table_names)
  table_names
}

#' Change names of tables in a `dm`
#'
#' @description
#' `cdm_rename_tbl()` renames tables.
#'
#' @rdname cdm_select_tbl
#' @export
cdm_rename_tbl <- function(dm, ...) {
  if (nrow(cdm_get_filter(dm)) > 0) {
    abort_only_possible_wo_filters("cdm_rename_tbl()")
  }
  table_list <- tidyrename_dm(dm, ...)
  cdm_restore_tbl(dm, table_list)
}

tidyrename_dm <- function(dm, ...) {
  all_table_names <- structure(
    src_tbls(dm),
    type = c("table", "tables")
  )

  table_names <- tidyselect::vars_rename(all_table_names, ...)
  check_correct_input(dm, table_names)
  table_names
}

cdm_restore_tbl <- function(dm, table_names) {
  def <-
    cdm_get_def(dm) %>%
    filter_recode_table(table_names) %>%
    mutate(fks = map(fks, filter_recode_table, table_names = table_names))

  new_dm3(def)
}

filter_recode_table <- function(data, table_names) {
  table_names_recode <- set_names(names(table_names), table_names)

  data %>%
    filter(table %in% !!table_names) %>%
    mutate(table = recode(table, !!!table_names_recode))
}
