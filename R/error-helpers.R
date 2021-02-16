# Cf. https://github.com/krlmlr/dm/issues/144 (Review error messages)

# error class generator ---------------------------------------------------

format_msg_and_bullets <- function(bullets) {
  if (length(bullets) <= 1) {
    bullets
  } else {
    paste0(bullets[[1]], "\n", format_error_bullets(bullets[-1]))
  }
}

dm_error <- function(x) {
  paste0("dm_error_", x)
}

dm_error_full <- function(x) {
  c(dm_error(x), "dm_error")
}

dm_abort <- function(bullets, class) {
  abort(
    format_msg_and_bullets(bullets),
    .subclass = dm_error_full(class)
  )
}

dm_warning <- function(x) {
  paste0("dm_warning_", x)
}

dm_warning_full <- function(x) {
  c(dm_warning(x), "dm_warning")
}

dm_warn <- function(bullets, class) {
  warn(
    format_msg_and_bullets(bullets),
    .subclass = dm_warning_full(class)
  )
}

# abort and text for key-helper functions ---------------------------------

abort_not_unique_key <- function(table_name, column_names) {
  abort(error_txt_not_unique_key(table_name, column_names), .subclass = dm_error_full("not_unique_key"))
}

error_txt_not_unique_key <- function(table_name, column_names) {
  glue("({commas(tick(column_names))}) not a unique key of {tick(table_name)}.")
}

# error: is not subset of -------------------------------------------------

abort_not_subset_of <- function(table_name_1, colname_1,
                                table_name_2, colname_2) {
  abort(error_txt_not_subset_of(table_name_1, colname_1, table_name_2, colname_2),
    .subclass = dm_error_full("not_subset_of")
  )
}

error_txt_not_subset_of <- function(table_name_1, colname_1,
                                    table_name_2, colname_2) {
  glue(
    "Column {tick(colname_1)} of table {tick(table_name_1)} contains values (see examples above) that are not present in column ",
    "{tick(colname_2)} of table {tick(table_name_2)}."
  )
}

# error sets not equal ----------------------------------------------------

abort_sets_not_equal <- function(error_msgs) {
  abort(error_txt_sets_not_equal(error_msgs), .subclass = dm_error_full("sets_not_equal"))
}

error_txt_sets_not_equal <- function(error_msgs) {
  paste0(error_msgs, ".", collapse = "\n  ")
}

# cardinality check errors ------------------------------------------------

abort_not_bijective <- function(child_table_name, fk_col_name) {
  abort(error_txt_not_bijective(child_table_name, fk_col_name),
    .subclass = dm_error_full("not_bijective")
  )
}

error_txt_not_bijective <- function(child_table_name, fk_col_name) {
  glue(
    "1..1 cardinality (bijectivity) is not given: Column {tick(fk_col_name)} in table ",
    "{tick(child_table_name)} contains duplicate values."
  )
}

abort_not_injective <- function(child_table_name, fk_col_name) {
  abort(error_txt_not_injective(child_table_name, fk_col_name),
    .subclass = dm_error_full("not_injective")
  )
}

error_txt_not_injective <- function(child_table_name, fk_col_name) {
  glue(
    "0..1 cardinality (injectivity from child table to parent table) is not given: Column {tick(fk_col_name)}",
    " in table {tick(child_table_name)} contains duplicate values."
  )
}

# errors in fk handling --------------------------------------------------

abort_ref_tbl_has_no_pk <- function(ref_table_name) {
  abort(error_txt_ref_tbl_has_no_pk(ref_table_name),
    .subclass = dm_error_full("ref_tbl_has_no_pk")
  )
}

error_txt_ref_tbl_has_no_pk <- function(ref_table_name) {
  glue(
    "ref_table {tick(ref_table_name)} needs a primary key first. ",
    "Use `dm_enum_pk_candidates()` to find appropriate columns and `dm_add_pk()` to define a primary key."
  )
}

# error helpers for draw_dm -----------------------------------------------

abort_last_col_missing <- function() {
  abort(error_txt_last_col_missing(), .subclass = dm_error_full("last_col_missing"))
}

error_txt_last_col_missing <- function() {
  "The last color can't be missing."
}

# errors in graph-functions -----------------------------------------------

abort_no_cycles <- function(g) {
  shortest_cycle <- igraph::girth(g) %>%
    pluck("circle") %>%
    names()
  # add the first element after the last element, so it's more clear that it's a cycle
  shortest_cycle <- paste(c(shortest_cycle, shortest_cycle[1]), collapse = " -> ")
  abort(error_txt_no_cycles(shortest_cycle), .subclass = dm_error_full("no_cycles"))
}

