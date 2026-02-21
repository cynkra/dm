#' Number of rows
#'
#' @description
#' Returns a named vector with the number of rows for each table.
#'
#' @param dm A [`dm`] object.
#'
#' @return A named vector with the number of rows for each table.
#'
#' @examplesIf rlang::is_installed("nycflights13")
#' dm_nycflights13() %>%
#'   dm_filter(airports = (faa %in% c("EWR", "LGA"))) %>%
#'   dm_nrow()
#' @export
dm_nrow <- function(dm) {
  check_not_zoomed(dm)
  # FIXME: with "direct" filter maybe no check necessary: but do we want to issue
  # a message in case the filters haven't been applied yet?
  check_no_filter(dm)
  map_dbl(dm_get_tables_impl(dm), ~ as.numeric(dplyr::pull(dplyr::collect(safe_count(.)))))
}

get_by <- function(dm, lhs_name, rhs_name) {
  if (dm_has_fk_impl(dm, lhs_name, rhs_name)) {
    cols <- dm_get_fk2_impl(dm, lhs_name, rhs_name)
  } else if (dm_has_fk_impl(dm, rhs_name, lhs_name)) {
    cols <- dm_get_fk2_impl(dm, rhs_name, lhs_name)[2:1]
  } else {
    abort_tables_not_neighbors(lhs_name, rhs_name)
  }

  if (nrow(cols) > 1) {
    abort_no_cycles(create_graph_from_dm(dm))
  }

  # Construct a `by` argument of the form `c("lhs_col[1]" = "rhs_col[1]", ...)`
  # as required by `*_join()`
  by <- get_key_cols(cols[[2]])
  names(by) <- get_key_cols(cols[[1]])
  by
}

# Normalize a `by` argument: convert `dplyr_join_by` objects to named character
# vectors, and ensure unnamed elements get names equal to their values.
normalize_join_by <- function(by) {
  if (inherits(by, "dplyr_join_by")) {
    return(set_names(by$y, by$x))
  }
  if (!is_named2(by)) {
    by <- set_names(by, by)
  }
  bad <- which(names2(by) == "")
  names(by)[bad] <- by[bad]
  by
}

update_filter <- function(dm, table_name, filters) {
  def <- dm_get_def(dm)
  def$filters[def$table == table_name] <- filters
  dm_from_def(def, zoomed = TRUE)
}
