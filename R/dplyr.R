#' \pkg{dplyr} table manipulation methods for zoomed dm objects
#'
#' @description
#' Use these methods without the '.dm_zoomed' suffix (see examples).
#' @param .data object of class `dm_zoomed`
#' @param ... see corresponding function in package \pkg{dplyr} or \pkg{tidyr}
#' @name dplyr_table_manipulation
#' @examplesIf rlang::is_installed("nycflights13")
#' zoomed <- dm_nycflights13() %>%
#'   dm_zoom_to(flights) %>%
#'   group_by(month) %>%
#'   arrange(desc(day)) %>%
#'   summarize(avg_air_time = mean(air_time, na.rm = TRUE))
#' zoomed
#' dm_insert_zoomed(zoomed, new_tbl_name = "avg_air_time_per_month")
NULL

#' @export
filter.dm <- function(.data, ...) {
  check_zoomed(.data)
}

#' @rdname dplyr_table_manipulation
#' @export
filter.dm_zoomed <- function(.data, ...) {
  .data %>%
    dm_filter_impl(..., set_filter = FALSE)
}

#' @export
mutate.dm <- function(.data, ...) {
  check_zoomed(.data)
}

#' @rdname dplyr_table_manipulation
#' @export
mutate.dm_zoomed <- function(.data, ...) {
  tbl <- tbl_zoomed(.data)
  mutated_tbl <- mutate(tbl, ...)
  # #663: user responsibility: those columns are tracked whose names remain
  selected <- set_names(intersect(colnames(tbl), colnames(mutated_tbl)))
  new_tracked_cols_zoom <- new_tracked_cols(.data, selected)
  replace_zoomed_tbl(.data, mutated_tbl, new_tracked_cols_zoom)
}

#' @export
transmute.dm <- function(.data, ...) {
  check_zoomed(.data)
}

#' @rdname dplyr_table_manipulation
#' @export
transmute.dm_zoomed <- function(.data, ...) {
  tbl <- tbl_zoomed(.data)
  # groups are "selected"; key tracking will continue for them
  groups <- set_names(map_chr(groups(tbl), as_string))
  transmuted_tbl <- transmute(tbl, ...)

  # #663: user responsibility: those columns are tracked whose names remain
  selected <- set_names(intersect(colnames(tbl), colnames(transmuted_tbl)))
  new_tracked_cols_zoom <- new_tracked_cols(.data, selected)

  replace_zoomed_tbl(.data, transmuted_tbl, new_tracked_cols_zoom)
}

#' @export
select.dm <- function(.data, ...) {
  check_zoomed(.data)
}

#' @rdname dplyr_table_manipulation
#' @export
select.dm_zoomed <- function(.data, ...) {
  tbl <- tbl_zoomed(.data)

  selected <- eval_select_both(quo(c(...)), colnames(tbl))
  selected_tbl <- select(tbl, !!!selected$indices)
  new_tracked_cols_zoom <- new_tracked_cols(.data, selected$names)

  replace_zoomed_tbl(.data, selected_tbl, new_tracked_cols_zoom)
}

#' @export
relocate.dm <- function(.data, ...) {
  check_zoomed(.data)
}

#' @rdname dplyr_table_manipulation
#' @inheritParams dplyr::relocate
#' @export
relocate.dm_zoomed <- function(.data, ..., .before = NULL, .after = NULL) {
  tbl <- tbl_zoomed(.data)

  relocated_tbl <- relocate(tbl, ..., .before = {{ .before }}, .after = {{ .after }})
  replace_zoomed_tbl(.data, relocated_tbl)
}

#' @export
rename.dm <- function(.data, ...) {
  check_zoomed(.data)
}

#' @rdname dplyr_table_manipulation
#' @export
rename.dm_zoomed <- function(.data, ...) {
  tbl <- tbl_zoomed(.data)

  renamed <- eval_rename_both(quo(c(...)), colnames(tbl))
  renamed_tbl <- rename(tbl, !!!renamed$indices)
  new_tracked_cols_zoom <- new_tracked_cols(.data, renamed$all_names)

  replace_zoomed_tbl(.data, renamed_tbl, new_tracked_cols_zoom)
}