error_txt_no_cycles <- function(shortest_cycle) {
  c("Cycles in the relationship graph not yet supported.", glue::glue("Shortest cycle: {shortest_cycle}"))
}


# error in dm_flatten_to_tbl() ----------------------------------------------

abort_tables_not_reachable_from_start <- function() {
  abort(error_txt_tables_not_reachable_from_start(), .subclass = dm_error_full("tables_not_reachable_from_start"))
}

error_txt_tables_not_reachable_from_start <- function() {
  glue("All selected tables must be reachable from `start`.")
}



# errors in table surgery -------------------------------------------------

abort_wrong_col_names <- function(table_name, actual_colnames, wrong_colnames) {
  abort(error_txt_wrong_col_names(table_name, actual_colnames, wrong_colnames),
    .subclass = dm_error_full("wrong_col_names")
  )
}

error_txt_wrong_col_names <- function(table_name, actual_colnames, wrong_colnames) {
  if (length(wrong_colnames) > 1) {
    glue(
      "Not all specified variables ",
      "{commas(tick(wrong_colnames))} ",
      "are columns of {tick(table_name)}. ",
      "Its columns are: \n",
      "{commas(tick(actual_colnames))}."
    )
  } else {
    glue(
      "{tick(wrong_colnames)} is not a column of ",
      "{tick(table_name)}. Its columns are: \n",
      "{commas(tick(actual_colnames))}."
    )
  }
}


abort_dupl_new_id_col_name <- function(table_name) {
  abort(error_txt_dupl_new_id_col_name(table_name), .subclass = dm_error_full("dupl_new_id_col_name"))
}

error_txt_dupl_new_id_col_name <- function(table_name) {
  glue("`new_id_column` can't have an identical name as one of the columns of {tick(table_name)}.")
}

abort_no_overwrite <- function() {
  fun_name <- as_string(sys.call(-1)[[1]])
  abort(error_txt_no_overwrite(fun_name), .subclass = dm_error_full("no_overwrite"))
}

error_txt_no_overwrite <- function(fun_name) {
  glue("`{fun_name}()` does not support the `overwrite` argument.")
}

abort_no_types <- function() {
  abort(error_txt_no_types(), .subclass = dm_error_full("no_types"))
}

error_txt_no_types <- function() {
  "`copy_dm_to()` does not support the `types` argument."
}

abort_no_indexes <- function() {
  abort(error_txt_no_indexes(), .subclass = dm_error_full("no_indexes"))
}

error_txt_no_indexes <- function() {
  "`copy_dm_to()` does not support the `indexes` argument."
}

abort_no_unique_indexes <- function() {
  abort(error_txt_no_unique_indexes(), .subclass = dm_error_full("no_unique_indexes"))
}

error_txt_no_unique_indexes <- function() {
  "`copy_dm_to()` does not support the `unique_indexes` argument."
}

abort_key_constraints_need_db <- function() {
  abort(error_txt_key_constraints_need_db(), .subclass = dm_error_full("key_constraints_need_db"))
}

error_txt_key_constraints_need_db <- function() {
  "Setting key constraints only works if the tables of the `dm` are on a database."
}

abort_no_src_or_con <- function() {
  abort(error_txt_no_src_or_con(), .subclass = dm_error_full("no_src_or_con"))
}

error_txt_no_src_or_con <- function() {
  "Argument `src` needs to be a `src` or a `con` object."
}

abort_update_not_supported <- function() {
  abort(error_txt_update_not_supported(), .subclass = dm_error_full("update_not_supported"))
}

error_txt_update_not_supported <- function() {
  "Updating `dm` objects not supported."
}

# errors when filters are set but they shouldn't be ------------------------------

abort_only_possible_wo_filters <- function(fun_name) {
  abort(error_txt_only_possible_wo_filters(fun_name), .subclass = dm_error_full("only_possible_wo_filters"))
}

error_txt_only_possible_wo_filters <- function(fun_name) {
  glue("You can't call `{fun_name}()` on a `dm` with filter conditions. Consider using `dm_apply_filters()` first.")
}

# no foreign key relation -------------------------------------------------

abort_tables_not_neighbors <- function(t1_name, t2_name) {
  abort(error_txt_tables_not_neighbors(t1_name, t2_name), .subclass = dm_error_full("tables_not_neighbors"))
}

