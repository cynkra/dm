#' @rdname deprecated
#' @keywords internal
#' @export
check_if_subset <- new_cdm_forward_2(check_subset, old_fwd_name = "check_if_subset")

#' @rdname deprecated
#' @keywords internal
#' @export
check_cardinality <- new_cdm_forward_2(examine_cardinality)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_get_src <- function(x) {
  deprecate_soft("0.1.0", "dm::cdm_get_src()", "dm::dm_get_src()")
  dm_get_src(x = x)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_get_con <- function(x) {
  deprecate_soft("0.1.0", "dm::cdm_get_con()", "dm::dm_get_con()")
  dm_get_con(x = x)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_get_tables <- function(x) {
  deprecate_soft("0.1.0", "dm::cdm_get_tables()", "dm::dm_get_tables()")
  dm_get_tables(x = x)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_get_filter <- function(x) {
  deprecate_soft("0.1.0", "dm::cdm_get_filter()", "dm::dm_get_filters()")
  dm_get_filters(x = x)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_add_tbl <- function(dm, ..., repair = "unique", quiet = FALSE) {
  deprecate_soft("0.1.0", "dm::cdm_add_tbl()", "dm::dm_add_tbl()")
  dm_add_tbl(dm = dm, ... = ..., repair = repair, quiet = quiet)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_rm_tbl <- function(dm, ...) {
  deprecate_soft("0.1.0", "dm::cdm_rm_tbl()", "dm::dm_rm_tbl()")
  dm_rm_tbl(dm = dm, ... = ...)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_copy_to <- function(dest, dm, ..., types = NULL, overwrite = NULL, indexes = NULL,
                        unique_indexes = NULL, set_key_constraints = TRUE, unique_table_names = FALSE,
                        table_names = NULL, temporary = TRUE) {
  deprecate_soft("0.1.0", "dm::cdm_copy_to()", "dm::copy_dm_to()")
  copy_dm_to(
    dest = dest, dm = dm, ... = ..., types = types,
    overwrite = overwrite, indexes = indexes, unique_indexes = unique_indexes,
    set_key_constraints = set_key_constraints, unique_table_names = unique_table_names,
    table_names = table_names, temporary = temporary
  )
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_disambiguate_cols <- function(dm, sep = ".", quiet = FALSE) {
  deprecate_soft("0.1.0", "dm::cdm_disambiguate_cols()", "dm::dm_disambiguate_cols()")
  dm_disambiguate_cols(dm = dm, sep = sep, quiet = quiet)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_draw <- function(dm, rankdir = "LR", col_attr = "column", view_type = "keys_only",
                     columnArrows = TRUE, graph_attrs = "", node_attrs = "", edge_attrs = "",
                     focus = NULL, graph_name = "Data Model") {
  deprecate_soft("0.1.0", "dm::cdm_draw()", "dm::dm_draw()")
  dm_draw(
    dm = dm, rankdir = rankdir, col_attr = col_attr,
    view_type = view_type, columnArrows = columnArrows, graph_attrs = graph_attrs,
    node_attrs = node_attrs, edge_attrs = edge_attrs, focus = focus,
    graph_name = graph_name
  )
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_set_colors <- function(dm, ...) {
  deprecate_soft("0.1.0", "dm::cdm_set_colors()", "dm::dm_set_colors()")
  display <- color_quos_to_display(...)
  dm_set_colors(dm, !!!display)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_get_colors <- function(dm) {
  deprecate_soft("0.1.0", "dm::cdm_get_colors()", "dm::dm_get_colors()")
  prep_recode(dm_get_colors(dm))
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_get_available_colors <- function() {
  deprecate_soft(
    "0.1.0", "dm::cdm_get_available_colors()",
    "dm::dm_get_available_colors()"
  )
  dm_get_available_colors()
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_filter <- function(dm, table, ...) {
  deprecate_soft("0.1.0", "dm::cdm_filter()", "dm::dm_filter()")
  dm_zoom_to(dm, {{ table }}) %>%
    dm_filter_impl(..., set_filter = TRUE) %>%
    dm_update_zoomed()
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_nrow <- function(dm) {
  deprecate_soft("0.1.0", "dm::cdm_nrow()", "dm::dm_nrow()")
  dm_nrow(dm = dm)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_flatten_to_tbl <- function(dm, start, ..., join = left_join) {
  deprecate_soft("0.1.0", "dm::cdm_flatten_to_tbl()", "dm::dm_flatten_to_tbl()")
  join_name <- deparse(substitute(join))
  start <- as_string(ensym(start))
  dm_flatten_to_tbl_impl(dm, start, ..., join = join, join_name = join_name, squash = FALSE)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_squash_to_tbl <- function(dm, start, ..., join = left_join) {
  deprecate_soft("0.1.0", "dm::cdm_squash_to_tbl()", "dm::dm_squash_to_tbl()")
  join_name <- deparse(substitute(join))
  if (!(join_name %in% c("left_join", "full_join", "inner_join"))) abort_squash_limited()
  start <- as_string(ensym(start))
  dm_flatten_to_tbl_impl(dm, start, ..., join = join, join_name = join_name, squash = TRUE)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_join_to_tbl <- function(dm, table_1, table_2, join = left_join) {
  force(join)
  deprecate_soft("0.1.0", "dm::cdm_join_to_tbl()", "dm::dm_join_to_tbl()")
  stopifnot(is_function(join))
  join_name <- deparse(substitute(join))

  t1_name <- as_string(ensym(table_1))
  t2_name <- as_string(ensym(table_2))

  rel <- parent_child_table(dm, {{ table_1 }}, {{ table_2 }})
  start <- rel$child_table
  other <- rel$parent_table

  dm_flatten_to_tbl_impl(dm, start, !!other, join = join, join_name = join_name, squash = FALSE)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_apply_filters <- function(dm) {
  deprecate_soft("0.1.0", "dm::cdm_apply_filters()", "dm::dm_apply_filters()")
  dm_apply_filters(dm = dm)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_apply_filters_to_tbl <- new_cdm_forward_2(dm_apply_filters_to_tbl)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_add_pk <- function(dm, table, column, check = FALSE, force = FALSE) {
  deprecate_soft("0.1.0", "dm::cdm_add_pk()", "dm::dm_add_pk()")
  dm_add_pk(dm, {{ table }}, {{ column }}, check, force)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_add_fk <- function(dm, table, column, ref_table, check = FALSE) {
  deprecate_soft("0.1.0", "dm::cdm_add_fk()", "dm::dm_add_fk()")
  dm_add_fk(dm, {{ table }}, {{ column }}, {{ ref_table }}, check)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_has_fk <- new_cdm_forward_2(dm_has_fk)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_get_fk <- new_cdm_forward_2(dm_get_fk)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_get_all_fks <- function(dm) {
  deprecate_soft("0.1.0", "dm::cdm_get_all_fks()", "dm::dm_get_all_fks()")
  dm_get_all_fks_impl(dm = dm)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_rm_fk <- new_cdm_forward_2(dm_rm_fk)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_enum_fk_candidates <- new_cdm_forward_2(dm_enum_fk_candidates)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_is_referenced <- new_cdm_forward_2(dm_is_referenced)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_get_referencing_tables <- new_cdm_forward_2(dm_get_referencing_tables)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_learn_from_db <- function(dest) {
  deprecate_soft("0.1.0", "dm::cdm_learn_from_db()", "dm::dm_from_src()")
  dm_from_src(dest)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_check_constraints <- function(dm) {
  deprecate_soft("0.1.0", "dm::cdm_check_constraints()", "dm::dm_examine_constraints()")
  dm_examine_constraints_impl(dm = dm)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_nycflights13 <- function(cycle = FALSE, color = TRUE, subset = TRUE) {
  deprecate_soft("0.1.0", "dm::cdm_nycflights13()", "dm::dm_nycflights13()")
  dm_nycflights13(cycle = cycle, color = color, subset = subset)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_paste <- function(dm, select = FALSE, tab_width = 2) {
  deprecate_soft("0.1.0", "dm::cdm_paste()", "dm::dm_paste()")
  dm_paste(dm = dm, select = select, tab_width = tab_width)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_has_pk <- new_cdm_forward_2(dm_has_pk)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_get_pk <- new_cdm_forward_2(dm_get_pk)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_get_all_pks <- function(dm) {
  deprecate_soft("0.1.0", "dm::cdm_get_all_pks()", "dm::dm_get_all_pks()")
  dm_get_all_pks_impl(dm = dm)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_rm_pk <- new_cdm_forward_2(dm_rm_pk)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_enum_pk_candidates <- function(dm, table) {
  deprecate_soft("0.1.0", "dm::cdm_enum_pk_candidates()", "dm::dm_enum_pk_candidates()")
  check_no_filter(dm)

  table_name <- as_name(ensym(table))
  check_correct_input(dm, table_name)

  table <- dm_get_tables_impl(dm)[[table_name]]
  enum_pk_candidates_impl(table)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_select_tbl <- function(dm, ...) {
  deprecate_soft("0.1.0", "dm::cdm_select_tbl()", "dm::dm_select_tbl()")
  dm_select_tbl(dm = dm, ... = ...)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_rename_tbl <- function(dm, ...) {
  deprecate_soft("0.1.0", "dm::cdm_rename_tbl()", "dm::dm_rename_tbl()")
  dm_rename_tbl(dm = dm, ... = ...)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_select <- new_cdm_forward_2(dm_select)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_rename <- new_cdm_forward_2(dm_rename)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_zoom_to_tbl <- new_cdm_forward_2(dm_zoom_to, old_fwd_name = "cdm_zoom_to_tbl", new_name = "dm_zoom_to")

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_insert_zoomed_tbl <- new_cdm_forward_2(dm_insert_zoomed, old_fwd_name = "cdm_insert_zoomed_tbl")

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_update_zoomed_tbl <- function(dm) {
  deprecate_soft("0.1.0", "dm::cdm_update_zoomed_tbl()", "dm::dm_update_zoomed()")
  dm_update_zoomed(dm = dm)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_zoom_out <- function(dm) {
  deprecate_soft("0.1.0", "dm::cdm_zoom_out()", "dm::dm_discard_zoomed()")
  dm_discard_zoomed(dm = dm)
}
