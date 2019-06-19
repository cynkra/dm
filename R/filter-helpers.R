#' Perform a join between two tables of a `dm`
#'
#' @description A join of desired type is performed between table `lhs` and
#' table `rhs`.
#'
#' @param dm A `dm`-object
#' @param lhs The table on the left hand side of the join
#' @param rhs The table on the right hand side of the join
#' @param join The type of join to be performed, see \code{\link[dplyr]{join}}
#'
#' @export
cdm_join_tbl <- function(dm, lhs, rhs, join = semi_join) {
  lhs_name <- as_name(enexpr(lhs))
  rhs_name <- as_name(enexpr(rhs))

  if (!(cdm_has_fk(dm, !!lhs_name, !!rhs_name) |
    cdm_has_fk(dm, !!rhs_name, !!lhs_name))) {
    abort(paste0(
      "No foreign key relation exists between table '", lhs_name,
      "' and table ", rhs_name, ", joining not possible."
    ))
  }

  if (cdm_has_fk(dm, !!lhs_name, !!rhs_name)) {
    lhs_col <- cdm_get_fk(dm, !!lhs_name, !!rhs_name)
    rhs_col <- cdm_get_pk(dm, !!rhs_name)
  } else {
    lhs_col <- cdm_get_pk(dm, !!lhs_name)
    rhs_col <- cdm_get_fk(dm, !!rhs_name, !!lhs_name)
  }
  by <- rhs_col
  names(by) <- lhs_col

  lhs_obj <- tbl(dm, lhs_name)
  rhs_obj <- tbl(dm, rhs_name)

  join(lhs_obj, rhs_obj, by = by)
}

perform_joins <- function(
                          dm, # function should be called with 1 already filtered table which needs to be in first entry of join_list
                          join_list,
                          join = semi_join) {
  reduce2(join_list$lhs, join_list$rhs, perform_join, join = join, .init = dm)
}

perform_join <- function(dm, lhs, rhs, join) {
  joined_tbl <- cdm_join_tbl(dm, !!lhs, !!rhs, join = join)

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

#' Number of rows of a table or of the whole `dm`-object
#'
#' @param dm A `dm`-object
#' @param table If `NULL` (default), the sum of the number of rows of all tables is returned.
#' If a table is specified, the number of the rows of this table is returned.
#' @export
cdm_nrow <- function(dm, table = NULL) {
  if (!quo_is_null(enquo(table))) {
    table_name <- as_name(enexpr(table))
    check_correct_input(dm, table_name)

    tbl_obj <- tbl(dm, table_name)
    nrows <- as_integer(pull(count(tbl_obj)))
    names(nrows) <- table_name
    return(nrows)
  }

  nrows <- sum(map_int(cdm_get_tables(dm), ~ as_integer(pull(count(.)))))
  dm_name <- as_label(substitute(dm))
  if (dm_name != ".") {
    names(nrows) <- dm_name
  } else {
    names(nrows) <- "dm"
  }

  return(nrows)
}