error_txt_tables_not_neighbors <- function(t1_name, t2_name) {
  glue("Tables `{t1_name}` and `{t2_name}` are not directly linked by a foreign key relation.")
}

# `dm_flatten_to_tbl()` and `dm_join_to_tbl()` only supported for parents

abort_only_parents <- function() {
  abort(error_txt_only_parents(), .subclass = dm_error_full("only_parents"))
}

error_txt_only_parents <- function() {
  paste0(
    "When using `dm_join_to_tbl()` or `dm_flatten_to_tbl()` all join partners of table `start` ",
    "have to be its direct neighbors. For 'flattening' with `left_join()`, `inner_join()` or `full_join()` ",
    "use `dm_squash_to_tbl()` as an alternative."
  )
}

# not all tables have the same src ----------------------------------------


abort_not_same_src <- function(dm_bind = FALSE) {
  abort(error_txt_not_same_src(dm_bind), .subclass = dm_error_full("not_same_src"))
}

error_txt_not_same_src <- function(dm_bind = FALSE) {
  if (!dm_bind) {
    "Not all tables in the object share the same `src`."
  } else {
    "All `dm` objects need to share the same `src`."
  }
}

# Something other than tables are put in a `dm` ------------------

abort_what_a_weird_object <- function(class) {
  abort(error_txt_what_a_weird_object(class), .subclass = dm_error_full("what_a_weird_object"))
}

error_txt_what_a_weird_object <- function(class) {
  glue("Don't know how to determine table source for object of class {commas(tick(class))}.")
}

abort_squash_limited <- function() {
  abort(error_txt_squash_limited(), .subclass = dm_error_full("squash_limited"))
}

error_txt_squash_limited <- function() {
  "`dm_squash_to_tbl()` only supports join methods `left_join`, `inner_join`, `full_join`."
}

abort_apply_filters_first <- function(join_name) {
  abort(error_txt_apply_filters_first(join_name), .subclass = dm_error_txt_apply_filters_first(join_name))
}

dm_error_txt_apply_filters_first <- function(join_name) {
  dm_error(c(paste0("apply_filters_first_", join_name), "apply_filters_first"))
}

error_txt_apply_filters_first <- function(join_name) {
  glue(
    "`dm_..._to_tbl()` with join method `{join_name}` generally wouldn't ",
    "produce the correct result when filters are set. ",
    "Please consider calling `dm_apply_filters()` first."
  )
}

abort_no_flatten_with_nest_join <- function() {
  abort(error_txt_no_flatten_with_nest_join(), .subclass = dm_error_full("no_flatten_with_nest_join"))
}

error_txt_no_flatten_with_nest_join <- function() {
  paste0(
    "`dm_..._to_tbl()` can't be called with `join = nest_join`, ",
    "see the help pages for these functions. Consider `join = left_join`."
  )
}


# object is not a `dm` (but should be one) --------------------------------
abort_is_not_dm <- function(obj_class) {
  abort(error_txt_is_not_dm(obj_class), .subclass = dm_error_full("is_not_dm"))
}

error_txt_is_not_dm <- function(obj_class) {
  glue("Required class `dm` but instead is {format_classes(obj_class)}.")
}


# local `dm` has no con ---------------------------------------------------
abort_con_only_for_dbi <- function() {
  abort(error_txt_con_only_for_dbi(), .subclass = dm_error_full("con_only_for_dbi"))
}

error_txt_con_only_for_dbi <- function() {
  "A local `dm` doesn't have a DB connection."
}

# when zoomed and it shouldn't be ------------------------------

abort_only_possible_wo_zoom <- function(fun_name) {
  abort(error_txt_only_possible_wo_zoom(fun_name), .subclass = dm_error_full("only_possible_wo_zoom"))
}

error_txt_only_possible_wo_zoom <- function(fun_name) {
  glue(
    "You can't call `{fun_name}()` on a `zoomed_dm`. Consider using one of `dm_update_zoomed()`, ",
    "`dm_insert_zoomed()` or `dm_discard_zoomed()` first."
  )
}

# when not zoomed and it should be ------------------------------

abort_only_possible_w_zoom <- function(fun_name) {
  abort(error_txt_only_possible_w_zoom(fun_name), .subclass = dm_error_full("only_possible_w_zoom"))
}

error_txt_only_possible_w_zoom <- function(fun_name) {
  glue("You can't call `{fun_name}()` on an unzoomed `dm`. Consider using `dm_zoom_to()` first.")
}

