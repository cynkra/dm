#' Add tables to a [`dm`]
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' Adds one or more new tables to a [`dm`].
#' Existing tables are not overwritten.
#'
#' @section Life cycle:
#' This function is deprecated as of dm 1.0.0, because the same functionality
#' is offered by [dm()] with `.name_repair = "unique"`.
#'
#' @return The initial `dm` with the additional table(s).
#'
#' @seealso [dm_mutate_tbl()], [dm_rm_tbl()]
#'
#' @param dm A [`dm`] object.
#' @param ... One or more tables to add to the `dm`.
#'   If no explicit name is given, the name of the expression is used.
#' @inheritParams vctrs::vec_as_names
#'
#' @export
#' @keywords internal
#' @examples
#' dm() %>%
#'   dm_add_tbl(mtcars, flowers = iris)
#'
#' # renaming table names if necessary (depending on the `repair` argument)
#' dm() %>%
#'   dm_add_tbl(new_tbl = mtcars, new_tbl = iris)
dm_add_tbl <- function(dm, ..., repair = "unique", quiet = FALSE) {
  deprecate_soft("1.0.0", "dm_add_tbl()", "dm()",
    details = 'Use `.name_repair = "unique"` if necessary.'
  )

  check_not_zoomed(dm)

  new_names <- names(exprs(..., .named = TRUE))
  new_tables <- list2(...)

  check_new_tbls(dm, new_tables)

  old_names <- src_tbls_impl(dm)
  names_list <- repair_table_names(old_names, new_names, repair, quiet)
  # rename old tables in case name repair changed their names

  dm <- dm_select_tbl_impl(dm, names_list$new_old_names)
  dm_add_tbl_impl(dm, new_tables, names_list$new_names)
}

repair_names_vec <- function(names, repair, quiet) {
  withCallingHandlers(
    vec_as_names(names, repair = repair, quiet = quiet),
    vctrs_error_names_must_be_unique = function(e) {
      abort_need_unique_names(names[duplicated(names)])
    }
  )
}

repair_table_names <- function(old_names, new_names, repair = "check_unique", quiet = FALSE) {
  all_names <- repair_names_vec(c(old_names, new_names), repair, quiet)
  all_names_ordered <- all_names[seq_along(old_names)]
  new_old_names <- set_names(old_names, all_names_ordered)
  old_new_names <- set_names(all_names_ordered, old_names)

  new_names <-
    all_names[seq2(length(old_names) + 1, length(all_names))]
  list(new_old_names = new_old_names, new_names = new_names, old_new_names = old_new_names)
}

dm_add_tbl_impl <- function(dm, tbls, table_name, filters = list_of(new_filter()),
                            pks = list_of(new_pk()), fks = list_of(new_fk())) {
  def <- dm_get_def(dm)

  def_0 <- def[rep_along(table_name, NA_integer_), ]
  def_0$table <- table_name
  def_0$data <- unname(tbls)
  def_0$pks <- pks
  def_0$fks <- fks
  def_0$filters <- filters

  new_dm3(vec_rbind(def, def_0))
}

#' Remove tables
#'
#' @description
#' Removes one or more tables from a [`dm`].
#'
#' @return The `dm` without the removed table(s) that were present in the initial `dm`.
#'
#' @seealso [dm()], [dm_select_tbl()]
#'
#' @param dm A [`dm`] object.
#' @param ... One or more unquoted table names to remove from the `dm`.
#' `tidyselect` is supported, see [dplyr::select()] for details on the semantics.
#'
#' @export
#' @examplesIf rlang::is_installed("nycflights13")
#' dm_nycflights13() %>%
#'   dm_rm_tbl(airports)
dm_rm_tbl <- function(dm, ...) {
  check_not_zoomed(dm)
  deselected_ind <- eval_select_table_indices(quo(c(...)), src_tbls_impl(dm))
  selected_ind <- setdiff(seq_along(dm), deselected_ind)

  dm_select_tbl(dm, !!!selected_ind)
}

check_new_tbls <- function(dm, tbls) {
  orig_tbls <- dm_get_tables_impl(dm)

  # are all new tables on the same source as the original ones?
  if (has_length(orig_tbls) && !all_same_source(c(orig_tbls[1], tbls))) {
    abort_not_same_src()
  }
}

#' Update tables in a [`dm`]
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Updates one or more existing tables in a [`dm`].
#' For now, the column names must be identical.
#' This restriction may be levied optionally in the future.
#'
#' @seealso [dm()], [dm_rm_tbl()]
#'
#' @param dm A [`dm`] object.
#' @param ... One or more tables to update in the `dm`.
#'   Must be named.
#'
#' @export
#' @examplesIf rlang::is_installed("nycflights13")
#' dm_nycflights13() %>%
#'   dm_mutate_tbl(flights = nycflights13::flights[1:3, ])
dm_mutate_tbl <- function(dm, ...) {
  check_not_zoomed(dm)

  old_names <- src_tbls_impl(dm)

  new_tables <- list2(...)
  stopifnot(is_named(new_tables))

  new_names <- names(new_tables)
  stopifnot(new_names %in% old_names)

  old_tables <- dm_get_tables_impl(dm)

  stopifnot(identical(map(new_tables, colnames), map(old_tables[new_names], colnames)))

  old_tables[new_names] <- new_tables

  def <- dm_get_def(dm)
  def$data <- unname(old_tables)
  new_dm3(def)
}