#' @export
distinct.dm <- function(.data, ...) {
  check_zoomed(.data)
}

#' @rdname dplyr_table_manipulation
#' @param .keep_all For `distinct.dm_zoomed()`: see [dplyr::distinct()]
#' @export
distinct.dm_zoomed <- function(.data, ..., .keep_all = FALSE) {
  tbl <- tbl_zoomed(.data)
  distinct_tbl <- distinct(tbl, ..., .keep_all = .keep_all)

  # #663: user responsibility: those columns are tracked whose names remain
  selected <- set_names(intersect(colnames(tbl), colnames(distinct_tbl)))
  new_tracked_cols_zoom <- new_tracked_cols(.data, selected)

  replace_zoomed_tbl(.data, distinct_tbl, new_tracked_cols_zoom)
}

#' @export
arrange.dm <- function(.data, ...) {
  check_zoomed(.data)
}

#' @rdname dplyr_table_manipulation
#' @export
arrange.dm_zoomed <- function(.data, ...) {
  tbl <- tbl_zoomed(.data)
  arranged_tbl <- arrange(tbl, ...)
  replace_zoomed_tbl(.data, arranged_tbl)
}

#' @export
slice.dm <- function(.data, ...) {
  check_zoomed(.data)
}

#' @rdname dplyr_table_manipulation
#' @param .keep_pk For `slice.dm_zoomed`: Logical, if `TRUE`, the primary key will be retained during this transformation. If `FALSE`, it will be dropped.
#' By default, the value is `NULL`, which causes the function to issue a message in case a primary key is available for the zoomed table.
#' This argument is specific for the `slice.dm_zoomed()` method.
#' @export
slice.dm_zoomed <- function(.data, ..., .keep_pk = NULL) {
  sliced_tbl <- slice(tbl_zoomed(.data), ...)
  orig_pk <- dm_get_pk_impl(.data, orig_name_zoomed(.data))
  tracked_cols <- col_tracker_zoomed(.data)
  if (is_null(.keep_pk)) {
    if (has_length(orig_pk) && any(unlist(orig_pk) %in% tracked_cols)) {
      message(
        paste(
          "Keeping PK column, but `slice.dm_zoomed()` can potentially damage the uniqueness of PK columns (duplicated indices).",
          "Set argument `.keep_pk` to `TRUE` or `FALSE` to ensure the behavior you intended."
        )
      )
    }
  } else if (!.keep_pk) {
    tracked_cols <- discard(tracked_cols, tracked_cols == orig_pk)
  }
  replace_zoomed_tbl(.data, sliced_tbl, tracked_cols)
}

#' @export
group_by.dm <- function(.data, ...) {
  check_zoomed(.data)
}

#' @rdname dplyr_table_manipulation
#' @export
group_by.dm_zoomed <- function(.data, ...) {
  tbl <- tbl_zoomed(.data)
  grouped_tbl <- group_by(tbl, ...)

  replace_zoomed_tbl(.data, grouped_tbl)
}

#' @rdname dplyr_table_manipulation
#' @export
group_by.dm_keyed_tbl <- function(.data, ...) {
  keys_info <- keyed_get_info(.data)
  tbl <- unclass_keyed_tbl(.data)
  grouped_tbl <- group_by(tbl, ...)
  new_keyed_tbl_from_keys_info(grouped_tbl, keys_info)
}

#' @export
group_data.dm <- function(.data) {
  check_zoomed(.data)
}

#' @export
group_data.dm_zoomed <- function(.data) {
  tbl <- tbl_zoomed(.data)
  group_data(tbl)
}

#' @export
group_keys.dm <- function(.tbl, ...) {
  check_zoomed(.tbl)
}

#' @export
group_keys.dm_zoomed <- function(.tbl, ...) {
  .data <- .tbl
  tbl <- tbl_zoomed(.data)
  group_keys(tbl, ...)
}

#' @export
group_indices.dm <- function(.data, ...) {
  check_zoomed(.data)
}

#' @export
group_indices.dm_zoomed <- function(.data, ...) {
  tbl <- tbl_zoomed(.data)
  group_indices(tbl, ...)
}

