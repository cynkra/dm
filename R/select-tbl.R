#' Select and rename tables
#'
#' @description
#' `cdm_select_tbl()` keeps the selected tables and their relationships,
#' optionally renaming them.
#'
#' @return The input `dm` with tables renamed or removed.
#'
#' @seealso [cdm_rm_tbl()]
#'
#' @param dm A [`dm`] object
#' @param ... One or more table names of the tables of the [`dm`] object.
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

#' Change the names of the tables in a `dm`
#'
#' @description
#' `cdm_rename_tbl()` renames tables.
#'
#' @rdname cdm_select_tbl
#' @export
cdm_rename_tbl <- function(dm, ...) {
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

  # Required to avoid an error further on
  if (is_empty(selected)) return(empty_dm())
  check_correct_input(dm, selected)

  def <-
    cdm_get_def(dm) %>%
    filter_recode_table_def(selected) %>%
    filter_recode_table_fks(selected)

  new_dm3(def)
}

filter_recode_table_fks <- function(def, selected) {
  def$fks <-
    # as_list_of() is needed so that `fks` doesn't become a normal list
    vctrs::as_list_of(map(
      def$fks, filter_recode_fks_of_table, selected = selected
    ))
  def
}

filter_recode_table_def <- function(data, selected) {
  # We want to keep the order mentioned in `selected` here.
  # data$table only contains unique values by definition.
  idx <- match(selected, data$table, nomatch = 0L)

  data[idx, ] %>%
    mutate(table = recode(table, !!!prep_recode(selected)))
}

filter_recode_fks_of_table <- function(data, selected) {
  # data$table can have multiple entries, we don't care about the order
  idx <- data$table %in% selected
  data[idx, ] %>%
    mutate(table = recode(table, !!!prep_recode(selected)))
}

prep_recode <- function(x) {
  set_names(names(x), x)
}
