perform_joins <- function(
                          dm, # function should be called with 1 already filtered table which needs to be in first entry of join_list
                          join_list,
                          join = semi_join) {
  reduce2(join_list$lhs, join_list$rhs, perform_join, join = join, .init = dm)
}

perform_join <- function(dm, lhs, rhs, join) {

  joined_tbl <- join(tbl(dm, lhs), tbl(dm, rhs), by = get_by(dm, lhs, rhs))
  cdm_update_table(dm, lhs, joined_tbl)
}

cdm_update_table <- function(dm, name, table) {
  if (!identical(colnames(table), colnames(tbl(dm, name)))) abort_wrong_table_cols_semi_join(name)

  tables_list <- cdm_get_tables(dm)
  tables_list[[name]] <- table

  new_dm(
    src = cdm_get_src(dm),
    tables = tables_list,
    data_model = cdm_get_data_model(dm)
  )
}

#' Number of rows
#'
#' Returns a named vector with the number of rows for each table.
#'
#' @param dm A [`dm`] object
#' @export
cdm_nrow <- function(dm) {
  map_dbl(cdm_get_tables(dm), ~ as.numeric(pull(collect(count(.)))))
}

get_by <- function(dm, lhs_name, rhs_name) {
  if (!relation_exists(dm, lhs_name, rhs_name)) {
    abort(
      paste0(
        "No foreign key relation exists between table `",
        lhs_name,
        "` ",
        "and table `",
        rhs_name,
        "`, joining not possible."
      )
    )
  }

  if (cdm_has_fk(dm, !!lhs_name, !!rhs_name)) {
    lhs_col <- cdm_get_fk(dm, !!lhs_name, !!rhs_name)
    rhs_col <- cdm_get_pk(dm, !!rhs_name)
  } else {
    lhs_col <- cdm_get_pk(dm, !!lhs_name)
    rhs_col <- cdm_get_fk(dm, !!rhs_name, !!lhs_name)
  }
  # Construct a `by` argument of the form `c("lhs_col[1]" = "rhs_col[1]", ...)`
  # as required by `*_join()`
  by <- rhs_col
  names(by) <- lhs_col
  by
}

relation_exists <- function(dm, table_1, table_2) {
  cdm_has_fk(dm, !!table_1, !!table_2) || cdm_has_fk(dm, !!table_2, !!table_1)
}
