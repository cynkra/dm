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
# when passed by new_cdm_forward(dm_filter)
cdm_filter <- function(dm, table, ...) {
  deprecate_soft("0.1.0", paste0("dm::cdm_filter()"))
  cdm_zoom_to_tbl(dm, {{ table }}) %>%
  filter(...) %>%
  cdm_update_zoomed_tbl()
}
