
# error class generator ---------------------------------------------------

cdm_error <- function(x) {
  c(paste0("dm_error_", x), "dm_error")
}


# abort and text for cdm_filter() error -----------------------------------

abort_pk_for_filter_missing <- function(table_name) {
  abort(error_txt_pk_filter_missing(table_name),
    .subclass = cdm_error("no_pk_filter")
  )
}

error_txt_pk_filter_missing <- function(table_name) {
  paste0("Table '", table_name,
         "' needs primary key for the filtering to work. ",
         "Please set one using cdm_add_pk()."
  )
}


# abort and text for cdm_semi_join() errors -------------------------------

abort_wrong_table_cols_semi_join <- function(table_name) {
  abort(error_txt_wrong_table_cols_semi_join(table_name),
        .subclass = cdm_error("wrong_table_cols_semi_join")
  )
}

error_txt_wrong_table_cols_semi_join <- function(table_name) {
  paste0("The table you passed to `cdm_semi_join()` needs to have same the columns as table '", table_name, "'.")
}

# abort and text for primary key handling errors --------------------------

abort_wrong_col_args <- function() {
  abort(error_txt_wrong_col_args(), .subclass = cdm_error("wrong_cols_args"))
}

error_txt_wrong_col_args <- function() {
  "Argument 'column' has to be given as character variable or unquoted and may only contain 1 element."
}

abort_key_set_force_false <- function() {
  abort(error_txt_key_set_force_false(), .subclass = cdm_error("key_set_force_false"))
}

error_txt_key_set_force_false <- function() {
  "If you want to change the existing primary key for a table, set `force` == TRUE."
}

abort_multiple_pks <- function(table_name) {
  abort(error_txt_multiple_pks(table_name), .subclass = cdm_error("multiple_pks"))

}

error_txt_multiple_pks <- function(table_name) {
  paste0(
    "Please use cdm_rm_pk() on ", table_name, ", more than 1 primary key is currently set for it."
  )
}


# abort and text for key-helper functions ---------------------------------

abort_not_unique_key <- function(table_name, column_names) {
  abort(error_txt_not_unique_key(table_name, column_names), .subclass = cdm_error("not_unique_key"))
}

error_txt_not_unique_key <- function(table_name, column_names) {
  paste0(
    "`",
    paste(column_names, collapse = ", "),
    "` not a unique key of `",
    table_name, "`."
  )
}
