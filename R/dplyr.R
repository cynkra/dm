#' @export
group_by.dm <- function(.data, ...) {
  check_zoomed(.data)
}

#' \pkg{dplyr} table manipulation methods for `zoomed_dm` objects
#'
#' Use these methods without the '.zoomed_dm' suffix (see examples).
#' @param .data object of class `zoomed_dm`
#' @param ... see corresponding function in package \pkg{dplyr} or \pkg{tidyr}
#' @rdname dplyr_table_manipulation
#' @examples
#' zoomed <- dm_nycflights13() %>%
#'   dm_zoom_to(flights) %>%
#'   group_by(month) %>%
#'   arrange(desc(day)) %>%
#'   summarize(avg_air_time = mean(air_time))
#' zoomed
#' dm_insert_zoomed(zoomed, new_tbl_name = "avg_air_time_per_month")
#' @export
group_by.zoomed_dm <- function(.data, ...) {
  tbl <- get_zoomed_tbl(.data)
  grouped_tbl <- group_by(tbl, ...)

  replace_zoomed_tbl(.data, grouped_tbl)
}

#' @export
ungroup.dm <- function(x, ...) {
  check_zoomed(x)
}

#' @rdname dplyr_table_manipulation
#' @param x For `ungroup.zoomed_dm`: object of class `zoomed_dm`
#' @export
ungroup.zoomed_dm <- function(x, ...) {
  tbl <- get_zoomed_tbl(x)
  ungrouped_tbl <- ungroup(tbl, ...)

  replace_zoomed_tbl(x, ungrouped_tbl)
}

#' @rdname dplyr_table_manipulation
#' @export
summarise.zoomed_dm <- function(.data, ...) {
  tbl <- get_zoomed_tbl(.data)
  # groups are "selected"; key tracking will continue for them
  groups <- set_names(map_chr(groups(tbl), as_string))
  summarized_tbl <- summarize(tbl, ...)
  new_tracked_keys_zoom <- new_tracked_keys(.data, groups)
  replace_zoomed_tbl(.data, summarized_tbl, new_tracked_keys_zoom)
}

#' @export
summarise.dm <- function(.data, ...) {
  check_zoomed(.data)
}

#' @export
filter.dm <- function(.data, ...) {
  check_zoomed(.data)
}

#' @rdname dplyr_table_manipulation
#' @export
filter.zoomed_dm <- function(.data, ...) {
  filter_quos <- enquos(...)
  if (is_empty(filter_quos)) {
    return(.data)
  } # valid table and empty ellipsis provided

  tbl <- get_zoomed_tbl(.data)
  filtered_tbl <- filter(tbl, !!!filter_quos)

  # attribute filter expression to zoomed table. Needs to be flagged with `zoomed = TRUE`, since
  # in case of `dm_insert_zoomed()` the filter exprs needs to be transferred
  set_filter_for_table(.data, orig_name_zoomed(.data), map(filter_quos, quo_get_expr), TRUE) %>%
    replace_zoomed_tbl(filtered_tbl)
}

#' @export
mutate.dm <- function(.data, ...) {
  check_zoomed(.data)
}

#' @rdname dplyr_table_manipulation
#' @export
mutate.zoomed_dm <- function(.data, ...) {
  tbl <- get_zoomed_tbl(.data)
  quos <- enquos(..., .named = TRUE)
  mutated_tbl <- mutate(tbl, !!!quos)
  # all columns that are not touched count as "selected"; names of "selected" are identical to "selected"
  # in case no keys are tracked, `set_names(NULL)` would throw an error
  selected <- set_names(setdiff(names2(get_tracked_keys(.data)), names(quos)))
  new_tracked_keys_zoom <- new_tracked_keys(.data, selected)
  replace_zoomed_tbl(.data, mutated_tbl, new_tracked_keys_zoom)
}

#' @export
transmute.dm <- function(.data, ...) {
  check_zoomed(.data)
}

