#' Deprecated functions
#'
#' These functions are deprecated in favor of better alternatives.
#' Most functions with the `cdm_` prefix have an identical alternative
#' with a `dm_` prefix.
#'
#' @name deprecated
NULL

#' sql_schema_create()
#'
#' `sql_schema_*()` functions have been replaced with the corresponding
#' `db_schema_*()` functions.
#'
#' @keywords internal
#' @rdname deprecated
#' @export
sql_schema_create <- function(dest, schema, ...) {
  # FIXME: Use sql_*() methods to construct the SQL code
  # Challenge: How to run multi-statement code with cleanup?
  deprecate_soft("0.2.5", "dm::sql_schema_create()", "dm::db_schema_create()")
  check_dots_empty()
  db_schema_create(dest, schema)
}
