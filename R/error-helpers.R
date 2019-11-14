
# error class generator ---------------------------------------------------

cdm_error <- function(x) {
  paste0("dm_error_", x)
}

cdm_error_full <- function(x) {
  c(cdm_error(x), "dm_error")
}


# abort and text for primary key handling errors --------------------------

abort_wrong_col_args <- function() {
  abort(error_txt_wrong_col_args(), .subclass = cdm_error_full("wrong_cols_args"))
}

error_txt_wrong_col_args <- function() {
  "Argument `column` has to be given as character variable or unquoted and may only contain 1 element."
}

abort_key_set_force_false <- function() {
  abort(error_txt_key_set_force_false(), .subclass = cdm_error_full("key_set_force_false"))
}

error_txt_key_set_force_false <- function() {
  "If you want to change the existing primary key for a table, set `force` == TRUE."
}


# abort and text for key-helper functions ---------------------------------

abort_not_unique_key <- function(table_name, column_names) {
  abort(error_txt_not_unique_key(table_name, column_names), .subclass = cdm_error_full("not_unique_key"))
}

error_txt_not_unique_key <- function(table_name, column_names) {
  paste0(
    "`",
    paste(column_names, collapse = ", "),
    "` not a unique key of `",
    table_name, "`."
  )
}


# general error: table not part of `dm` -----------------------------------


abort_table_not_in_dm <- function(table_name, dm) {
  abort(error_txt_table_not_in_dm(table_name, dm), .subclass = cdm_error_full("table_not_in_dm"))
}

error_txt_table_not_in_dm <- function(table_name, dm) {
  paste0(
    "Tables ",
    commas(tick(table_name)),
    " not in `dm` object. Available table names: ",
    commas(tick(src_tbls(dm)))
  )
}


# error: is not subset of -------------------------------------------------

abort_not_subset_of <- function(table_name_1, colname_1,
                                table_name_2, colname_2) {
  abort(error_txt_not_subset_of(table_name_1, colname_1, table_name_2, colname_2),
    .subclass = cdm_error_full("not_subset_of")
  )
}

error_txt_not_subset_of <- function(table_name_1, colname_1,
                                    table_name_2, colname_2) {
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
  abort(error_txt_sets_not_equal(error_msgs), .subclass = cdm_error_full("sets_not_equal"))
}

error_txt_sets_not_equal <- function(error_msgs) {
  paste0(error_msgs, collapse = "\n  ")
}


# cardinality check errors ------------------------------------------------

abort_not_bijective <- function(child_table_name, fk_col_name) {
  abort(error_txt_not_bijective(child_table_name, fk_col_name),
    .subclass = cdm_error_full("not_bijective")
  )
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
    .subclass = cdm_error_full("not_injective")
  )
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

abort_ref_tbl_has_no_pk <- function(ref_table_name) {
  abort(error_txt_ref_tbl_has_no_pk(ref_table_name),
    .subclass = cdm_error_full("ref_tbl_has_no_pk")
  )
}

error_txt_ref_tbl_has_no_pk <- function(ref_table_name) {
  paste0(
    "ref_table ", tick(ref_table_name), " needs a primary key first. ",
    "Use `cdm_enum_pk_candidates()` to find candidates, and `cdm_add_pk()` define a primary key."
  )
}

abort_is_not_fkc <- function(child_table_name, wrong_fk_colnames,
                             parent_table_name, actual_fk_colnames) {
  abort(
    error_txt_is_not_fk(
      child_table_name, wrong_fk_colnames, parent_table_name, actual_fk_colnames
    ),
    .subclass = cdm_error_full("is_not_fkc")
  )
}

error_txt_is_not_fk <- function(child_table_name, wrong_fk_colnames,
                                parent_table_name, actual_fk_colnames) {
  paste0(
    "The given combination of columns ",
    paste0(tick(wrong_fk_colnames), collapse = ", "), " ",
    "is not a foreign key of table ",
    tick(child_table_name), " ",
    "with regards to ref_table ",
    tick(parent_table_name), ". ",
    "Foreign key columns are: ",
    commas(tick(actual_fk_colnames)), "."
  )
}

abort_rm_fk_col_missing <- function() {
  abort(error_txt_rm_fk_col_missing(), .subclass = cdm_error_full("rm_fk_col_missing"))
}

error_txt_rm_fk_col_missing <- function() {
  "Parameter `column` has to be set. Pass `NULL` for removing all references."
}


# error helpers for draw_dm -----------------------------------------------

abort_last_col_missing <- function() {
  abort(error_txt_last_col_missing(), .subclass = cdm_error_full("last_col_missing"))
}

error_txt_last_col_missing <- function() {
  "The last color cannot be missing."
}