#' @export
group_vars.dm <- function(x) {
  check_zoomed(x)
}

#' @export
group_vars.dm_zoomed <- function(x) {
  .data <- x
  tbl <- tbl_zoomed(.data)
  group_vars(tbl)
}

#' @export
groups.dm <- function(x) {
  check_zoomed(x)
}

#' @export
groups.dm_zoomed <- function(x) {
  .data <- x
  tbl <- tbl_zoomed(.data)
  groups(tbl)
}

#' @export
ungroup.dm <- function(x, ...) {
  check_zoomed(x)
}

#' @rdname dplyr_table_manipulation
#' @param x For `ungroup.dm_zoomed`: object of class `dm_zoomed`
#' @export
ungroup.dm_zoomed <- function(x, ...) {
  tbl <- tbl_zoomed(x)
  ungrouped_tbl <- ungroup(tbl, ...)

  replace_zoomed_tbl(x, ungrouped_tbl)
}

#' @export
summarise.dm <- function(.data, ...) {
  check_zoomed(.data)
}

#' @rdname dplyr_table_manipulation
#' @export
summarise.dm_zoomed <- function(.data, ...) {
  tbl <- tbl_zoomed(.data)
  # groups are "selected"; key tracking will continue for them
  # #663: user responsibility: if group columns are manipulated, they are still tracked
  groups <- set_names(map_chr(groups(tbl), as_string))
  summarized_tbl <- summarize(tbl, ...)
  new_tracked_cols_zoom <- new_tracked_cols(.data, groups)
  replace_zoomed_tbl(.data, summarized_tbl, new_tracked_cols_zoom)
}


#' @rdname dplyr_table_manipulation
#' @export
summarise.dm_keyed_tbl <- function(.data, ...) {
  keys_info <- keyed_get_info(.data)
  tbl <- unclass_keyed_tbl(.data)

  new_pk <- group_vars(.data)
  if (length(new_pk) == 0) {
    new_pk <- NULL
  }

  summarised_tbl <- NextMethod()

  # FIXME: Add original FKs for the remaining columns
  # (subsets of the grouped columns), use new UUID
  new_keyed_tbl(
    summarised_tbl,
    pk = new_pk,
    uuid = keys_info$uuid
  )
}

#' @export
count.dm <- function(x, ...) {
  check_zoomed(x)
}

#' @rdname dplyr_table_manipulation
#' @inheritParams dplyr::count
#' @export
count.dm_zoomed <- function(x, ..., wt = NULL, sort = FALSE, name = NULL,
                            .drop = group_by_drop_default(x)) {
  tbl <- tbl_zoomed(x)

  if (!missing(...)) {
    out <- group_by(tbl, ..., .add = TRUE, .drop = .drop)
  } else {
    out <- tbl
  }

  groups <- set_names(map_chr(groups(out), as_string))

  out <- tally(out, wt = !!enquo(wt), sort = sort, name = name)

  # Ensure grouping is transient
  if (is.data.frame(tbl)) {
    out <- dplyr_reconstruct(out, tbl)
  }

  new_tracked_cols_zoom <- new_tracked_cols(x, groups)
  replace_zoomed_tbl(x, out, new_tracked_cols_zoom)
}

#' @export
tally.dm <- function(x, ...) {
  check_zoomed(x)
}

#' @rdname dplyr_table_manipulation
#' @export
tally.dm_zoomed <- function(x, ...) {
  tbl <- tbl_zoomed(x)
  groups <- set_names(map_chr(groups(tbl), as_string))

  out <- tally(tbl, ...)

  # Ensure grouping is transient
  if (is.data.frame(tbl)) {
    out <- dplyr_reconstruct(out, tbl)
  }

  new_tracked_cols_zoom <- new_tracked_cols(x, groups)
  replace_zoomed_tbl(x, out, new_tracked_cols_zoom)
}

#' @export
pull.dm <- function(.data, var = -1, name = NULL) {
  check_zoomed(.data)
}

