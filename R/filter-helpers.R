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

#' @export
cdm_is_referenced <- function(dm, table_name) {
  data_model <- cdm_get_data_model(dm)
  references <- data_model$references
  which_ind <- references$ref == table_name
  any(which_ind)
}

#' @export
cdm_get_referencing_tables <- function(dm, table_name) {
  data_model <- cdm_get_data_model(dm)
  references <- data_model$references
  which_ind <- references$ref == table_name
  as.character(references$table[which_ind])
}