abort_wrong_color <- function(avail_color_names) {
  abort(error_txt_wrong_color(avail_color_names), .subclass = cdm_error_full("wrong_color"))
}

error_txt_wrong_color <- function(avail_color_names) {
  paste0(
    "Available color names are only: \n",
    paste0(avail_color_names, collapse = ",\n")
  )
}


# errors in graph-functions -----------------------------------------------

abort_no_cycles <- function() {
  abort(error_txt_no_cycles(), .subclass = cdm_error_full("no_cycles"))
}

error_txt_no_cycles <- function() {
  "Cycles in the relationship graph not yet supported."
}


# error in cdm_flatten_to_tbl() ----------------------------------------------

abort_tables_not_reachable_from_start <- function() {
  abort(error_txt_tables_not_reachable_from_start(), .subclass = cdm_error_full("tables_not_reachable_from_start"))
}

error_txt_tables_not_reachable_from_start <- function(fun_name, param) {
  glue("All selected tables must be reachable from `start`.")
}



# errors in table surgery -------------------------------------------------

abort_wrong_col_names <- function(table_name, actual_colnames, wrong_colnames) {
  abort(error_txt_wrong_col_names(table_name, actual_colnames, wrong_colnames),
    .subclass = cdm_error_full("wrong_col_names")
  )
}

error_txt_wrong_col_names <- function(table_name, actual_colnames, wrong_colnames) {
  if (length(wrong_colnames) > 1) {
    paste0(
      "Not all specified variables ",
      paste(tick(wrong_colnames), collapse = ", "), " ",
      "are columns of ", tick(table_name), ". ",
      "Its columns are: \n",
      paste(tick(actual_colnames), collapse = ", "), "."
    )
  } else {
    paste0(
      tick(wrong_colnames), " is not a column of ",
      tick(table_name), ". Its columns are: \n",
      commas(tick(actual_colnames)), "."
    )
  }
}


abort_dupl_new_id_col_name <- function(table_name) {
  abort(error_txt_dupl_new_id_col_name(table_name), .subclass = cdm_error_full("dupl_new_id_col_name"))
}

error_txt_dupl_new_id_col_name <- function(table_name) {
  paste0("`new_id_column` can not have an identical name as one of the columns of `", table_name, "`.")
}

abort_too_many_cols <- function(table_name) {
  abort(error_txt_too_many_cols(table_name), .subclass = cdm_error_full("too_many_cols"))
}

error_txt_too_many_cols <- function(table_name) {
  paste0("Number of columns to be extracted has to be less than total number of columns of ", table_name)
}

abort_no_overwrite <- function() {
  abort(error_txt_no_overwrite(), .subclass = cdm_error_full("no_overwrite"))
}

error_txt_no_overwrite <- function() {
  paste0("`cdm_copy_to()` does not support the `overwrite` argument.")
}

abort_no_types <- function() {
  abort(error_txt_no_types(), .subclass = cdm_error_full("no_types"))
}

error_txt_no_types <- function() {
  paste0("`cdm_copy_to()` does not support the `types` argument.")
}

abort_no_indexes <- function() {
  abort(error_txt_no_indexes(), .subclass = cdm_error_full("no_indexes"))
}

error_txt_no_indexes <- function() {
  paste0("`cdm_copy_to()` does not support the `indexes` argument.")
}

abort_no_unique_indexes <- function() {
  abort(error_txt_no_unique_indexes(), .subclass = cdm_error_full("no_unique_indexes"))
}

error_txt_no_unique_indexes <- function() {
  paste0("`cdm_copy_to()` does not support the `unique_indexes` argument.")
}

abort_need_named_vec <- function(dm) {
  abort(error_txt_need_named_vec(dm), .subclass = cdm_error_full("need_named_vec"))
}

error_txt_need_named_vec <- function(dm) {
  paste0("Parameter `table_names` in `cdm_copy_to()` needs to be a named vector, the names ",
    "must be from the original table names returned by `src_tbls()`: ",
    commas(tick(src_tbls(dm)))
  )
}

abort_src_not_db <- function() {
  abort(error_src_not_db(), .subclass = cdm_error_full("src_not_db"))
}

error_src_not_db <- function() {
  paste0("This does not work if `cdm_get_src(dm)` is not on a database.")
}

abort_first_rm_fks <- function(table, fks) {
  abort(error_first_rm_fks(table, fks), .subclass = cdm_error_full("first_rm_fks"))
}

error_first_rm_fks <- function(table, fks) {
  glue("There are foreign keys pointing from table(s) {commas(tick(fks))} to table {tick(table)}. First remove those or set `rm_referencing_fks = TRUE`.")
}