#' @rdname dplyr_table_manipulation
#' @export
transmute.zoomed_dm <- function(.data, ...) {
  tbl <- get_zoomed_tbl(.data)
  # groups are "selected"; key tracking will continue for them
  groups <- set_names(map_chr(groups(tbl), as_string))
  transmuted_tbl <- transmute(tbl, ...)
  new_tracked_keys_zoom <- new_tracked_keys(.data, groups)

  replace_zoomed_tbl(.data, transmuted_tbl, new_tracked_keys_zoom)
}

#' @export
select.dm <- function(.data, ...) {
  check_zoomed(.data)
}

#' @rdname dplyr_table_manipulation
#' @export
select.zoomed_dm <- function(.data, ...) {
  tbl <- get_zoomed_tbl(.data)
  selected <- tidyselect::vars_select(colnames(tbl), ...)
  selected_tbl <- select(tbl, !!!selected)

  new_tracked_keys_zoom <- new_tracked_keys(.data, selected)

  replace_zoomed_tbl(.data, selected_tbl, new_tracked_keys_zoom)
}

#' @export
rename.dm <- function(.data, ...) {
  check_zoomed(.data)
}

#' @rdname dplyr_table_manipulation
#' @export
rename.zoomed_dm <- function(.data, ...) {
  tbl <- get_zoomed_tbl(.data)
  renamed <- tidyselect::vars_rename(colnames(tbl), ...)
  renamed_tbl <- rename(tbl, !!!renamed)

  new_tracked_keys_zoom <- new_tracked_keys(.data, renamed)

  replace_zoomed_tbl(.data, renamed_tbl, new_tracked_keys_zoom)
}

#' @export
distinct.dm <- function(.data, ...) {
  check_zoomed(.data)
}

#' @rdname dplyr_table_manipulation
#' @param .keep_all For `distinct.zoomed_dm()`: see [`dplyr::distinct`]
#' @export
distinct.zoomed_dm <- function(.data, ..., .keep_all = FALSE) {
  tbl <- get_zoomed_tbl(.data)
  distinct_tbl <- distinct(tbl, ..., .keep_all = .keep_all)
  # when keeping all columns or empty ellipsis (use all columns for distinct) all keys columns remain
  if (.keep_all || is_empty(enexprs(...))) {
    return(replace_zoomed_tbl(.data, distinct_tbl))
  }
  selected <- tidyselect::vars_select(colnames(tbl), ...)
  new_tracked_keys_zoom <- new_tracked_keys(.data, selected)
  replace_zoomed_tbl(.data, distinct_tbl, new_tracked_keys_zoom)
}

#' @export
arrange.dm <- function(.data, ...) {
  check_zoomed(.data)
}

#' @rdname dplyr_table_manipulation
#' @export
arrange.zoomed_dm <- function(.data, ...) {
  replace_zoomed_tbl(.data, arrange(get_zoomed_tbl(.data), ...))
}

#' @export
slice.dm <- function(.data, ...) {
  check_zoomed(.data)
}

#' @rdname dplyr_table_manipulation
#' @param .keep_pk For `slice.zoomed_dm`: Logical, if `TRUE`, the primary key will be retained during this transformation. If `FALSE`, it will be dropped.
#' By default, the value is `NULL`, which causes the function to issue a message in case a primary key is available for the zoomed table.
#' This argument is specific for the `slice.zoomed_dm()` method.
#' @export
slice.zoomed_dm <- function(.data, ..., .keep_pk = NULL) {
  sliced_tbl <- slice(get_zoomed_tbl(.data), ...)
  orig_pk <- dm_get_pk_impl(.data, orig_name_zoomed(.data))
  tracked_keys <- get_tracked_keys(.data)
  if (is_null(.keep_pk)) {
    if (has_length(orig_pk) && orig_pk %in% tracked_keys) {
      message(
        paste(
          "Keeping PK column, but `slice.zoomed_dm()` can potentially damage the uniqueness of PK columns (duplicated indices).",
          "Set argument `.keep_pk` to `TRUE` or `FALSE` to ensure the behavior you intended."
        )
      )
    }
  } else if (!.keep_pk) {
    tracked_keys <- discard(tracked_keys, tracked_keys == orig_pk)
  }
  replace_zoomed_tbl(.data, sliced_tbl, tracked_keys)
}