#' @rdname dplyr_table_manipulation
#' @inheritParams dplyr::pull
#' @export
pull.dm_zoomed <- function(.data, var = -1, ...) {
  tbl <- tbl_zoomed(.data)
  pull(tbl, var = {{ var }}, ...)
}

#' @rdname dplyr_table_manipulation
#' @export
compute.dm_zoomed <- function(x, ...) {
  zoomed_df <-
    tbl_zoomed(x) %>%
    compute(...)
  replace_zoomed_tbl(x, zoomed_df)
}

#' \pkg{dplyr} join methods for zoomed dm objects
#'
#' Use these methods without the '.dm_zoomed' suffix (see examples).
#' @name dplyr_join
#' @param x,y tbls to join. `x` is the `dm_zoomed` and `y` is another table in the `dm`.
#' @param by If left `NULL` (default), the join will be performed by via the foreign key relation that exists between the originally zoomed table (now `x`)
#' and the other table (`y`).
#' If you provide a value (for the syntax see [`dplyr::join`]), you can also join tables that are not connected in the `dm`.
#' @param copy Disabled, since all tables in a `dm` are by definition on the same `src`.
#' @param suffix Disabled, since columns are disambiguated automatically if necessary, changing the column names to `table_name.column_name`.
#' @param select Select a subset of the \strong{RHS-table}'s columns, the syntax being `select = c(col_1, col_2, col_3)` (unquoted or quoted).
#' This argument is specific for the `join`-methods for `dm_zoomed`.
#' The table's `by` column(s) are automatically added if missing in the selection.
#' @param ... see [`dplyr::join`]
#' @examplesIf rlang::is_installed("nycflights13")
#' flights_dm <- dm_nycflights13()
#' dm_zoom_to(flights_dm, flights) %>%
#'   left_join(airports, select = c(faa, name))
#'
#' # this should illustrate that tables don't necessarily need to be connected
#' dm_zoom_to(flights_dm, airports) %>%
#'   semi_join(airlines, by = "name")
NULL

#' @export
left_join.dm <- function(x, ...) {
  check_zoomed(x)
}

#' @rdname dplyr_join
#' @export
left_join.dm_zoomed <- function(x, y, by = NULL, copy = NULL, suffix = NULL, select = NULL, ...) {
  y_name <- as_string(enexpr(y))
  join_data <- prepare_join(x, {{ y }}, by, {{ select }}, suffix, copy)
  joined_tbl <- left_join(join_data$x_tbl, join_data$y_tbl, join_data$by, copy = FALSE, ...)
  replace_zoomed_tbl(x, joined_tbl, join_data$new_col_names)
}

#' @rdname dplyr_join
#' @export
left_join.dm_keyed_tbl <- function(x, y, by = NULL, copy = NULL, suffix = NULL, ..., keep = FALSE) {
  if (!is_dm_keyed_tbl(y)) {
    return(NextMethod())
  }

  join_spec <- keyed_build_join_spec(x, y, by, suffix)
  joined_tbl <- left_join(
    join_spec$x_tbl, join_spec$y_tbl, deframe(join_spec$by),
    copy = copy,
    suffix = join_spec$suffix,
    keep = keep,
    ...
  )

  new_keyed_tbl(
    joined_tbl,
    pk = join_spec$new_pk,
    fks_in = join_spec$new_fks_in,
    fks_out = join_spec$new_fks_out,
    uuid = join_spec$new_uuid
  )
}

#' @export
inner_join.dm <- function(x, ...) {
  check_zoomed(x)
}

#' @rdname dplyr_join
#' @export
inner_join.dm_zoomed <- function(x, y, by = NULL, copy = NULL, suffix = NULL, select = NULL, ...) {
  y_name <- as_string(enexpr(y))
  join_data <- prepare_join(x, {{ y }}, by, {{ select }}, suffix, copy)
  joined_tbl <- inner_join(join_data$x_tbl, join_data$y_tbl, join_data$by, copy = FALSE, ...)
  replace_zoomed_tbl(x, joined_tbl, join_data$new_col_names)
}