abort_no_src_or_con <- function() {
  abort(error_no_src_or_con(), .subclass = cdm_error_full("no_src_or_con"))
}

error_no_src_or_con <- function() {
  paste0('`src` needs to be a "src" or a "con" object.')
}


abort_update_not_supported <- function() {
  abort(error_update_not_supported(), .subclass = cdm_error_full("update_not_supported"))
}

error_update_not_supported <- function() {
  paste0('Updating "dm" objects not supported.')
}

# when filters are set and they shouldn't be ------------------------------

abort_only_possible_wo_filters <- function(fun_name) {
  abort(error_only_possible_wo_filters(fun_name), .subclass = cdm_error_full("only_possible_wo_filters"))
}

error_only_possible_wo_filters <- function(fun_name) {
  glue("You cannot call `{fun_name}()` on a `dm` with filter conditions. Consider using `cdm_apply_filters()` first.")
}


# no foreign key relation -------------------------------------------------

abort_tables_not_neighbours <- function(t1_name, t2_name) {
  abort(error_tables_not_neighbours(t1_name, t2_name), .subclass = cdm_error_full("tables_not_neighbours"))
}

error_tables_not_neighbours <- function(t1_name, t2_name) {
  glue("Tables `{t1_name}` and `{t2_name}` are not directly linked by a foreign key relation.")
}

# `cdm_flatten_to_tbl()` and `cdm_join_to_tbl()` only supported for parents

abort_only_parents <- function() {
  abort(error_only_parents(), .subclass = cdm_error_full("only_parents"))
}

error_only_parents <- function() {
  paste0("When using `cdm_join_to_tbl()` or `cdm_flatten_to_tbl()` all join partners of table `start` ",
         "have to be its direct neighbours. For 'flattening' with `left_join()`, `inner_join()` or `full_join()` ",
         "use `cdm_squash_to_tbl()` as an alternative.")
}

# not all tables have the same src ----------------------------------------


abort_not_same_src <- function() {
  abort(error_not_same_src(), .subclass = cdm_error_full("not_same_src"))
}

error_not_same_src <- function() {
  "Not all tables in the object share the same `src`"
}

# Something other than tables are put in a `dm` ------------------

abort_what_a_weird_object <- function(class) {
  abort(error_what_a_weird_object(class), .subclass = cdm_error_full("what_a_weird_object"))
}

error_what_a_weird_object <- function(class) {
  paste0("Don't know how to determine table source for object of class ",
         class)
}

# not all tables have the same src ----------------------------------------


abort_not_same_src <- function() {
  abort(error_not_same_src(), .subclass = cdm_error_full("not_same_src"))
}

error_not_same_src <- function() {
  "Not all tables in the object share the same `src`"
}

# Something other than tables are put in a `dm` ------------------

abort_what_a_weird_object <- function(class) {
  abort(error_what_a_weird_object(class), .subclass = cdm_error_full("what_a_weird_object"))
}

error_what_a_weird_object <- function(class) {
  paste0("Don't know how to determine table source for object of class ",
         class)
}

abort_squash_limited <- function() {
  abort(error_squash_limited(), .subclass = cdm_error_full("squash_limited"))
}

error_squash_limited <- function() {
  paste0("`cdm_squash_to_tbl()` only supports join methods `left_join`, `inner_join`, `full_join`.")
}

abort_apply_filters_first <- function(join_name) {
  abort(error_apply_filters_first(join_name), .subclass = cdm_error_apply_filters_first(join_name))
}

cdm_error_apply_filters_first <- function(join_name) {
  cdm_error(c(paste0("apply_filters_first_", join_name), "apply_filters_first"))
}

error_apply_filters_first <- function(join_name) {
  glue("`cdm_..._to_tbl()` with join method `{join_name}` generally wouldn't ",
       "produce the correct result when filters are set. ",
       "Please consider calling `cdm_apply_filters()` first.")
}

abort_no_flatten_with_nest_join <- function() {
  abort(error_no_flatten_with_nest_join(), .subclass = cdm_error_full("no_flatten_with_nest_join"))
}

error_no_flatten_with_nest_join <- function() {
  paste0("`cdm_..._to_tbl() can't be called with `join = nest_join`, because it doesn't make sense, ",
  "cf. the help pages for these functions. Consider `join = left_join`")
}

# either explicit table names, or auto-unique ones ------------------------

abort_unique_table_names_or_table_names <- function() {
  abort(error_unique_table_names_or_table_names(), .subclass = cdm_error_full("unique_table_names_or_table_names"))
}

error_unique_table_names_or_table_names <- function() {
  "Can supply either `table_names` or `unique_table_names = TRUE`, not both."
}


