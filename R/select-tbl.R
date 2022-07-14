#' Select and rename tables
#'
#' @description
#' `dm_select_tbl()` keeps the selected tables and their relationships,
#' optionally renaming them.
#'
#' @return The input `dm` with tables renamed or removed.
#'
#' @param dm A [`dm`] object.
#' @param ... One or more table names of the tables of the [`dm`] object.
#' `tidyselect` is supported, see [dplyr::select()] for details on the semantics.
#'
#' @examplesIf rlang::is_installed("nycflights13")
#' dm_nycflights13() %>%
#'   dm_select_tbl(airports, fl = flights)
#' @export
dm_select_tbl <- function(dm, ...) {
  check_not_zoomed(dm)
  check_no_filter(dm)

  selected <- eval_select_table(quo(c(...)), src_tbls_impl(dm))
  dm_select_tbl_impl(dm, selected)
}

#' Change the names of the tables in a `dm`
#'
#' @description
#' `dm_rename_tbl()` renames tables.
#'
#' @rdname dm_select_tbl
#'
#' @examplesIf rlang::is_installed("nycflights13")
#' dm_nycflights13() %>%
#'   dm_rename_tbl(ap = airports, fl = flights)
#' @export
dm_rename_tbl <- function(dm, ...) {
  check_not_zoomed(dm)

  selected <- eval_rename_table_all(quo(c(...)), src_tbls_impl(dm))
  dm_select_tbl_impl(dm, selected)
}

dm_select_tbl_impl <- function(dm, selected) {
  if (anyDuplicated(names(selected))) {
    abort_need_unique_names(names(selected[duplicated(names(selected))]))
  }

  # Required to avoid an error further on
  if (is_empty(selected)) {
    return(empty_dm())
  }

  def <-
    dm_get_def(dm) %>%
    filter_recode_table_def(selected) %>%
    filter_recode_table_fks(selected)

  new_dm3(def)
}

filter_recode_table_fks <- function(def, selected) {
  def$fks <-
    # as_list_of() is needed so that `fks` doesn't become a normal list
    as_list_of(map(
      def$fks, filter_recode_fks_of_table,
      selected = selected
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
  out <- data[idx, ]
  out$table <- recode(out$table, !!!prep_recode(selected))
  out
}

prep_recode <- function(x) {
  set_names(names(x), x)
}

prep_compact_recode <- function(x) {
  x <- x[names(x) != x]
  prep_recode(x)
}

recode2 <- function(x, new) {
  recipe <- prep_compact_recode(new)
  if (is_empty(recipe)) {
    x
  } else {
    recode(x, !!!recipe)
  }
}
