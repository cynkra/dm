# Cf. https://github.com/cynkra/dm/issues/144 (Review error messages)

# error call infrastructure -----------------------------------------------

# Call in exported functions to mark them as the error origin.
# Similar to dplyr:::dplyr_local_error_call().
dm_local_error_call <- function(call = frame, frame = caller_env()) {
  frame$.__dm_error_call__. <- call
  invisible(NULL)
}

# Call in internal functions to retrieve the error call.
# Similar to dplyr:::dplyr_error_call().
dm_error_call <- function(call) {
  if (is_missing(call)) {
    call <- caller_env()
  }

  # Walk up the call stack to find the exported function that set
  # .__dm_error_call__. via dm_local_error_call().
  frame <- call
  n <- sys.nframe()
  for (i in seq_len(n)) {
    caller <- eval_bare(quote(base::parent.frame()), frame)
    if (
      identical(caller, frame) ||
        identical(caller, global_env()) ||
        identical(caller, base_env()) ||
        identical(caller, empty_env())
    ) {
      break
    }
    caller_call <- caller[[".__dm_error_call__."]]
    if (!is_null(caller_call)) {
      call <- caller_call
      break
    }
    frame <- caller
  }

  call
}

# error class generator ---------------------------------------------------

dm_error <- function(x) {
  paste0("dm_error_", x)
}

dm_error_full <- function(x) {
  c(dm_error(x), "dm_error")
}

dm_abort <- function(bullets, class) {
  cli::cli_abort(bullets, class = dm_error_full(class), call = dm_error_call())
}

dm_warning <- function(x) {
  paste0("dm_warning_", x)
}

dm_warning_full <- function(x) {
  c(dm_warning(x), "dm_warning")
}

dm_warn <- function(bullets, class) {
  cli::cli_warn(bullets, class = dm_warning_full(class))
}

# abort and text for key-helper functions ---------------------------------

abort_not_unique_key <- function(table_name, column_names) {
  cli::cli_abort(
    "({commas(tick(column_names))}) not a unique key of {.code {table_name}}.",
    class = dm_error_full("not_unique_key"),
    call = dm_error_call()
  )
}

# error: is not subset of -------------------------------------------------

abort_not_subset_of <- function(table_name_1, colname_1, table_name_2, colname_2) {
  plural <- s_if_plural(colname_1)
  cli::cli_abort(
    "Column{plural['n']} ({commas(tick(colname_1))}) of table {.field {table_name_1}} contain{plural['v']} values (see examples above) that are not present in column{plural['n']} ({commas(tick(colname_2))}) of table {.field {table_name_2}}.",
    class = dm_error_full("not_subset_of"),
    call = dm_error_call()
  )
}

# error sets not equal ----------------------------------------------------

abort_sets_not_equal <- function(error_msgs) {
  cli::cli_abort(error_msgs, class = dm_error_full("sets_not_equal"), call = dm_error_call())
}

# cardinality check errors ------------------------------------------------

abort_not_bijective <- function(child_table_name, fk_col_name) {
  plural <- s_if_plural(fk_col_name)
  cli::cli_abort(
    "1..1 cardinality (bijectivity) is not given: Column{plural['n']} ({commas(tick(fk_col_name))}) in table {.field {child_table_name}} contain{plural['v']} duplicate values.",
    class = dm_error_full("not_bijective"),
    call = dm_error_call()
  )
}

abort_not_injective <- function(child_table_name, fk_col_name) {
  plural <- s_if_plural(fk_col_name)
  cli::cli_abort(
    "0..1 cardinality (injectivity from child table to parent table) is not given: Column{plural['n']} ({commas(tick(fk_col_name))}) in table {.field {child_table_name}} contain{plural['v']} duplicate values.",
    class = dm_error_full("not_injective"),
    call = dm_error_call()
  )
}

# errors in fk handling --------------------------------------------------

abort_ref_tbl_has_no_pk <- function(ref_table_name) {
  cli::cli_abort(
    "ref_table {.field {ref_table_name}} needs a primary key first. Use {.fn dm_enum_pk_candidates} to find appropriate columns and {.fn dm_add_pk} to define a primary key.",
    class = dm_error_full("ref_tbl_has_no_pk"),
    call = dm_error_call()
  )
}

# error helpers for draw_dm -----------------------------------------------

