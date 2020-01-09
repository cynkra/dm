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
cdm_draw <- function(
  dm,
  rankdir = "LR",
  col_attr = "column",
  view_type = "keys_only",
  columnArrows = TRUE,
  graph_attrs = "",
  node_attrs = "",
  edge_attrs = "",
  focus = NULL,
  graph_name = "Data Model") {

  deprecate_soft("0.1.0", "dm::cdm_draw()", "dm::dm_draw()")
  check_dm(dm)
  if (is_empty(dm)) {
    message("The dm cannot be drawn because it is empty.")
    return(invisible(NULL))
  }
  # FIXME: here the color scheme is set with an options(...)-call;
  # should have some schemes available for the user to choose from
  if (is_null(getOption("datamodelr.scheme"))) bdm_set_color_scheme(bdm_color_scheme)

  data_model <- dm_get_data_model(dm)

  graph <- bdm_create_graph(
    data_model,
    rankdir = rankdir,
    col_attr = col_attr,
    view_type = view_type,
    columnArrows = columnArrows,
    graph_attrs = graph_attrs,
    node_attrs = node_attrs,
    edge_attrs = edge_attrs,
    focus = focus,
    graph_name = graph_name,
    legacy = TRUE
  )
  bdm_render_graph(graph)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_set_colors <- function(dm, ...) {
  deprecate_soft("0.1.0", "dm::cdm_set_colors()", "dm::dm_set_colors()")
  display_df <- color_quos_to_display(...)

  def <-
    dm_get_def(dm) %>%
    left_join(display_df, by = "table") %>%
    mutate(display = coalesce(new_display, display)) %>%
    select(-new_display)

  new_dm3(def)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_get_colors <- nse(function(dm) {
  deprecate_soft("0.1.0", "dm::cdm_get_colors()", "dm::dm_get_colors()")
  dm_get_def(dm) %>%
    select(table, display) %>%
    as_tibble() %>%
    mutate(color = colors$dm[match(display, colors$datamodelr)]) %>%
    select(-display)
})

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
  deprecate_soft("0.1.0", "dm::cdm_filter()")
  dm_zoom_to_tbl(dm, {{ table }}) %>%
    filter(...) %>%
    dm_update_zoomed_tbl()
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
  deprecate_soft("0.1.0", "dm::cdm_flatten_to_tbl()")
  join_name <- deparse(substitute(join))
  start <- as_string(ensym(start))
  dm_flatten_to_tbl_impl(dm, start, ..., join = join, join_name = join_name, squash = FALSE)
}

#' @rdname deprecated
#' @keywords internal
#' @export
# FIXME: both `new_cdm_forward_2(dm_squash_to_tbl)` and `new_cdm_forward_2(dm_squash_to_tbl)` don't work
cdm_squash_to_tbl <- function(dm, start, ..., join = left_join) {
  deprecate_soft("0.1.0", "dm::dm_squash_to_tbl()")
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
  deprecate_soft("0.1.0", "dm::dm_join_to_tbl()")
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
  deprecate_soft("0.1.0", "dm::cdm_add_pk()")
  dm_add_pk(dm, {{ table }}, {{ column }}, check, force)
}

#' @rdname deprecated
#' @keywords internal
#' @export
# FIXME: neither `new_cdm_forward_2(dm_add_fk)` nor `new_cdm_forward_2(dm_add_fk)` work
cdm_add_fk <- function(dm, table, column, ref_table, check = FALSE) {
  deprecate_soft("0.1.0", "dm::cdm_add_fk()")
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
cdm_get_all_fks <- new_cdm_forward(dm_get_all_fks)

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
cdm_learn_from_db <- new_cdm_forward(dm_learn_from_db)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_check_constraints <- new_cdm_forward(dm_check_constraints)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_nycflights13 <- nse(function(cycle = FALSE, color = TRUE) {
  deprecate_soft('0.1.0', "dm::cdm_nycflights13()", "dm::dm_nycflights13()")

  dm <-
    dm_from_src(
      src_df("nycflights13")
    ) %>%
    dm_add_pk(planes, tailnum) %>%
    dm_add_pk(airlines, carrier) %>%
    dm_add_pk(airports, faa) %>%
    dm_add_fk(flights, tailnum, planes, check = FALSE) %>%
    dm_add_fk(flights, carrier, airlines) %>%
    dm_add_fk(flights, origin, airports)

  if (color) {
    dm <-
      dm %>%
      cdm_set_colors(
        flights = "blue",
        airports = ,
        planes = ,
        airlines = "orange",
        weather = "green"
      )
  }

  if (cycle) {
    dm <-
      dm %>%
      dm_add_fk(flights, dest, airports, check = FALSE)
  }

  dm
})

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
cdm_get_all_pks <- new_cdm_forward(dm_get_all_pks)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_rm_pk <- new_cdm_forward_2(dm_rm_pk)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_enum_pk_candidates <- new_cdm_forward_2(dm_enum_pk_candidates)

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
cdm_zoom_to_tbl <- new_cdm_forward_2(dm_zoom_to_tbl)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_insert_zoomed_tbl <- new_cdm_forward_2(dm_insert_zoomed_tbl)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_update_zoomed_tbl <- new_cdm_forward(dm_update_zoomed_tbl)

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_zoom_out <- new_cdm_forward(dm_zoom_out)
