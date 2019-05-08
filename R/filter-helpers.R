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
perform_joins_of_join_list <- function( # FIXME: jumbles up order in $tables part of `dm`-object; does it matter?
  tables, # function should be called with 1 already filtered table which needs to be in first entry of join_list
  join_list,
  join = semi_join) {

  if (is_empty(join_list)) return(tables)
  joined_tbl <- join(tables[[join_list[[1]][["lhs_table"]]]],
               tables[[join_list[[1]][["rhs_table"]]]],
               join_list[[1]][["by"]])

  tables[[join_list[[1]][["lhs_table"]]]] <- joined_tbl
  join_list[[1]] <- NULL
  perform_joins_of_join_list(tables, join_list)
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

# works only for circle free (FIXME: ordered, fork-less) graph of connections
#' @export
calculate_join_list <- function(data_model, table_name, join_list = list()) {
  references <- data_model$references
  if (is_referenced_data_model(data_model, table_name)) {
    which_ind <- references$ref == table_name
    if (sum(which_ind) != 1) {
      abort("more than 1 foreign key relation per table is (so far) not supported")
    }
    rhs_table <- table_name
    rhs_column <- as.character(references$ref_col[which_ind])
    lhs_table <- as.character(references$table[which_ind])
    lhs_column <- as.character(references$column[which_ind])
    new_data_model <- rm_data_model_reference(
      data_model,
      lhs_table,
      lhs_column,
      rhs_table)
    } else if (is_referencing_data_model(data_model, table_name)) {
    which_ind <- references$table == table_name
    if (sum(which_ind) != 1) {
      abort("more than 1 foreign key relation per table is (so far) not supported")
    }
    rhs_table <- table_name
    rhs_column <- as.character(references$column[which_ind])
    lhs_table <- as.character(references$ref[which_ind])
    lhs_column <- as.character(references$ref_col[which_ind])
    new_data_model <- rm_data_model_reference(
      data_model,
      rhs_table,
      rhs_column,
      lhs_table)
  } else {
    return(join_list) # this is where the recursive function call ends, when no further references are found for `table_name`
  }

  by = rhs_column
  names(by) <- lhs_column

  next_list_entry <- list(
    "lhs_table" = lhs_table,
    "rhs_table" = rhs_table,
    "by" = by
    )

  if (is_empty(join_list)) {
    join_list[[letters[1]]] <- next_list_entry
  } else {
    join_list[[letters[length(join_list) + 1]]] <- next_list_entry
  }

  calculate_join_list(new_data_model, lhs_table, join_list) # function recursively calls itself until no "path" exists from `new_table` onwards
}
