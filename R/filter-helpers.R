#' @export
cdm_join_tbl <- function(dm, lhs, rhs, join = semi_join) {
  lhs_name <- as_name(enexpr(lhs))
  rhs_name <- as_name(enexpr(rhs))

  if (!(cdm_has_fk(dm, !!lhs_name, !!rhs_name) |
        cdm_has_fk(dm, !!rhs_name, !!lhs_name))) {
    abort(paste0("No foreign key relation exists between table '", lhs_name,
                 "' and table ", rhs_name, ", joining not possible."))
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

  reduce(join_list, perform_join, join = join, .init = dm)
}

perform_join <- function(dm, join_item, join) {
  lhs <- join_item[["lhs_table"]]
  rhs <- join_item[["rhs_table"]]
  joined_tbl <- cdm_join_tbl(dm, !!lhs, !!rhs, join = join)

  cdm_update_table(dm, lhs, joined_tbl)
}

cdm_update_table <- function(dm, name, table) {
  stopifnot(identical(colnames(table), colnames(tbl(dm, name))))

  tables_list <- cdm_get_tables(dm)
  tables_list[[name]] <- table

  new_dm(
    src = cdm_get_src(dm),
    tables = tables_list,
    data_model = cdm_get_data_model(dm)
  )
}
