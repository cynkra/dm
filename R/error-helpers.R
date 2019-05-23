
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


# general error: table not part of 'dm' -----------------------------------


abort_table_not_in_dm <- function(table_name, tables_in_dm) {
  abort(error_txt_table_not_in_dm(table_name, tables_in_dm), .subclass = cdm_error("table_not_in_dm"))
}

error_txt_table_not_in_dm <- function(table_name, tables_in_dm) {
  if (str_length(table_name) == 0) {
    "Table argument is missing."
  } else {
    paste0(
      "Table: ",
      table_name,
      " not in `dm`-object. Available table names are: ",
      paste0(tables_in_dm, collapse = ", ")
    )
  }
}


# error: is not subset of -------------------------------------------------

abort_not_subset_of <- function(
  table_name_1, colname_1, table_name_2, colname_2
  ) {
  abort(error_txt_not_subset_of(table_name_1, colname_1, table_name_2, colname_2),
        .subclass = cdm_error("not_subset_of"))
}

error_txt_not_subset_of <- function(
  table_name_1, colname_1, table_name_2, colname_2
  ) {
  paste0(
    "Column `",
    colname_1,
    "` in table `",
    table_name_1,
    "` contains values (see above) that are not present in column `",
    colname_2,
    "` in table `",
    table_name_2,
    "`"
  )
}


# error sets not equal ----------------------------------------------------

abort_sets_not_equal <- function(error_msgs) {
  abort(error_txt_sets_not_equal(error_msgs), .subclass = cdm_error("sets_not_equal"))
}

error_txt_sets_not_equal <- function(error_msgs) {
  paste0(error_msgs, collapse = "\n  ")
}


# cardinality check errors ------------------------------------------------

abort_not_bijective <- function(child_table_name, fk_col_name) {
  abort(error_txt_not_bijective(child_table_name, fk_col_name),
        .subclass = cdm_error("not_bijective"))
}

error_txt_not_bijective <- function(child_table_name, fk_col_name) {
  paste0(
    "1..1 cardinality (bijectivity) is not given: Column `",
    fk_col_name,
    "` in table `",
    child_table_name,
    "` contains duplicate values."
  )
}

abort_not_injective <- function(child_table_name, fk_col_name) {
  abort(error_txt_not_injective(child_table_name, fk_col_name),
        .subclass = cdm_error("not_injective"))
}

error_txt_not_injective <- function(child_table_name, fk_col_name) {
  paste0(
    "0..1 cardinality (injectivity from child table to parent table) is not given: Column `",
    fk_col_name,
    "` in table `",
    child_table_name,
    "` contains duplicate values."
  )
}


# errors in fk handling --------------------------------------------------

abort_ref_tbl_has_no_pk <- function(ref_table_name, pk_candidates) {
  abort(error_txt_ref_tbl_has_no_pk(ref_table_name, pk_candidates),
        .subclass = cdm_error("ref_tbl_has_no_pk"))
}

error_txt_ref_tbl_has_no_pk <- function(ref_table_name, pk_candidates) {
    paste0("ref_table '", ref_table_name, "' needs a primary key first.",
           " Candidates are: '",
           paste0(pk_candidates, collapse = ", "),
           "'. Use 'cdm_add_pk()' to set it.")
}

abort_is_not_fkc <- function(
  child_table_name, wrong_fk_colnames, parent_table_name, actual_fk_colnames) {
  abort(error_txt_is_not_fk(
    child_table_name, wrong_fk_colnames, parent_table_name, actual_fk_colnames),
    .subclass = cdm_error("is_not_fk")
    )
}

error_txt_is_not_fk <- function(
  child_table_name, wrong_fk_colnames, parent_table_name, actual_fk_colnames) {
  paste0("The given combination of columns '",
         paste0(wrong_fk_colnames, collapse = ", "),
         "' is not a foreign key of table '",
         child_table_name,
         "' with regards to ref_table '",
         parent_table_name,
         "'. Foreign key columns are: '",
         paste0(actual_fk_colnames,
                collapse = ", "), "'.")
}

abort_rm_fk_col_missing <- function() {
  abort(error_txt_rm_fk_col_missing(), .subclass = cdm_error("rm_fk_col_missing"))
}

error_txt_rm_fk_col_missing <- function() {
  "Parameter 'column' has to be set. 'NULL' for removing all references."
}


# error helpers for draw_dm -----------------------------------------------

abort_last_col_missing <- function() {
  abort(error_txt_last_col_missing(), .subclass = cdm_error("last_col_missing"))
}

error_txt_last_col_missing <- function() {
  "The last color cannot be missing."
}

abort_wrong_color <- function(avail_color_names) {
  abort(error_txt_wrong_color(avail_color_names), .subclass = cdm_error("wrong_color"))
}

error_txt_wrong_color <- function(avail_color_names) {
  paste0("Available color names are only: \n",
         paste0(avail_color_names, collapse = ",\n")
  )
}


# errors in graph-functions -----------------------------------------------

abort_no_cycles <- function() {
  abort(error_txt_no_cycles(), .subclass = cdm_error("no_cycles"))
}

error_txt_no_cycles <- function() {
  "Cycles not yet supported"
}


# errors in cdm_select() --------------------------------------------------

abort_vertices_not_connected <- function() {
  abort(error_txt_vertices_not_connected(), .subclass = cdm_error("vertices_not_connected"))
}

error_txt_vertices_not_connected <- function() {
  "Not all of the selected tables of the 'dm'-object are connected."
}



# errors in table surgery -------------------------------------------------

abort_wrong_col_names <- function(table_name, actual_colnames, wrong_colnames) {
  abort(error_txt_wrong_col_names(table_name, actual_colnames, wrong_colnames),
        .subclass = cdm_error("wrong_col_names"))
}

error_txt_wrong_col_names <- function(table_name, actual_colnames, wrong_colnames) {
  if (length(wrong_colnames) > 1) {
    paste0(
      "Not all specified variables `", paste(wrong_colnames, collapse = ", "),
      "` are columns of `", table_name,
      "`. Its columns are: \n`", paste(actual_colnames, collapse = ", "), "`."
    )
  } else {
    paste0(
      "'", wrong_colnames, "' is not a column of '",
      table_name, "'. Its columns are: \n'",
      paste0(actual_colnames, collapse = "', '"), "'")
  }
}


abort_dupl_new_id_col_name <- function(table_name) {
  abort(error_txt_dupl_new_id_col_name(table_name), .subclass = cdm_error("dupl_new_id_col_name"))
}

error_txt_dupl_new_id_col_name <- function(table_name) {
  paste0("`new_id_column` can not have an identical name as one of the columns of `", table_name, "`.")
}

abort_too_many_cols <- function(table_name) {
  abort(error_txt_too_many_cols(table_name), .subclass = cdm_error("too_many_cols"))
}

error_txt_too_many_cols <- function(table_name) {
  paste0("Number of columns to be extracted has to be less than total number of columns of ", table_name)
}