#' @export
left_join.dm <- function(x, ...) {
  check_zoomed(x)
}

#' \pkg{dplyr} join methods for `zoomed_dm` objects
#'
#' Use these methods without the '.zoomed_dm' suffix (see examples).
#' @rdname dplyr_join
#' @param x,y tbls to join. `x` is the `zoomed_dm` and `y` is another table in the `dm`.
#' @param by If left `NULL` (default), the join will be performed by via the foreign key relation that exists between the originally zoomed table (now `x`)
#' and the other table (`y`).
#' If you provide a value (for the syntax see [`dplyr::join`]), you can also join tables that are not connected in the `dm`.
#' @param copy Disabled, since all tables in a `dm` are by definition on the same `src`.
#' @param suffix Disabled, since columns are disambiguated automatically if necessary, changing the column names to `table_name.column_name`.
#' @param select Select a subset of the \strong{RHS-table}'s columns, the syntax being `select = c(col_1, col_2, col_3)` (unquoted or quoted).
#' This argument is specific for the `join`-methods for `zoomed_dm`.
#' @export
left_join.zoomed_dm <- function(x, y, by = NULL, copy = NULL, suffix = NULL, select = NULL, ...) {
  y_name <- as_string(enexpr(y))
  join_data <- prepare_join(x, {{ y }}, by, {{ select }}, suffix, copy)
  joined_tbl <- left_join(join_data$x_tbl, join_data$y_tbl, join_data$by, copy = FALSE, ...)
  replace_zoomed_tbl(x, joined_tbl, join_data$new_key_names)
}

#' @export
inner_join.dm <- function(x, ...) {
  check_zoomed(x)
}

#' @rdname dplyr_join
#' @export
inner_join.zoomed_dm <- function(x, y, by = NULL, copy = NULL, suffix = NULL, select = NULL, ...) {
  y_name <- as_string(enexpr(y))
  join_data <- prepare_join(x, {{ y }}, by, {{ select }}, suffix, copy)
  joined_tbl <- inner_join(join_data$x_tbl, join_data$y_tbl, join_data$by, copy = FALSE, ...)
  replace_zoomed_tbl(x, joined_tbl, join_data$new_key_names)
}

#' @export
full_join.dm <- function(x, ...) {
  check_zoomed(x)
}

#' @rdname dplyr_join
#' @export
full_join.zoomed_dm <- function(x, y, by = NULL, copy = NULL, suffix = NULL, select = NULL, ...) {
  y_name <- as_string(enexpr(y))
  join_data <- prepare_join(x, {{ y }}, by, {{ select }}, suffix, copy)
  joined_tbl <- full_join(join_data$x_tbl, join_data$y_tbl, join_data$by, copy = FALSE, ...)
  replace_zoomed_tbl(x, joined_tbl, join_data$new_key_names)
}

#' @export
right_join.dm <- function(x, ...) {
  check_zoomed(x)
}

#' @rdname dplyr_join
#' @export
right_join.zoomed_dm <- function(x, y, by = NULL, copy = NULL, suffix = NULL, select = NULL, ...) {
  y_name <- as_string(enexpr(y))
  join_data <- prepare_join(x, {{ y }}, by, {{ select }}, suffix, copy)
  joined_tbl <- right_join(join_data$x_tbl, join_data$y_tbl, join_data$by, copy = FALSE, ...)
  replace_zoomed_tbl(x, joined_tbl, join_data$new_key_names)
}

#' @export
semi_join.dm <- function(x, ...) {
  check_zoomed(x)
}