abort_last_col_missing <- function() {
  cli::cli_abort(
    "The last color can't be missing.",
    class = dm_error_full("last_col_missing"),
    call = dm_error_call()
  )
}

# errors in graph-functions -----------------------------------------------

abort_no_cycles <- function(g) {
  shortest_cycle <-
    graph_girth(g) %>%
    pluck("circle") %>%
    names()
  # add the first element after the last element, so it's more clear that it's a cycle
  shortest_cycle <- paste(c(shortest_cycle, shortest_cycle[1]), collapse = " -> ")
  # FIXME: extract, also identify parallel edges as circles
  cli::cli_abort(
    c(
      "Cycles in the relationship graph not yet supported.",
      i = "Shortest cycle: {shortest_cycle}"
    ),
    class = dm_error_full("no_cycles"),
    call = dm_error_call()
  )
}

# error in dm_flatten_to_tbl() ----------------------------------------------

abort_tables_not_reachable_from_start <- function(table_arg = ".start") {
  cli::cli_abort(
    "All selected tables must be reachable from {.arg {table_arg}}.",
    class = dm_error_full("tables_not_reachable_from_start"),
    call = dm_error_call()
  )
}

# errors in table surgery -------------------------------------------------

abort_dupl_new_id_col_name <- function(table_name) {
  cli::cli_abort(
    "{.arg new_id_column} can't have an identical name as one of the columns of {.field {table_name}}.",
    class = dm_error_full("dupl_new_id_col_name"),
    call = dm_error_call()
  )
}

abort_no_overwrite <- function() {
  cli::cli_abort(
    "The {.arg overwrite} argument is not supported.",
    class = dm_error_full("no_overwrite"),
    call = dm_error_call()
  )
}

abort_update_not_supported <- function() {
  cli::cli_abort(
    "Updating {.cls dm} objects not supported.",
    class = dm_error_full("update_not_supported"),
    call = dm_error_call()
  )
}

# errors when filters are set but they shouldn't be ------------------------------

abort_only_possible_wo_filters <- function(fun_name) {
  cli::cli_abort(
    "Not supported on a {.cls dm} with filter conditions. Consider using {.fn dm_apply_filters} first.",
    class = dm_error_full("only_possible_wo_filters"),
    call = dm_error_call()
  )
}

# no foreign key relation -------------------------------------------------

abort_tables_not_neighbors <- function(t1_name, t2_name) {
  cli::cli_abort(
    "Tables {.field {t1_name}} and {.field {t2_name}} are not directly linked by a foreign key relation.",
    class = dm_error_full("tables_not_neighbors"),
    call = dm_error_call()
  )
}

# `dm_flatten_to_tbl()` and `dm_join_to_tbl()` only supported for parents

abort_only_parents <- function(func, table_arg, recursive_arg) {
  cli::cli_abort(
    "All join partners of table {.arg {table_arg}} must be its direct neighbors. Use {.code {recursive_arg} = TRUE} for recursive flattening.",
    class = dm_error_full("only_parents"),
    call = dm_error_call()
  )
}

# not all tables have the same src ----------------------------------------

abort_not_same_src <- function(dm_bind = FALSE) {
  if (!dm_bind) {
    cli::cli_abort(
      "Not all tables in the object share the same {.arg src}.",
      class = dm_error_full("not_same_src"),
      call = dm_error_call()
    )
  } else {
    cli::cli_abort(
      "All {.cls dm} objects need to share the same {.arg src}.",
      class = dm_error_full("not_same_src"),
      call = dm_error_call()
    )
  }
}

# Something other than tables are put in a `dm` ------------------

abort_what_a_weird_object <- function(class) {
  cli::cli_abort(
    "Don't know how to determine table source for object of class {.cls {class}}.",
    class = dm_error_full("what_a_weird_object"),
    call = dm_error_call()
  )
}

abort_squash_limited <- function(func = "dm_flatten_to_tbl", recursive_arg = ".recursive") {
  cli::cli_abort(
    "Recursive flattening only supports {.fn left_join}, {.fn inner_join}, or {.fn full_join}.",
    class = dm_error_full("squash_limited"),
    call = dm_error_call()
  )
}

abort_apply_filters_first <- function(join_name) {
  cli::cli_abort(
    "{.fn dm_..._to_tbl} with join using {.fn {join_name}} generally wouldn't produce the correct result when filters are set. Please consider calling {.fn dm_apply_filters} first.",
    class = dm_error_txt_apply_filters_first(join_name),
    call = dm_error_call()
  )
}