# errors for `copy_to.dm()` ----------------------------------------------

abort_only_data_frames_supported <- function() {
  abort("`copy_to.dm()` only supports class `data.frame` for argument `df`", .subclass = dm_error_full("only_data_frames_supported"))
}

abort_one_name_for_copy_to <- function(name) {
  abort(glue("Argument `name` in `copy_to.dm()` needs to have length 1, but has length {length(name)} ({commas(tick(name))})"),
    .subclass = dm_error_full("one_name_for_copy_to")
  )
}

# table for which key should be set not in list of tables when creating dm -----------------------

abort_unnamed_table_list <- function() {
  abort(error_txt_unnamed_table_list(), .subclass = dm_error_full("unnamed_table_list"))
}

error_txt_unnamed_table_list <- function() {
  "Table list in `new_dm()` needs to be named."
}

# new table name needs to be unique ---------------------------------------

abort_need_unique_names <- function(duplicate_names) {
  abort(error_txt_need_unique_names(unique(duplicate_names)), .subclass = dm_error_full("need_unique_names"))
}

error_txt_need_unique_names <- function(duplicate_names) {
  glue(
    "Each new table needs to have a unique name. Duplicate new name(s): ",
    "{commas(tick(duplicate_names))}."
  )
}

# lost track of by-column (FK-relation) -----------------------------------

abort_fk_not_tracked <- function(x_orig_name, y_name) {
  abort(error_txt_fk_not_tracked(x_orig_name, y_name), .subclass = dm_error_full("fk_not_tracked"))
}

error_txt_fk_not_tracked <- function(x_orig_name, y_name) {
  glue(
    "The foreign key that existed between the originally zoomed table {tick(x_orig_name)} ",
    "and {tick(y_name)} got lost in transformations. Please explicitly provide the `by` argument."
  )
}

# lost track of PK-column(s) -----------------------------------

abort_pk_not_tracked <- function(orig_table, orig_pk) {
  abort(error_txt_pk_not_tracked(orig_table, orig_pk), .subclass = dm_error_full("pk_not_tracked"))
}

error_txt_pk_not_tracked <- function(orig_table, orig_pk) {
  glue(
    "The primary key column(s) {commas(tick(orig_pk))} of the originally zoomed table {tick(orig_table)} got lost ",
    "in transformations. Therefore it is not possible to use `nest.zoomed_dm()`."
  )
}


# only for local src ------------------------------------------------------

abort_only_for_local_src <- function(src_dm) {
  abort(error_txt_only_for_local_src(format_classes(class(src_dm))), .subclass = dm_error_full("only_for_local_src"))
}

error_txt_only_for_local_src <- function(src_class) {
  glue("`nest_join.zoomed_dm()` works only for a local `src`, not on a database with `src`-class: {src_class}.")
}

# dm invalid --------------------------------------------------------------

abort_dm_invalid <- function(why) {
  abort(error_txt_dm_invalid(why), .subclass = dm_error_full("dm_invalid"))
}

error_txt_dm_invalid <- function(why) {
  glue("This `dm` is invalid, reason: {why}")
}


# Errors for `pull_tbl.dm()` -----------------------------

abort_no_table_provided <- function() {
  abort(error_txt_no_table_provided(), .subclass = dm_error_full("no_table_provided"))
}

error_txt_no_table_provided <- function() {
  "Argument `table` for `pull_tbl.dm()` missing."
}

abort_table_not_zoomed <- function(table_name, zoomed_tables) {
  abort(error_txt_table_not_zoomed(table_name, zoomed_tables), .subclass = dm_error_full("table_not_zoomed"))
}

error_txt_table_not_zoomed <- function(table_name, zoomed_tables) {
  glue(
    "In `pull_tbl.zoomed_dm`: Table {tick(table_name)} not zoomed, ",
    "zoomed tables: {commas(tick(zoomed_tables))}."
  )
}

abort_not_pulling_multiple_zoomed <- function() {
  abort(error_txt_not_pulling_multiple_zoomed(), .subclass = dm_error_full("not_pulling_multiple_zoomed"))
}

error_txt_not_pulling_multiple_zoomed <- function() {
  "If more than 1 zoomed table is available you need to specify argument `table` in `pull_tbl.zoomed_dm()`."
}

abort_cols_not_avail <- function(wrong_col) {
  abort(error_txt_cols_not_avail(wrong_col), .subclass = dm_error_full("cols_not_avail"))
}

