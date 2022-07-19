#' Get connection
#'
#' @description
#' `dm_get_con()` returns the DBI connection for a `dm` object.
#' This works only if the tables are stored on a database, otherwise an error
#' is thrown.
#'
#' @details
#' All lazy tables in a dm object must be stored on the same database server
#' and accessed through the same connection, because a large part
#' of the package's functionality relies on efficient joins.
#'
#' @inheritParams dm_add_pk
#'
#' @return The [`DBI::DBIConnection-class`] object for a `dm` object.
#'
#' @export
#' @examplesIf dm:::dm_has_financial()
#' dm_financial() %>%
#'   dm_get_con()
dm_get_con <- function(dm) {
  check_not_zoomed(dm)
  src <- dm_get_src_impl(dm)
  if (!inherits(src, "src_dbi")) abort_con_only_for_dbi()
  src$con
}

dm_get_src_impl <- function(x) {
  tables <- dm_get_tables_impl(x)
  tbl_src(tables[1][[1]])
}