#' @rdname dplyr_join
#' @export
semi_join.zoomed_dm <- function(x, y, by = NULL, copy = NULL, suffix = NULL, select = NULL, ...) {
  y_name <- as_string(enexpr(y))
  join_data <- prepare_join(x, {{ y }}, by, {{ select }}, suffix, copy, disambiguate = FALSE)
  joined_tbl <- semi_join(join_data$x_tbl, join_data$y_tbl, join_data$by, copy = FALSE, ...)
  replace_zoomed_tbl(x, joined_tbl, join_data$new_key_names)
}

#' @export
anti_join.dm <- function(x, ...) {
  check_zoomed(x)
}

#' @rdname dplyr_join
#' @export
anti_join.zoomed_dm <- function(x, y, by = NULL, copy = NULL, suffix = NULL, select = NULL, ...) {
  y_name <- as_string(enexpr(y))
  join_data <- prepare_join(x, {{ y }}, by, {{ select }}, suffix, copy, disambiguate = FALSE)
  joined_tbl <- anti_join(join_data$x_tbl, join_data$y_tbl, join_data$by, copy = FALSE, ...)
  replace_zoomed_tbl(x, joined_tbl, join_data$new_key_names)
}

prepare_join <- function(x, y, by, selected, suffix, copy, disambiguate = TRUE) {
  y_name <- as_string(ensym(y))
  check_correct_input(x, y_name)
  select_quo <- enquo(selected)

  if (!is_null(suffix)) message("Column names are disambiguated if necessary, `suffix` ignored.")
  if (!is_null(copy)) message("Tables in a `dm` are necessarily on the same `src`, setting `copy = FALSE`.")

  x_tbl <- get_zoomed_tbl(x)
  x_orig_name <- orig_name_zoomed(x)
  y_tbl <- dm_get_tables_impl(x)[[y_name]]
  all_cols_y <- colnames(y_tbl)

  if (quo_is_null(select_quo)) {
    selected <- tidyselect::vars_select(all_cols_y, everything())
  } else {
    selected <- tidyselect::vars_select(all_cols_y, !!select_quo)
  }

  if (is_null(by)) {
    by <- get_by(x, x_orig_name, y_name)
    if (!any(selected == by)) abort_need_to_select_rhs_by(y_name, unname(by))

    if (!all(names(by) %in% get_tracked_keys(x))) abort_fk_not_tracked(x_orig_name, y_name)
  }

  by <- repair_by(by)

  new_key_names <- get_tracked_keys(x)

  y_tbl <- select(y_tbl, !!!selected)

  if (disambiguate) {
    x_disambig_name <- x_orig_name
    y_disambig_name <- y_name
    if (x_disambig_name == y_disambig_name) {
      x_disambig_name <- paste0(x_disambig_name, ".x")
      y_disambig_name <- paste0(y_disambig_name, ".y")
    }

    table_colnames <-
      vctrs::vec_rbind(
        tibble(table = x_disambig_name, column = colnames(x_tbl)),
        tibble(table = y_disambig_name, column = colnames(y_tbl)) %>% filter(!(column %in% by))
      )

    recipe <- compute_disambiguate_cols_recipe(table_colnames, sep = ".")
    explain_col_rename(recipe)

    x_renames <- recipe %>%
      filter(table == x_disambig_name) %>%
      pull(renames)
    y_renames <- recipe %>%
      filter(table == y_disambig_name) %>%
      pull(renames)

    if (has_length(x_renames)) {
      x_tbl <- x_tbl %>% rename(!!!x_renames[[1]])
      names(by) <- recode(names2(by), !!!prep_recode(x_renames[[1]]))
      names(new_key_names) <- recode(names(new_key_names), !!!prep_recode(x_renames[[1]]))
    }

    if (has_length(y_renames)) {
      y_tbl <- y_tbl %>% rename(!!!y_renames[[1]])
      selected[] <- recode(selected, !!!prep_recode(y_renames[[1]]))
    }
  }

  # in case key columns of x_tbl have the same name as selected columns of y_tbl
  # the column names of x will be adapted (not for `semi_join()` and `anti_join()`)
  # We can track the new column names
  list(x_tbl = x_tbl, y_tbl = y_tbl, by = by, new_key_names = new_key_names)
}