error_txt_cols_not_avail <- function(wrong_col) {
  glue(
    "The color(s) {commas(tick(wrong_col))} are not ",
    "available. Call `dm_get_available_colors()` for possible color names or use hex color codes."
  )
}

abort_only_named_args <- function(fun_name, name_meaning) {
  abort(error_txt_only_named_args(fun_name, name_meaning), .subclass = dm_error_full("only_named_args"))
}

error_txt_only_named_args <- function(fun_name, name_meaning) {
  glue(
    "All `...` arguments to function {tick(paste0(fun_name, '()'))} must be named. ",
    "The names represent {name_meaning}."
  )
}

abort_wrong_syntax_set_cols <- function() {
  abort(error_txt_wrong_syntax_set_cols(), .subclass = dm_error_full("wrong_syntax_set_cols"))
}

error_txt_wrong_syntax_set_cols <- function() {
  "You seem to be using outdated syntax for `dm_set_colors()`, type `?dm_set_colors()` for examples."
}

abort_temp_table_requested <- function(table_names, tbls_in_dm) {
  abort(error_txt_temp_table_requested(table_names, tbls_in_dm), .subclass = dm_error_full("temp_table_requested"))
}

error_txt_temp_table_requested <- function(table_names, tbls_in_dm) {
  temp_tables <- setdiff(table_names, tbls_in_dm)
  glue(
    "The following requested tables from the DB are temporary tables and can't be included in the result: ",
    "{commas(tick(temp_tables))}."
  )
}

abort_parameter_not_correct_class <- function(parameter, correct_class, class) {
  abort(error_txt_parameter_not_correct_class(
    parameter,
    correct_class,
    class),
    .subclass = dm_error_full("parameter_not_correct_class")
  )
}

error_txt_parameter_not_correct_class <- function(parameter, correct_class, class) {
  glue(
    "Parameter {tick(parameter)} needs to be of class {tick(correct_class)} but is of class {format_classes(class)}."
  )
}

abort_parameter_not_correct_length <- function(parameter, correct_length, parameter_value) {
  abort(error_txt_parameter_not_correct_length(
    parameter,
    correct_length,
    parameter_value),
    .subclass = dm_error_full("parameter_not_correct_length")
  )
}

error_txt_parameter_not_correct_length <- function(parameter, correct_length, parameter_value) {
  glue(
    "Parameter {tick(parameter)} needs to be of length {tick(correct_length)} but is ",
    "of length {as.character(length(parameter_value))} ({commas(tick(parameter_value))})."
  )
}

warn_if_not_null <- function(arg, arg_name = deparse(substitute(arg)), only_on = c("MSSQL", "Postgres")) {
  if (!is.null(arg)) {
    dm_warn(
      glue::glue(
        "Argument {tick(arg_name)} ignored: currently only supported for {paste0(only_on, collapse = ' and ')}."
      ), class = "non_null_param"
    )
  }
  NULL
}

# Errors for schema handling functions ------------------------------------

abort_schema_exists <- function(schema, dbname = NULL) {
  abort(error_txt_schema_exists(schema, dbname),
    .subclass = dm_error_full("schema_exists")
  )
}

error_txt_schema_exists <- function(schema, dbname) {
  if (!is_null(dbname)) {
    msg_suffix <- paste0(" on database ", tick(dbname))
  } else {
    msg_suffix <- ""
  }
  glue(
    "A schema named {tick(schema)} already exists{msg_suffix}."
  )
}

abort_no_schema_exists <- function(schema, dbname = NULL) {
  abort(error_txt_no_schema_exists(schema, dbname),
        .subclass = dm_error_full("no_schema_exists")
  )
}

error_txt_no_schema_exists <- function(schema, dbname) {
  if (!is_null(dbname)) {
    msg_suffix <- paste0(" on database ", tick(dbname))
  } else {
    msg_suffix <- ""
  }
  glue(
    "No schema named {tick(schema)} exists{msg_suffix}."
  )
}

abort_schema_not_empty <- function(schema, dbname = NULL) {
  abort(error_txt_schema_not_empty(schema, dbname),
        .subclass = dm_error_full("schema_not_empty")
  )
}

error_txt_schema_not_empty <- function(schema, dbname) {
  if (!is_null(dbname)) {
    msg_infix <- paste0(" on database ", tick(dbname))
  } else {
    msg_infix <- ""
  }
  glue(
    "Schema {tick(schema)}{msg_infix} needs to be empty before it can be dropped."
  )
}
