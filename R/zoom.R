
#' Single out a table of a `dm`
#'
#' Zooming to a table of a [`dm`] allows for the use of many `dplyr`-verbs directly on this table, while retaining the
#' context of the `dm` object.
#'
#' @inheritParams dm_add_pk
#' @inheritParams vctrs::vec_as_names
#'
#' @details `dm_zoom_to_tbl()`: zooms to the given table.
#'
#' `dm_update_zoomed_tbl()`: overwrites the originally zoomed table with the manipulated table.
#' The filter conditions for the zoomed table are added to the original filter conditions.
#'
#' `dm_insert_zoomed_tbl()`: adds a new table to the `dm`.
#'
#' `dm_discard_zoomed()`: discards the zoomed table and returns the `dm` as it was before zooming.
#'
#' Whenever possible, the key relations of the original table are transferred to the resulting table
#' when using `dm_insert_zoomed_tbl()` or `dm_update_zoomed_tbl()`.
#'
#' Functions from `dplyr` that are supported for a `zoomed_dm`: `group_by()`, `summarise()`, `mutate()`,
#' `transmute()`, `filter()`, `select()`, `rename()` and `ungroup()`.
#' You can use these functions just like you would
#' with a normal table.
#'
#' In addition to filtering the zoomed table, the filter condition from `filter()` is also stored in the `dm`.
#' Depending on which function you use to return to a normal `dm`, one of the following happens:
#'
#' 1. `dm_discard_zoomed()`: all filter conditions for the zoomed table are discarded
#' 1. `dm_update_zoomed_tbl()`: the filter conditions of the original table and those of the zoomed table are combined
#' 1. `dm_insert_zoomed_tbl()`: the filter conditions of the original table stay there and those of the zoomed table are
#' transferred to the new table of the `dm`
#'
#' Furthermore, the different `join()`-variants from {dplyr} are also supported (apart from `nest_join()`).
#' The join-methods for `zoomed_dm` have an extra argument `select` that let's you choose the columns of the RHS table
#' in a {tidyselect} manner.
#'
#' And -- last but not least -- also the {tidyr}-functions `unite()` and `separate()` are supported for `zoomed_dm`.
#'
#' @rdname dm_zoom_to_tbl
#'
#' @return For `dm_zoom_to_tbl()`: A `zoomed_dm` object.
#'
#' @examples
#' library(dplyr)
#' flights_zoomed <- dm_zoom_to_tbl(dm_nycflights13(), flights)
#'
#' flights_zoomed
#'
#' flights_zoomed_transformed <-
#'   flights_zoomed %>%
#'   mutate(am_pm_dep = if_else(dep_time < 1200, "am", "pm")) %>%
#'   # `by`-argument of `left_join()` can be explicitly given
#'   # otherwise the key-relation is used
#'   left_join(airports) %>%
#'   select(year:dep_time, am_pm_dep, everything())
#'
#' # replace table `flights` with the zoomed table
#' dm_update_zoomed_tbl(flights_zoomed_transformed)
#'
#' # insert the zoomed table as a new table
#' dm_insert_zoomed_tbl(flights_zoomed_transformed, extended_flights)
#'
#' # discard the zoomed table
#' dm_discard_zoomed(flights_zoomed_transformed)
#' @export
dm_zoom_to_tbl <- function(dm, table) {
  # FIXME: to include in documentation after #185:
  # Please refer to `vignette("dm-zoom-to-table")` for a more thorough introduction.
  if (is_zoomed(dm)) abort_no_zoom_allowed()

  # for now only one table can be zoomed on
  zoom <- as_string(ensym(table))
  check_correct_input(dm, zoom)

  keys <- list(get_all_keys(dm, zoom))

  structure(
    new_dm3(
      dm_get_def(dm) %>%
        mutate(
          zoom = if_else(table == !!zoom, data, list(NULL)),
          key_tracker_zoom = if_else(table == !!zoom, keys, list(NULL))
        )
    ),
    class = c("zoomed_dm", "dm")
  )
}

is_zoomed <- function(dm) {
  inherits(dm, "zoomed_dm")
}

