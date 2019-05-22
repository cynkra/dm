
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
