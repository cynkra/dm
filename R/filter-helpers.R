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
  is_referenced_data_model(data_model, table_name)
}

is_referenced_data_model <- function(data_model, table_name) {
  references <- data_model$references
  which_ind <- references$ref == table_name
  any(which_ind)
}

is_referencing_data_model <- function(data_model, table_name) {
  references <- data_model$references
  which_ind <- references$table == table_name
  any(which_ind)
}

#' @export
cdm_get_referencing_tables <- function(dm, table_name) {
  data_model <- cdm_get_data_model(dm)
  references <- data_model$references
  which_ind <- references$ref == table_name
  as.character(references$table[which_ind])
}

find_next_connection <- function(data_model, table_name, fk_or_pk) {
  references <- data_model$references

  if (fk_or_pk == "pk") {
    which_ind <- references$ref == table_name
    if (!any(which_ind)) return(NULL)
    referenced_table <- table_name
    referenced_column <- as.character(references$ref_col[which_ind][1])
    referencing_table <- as.character(references$table[which_ind][1])
    referencing_column <- as.character(references$column[which_ind][1])
  } else if (fk_or_pk == "fk") {
    which_ind <- references$table == table_name
    if (!any(which_ind)) return(NULL)
    referencing_table <- table_name
    referencing_column <- as.character(references$column[which_ind][1])
    referenced_table <- as.character(references$ref[which_ind][1])
    referenced_column <- as.character(references$ref_col[which_ind][1])
  }
  list("thinned_data_model" = rm_data_model_reference(
    data_model,
    referencing_table,
    referencing_column,
    referenced_table),
       "referencing_table" = referencing_table,
       "referencing_column" = referencing_column,
       "referenced_table" = referenced_table,
       "referenced_column" = referenced_column)
}
