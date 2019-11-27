#' Number of rows
#'
#' Returns a named vector with the number of rows for each table.
#'
#' @param dm A [`dm`] object.
#' @export
cdm_nrow <- function(dm) {
  # FIXME: with "direct" filter maybe no check necessary: but do we want to issue
  # a message in case the filters haven't been applied yet?
  check_no_filter(dm)
  map_dbl(cdm_get_tables(dm), ~ as.numeric(pull(collect(count(.)))))
}

get_by <- function(dm, lhs_name, rhs_name) {
  if (cdm_has_fk(dm, !!lhs_name, !!rhs_name)) {
    lhs_col <- cdm_get_fk(dm, !!lhs_name, !!rhs_name)
    rhs_col <- cdm_get_pk(dm, !!rhs_name)
  } else if (cdm_has_fk(dm, !!rhs_name, !!lhs_name)) {
    lhs_col <- cdm_get_pk(dm, !!lhs_name)
    rhs_col <- cdm_get_fk(dm, !!rhs_name, !!lhs_name)
  } else {
    abort_tables_not_neighbours(lhs_name, rhs_name)
  }

  if (length(lhs_col) > 1 || length(rhs_col) > 1) abort_no_cycles()
  # Construct a `by` argument of the form `c("lhs_col[1]" = "rhs_col[1]", ...)`
  # as required by `*_join()`
  by <- rhs_col
  names(by) <- lhs_col
  by
}

repair_by <- function(by) {
  bad <- which(names2(by) == "")
  names(by)[bad] <- by[bad]
  by
}

update_filter <- function(dm, table_name, filters) {
  def <- cdm_get_def(dm)
  def$filters[def$table == table_name] <- filters
  new_dm3(def)
}
