#' @rdname deprecated
#' @keywords internal
#' @export
check_if_subset <- function(t1, c1, t2, c2) {
  deprecate_soft("0.1.0", "dm::check_if_subset()", "dm::check_subset()")
  t1q <- enquo(t1)
  t2q <- enquo(t2)
  c1q <- ensym(c1)
  c2q <- ensym(c2)
  if (is_subset(eval_tidy(t1q), !!c1q, eval_tidy(t2q), !!c2q)) {
    return(invisible(eval_tidy(t1q)))
  }
  v1 <- pull(eval_tidy(t1q), !!ensym(c1q))
  v2 <- pull(eval_tidy(t2q), !!ensym(c2q))
  setdiff_v1_v2 <- setdiff(v1, v2)
  print(filter(eval_tidy(t1q), !!c1q %in% setdiff_v1_v2))
  abort_not_subset_of(
    as_name(t1q), as_name(c1q), as_name(t2q),
    as_name(c2q)
  )
}

#' @rdname deprecated
#' @keywords internal
#' @export
check_cardinality <- function(parent_table, pk_column, child_table, fk_column) {
  deprecate_soft("0.1.0", "dm::check_cardinality()", "dm::examine_cardinality()")
  pt <- enquo(parent_table)
  pkc <- enexpr(pk_column)
  ct <- enquo(child_table)
  fkc <- enexpr(fk_column)
  if (!is_unique_key(eval_tidy(pt), !!pkc)$unique) {
    return(glue(
      "Column(s) {tick(commas(as_string(pkc)))} not ",
      "a unique key of {tick('parent_table')}."
    ))
  }
  if (!is_subset(!!ct, !!fkc, !!pt, !!pkc)) {
    return(glue(
      "Column(s) {tick(commas(as_string(fkc)))} of {tick('child_table')} not ",
      "a subset of column(s) {tick(commas(as_string(pkc)))} of {tick('parent_table')}."
    ))
  }
  min_1 <- is_subset(!!pt, !!pkc, !!ct, !!fkc)
  max_1 <- pull(is_unique_key(eval_tidy(ct), !!fkc), unique)
  if (min_1 && max_1) {
    return("bijective mapping (child: 1 -> parent: 1)")
  } else if (min_1) {
    return("surjective mapping (child: 1 to n -> parent: 1)")
  } else if (max_1) {
    return("injective mapping (child: 0 or 1 -> parent: 1)")
  }
  "generic mapping (child: 0 to n -> parent: 1)"
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_get_src <- function(x) {
  deprecate_soft("0.1.0", "dm::cdm_get_src()", "dm::dm_get_con()")
  check_not_zoomed(x)
  out <- dm_get_src_impl(x)
  if (is.null(out)) {
    out <- default_local_src()
  }
  out
}

default_local_src <- function() {
  structure(
    list(tbl_f = as_tibble, name = "<environment: R_GlobalEnv>", env = .GlobalEnv),
    class = c("src_local", "src")
  )
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_get_con <- function(x) {
  deprecate_soft("0.1.0", "dm::cdm_get_con()", "dm::dm_get_con()")
  dm_get_con(dm = x)
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
  dm_get_filters(dm = x)
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

  if (!is_null(unique_table_names)) {
    if (is.null(table_names) && temporary && !unique_table_names) {
      table_names <- identity
    }
  }

  copy_dm_to(
    dest = dest, dm = dm, ... = ..., types = types,
    overwrite = overwrite, indexes = indexes, unique_indexes = unique_indexes,
    set_key_constraints = set_key_constraints,
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
  dm %>%
    dm_zoom_to({{ table }}) %>%
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
  start <- dm_tbl_name(dm, {{ start }})
  dm_flatten_to_tbl_impl(dm, start, ..., join = join, join_name = join_name, squash = FALSE)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_squash_to_tbl <- function(dm, start, ..., join = left_join) {
  deprecate_soft("0.1.0", "dm::cdm_squash_to_tbl()", "dm::dm_squash_to_tbl()")
  join_name <- deparse(substitute(join))
  if (!(join_name %in% c("left_join", "full_join", "inner_join"))) abort_squash_limited()
  start <- dm_tbl_name(dm, {{ start }})
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

  t1_name <- dm_tbl_name(dm, {{ table_1 }})
  t2_name <- dm_tbl_name(dm, {{ table_2 }})

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
cdm_apply_filters_to_tbl <- function(dm, table) {
  deprecate_soft(
    "0.1.0", "dm::cdm_apply_filters_to_tbl()",
    "dm::dm_apply_filters_to_tbl()"
  )
  check_not_zoomed(dm)
  table_name <- dm_tbl_name(dm, {{ table }})
  dm_get_filtered_table(dm, table_name)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_add_pk <- function(dm, table, column, check = FALSE, force = FALSE) {
  deprecate_soft("0.1.0", "dm::cdm_add_pk()", "dm::dm_add_pk()")
  dm_add_pk(dm, {{ table }}, {{ column }}, check = check, force = force)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_add_fk <- function(dm, table, column, ref_table, check = FALSE) {
  deprecate_soft("0.1.0", "dm::cdm_add_fk()", "dm::dm_add_fk()")
  dm_add_fk(dm, {{ table }}, {{ column }}, {{ ref_table }}, check = check)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_has_fk <- function(dm, table, ref_table) {
  deprecate_soft("0.1.0", "dm::cdm_has_fk()", "dm::dm_has_fk()")
  check_not_zoomed(dm)
  table_name <- dm_tbl_name(dm, {{ table }})
  ref_table_name <- dm_tbl_name(dm, {{ ref_table }})
  dm_has_fk_impl(dm, table_name, ref_table_name)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_get_fk <- function(dm, table, ref_table) {
  deprecate_soft("0.1.0", "dm::cdm_get_fk()", "dm::dm_get_fk()")
  check_not_zoomed(dm)
  table_name <- dm_tbl_name(dm, {{ table }})
  ref_table_name <- dm_tbl_name(dm, {{ ref_table }})
  new_keys(dm_get_fk_impl(dm, table_name, ref_table_name))
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_get_all_fks <- function(dm) {
  deprecate_soft("0.1.0", "dm::cdm_get_all_fks()", "dm::dm_get_all_fks()")
  dm %>%
    dm_get_all_fks_impl() %>%
    mutate(child_fk_cols = as.character(unclass(child_fk_cols))) %>%
    mutate(parent_key_cols = as.character(unclass(parent_key_cols)))
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_rm_fk <- function(dm, table, columns, ref_table) {
  deprecate_soft("0.1.0", "dm::cdm_rm_fk()", "dm::dm_rm_fk()")
  check_not_zoomed(dm)
  column_quo <- enquo(columns)
  if (quo_is_missing(column_quo)) {
    abort_rm_fk_col_missing()
  }
  table_name <- dm_tbl_name(dm, {{ table }})
  ref_table_name <- dm_tbl_name(dm, {{ ref_table }})
  fk_cols <- dm_get_fk_impl(dm, table_name, ref_table_name)
  if (is_empty(fk_cols)) {
    return(dm)
  }
  if (quo_is_null(column_quo)) {
    cols <- get_key_cols(fk_cols)
  } else {
    cols <- as_name(ensym(columns))
    if (!all(cols %in% fk_cols)) {
      abort_is_not_fkc()
    }
  }
  dm_rm_fk_impl(dm, table_name, cols, ref_table_name, NULL)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_enum_fk_candidates <- function(dm, table, ref_table) {
  deprecate_soft("0.1.0", "dm::cdm_enum_fk_candidates()", "dm::dm_enum_fk_candidates()")
  check_not_zoomed(dm)
  check_no_filter(dm)
  table_name <- dm_tbl_name(dm, {{ table }})
  ref_table_name <- dm_tbl_name(dm, {{ ref_table }})

  ref_tbl_pk <- dm_get_pk_impl(dm, ref_table_name)
  ref_tbl <- tbl_impl(dm, ref_table_name)
  tbl <- tbl_impl(dm, table_name)
  enum_fk_candidates_impl(
    table_name, tbl, ref_table_name,
    ref_tbl, ref_tbl_pk
  ) %>%
    rename(columns = column) %>%
    mutate(columns = new_keys(columns))
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_is_referenced <- function(dm, table) {
  deprecate_soft("0.1.0", "dm::cdm_is_referenced()", "dm::dm_is_referenced()")
  check_not_zoomed(dm)
  has_length(dm_get_referencing_tables(dm, !!ensym(table)))
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_get_referencing_tables <- function(dm, table) {
  deprecate_soft(
    "0.1.0", "dm::cdm_get_referencing_tables()",
    "dm::dm_get_referencing_tables()"
  )
  check_not_zoomed(dm)
  table <- dm_tbl_name(dm, {{ table }})
  def <- dm_get_def(dm)
  i <- which(def$table == table)
  def$fks[[i]]$table
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_learn_from_db <- function(dest) {
  deprecate_soft("0.1.0", "dm::cdm_learn_from_db()", "dm::dm_from_src()")
  dm_from_con(con_from_src_or_con(dest))
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_check_constraints <- function(dm) {
  deprecate_soft("0.1.0", "dm::cdm_check_constraints()", "dm::dm_examine_constraints()")
  dm_examine_constraints_impl(dm = dm, progress = FALSE, top_level_fun = "cdm_check_constraints")
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

  if (isTRUE(select)) {
    options <- c("keys", "select")
  } else {
    options <- c("keys")
  }

  code <- dm_paste_impl(dm = dm, options, tab_width)

  # without "\n" in the end it looks weird when a warning is issued
  cat(code, "\n")

  invisible(dm)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_has_pk <- function(dm, table) {
  deprecate_soft("0.1.0", "dm::cdm_has_pk()", "dm::dm_has_pk()")
  check_not_zoomed(dm)
  has_length(dm_get_pk(dm, {{ table }}))
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_get_pk <- function(dm, table) {
  deprecate_soft("0.1.0", "dm::cdm_get_pk()", "dm::dm_get_pk()")
  check_not_zoomed(dm)
  table_name <- dm_tbl_name(dm, {{ table }})
  new_keys(dm_get_pk_impl(dm, table_name))
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_get_all_pks <- function(dm) {
  deprecate_soft("0.1.0", "dm::cdm_get_all_pks()", "dm::dm_get_all_pks()")
  dm %>%
    dm_get_all_pks_impl() %>%
    mutate(pk_cols = as.character(unclass(pk_cols)))
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_rm_pk <- function(dm, table, rm_referencing_fks = FALSE) {
  deprecate_soft("0.1.0", "dm::cdm_rm_pk()", "dm::dm_rm_pk()")
  check_not_zoomed(dm)
  table_name <- dm_tbl_name(dm, {{ table }})
  def <- dm_get_def(dm)
  if (!rm_referencing_fks && dm_is_referenced(dm, !!table_name)) {
    affected <- dm_get_referencing_tables(dm, !!table_name)
    abort_first_rm_fks(table_name, affected)
  }
  def$pks[def$table == table_name] <- list(new_pk())
  def$fks[def$table == table_name] <- list(new_fk())
  new_dm3(def)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_enum_pk_candidates <- function(dm, table) {
  deprecate_soft("0.1.0", "dm::cdm_enum_pk_candidates()", "dm::dm_enum_pk_candidates()")
  check_no_filter(dm)

  table_name <- dm_tbl_name(dm, {{ table }})

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
cdm_select <- function(dm, table, ...) {
  deprecate_soft("0.1.0", "dm::cdm_select()", "dm::dm_select()")
  check_not_zoomed(dm)
  table_name <- dm_tbl_name(dm, {{ table }})

  dm %>%
    dm_zoom_to(!!table_name) %>%
    select(...) %>%
    dm_update_zoomed()
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_rename <- function(dm, table, ...) {
  deprecate_soft("0.1.0", "dm::cdm_rename()", "dm::dm_rename()")
  check_not_zoomed(dm)
  table_name <- dm_tbl_name(dm, {{ table }})

  dm %>%
    dm_zoom_to(!!table_name) %>%
    rename(...) %>%
    dm_update_zoomed()
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_zoom_to_tbl <- function(dm, table) {
  deprecate_soft("0.1.0", "dm::cdm_zoom_to_tbl()", "dm::dm_zoom_to()")
  check_not_zoomed(dm)
  zoom <- dm_tbl_name(dm, {{ table }})

  cols <- list(get_all_cols(dm, zoom))
  dm %>%
    dm_get_def() %>%
    mutate(
      zoom = if_else(table == !!zoom, data, list(NULL)),
      col_tracker_zoom = if_else(table == !!zoom, cols, list(NULL))
    ) %>%
    new_dm3(zoomed = TRUE)
}

#' @rdname deprecated
#' @keywords internal
#' @export
cdm_insert_zoomed_tbl <- function(dm, new_tbl_name = NULL, repair = "unique", quiet = FALSE) {
  deprecate_soft("0.1.0", "dm::cdm_insert_zoomed_tbl()", "dm::dm_insert_zoomed()")

  check_zoomed(dm)
  if (is_null(enexpr(new_tbl_name))) {
    new_tbl_name_chr <- orig_name_zoomed(dm)
  } else {
    if (is_symbol(enexpr(new_tbl_name))) {
      warning("The argument `new_tbl_name` in `dm_insert_zoomed()` should be of class `character`.")
    }
    new_tbl_name_chr <- as_string(enexpr(new_tbl_name))
  }
  names_list <- repair_table_names(
    old_names = src_tbls_impl(dm),
    new_names = new_tbl_name_chr, repair, quiet
  )
  dm <- dm_select_tbl_zoomed_impl(dm, names_list$new_old_names)
  new_tbl_name_chr <- names_list$new_names
  old_tbl_name <- orig_name_zoomed(dm)
  new_tbl <- list(tbl_zoomed(dm))
  all_filters <- filters_zoomed(dm)
  old_filters <- all_filters %>% filter(!zoomed)
  new_filters <-
    all_filters %>%
    filter(zoomed) %>%
    mutate(zoomed = FALSE)
  upd_pk <- list_of(update_zoomed_pk(dm))
  upd_inc_fks <- list_of(update_zoomed_incoming_fks(dm))
  dm_wo_outgoing_fks <-
    dm %>%
    update_filter(old_tbl_name, list_of(old_filters)) %>%
    dm_add_tbl_zoomed_impl(new_tbl, new_tbl_name_chr, list_of(new_filters)) %>%
    dm_get_def() %>%
    mutate(
      pks = if_else(table == new_tbl_name_chr, !!upd_pk, pks),
      fks = if_else(table == new_tbl_name_chr, !!upd_inc_fks, fks)
    ) %>%
    new_dm3(zoomed = TRUE, validate = FALSE)

  dm_wo_outgoing_fks %>%
    dm_insert_zoomed_outgoing_fks(new_tbl_name_chr, names_list$old_new_names[old_tbl_name], col_tracker_zoomed(dm)) %>%
    dm_clean_zoomed()
}

dm_select_tbl_zoomed_impl <- function(dm, selected) {
  if (anyDuplicated(names(selected))) abort_need_unique_names(names(selected[duplicated(names(selected))]))

  def <-
    dm_get_def(dm) %>%
    filter_recode_table_def(selected) %>%
    filter_recode_table_fks(selected)

  new_dm3(def, zoomed = TRUE)
}

dm_add_tbl_zoomed_impl <- function(dm, tbls, table_name, filters = list_of(new_filter()),
                                   pks = list_of(new_pk()), fks = list_of(new_fk())) {
  def <- dm_get_def(dm)

  def_0 <- def[rep_along(table_name, NA_integer_), ]
  def_0$table <- table_name
  def_0$data <- unname(tbls)
  def_0$pks <- pks
  def_0$fks <- fks
  def_0$filters <- filters

  new_dm3(vec_rbind(def, def_0), zoomed = TRUE)
}


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


abort_rm_fk_col_missing <- function() {
  abort(error_txt_rm_fk_col_missing(), class = dm_error_full("rm_fk_col_missing"))
}

error_txt_rm_fk_col_missing <- function() {
  "Parameter `columns` has to be set. Pass `NULL` for removing all references."
}