#' @rdname dplyr_join
#' @export
inner_join.dm_keyed_tbl <- function(x, y, by = NULL, copy = NULL, suffix = NULL, ..., keep = FALSE) {
  if (!is_dm_keyed_tbl(y)) {
    return(NextMethod())
  }

  join_spec <- keyed_build_join_spec(x, y, by, suffix)
  joined_tbl <- inner_join(
    join_spec$x_tbl, join_spec$y_tbl, deframe(join_spec$by),
    copy = copy,
    suffix = join_spec$suffix,
    keep = keep,
    ...
  )

  new_keyed_tbl(
    joined_tbl,
    pk = join_spec$new_pk,
    fks_in = join_spec$new_fks_in,
    fks_out = join_spec$new_fks_out,
    uuid = join_spec$new_uuid
  )
}

#' @export
full_join.dm <- function(x, ...) {
  check_zoomed(x)
}

#' @rdname dplyr_join
#' @export
full_join.dm_zoomed <- function(x, y, by = NULL, copy = NULL, suffix = NULL, select = NULL, ...) {
  y_name <- as_string(enexpr(y))
  join_data <- prepare_join(x, {{ y }}, by, {{ select }}, suffix, copy)
  joined_tbl <- full_join(join_data$x_tbl, join_data$y_tbl, join_data$by, copy = FALSE, ...)
  replace_zoomed_tbl(x, joined_tbl, join_data$new_col_names)
}

#' @rdname dplyr_join
#' @export
full_join.dm_keyed_tbl <- function(x, y, by = NULL, copy = NULL, suffix = NULL, ..., keep = FALSE) {
  if (!is_dm_keyed_tbl(y)) {
    return(NextMethod())
  }

  join_spec <- keyed_build_join_spec(x, y, by, suffix)
  joined_tbl <- full_join(
    join_spec$x_tbl, join_spec$y_tbl, deframe(join_spec$by),
    copy = copy,
    suffix = join_spec$suffix,
    keep = keep,
    ...
  )

  new_keyed_tbl(
    joined_tbl,
    pk = join_spec$new_pk,
    fks_in = join_spec$new_fks_in,
    fks_out = join_spec$new_fks_out,
    uuid = join_spec$new_uuid
  )
}

#' @export
right_join.dm <- function(x, ...) {
  check_zoomed(x)
}

#' @rdname dplyr_join
#' @export
right_join.dm_zoomed <- function(x, y, by = NULL, copy = NULL, suffix = NULL, select = NULL, ...) {
  y_name <- as_string(enexpr(y))
  join_data <- prepare_join(x, {{ y }}, by, {{ select }}, suffix, copy)
  joined_tbl <- right_join(join_data$x_tbl, join_data$y_tbl, join_data$by, copy = FALSE, ...)
  replace_zoomed_tbl(x, joined_tbl, join_data$new_col_names)
}

#' @rdname dplyr_join
#' @export
right_join.dm_keyed_tbl <- function(x, y, by = NULL, copy = NULL, suffix = NULL, ..., keep = FALSE) {
  if (!is_dm_keyed_tbl(y)) {
    return(NextMethod())
  }

  join_spec <- keyed_build_join_spec(x, y, by, suffix)
  joined_tbl <- right_join(
    join_spec$x_tbl, join_spec$y_tbl, deframe(join_spec$by),
    copy = copy,
    suffix = join_spec$suffix,
    keep = keep,
    ...
  )

  new_keyed_tbl(
    joined_tbl,
    pk = join_spec$new_pk,
    fks_in = join_spec$new_fks_in,
    fks_out = join_spec$new_fks_out,
    uuid = join_spec$new_uuid
  )
}

#' @export
semi_join.dm <- function(x, ...) {
  check_zoomed(x)
}

#' @rdname dplyr_join
#' @export
semi_join.dm_zoomed <- function(x, y, by = NULL, copy = NULL, suffix = NULL, select = NULL, ...) {
  y_name <- as_string(enexpr(y))
  join_data <- prepare_join(x, {{ y }}, by, {{ select }}, suffix, copy, disambiguate = FALSE)
  joined_tbl <- semi_join(join_data$x_tbl, join_data$y_tbl, join_data$by, copy = FALSE, ...)
  replace_zoomed_tbl(x, joined_tbl, join_data$new_col_names)
}

