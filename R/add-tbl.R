#' Add tables to a [`dm`]
#'
#' @description
#' `dm_add_tbl()` adds one or more tables to a [`dm`].
#' It uses [mutate()] semantics.
#'
#' @return The initial `dm` with the additional table(s).
#'
#' @seealso [dm_rm_tbl()]
#'
#' @param dm A [`dm`] object.
#' @param ... One or more tables to add to the `dm`.
#'   If no explicit name is given, the name of the expression is used.
#' @inheritParams vctrs::vec_as_names
#'
#' @examples
#' dm_nycflights13() %>%
#'   dm_add_tbl(cars = mtcars, flowers = iris)
#'
#' # renaming table names if necessary (depending on argument `repair`)
#' dm_nycflights13() %>%
#'   dm_add_tbl(new_tbl = mtcars, new_tbl = iris)
#'
#' @export
dm_add_tbl <- function(dm, ..., repair = "unique", quiet = FALSE) {
  check_dm(dm)

  new_names <- names(exprs(..., .named = TRUE))
  new_tables <- list(...)

  check_new_tbls(dm, new_tables)

  old_names <- src_tbls(dm)
  names_list <- repair_table_names(old_names, new_names, repair, quiet)
  # rename old tables in case name repair changed their names
  dm <- dm_select_tbl_impl(dm, names_list$new_old_names)

  dm_add_tbl_impl(dm, new_tables, names_list$new_names)
}

repair_table_names <- function(old_names, new_names, repair = "check_unique", quiet = FALSE) {
  all_names <- tryCatch(
    vctrs::vec_as_names(c(old_names, new_names), repair = repair, quiet = quiet),
    error = function(e) {
      if (inherits(e, "vctrs_error_names_must_be_unique")) abort_need_unique_names(intersect(old_names, new_names))
      abort(e$message)
    }
  )
  new_old_names <- set_names(old_names, all_names[seq_along(old_names)])

  new_names <-
    all_names[seq2(length(old_names) + 1, length(all_names))]
  list(new_old_names = new_old_names, new_names = new_names)
}

dm_add_tbl_impl <- function(dm, tbls, table_name, filters = vctrs::list_of(new_filter())) {
  def <- dm_get_def(dm)

  def_0 <- def[rep_along(table_name, NA_integer_), ]
  def_0$table <- table_name
  def_0$data <- tbls
  def_0$pks <- vctrs::list_of(new_pk())
  def_0$fks <- vctrs::list_of(new_fk())
  def_0$filters <- filters

  new_dm3(vctrs::vec_rbind(def, def_0))
}

#' Remove tables from a [`dm`]
#'
#' @description
#' Removes one or more tables from a [`dm`].
#'
#' @return The `dm` without the removed table(s) that were present in the initial `dm`.
#'
#' @seealso [dm_add_tbl()], [dm_select_tbl()]
#'
#' @param dm A [`dm`] object.
#' @param ... One or more unquoted table names to remove from the `dm`.
#' `tidyselect` is supported, see [`dplyr::select()`] for details on the semantics.
#'
#' @export
dm_rm_tbl <- function(dm, ...) {
  check_dm(dm)
  selected <- dm_try_tables(setdiff(src_tbls(dm), tidyselect::vars_select(src_tbls(dm), ...)), src_tbls(dm))

  dm_select_tbl(dm, !!!selected)
}

check_new_tbls <- function(dm, tbls) {
  orig_tbls <- dm_get_tables(dm)

  # are all new tables on the same source as the original ones?
  if (has_length(orig_tbls) && !all_same_source(c(orig_tbls[1], tbls))) {
    abort_not_same_src()
  }
}

dm_try_tables <- function(code, table_names) {
  selected <- tryCatch(
    force(code),
    error = function(e) {
      error_class <- class(e)
      if (inherits(e, "rlang_error")) {
        abort_w_message(
          # error like "Unknown column `wrong_column` "
          # FIXME: which other "rlang_error"s are possible?
          glue(
            "{trimws(sub('column', 'table', conditionMessage(e), fixed = TRUE))}. ",
            "Available tables in `dm`: {commas(tick(table_names))}"
          )
        )
      } else if (inherits(e, "simpleError")) {
        # error like "object 'wrong_object' not found"
        # FIXME: which other "simpleError"s are possible?
        wrong_table <- gsub("^.*'(.*)'.*$", "\\1", e$message)
        abort_w_message(
          glue(
            "Unknown table {tick(wrong_table)}. ",
            "Available tables in `dm`: {commas(tick(table_names))}"
          )
        )
      } else {
        abort(e$message)
      }
    }
  )
  selected
}