# object is not a `dm` (but should be one) --------------------------------
abort_is_not_dm <- function(obj_class) {
  abort(error_is_not_dm(obj_class), .subclass = cdm_error_full("is_not_dm"))
}

error_is_not_dm <- function(obj_class) {
  glue("Required class `dm` but instead is {tick(obj_class)}")
}


# local `dm` has no con ---------------------------------------------------
abort_con_only_for_dbi <- function() {
  abort(error_con_only_for_dbi(), .subclass = cdm_error_full("con_only_for_dbi"))
}

error_con_only_for_dbi <- function() {
  "A local `dm` doesn't have a DB connection"
}

# no zoom allowed for `cdm_zoom_to_tbl()` ---------------------------------

abort_no_zoom_allowed <- function() {
  abort(error_no_zoom_allowed(), .subclass = cdm_error_full("no_zoom_allowed"))
}

error_no_zoom_allowed <- function() {
  paste0("`cdm_zoom_to_tbl()` only works for unzoomed `dm`. Please use one of `cdm_update_zoomed_tbl()`, ",
         "`cdm_insert_zoomed_tbl()` or `cdm_zoom_out()` first.")
}

# general abort with customized msg ---------------------------------------

abort_w_message <- function(msg) {
  abort(msg, .subclass = cdm_error_full("w_message"))
}

abort_w_message

# no table zoomed, but 'cdm_insert_tbl()' called ---------------------------------

abort_no_table_zoomed <- function() {
  abort(error_no_table_zoomed(), .subclass = cdm_error_full("no_table_zoomed"))
}

error_no_table_zoomed <- function() {
  "`cdm_insert_tbl()` only works for zoomed `dm`"
}


# new table needs a name --------------------------------------------------

abort_table_needs_name <- function() {
  abort(error_table_needs_name(), .subclass = cdm_error_full("table_needs_name"))
}

error_table_needs_name <- function() {
  "The new table to insert with `cdm_insert_zoomed_tbl()` must have a name"
}

# when zoomed and it shouldn't be ------------------------------

abort_only_possible_wo_zoom <- function(fun_name) {
  abort(error_only_possible_wo_zoom(fun_name), .subclass = cdm_error_full("only_possible_wo_zoom"))
}

error_only_possible_wo_zoom <- function(fun_name) {
  glue("You cannot call `{fun_name}()` on a `zoomed_dm`. Consider using one of `cdm_update_zoomed_tbl()`, ",
       "`cdm_insert_zoomed_tbl()` or `cdm_zoom_out()` first.")
}

# when not zoomed and it should be ------------------------------

abort_only_possible_w_zoom <- function(fun_name) {
  abort(error_only_possible_w_zoom(fun_name), .subclass = cdm_error_full("only_possible_w_zoom"))
}

error_only_possible_w_zoom <- function(fun_name) {
  glue("You cannot call `{fun_name}()` on an unzoomed `dm`. Consider using `cdm_zoom_to_tbl()` first.")
}

# new table name needs to be unique ---------------------------------------

abort_need_unique_names <- function(duplicate_names) {
  abort(error_need_unique_names(duplicate_names), .subclass = cdm_error_full("need_unique_names"))
}

error_need_unique_names <- function(duplicate_names) {
  glue("Each new table needs to have a unique name. Duplicate new name(s): ",
       "{commas(tick(duplicate_names))}.")
}

# lost track of by-column (FK-relation) -----------------------------------

abort_fk_not_tracked <- function(x_orig_name, y_name) {
 abort(error_fk_not_tracked(x_orig_name, y_name), .subclass = cdm_error_full("fk_not_tracked"))
}

error_fk_not_tracked <- function(x_orig_name, y_name) {
  glue("The foreign key that existed between the originally zoomed table {tick(x_orig_name)} ",
       "and {tick(y_name)} got lost in transformations. Please explicitly provide the `by` argument.")
}

# RHS-by column not selected ----------------------------------------------

abort_need_to_select_rhs_by <- function(y_name, rhs_by) {
  abort(error_need_to_select_rhs_by(y_name, rhs_by), .subclass = "need_to_select_rhs_by")
}

error_need_to_select_rhs_by <- function(y_name, rhs_by) {
  glue("You need to select by-column {tick(rhs_by)} of RHS-table {tick(y_name)}.")
}


# join logic problem: duplicates when auto-readding RHS-by-column --------

abort_duplicated_cols_introduced <- function(duplicates) {
  abort(error_duplicated_cols_introduced(duplicates), .subclass = cdm_error_full("duplicated_cols_introduced"))
}

error_duplicated_cols_introduced <- function(duplicates) {
  glue("When re-adding RHS `by`-column taken from `dm` key relations, duplicated column names were created: {tick(duplicates)}. ",
  "Please review the renaming performed in parameter `select`.")
}
