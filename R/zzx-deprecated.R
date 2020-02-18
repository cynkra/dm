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
cdm_get_src <- new_cdm_forward(dm_get_src)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_get_con <- new_cdm_forward(dm_get_con)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_get_tables <- new_cdm_forward(dm_get_tables)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_get_filter <- new_cdm_forward(dm_get_filters, old_fwd_name = "cdm_get_filter")

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_add_tbl <- new_cdm_forward(dm_add_tbl)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_rm_tbl <- new_cdm_forward(dm_rm_tbl)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_copy_to <- new_cdm_forward(copy_dm_to, old_fwd_name = "cdm_copy_to")

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_disambiguate_cols <- new_cdm_forward(dm_disambiguate_cols)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_draw <- new_cdm_forward(dm_draw)

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
cdm_get_available_colors <- new_cdm_forward(dm_get_available_colors)

#' @rdname deprecated
#' @keywords internal
#' @export
# FIXME:
# when using `new_cdm_forward`: error
# when using `new_cdm_forward_2`: note in R CMD check
cdm_filter <- function(dm, table, ...) {
  deprecate_soft("0.1.0", "dm::cdm_filter()", "dm::dm_filter()")
  dm_zoom_to(dm, {{ table }}) %>%
    dm_filter_impl(..., set_filter = TRUE) %>%
    dm_update_zoomed()
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_nrow <- new_cdm_forward(dm_nrow)

#' @rdname deprecated
#' @keywords internal
#' @export
# FIXME: both `new_cdm_forward_2(dm_flatten_to_tbl)` and `new_cdm_forward_2(dm_flatten_to_tbl)` don't work
cdm_flatten_to_tbl <- function(dm, start, ..., join = left_join) {
  deprecate_soft("0.1.0", "dm::cdm_flatten_to_tbl()", "dm::dm_flatten_to_tbl()")
  join_name <- deparse(substitute(join))
  start <- as_string(ensym(start))
  dm_flatten_to_tbl_impl(dm, start, ..., join = join, join_name = join_name, squash = FALSE)
}

#' @rdname deprecated
#' @keywords internal
#' @export
# FIXME: both `new_cdm_forward_2(dm_squash_to_tbl)` and `new_cdm_forward_2(dm_squash_to_tbl)` don't work
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
# FIXME: both `new_cdm_forward_2(dm_join_to_tbl)` and `new_cdm_forward_2(dm_join_to_tbl)` don't work
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
cdm_apply_filters <- new_cdm_forward(dm_apply_filters)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_apply_filters_to_tbl <- new_cdm_forward_2(dm_apply_filters_to_tbl)

#' @rdname deprecated
#' @keywords internal
#' @export
# FIXME: neither `new_cdm_forward_2(dm_add_pk)` nor `new_cdm_forward_2(dm_add_pk)` work
cdm_add_pk <- function(dm, table, column, check = FALSE, force = FALSE) {
  deprecate_soft("0.1.0", "dm::cdm_add_pk()", "dm::dm_add_pk()")
  dm_add_pk(dm, {{ table }}, {{ column }}, check, force)
}

#' @rdname deprecated
#' @keywords internal
#' @export
# FIXME: neither `new_cdm_forward_2(dm_add_fk)` nor `new_cdm_forward_2(dm_add_fk)` work
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
cdm_get_all_fks <- new_cdm_forward(dm_get_all_fks_impl, old_fwd_name = "cdm_get_all_fks", new_name = "dm_get_all_fks")

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
cdm_check_constraints <- new_cdm_forward(
  dm_examine_constraints_impl,
  old_fwd_name = "cdm_check_constraints",
  new_name = "dm_examine_constraints"
)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_nycflights13 <- new_cdm_forward(dm_nycflights13)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_paste <- new_cdm_forward(dm_paste)

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
cdm_get_all_pks <- new_cdm_forward(dm_get_all_pks_impl, old_fwd_name = "cdm_get_all_pks", new_name = "dm_get_all_pks")

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
cdm_select_tbl <- new_cdm_forward(dm_select_tbl)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_rename_tbl <- new_cdm_forward(dm_rename_tbl)

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
cdm_update_zoomed_tbl <- new_cdm_forward(dm_update_zoomed, old_fwd_name = "cdm_update_zoomed_tbl")

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_zoom_out <- new_cdm_forward(dm_discard_zoomed, old_fwd_name = "cdm_zoom_out")