get_zoomed_tbl <- function(dm) {
  dm_get_zoomed_tbl(dm) %>%
    pull(zoom) %>%
    pluck(1)
}

#' @rdname dm_zoom_to_tbl
#' @param new_tbl_name Name of the new table.
#' @inheritParams vctrs::vec_as_names
#'
#' @return For `dm_insert_zoomed_tbl()`, `dm_update_zoomed_tbl()` and `dm_zoomed_out()`: A `dm` object.
#'
#' @export
dm_insert_zoomed_tbl <- function(dm, new_tbl_name = NULL, repair = "unique", quiet = FALSE) {
  if (!is_zoomed(dm)) abort_no_table_zoomed()
  new_tbl_name_chr <-
    if (is_null(enexpr(new_tbl_name))) orig_name_zoomed(dm) else as_string(enexpr(new_tbl_name))
  names_list <-
    repair_table_names(old_names = names(dm), new_names = new_tbl_name_chr, repair, quiet)
  # rename dm in case of name repair
  dm <- dm_select_tbl_impl(dm, names_list$new_old_names)

  new_tbl_name_chr <- names_list$new_names
  old_tbl_name <- orig_name_zoomed(dm)
  new_tbl <- list(get_zoomed_tbl(dm))
  # filters need to be split: old_filters belong to the old table, new filters to the inserted table
  all_filters <- get_filter_for_table(dm, old_tbl_name)
  old_filters <- all_filters %>% filter(!zoomed)
  new_filters <- all_filters %>%
    filter(zoomed) %>%
    mutate(zoomed = FALSE)

  # PK: either the same primary key as in the old table, renamed in the new table, or no primary key if none available
  upd_pk <- update_zoomed_pk(dm)

  # incoming FKs: in the new row, based on the old table;
  # if PK available, foreign key relations can be copied from the old table
  # if PK vanished, the entry will be empty
  upd_inc_fks <- update_zoomed_incoming_fks(dm)

  dm_wo_outgoing_fks <-
    update_filter(dm, old_tbl_name, vctrs::list_of(old_filters)) %>%
    dm_add_tbl_impl(new_tbl, new_tbl_name_chr, vctrs::list_of(new_filters)) %>%
    dm_get_def() %>%
    mutate(
      pks = if_else(table == new_tbl_name_chr, upd_pk, pks),
      fks = if_else(table == new_tbl_name_chr, upd_inc_fks, fks)
    ) %>%
    new_dm3(zoomed = TRUE)

  # outgoing FKs: potentially in several rows, based on the old table;
  # renamed(?) FK columns if they still exist
  dm_update_zoomed_outgoing_fks(dm_wo_outgoing_fks, new_tbl_name_chr, is_upd = FALSE) %>%
    dm_discard_zoomed()
}

#' @rdname dm_zoom_to_tbl
#' @export
dm_update_zoomed_tbl <- function(dm) {
  if (!is_zoomed(dm)) {
    return(dm)
  }
  table_name <- orig_name_zoomed(dm)
  upd_filter <- vctrs::list_of(get_filter_for_table(dm, table_name) %>% mutate(zoomed = FALSE))
  new_def <- dm_get_def(dm) %>%
    mutate(
      data = if_else(table == table_name, zoom, data),
      pks = if_else(table == table_name, update_zoomed_pk(dm), pks),
      fks = if_else(table == table_name, update_zoomed_incoming_fks(dm), fks),
      filters = if_else(table == table_name, upd_filter, filters)
    )
  new_dm3(new_def, zoomed = TRUE) %>%
    dm_update_zoomed_outgoing_fks(table_name, is_upd = TRUE) %>%
    dm_discard_zoomed()
}

#' @rdname dm_zoom_to_tbl
#' @export
dm_discard_zoomed <- function(dm) {
  if (!is_zoomed(dm)) {
    return(dm)
  }
  old_tbl_name <- orig_name_zoomed(dm)
  upd_filter <- get_filter_for_table(dm, old_tbl_name) %>%
    filter(zoomed == FALSE)
  new_dm3(
    dm_get_def(dm) %>%
      mutate(
        zoom = list(NULL),
        key_tracker_zoom = list(NULL),
        filters = if_else(table == old_tbl_name, vctrs::list_of(upd_filter), filters)
      )
  )
}