dm_error_txt_apply_filters_first <- function(join_name) {
  dm_error(c(paste0("apply_filters_first_", join_name), "apply_filters_first"))
}

abort_no_flatten_with_nest_join <- function(func = "dm_..._to_tbl") {
  cli::cli_abort(
    "{.code join = nest_join} is not supported. Consider {.code join = left_join}.",
    class = dm_error_full("no_flatten_with_nest_join"),
    call = dm_error_call()
  )
}


# object is not a `dm` (but should be one) --------------------------------
abort_is_not_dm <- function(obj_class) {
  cli::cli_abort(
    "Required class {.cls dm} but instead is {.cls {obj_class}}.",
    class = dm_error_full("is_not_dm"),
    call = dm_error_call()
  )
}


# local `dm` has no con ---------------------------------------------------
abort_con_only_for_dbi <- function() {
  cli::cli_abort(
    "A local {.cls dm} doesn't have a DB connection.",
    class = dm_error_full("con_only_for_dbi"),
    call = dm_error_call()
  )
}

# when zoomed and it shouldn't be ------------------------------

abort_only_possible_wo_zoom <- function(fun_name) {
  cli::cli_abort(
    "Not supported on a {.cls dm_zoomed}. Consider using one of {.fn dm_update_zoomed}, {.fn dm_insert_zoomed} or {.fn dm_discard_zoomed} first.",
    class = dm_error_full("only_possible_wo_zoom"),
    call = dm_error_call()
  )
}

# when not zoomed and it should be ------------------------------

abort_only_possible_w_zoom <- function(fun_name) {
  cli::cli_abort(
    "Not supported on an unzoomed {.cls dm}. Consider using {.fn dm_zoom_to} first.",
    class = dm_error_full("only_possible_w_zoom"),
    call = dm_error_call()
  )
}

# errors for `copy_to.dm()` ----------------------------------------------

abort_only_data_frames_supported <- function() {
  cli::cli_abort(
    "Only class {.cls data.frame} is supported for argument {.arg df}.",
    class = dm_error_full("only_data_frames_supported"),
    call = dm_error_call()
  )
}

abort_one_name_for_copy_to <- function(name) {
  cli::cli_abort(
    "Argument {.arg name} must have length 1, not length {length(name)}.",
    class = dm_error_full("one_name_for_copy_to"),
    call = dm_error_call()
  )
}

# new table name needs to be unique ---------------------------------------

abort_need_unique_names <- function(duplicate_names) {
  dupl <- unique(duplicate_names)
  cli::cli_abort(
    "{cli::qty(length(dupl))}Each new table needs to have a unique name. Duplicate new name{?s}: {.field {dupl}}.",
    class = dm_error_full("need_unique_names"),
    call = dm_error_call()
  )
}

# lost track of by-column (FK-relation) -----------------------------------

abort_fk_not_tracked <- function(x_orig_name, y_name) {
  cli::cli_abort(
    "The foreign key that existed between the originally zoomed table {.field {x_orig_name}} and {.field {y_name}} got lost in transformations. Please explicitly provide the {.arg by} argument.",
    class = dm_error_full("fk_not_tracked"),
    call = dm_error_call()
  )
}

# lost track of PK-column(s) -----------------------------------

abort_pk_not_tracked <- function(orig_table, orig_pk) {
  cli::cli_abort(
    "The primary key column(s) {commas(tick(orig_pk))} of the originally zoomed table {.field {orig_table}} got lost in transformations.",
    class = dm_error_full("pk_not_tracked"),
    call = dm_error_call()
  )
}


# only for local src ------------------------------------------------------

abort_only_for_local_src <- function(src_dm) {
  cli::cli_abort(
    "Only supported for a local {.arg src}, not on a database with {.arg src}-class: {.cls {class(src_dm)}}.",
    class = dm_error_full("only_for_local_src"),
    call = dm_error_call()
  )
}

# Errors for `pull_tbl.dm()` -----------------------------

abort_no_table_provided <- function() {
  cli::cli_abort(
    "Argument {.arg table} is missing.",
    class = dm_error_full("no_table_provided"),
    call = dm_error_call()
  )
}

