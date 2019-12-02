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
cdm_get_filter <- new_cdm_forward(dm_get_filter)

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
cdm_copy_to <- new_cdm_forward(dm_copy_to)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_disambiguate_cols <- new_cdm_forward(dm_disambiguate_cols)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_set_colors <- new_cdm_forward(dm_set_colors)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_get_colors <- new_cdm_forward(dm_get_colors)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_get_available_colors <- new_cdm_forward(dm_get_available_colors)

#' @rdname deprecated
#' @keywords internal
#' @export
# FIXME: name of table comes from {{ table }}, which is not available anymore
# when passed by `new_cdm_forward(dm_filter)`
cdm_filter <- function(dm, table, ...) {
  deprecate_soft("0.1.0", paste0("dm::cdm_filter()"))
  cdm_zoom_to_tbl(dm, {{ table }}) %>%
  filter(...) %>%
  cdm_update_zoomed_tbl()
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_nrow <- new_cdm_forward(dm_nrow)

#' @rdname deprecated
#' @keywords internal
#' @export
# FIXME: name of `start` comes from {{ start }} (deparse(substitute()), which is not available anymore
# when passed by `new_cdm_forward(dm_flatten_to_tbl)`
cdm_flatten_to_tbl <- function(dm, start, ..., join = left_join) {
  join_name <- deparse(substitute(join))
  start <- as_string(ensym(start))
  dm_flatten_to_tbl_impl(dm, start, ..., join = join, join_name = join_name, squash = FALSE)
}

#' @rdname deprecated
#' @keywords internal
#' @export
# FIXME: name of `table_1` (etc.) comes from {{ table_1 }} (deparse(substitute()), which is not available anymore
# when passed by `new_cdm_forward(dm_join_to_tbl)`
cdm_join_to_tbl <- function(dm, table_1, table_2, join = left_join) {
  force(join)
  stopifnot(is_function(join))
  join_name <- deparse(substitute(join))

  t1_name <- as_string(ensym(table_1))
  t2_name <- as_string(ensym(table_2))

  rel <- parent_child_table(dm, {{ table_1 }}, {{ table_2 }})
  start <- rel$child_table
  other <- rel$parent_table

  dm_flatten_to_tbl_impl(dm, start, !!other, join = join, join_name = join_name, squash = FALSE)
}
