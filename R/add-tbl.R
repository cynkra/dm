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
                            pks = list_of(new_pk()), fks = list_of(new_fk()), uks = list_of(new_uk())) {
  def <- dm_get_def(dm)

  def_0 <- def[rep_along(table_name, NA_integer_), ]
  def_0$table <- table_name
  def_0$data <- unname(tbls)
  def_0$pks <- pks
  def_0$uks <- uks
  def_0$fks <- fks
  def_0$filters <- filters

  new_dm3(vec_rbind(def, def_0))
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
#' @seealso [dm()], [dm_select_tbl()]
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