abort_table_not_zoomed <- function(table_name, zoomed_tables) {
  cli::cli_abort(
    "Table {.code {table_name}} not zoomed, zoomed tables: {.code {zoomed_tables}}.",
    class = dm_error_full("table_not_zoomed"),
    call = dm_error_call()
  )
}

abort_not_pulling_multiple_zoomed <- function() {
  cli::cli_abort(
    "If more than one zoomed table is available, you need to specify argument {.arg table}.",
    class = dm_error_full("not_pulling_multiple_zoomed"),
    call = dm_error_call()
  )
}

abort_cols_not_avail <- function(wrong_col) {
  cli::cli_abort(
    "{cli::qty(length(wrong_col))}The color{?s} {.val {wrong_col}} {?is/are} not available. Call {.fn dm_get_available_colors} for possible color names or use hex color codes.",
    class = dm_error_full("cols_not_avail"),
    call = dm_error_call()
  )
}

abort_only_named_args <- function(fun_name, name_meaning) {
  cli::cli_abort(
    "All {.arg ...} arguments must be named. The names represent {name_meaning}.",
    class = dm_error_full("only_named_args"),
    call = dm_error_call()
  )
}

abort_wrong_syntax_set_cols <- function() {
  cli::cli_abort(
    "You seem to be using outdated syntax for setting colors, type {.code ?dm_set_colors()} for examples.",
    class = dm_error_full("wrong_syntax_set_cols"),
    call = dm_error_call()
  )
}

abort_parameter_not_correct_class <- function(parameter, correct_class, class) {
  cli::cli_abort(
    "Parameter {.arg {parameter}} needs to be of class {.cls {correct_class}} but is of class {.cls {class}}.",
    class = dm_error_full("parameter_not_correct_class"),
    call = dm_error_call()
  )
}

abort_parameter_not_correct_length <- function(parameter, correct_length, parameter_value) {
  cli::cli_abort(
    "Argument {.arg {parameter}} needs to be of length {.val {correct_length}} but is of length {.val {length(parameter_value)}} ({.val {parameter_value}}).",
    class = dm_error_full("parameter_not_correct_length"),
    call = dm_error_call()
  )
}

warn_if_arg_not <- function(
  arg,
  only_on,
  arg_name = deparse(substitute(arg)),
  correct = NULL,
  additional_msg = ""
) {
  if (!identical(arg, correct)) {
    only_on_string <- glue::glue_collapse(only_on, sep = ", ", last = " and ")
    msg <- cli::format_inline(
      "Argument {.arg {arg_name}} ignored: currently only supported for {only_on_string}."
    )
    dm_warn(
      c(msg, if (!is.null(additional_msg) && nzchar(additional_msg)) c(i = additional_msg)),
      class = "arg_not"
    )
  }
  NULL
}

# Errors for schema handling functions ------------------------------------

abort_no_schemas_supported <- function(dbms = NULL, con = NULL) {
  if (!is.null(dbms)) {
    cli::cli_abort(
      "The concept of schemas is not supported for DBMS {.code {dbms}}.",
      class = dm_error_full("no_schemas_supported"),
      call = dm_error_call()
    )
  } else if (!is.null(con)) {
    cli::cli_abort(
      "Currently schemas are not supported for a connection of class {.cls {class(con)}}.",
      class = dm_error_full("no_schemas_supported"),
      call = dm_error_call()
    )
  } else {
    # if local src, `con = NULL`
    cli::cli_abort(
      "Schemas are not available locally.",
      class = dm_error_full("no_schemas_supported"),
      call = dm_error_call()
    )
  }
}

abort_temporary_not_in_schema <- function() {
  cli::cli_abort(
    "If argument {.arg temporary} is {.val {TRUE}}, argument {.arg schema} has to be {.val {I('NULL')}}.",
    class = dm_error_full("temporary_not_in_schema"),
    call = dm_error_call()
  )
}

abort_one_of_schema_table_names <- function() {
  cli::cli_abort(
    "Only one of the arguments {.arg schema} and {.arg table_names} can be different from {.val {I('NULL')}}.",
    class = dm_error_full("one_of_schema_table_names"),
    call = dm_error_call()
  )
}

s_if_plural <- function(vec) {
  if (length(vec) > 1) {
    # n = noun, v = verb
    c(n = "s", v = "")
  } else {
    c(n = "", v = "s")
  }
}