#' @rdname dplyr_join
#' @export
semi_join.dm_keyed_tbl <- function(x, y, by = NULL, copy = NULL, ...) {
  if (!is_dm_keyed_tbl(y)) {
    return(NextMethod())
  }

  if (is.null(by)) {
    by <- keyed_by(x, y)
  }

  joined_tbl <- semi_join(
    unclass_keyed_tbl(x), unclass_keyed_tbl(y), by,
    copy = copy,
    ...
  )

  new_keyed_tbl_from_keys_info(joined_tbl, keyed_get_info(x))
}

#' @export
anti_join.dm <- function(x, ...) {
  check_zoomed(x)
}

#' @rdname dplyr_join
#' @export
anti_join.dm_zoomed <- function(x, y, by = NULL, copy = NULL, suffix = NULL, select = NULL, ...) {
  y_name <- as_string(enexpr(y))
  join_data <- prepare_join(x, {{ y }}, by, {{ select }}, suffix, copy, disambiguate = FALSE)
  joined_tbl <- anti_join(join_data$x_tbl, join_data$y_tbl, join_data$by, copy = FALSE, ...)
  replace_zoomed_tbl(x, joined_tbl, join_data$new_col_names)
}

#' @rdname dplyr_join
#' @export
anti_join.dm_keyed_tbl <- function(x, y, by = NULL, copy = NULL, ...) {
  if (!is_dm_keyed_tbl(y)) {
    return(NextMethod())
  }

  if (is.null(by)) {
    by <- keyed_by(x, y)
  }

  joined_tbl <- anti_join(
    unclass_keyed_tbl(x), unclass_keyed_tbl(y), by,
    copy = copy,
    ...
  )

  new_keyed_tbl_from_keys_info(joined_tbl, keyed_get_info(x))
}

#' @export
nest_join.dm <- function(x, ...) {
  check_zoomed(x)
}

#' @rdname dplyr_join
#' @inheritParams dplyr::nest_join
#' @export
nest_join.dm_zoomed <- function(x, y, by = NULL, copy = FALSE, keep = FALSE, name = NULL, ...) {
  y_name <- as_string(enexpr(y))
  name <- name %||% y_name
  join_data <- prepare_join(x, {{ y }}, by, NULL, NULL, NULL, disambiguate = FALSE)
  joined_tbl <- nest_join(join_data$x_tbl, join_data$y_tbl, join_data$by, copy, keep, name, ...)
  replace_zoomed_tbl(x, joined_tbl, join_data$new_col_names)
}

