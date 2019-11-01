#' Select and rename tables
#'
#' @description
#' `dm_select_tbl()` keeps the selected tables and their relationships,
#' optionally renaming them.
#'
#' @return The input `dm` with tables renamed or removed.
#'
#' @seealso [dm_rm_tbl()]
#'
#' @param dm A [`dm`] object
#' @param ... One or more table names of the [`dm`] object's tables.
#'   See [tidyselect::vars_select()] and [tidyselect::vars_rename()]
#'   for details on the semantics.
#'
#' @export
dm_select_tbl <- function(dm, ...) {
  check_no_filter(dm)

  vars <- tidyselect_table_names(dm)
  selected <- tidyselect::vars_select(vars, ...)
  dm_select_tbl_impl(dm, selected)
}

#' Change names of tables in a `dm`
#'
#' @description
#' `dm_rename_tbl()` renames tables.
#'
#' @rdname dm_select_tbl
#' @export
dm_rename_tbl <- function(dm, ...) {
  check_no_filter(dm)

  vars <- tidyselect_table_names(dm)
  selected <- tidyselect::vars_rename(vars, ...)
  dm_select_tbl_impl(dm, selected)
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

dm_select_tbl_impl <- function(dm, selected) {

  # Required to avoid error further below
  if (is_empty(selected)) return(empty_dm())
  check_correct_input(dm, selected)

  def <-
    dm_get_def(dm) %>%
    filter_recode_table(selected) %>%
    filter_recode_table_fks(selected)

  new_dm3(def)
}

filter_recode_table_fks <- function(def, selected) {
  def$fks <-
    # as_list_of() is needed so that `fks` doesn't become a normal list
    vctrs::as_list_of(map(
      def$fks, filter_recode_table, selected = selected
    ))
  def
}

filter_recode_table <- function(data, selected) {
  idx <- match(selected, data$table, nomatch = 0L)
  data[idx, ] %>%
    mutate(table = recode(table, !!!prep_recode(selected)))
}

prep_recode <- function(x) {
  set_names(names(x), x)
}