update_zoomed_pk <- function(dm) {
  old_tbl_name <- orig_name_zoomed(dm)
  tracked_keys <- get_tracked_keys(dm)
  orig_pk <- dm_get_pk(dm, !!old_tbl_name)
  upd_pk <- if (!is_empty(orig_pk) && orig_pk %in% tracked_keys) {
    new_pk(list(names(tracked_keys[tracked_keys == orig_pk])))
  } else {
    new_pk()
  }
  vctrs::list_of(upd_pk)
}

update_zoomed_incoming_fks <- function(dm) {
  old_tbl_name <- orig_name_zoomed(dm)
  tracked_keys <- get_tracked_keys(dm)
  orig_pk <- dm_get_pk(dm, !!old_tbl_name)
  if (!is_empty(orig_pk) && orig_pk %in% tracked_keys) {
    filter(dm_get_def(dm), table == old_tbl_name) %>% pull(fks)
  } else {
    vctrs::list_of(new_fk())
  }
}

# is_upd is logical: either update (TRUE) or insert (FALSE)
# if `is_upd`, new_tbl_name needs to be the same as old_tbl_name
dm_update_zoomed_outgoing_fks <- function(dm, new_tbl_name, is_upd) {
  old_tbl_name <- orig_name_zoomed(dm)
  tracked_keys <- get_tracked_keys(dm)
  old_out_keys <- dm_get_all_fks(dm) %>%
    filter(child_table == old_tbl_name) %>%
    select(table = parent_table, column = child_fk_col)

  old_and_new_out_keys <-
    if (nrow(old_out_keys) > 0 && any(old_out_keys$column %in% tracked_keys)) {
      filter(old_out_keys, column %in% tracked_keys) %>%
        mutate(new_column = names(tracked_keys[match(column, tracked_keys, nomatch = 0L)]))
    } else {
      filter(old_out_keys, 0 == 1) %>% mutate(new_column = character(0))
    }

  if (is_upd) {
    # need to remove the old keys
    dm <- reduce2(
      old_out_keys$column,
      old_out_keys$table,
      ~ dm_rm_fk(..1, !!old_tbl_name, !!..2, !!..3),
      .init = dm
    )
  }
  structure(
    reduce2(old_and_new_out_keys$new_column, old_and_new_out_keys$table, ~ dm_add_fk(..1, !!new_tbl_name, !!..2, !!..3), .init = dm),
    class = c("zoomed_dm", "dm")
  )
}


get_tracked_keys <- function(dm) {
  dm_get_def(dm) %>%
    filter(table == orig_name_zoomed(dm)) %>%
    pull(key_tracker_zoom) %>%
    extract2(1)
}

orig_name_zoomed <- function(dm) {
  dm_get_zoomed_tbl(dm) %>% pull(table)
}

replace_zoomed_tbl <- function(dm, new_zoomed_tbl, tracked_keys = NULL) {
  table <- orig_name_zoomed(dm)
  def <- dm_get_def(dm)
  def$zoom[def$table == table] <- list(new_zoomed_tbl)
  if (!is_null(tracked_keys)) def$key_tracker_zoom[def$table == table] <- list(tracked_keys)
  new_dm3(def, zoomed = TRUE)
}

check_zoomed <- function(dm) {
  check_dm(dm)
  if (is_zoomed(dm)) {
    return()
  }

  fun_name <- as_string(sys.call(-1)[[1]])
  # if a method for `zoomed_dm()` is used for a `dm`, we don't want `fun_name = method.dm` but rather `fun_name = method`
  fun_name <- sub("\\.dm", "", fun_name)
  abort_only_possible_w_zoom(fun_name)
}

check_not_zoomed <- function(dm) {
  check_dm(dm)
  if (!is_zoomed(dm)) {
    return()
  }

  fun_name <- as_string(sys.call(-1)[[1]])
  abort_only_possible_wo_zoom(fun_name)
}