prepare_join <- function(x, y, by, selected, suffix, copy, disambiguate = TRUE) {
  y_name <- dm_tbl_name(x, {{ y }})
  select_quo <- enquo(selected)

  if (!is_null(suffix)) message("Column names are disambiguated if necessary, `suffix` ignored.")
  if (!is_null(copy)) message("Tables in a `dm` are necessarily on the same `src`, setting `copy = FALSE`.")

  zoomed <- dm_get_zoom(x, c("table", "zoom", "col_tracker_zoom"))

  x_tbl <- zoomed$zoom[[1]]
  x_orig_name <- zoomed$table
  y_tbl <- dm_get_tables_impl(x)[[y_name]]
  all_cols_y <- colnames(y_tbl)

  if (quo_is_null(select_quo)) {
    select_quo <- quo(everything())
  }

  selected <- eval_select_both(select_quo, colnames(y_tbl))$names

  new_col_names <- zoomed$col_tracker_zoom[[1]]

  if (is_null(by)) {
    by <- get_by(x, x_orig_name, y_name)

    # If the original FK-relation between original `x` and `y` got lost, `by` needs to be provided explicitly
    if (!all(names(by) %in% new_col_names)) abort_fk_not_tracked(x_orig_name, y_name)
  }

  by <- repair_by(by)

  # selection without RHS `by`; only this is needed for disambiguation and by-columns are added later on for all join-types
  selected_wo_by <- selected[selected %in% setdiff(selected, by)]

  if (disambiguate) {
    x_disambig_name <- x_orig_name
    y_disambig_name <- y_name
    if (x_disambig_name == y_disambig_name) {
      x_disambig_name <- paste0(x_disambig_name, ".x")
      y_disambig_name <- paste0(y_disambig_name, ".y")
    }

    table_colnames <-
      vec_rbind(
        tibble(table = x_disambig_name, column = colnames(x_tbl)),
        tibble(table = y_disambig_name, column = names(selected_wo_by))
      )

    recipe <- compute_disambiguate_cols_recipe(table_colnames, sep = ".")
    explain_col_rename(recipe)

    x_renames <-
      recipe %>%
      filter(table == x_disambig_name) %>%
      pull(renames)
    y_renames <-
      recipe %>%
      filter(table == y_disambig_name) %>%
      pull(renames)

    if (has_length(x_renames)) {
      x_tbl <- x_tbl %>% rename(!!!x_renames[[1]])
      names(by) <- recode(names2(by), !!!prep_recode(x_renames[[1]]))
      names(new_col_names) <- recode(names(new_col_names), !!!prep_recode(x_renames[[1]]))
    }

    if (has_length(y_renames)) {
      names(selected_wo_by) <- recode(names(selected_wo_by), !!!prep_recode(y_renames[[1]]))
    }
  }

  # inform user in case RHS `by` column(s) are added
  if (!all(by %in% selected)) {
    new_cols <- glue_collapse(tick_if_needed(setdiff(by, selected)), ", ")
  }

  # rename RHS `by` columns in the tibble to avoid after-the-fact disambiguation collision
  prefix <- unique_prefix(names(selected_wo_by))
  by_rhs_rename <- by
  names(by_rhs_rename) <- paste0(prefix, seq_along(by_rhs_rename))
  stopifnot(!any(names(selected_wo_by) %in% names(by_rhs_rename)))

  # complete vector of selection consisting of selection without by and the newly named by-columns
  selected_repaired <- c(selected_wo_by, by_rhs_rename)

  y_tbl <- select(y_tbl, !!!selected_repaired)

  # the `by` argument needs to be updated: LHS stays, RHS needs to be replaced with new names
  repaired_by <- set_names(recode(by, !!!prep_recode(by_rhs_rename)), names(by))

  # in case key columns of x_tbl have the same name as selected columns of y_tbl
  # the column names of x will be adapted (not for `semi_join()` and `anti_join()`)
  # We can track the new column names
  list(x_tbl = x_tbl, y_tbl = y_tbl, by = repaired_by, new_col_names = new_col_names)
}

unique_prefix <- function(x) {
  if (is_empty(x)) {
    return("...")
  }

  dots <- max(max(nchar(x, "bytes")), 3)
  paste(rep(".", dots), collapse = "")
}

# Workaround for dev dplyr + dbplyr
safe_count <- function(x, ..., wt = NULL, sort = FALSE, name = NULL, .drop = group_by_drop_default(x)) {
  quos <- enquos(...)

  if (has_length(quos)) {
    named <- names2(quos) != ""
    if (any(named)) {
      quos <- as.list(quos)
      named_quos <- quos[named]
      x <- mutate(x, !!!named_quos)
      quos[named] <- syms(names2(quos)[named])
      names(quos) <- NULL
    }
    out <- group_by(x, !!!quos, .add = FALSE, .drop = .drop)
  } else {
    out <- ungroup(x)
  }

  # Compatibility for dplyr < 1.0.0
  if (is.null(name)) {
    out <- tally(out, wt = !!enquo(wt), sort = sort)
  } else {
    out <- tally(out, wt = !!enquo(wt), sort = sort, name = name)
  }
  ungroup(out)
}

new_tracked_cols <- function(dm, selected) {
  tracked_cols <- col_tracker_zoomed(dm)
  old_tracked_names <- names(tracked_cols)
  # the new tracked keys need to be the remaining original column names
  # and their name needs to be the newest one (tidyselect-syntax)
  # `intersect(selected, old_tracked_names)` is empty, return `NULL`

  selected_match <- selected[selected %in% old_tracked_names]
  set_names(
    tracked_cols[selected_match],
    names(selected_match)
  )
}
