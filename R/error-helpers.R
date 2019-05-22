
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
