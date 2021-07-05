
#' Mark table for manipulation
#'
#' @description
#' Zooming to a table of a [`dm`] allows for the use of many `dplyr`-verbs directly on this table, while retaining the
#' context of the `dm` object.
#'
#' `dm_zoom_to()` zooms to the given table.
#'
#' `dm_update_zoomed()` overwrites the originally zoomed table with the manipulated table.
#' The filter conditions for the zoomed table are added to the original filter conditions.
#'
#' `dm_insert_zoomed()` adds a new table to the `dm`.
#'
#' `dm_discard_zoomed()` discards the zoomed table and returns the `dm` as it was before zooming.
#'
#' Please refer to `vignette("tech-db-zoom", package = "dm")`
#' for a more detailed introduction.
#'
#' @inheritParams dm_add_pk
#' @inheritParams vctrs::vec_as_names
#'
#' @details
#' Whenever possible, the key relations of the original table are transferred to the resulting table
#' when using `dm_insert_zoomed()` or `dm_update_zoomed()`.
#'
#' Functions from `dplyr` that are supported for a `zoomed_dm`: [group_by()], [summarise()], [mutate()],
#' [transmute()], [filter()], [select()], [rename()] and [ungroup()].
#' You can use these functions just like you would
#' with a normal table.
#'
#' Calling [filter()] on a zoomed `dm` is different from calling [dm_filter()]:
#' only with the latter, the filter expression is added to the list of table filters stored in the dm.
#'
#' Furthermore, different `join()`-variants from {dplyr} are also supported,
#' e.g. [left_join()] and [semi_join()].
#' (Support for [nest_join()] is planned.)
#' The join-methods for `zoomed_dm` infer the columns to join by from the primary and foreign keys,
#' and have an extra argument `select` that allows choosing the columns of the RHS table.
#'
#' And -- last but not least -- also the {tidyr}-functions [unite()] and [separate()] are supported for `zoomed_dm`.
#'
#' @rdname dm_zoom_to
#'
#' @return For `dm_zoom_to()`: A `zoomed_dm` object.
#'
#' @export
#' @examplesIf rlang::is_installed("nycflights13") && rlang::is_installed("DiagrammeR")
#' flights_zoomed <- dm_zoom_to(dm_nycflights13(), flights)
#'
#' flights_zoomed
#'
#' flights_zoomed_transformed <-
#'   flights_zoomed %>%
#'   mutate(am_pm_dep = ifelse(dep_time < 1200, "am", "pm")) %>%
#'   # `by`-argument of `left_join()` can be explicitly given
#'   # otherwise the key-relation is used
#'   left_join(airports) %>%
#'   select(year:dep_time, am_pm_dep, everything())
#'
#' flights_zoomed_transformed
#'
#' # replace table `flights` with the zoomed table
#' flights_zoomed_transformed %>%
#'   dm_update_zoomed()
#'
#' # insert the zoomed table as a new table
#' flights_zoomed_transformed %>%
#'   dm_insert_zoomed("extended_flights") %>%
#'   dm_draw()
#'
#' # discard the zoomed table
#' flights_zoomed_transformed %>%
#'   dm_discard_zoomed()
dm_zoom_to <- function(dm, table) {
  check_not_zoomed(dm)
  # for now only one table can be zoomed on
  zoom <- dm_tbl_name(dm, {{ table }})

  cols <- list(get_all_cols(dm, zoom))

  dm_get_def(dm) %>%
    mutate(
      zoom = if_else(table == !!zoom, data, list(NULL)),
      col_tracker_zoom = if_else(table == !!zoom, cols, list(NULL))
    ) %>%
    new_dm3(zoomed = TRUE)
}

is_zoomed <- function(dm) {
  inherits(dm, "zoomed_dm")
}

get_zoomed_tbl <- function(dm) {
  dm_get_zoomed_tbl(dm) %>%
    pull(zoom) %>%
    pluck(1)
}

#' @rdname dm_zoom_to
#' @param new_tbl_name Name of the new table.
#' @inheritParams vctrs::vec_as_names
#'
#' @return For `dm_insert_zoomed()`, `dm_update_zoomed()` and `dm_discard_zoomed()`: A `dm` object.
#'
#' @export
dm_insert_zoomed <- function(dm, new_tbl_name = NULL, repair = "unique", quiet = FALSE) {
  check_zoomed(dm)
  if (is_null(enexpr(new_tbl_name))) {
    new_tbl_name_chr <- orig_name_zoomed(dm)
  } else {
    if (is_symbol(enexpr(new_tbl_name))) {
      warning(
        "The argument `new_tbl_name` in `dm_insert_zoomed()` should be of class `character`."
      )
    }
    new_tbl_name_chr <- as_string(enexpr(new_tbl_name))
  }
  names_list <- repair_table_names(
    old_names = src_tbls_impl(dm),
    new_names = new_tbl_name_chr, repair, quiet
  )
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
  upd_pk <- vctrs::list_of(update_zoomed_pk(dm))

  # incoming FKs: in the new row, based on the old table;
  # if PK available, foreign key relations can be copied from the old table
  # if PK vanished, the entry will be empty
  upd_inc_fks <- vctrs::list_of(update_zoomed_incoming_fks(dm))

  dm_wo_outgoing_fks <-
    dm %>%
    update_filter(old_tbl_name, vctrs::list_of(old_filters)) %>%
    dm_add_tbl_impl(new_tbl, new_tbl_name_chr, vctrs::list_of(new_filters)) %>%
    dm_get_def() %>%
    mutate(
      pks = if_else(table == new_tbl_name_chr, !!upd_pk, pks),
      fks = if_else(table == new_tbl_name_chr, !!upd_inc_fks, fks)
    ) %>%
    new_dm3(zoomed = TRUE)

  # outgoing FKs: potentially in several rows, based on the old table;
  # renamed(?) FK columns if they still exist
  dm_wo_outgoing_fks %>%
    dm_insert_zoomed_outgoing_fks(new_tbl_name_chr) %>%
    dm_clean_zoomed()
}

#' @rdname dm_zoom_to
#' @export
dm_update_zoomed <- function(dm) {
  check_zoomed(dm)

  def <- dm_get_def(dm)
  table_name <- orig_name_zoomed(dm)
  where <- which(def$table == table_name)

  orig_colnames <- colnames(def$data[[where]])
  tracked_cols <- get_tracked_cols(dm)
  # Test if keys need to be updated (TRUE, if at least one column was renamed or lost)
  upd_keys <- !all(orig_colnames %in% tracked_cols) || !all(names(tracked_cols) == tracked_cols)

  upd_filter <-
    get_filter_for_table(dm, table_name) %>%
    mutate(zoomed = FALSE)

  new_def <- def
  new_def$data[[where]] <- new_def$zoom[[where]]
  new_def$filters[[where]] <- upd_filter

  if (upd_keys) {
    new_def$pks[[where]] <- update_zoomed_pk(dm)
    new_def$fks[[where]] <- update_zoomed_incoming_fks(dm)

    out <-
      new_def %>%
      new_dm3(zoomed = TRUE) %>%
      dm_update_zoomed_outgoing_fks()
  } else {
    out <- new_dm3(new_def, zoomed = TRUE)
  }

  out %>%
    dm_clean_zoomed()
}

#' @rdname dm_zoom_to
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
        filters = if_else(
          table == old_tbl_name,
          vctrs::list_of(upd_filter),
          filters
        )
      ) %>%
      clean_zoom()
  )
}

dm_clean_zoomed <- function(dm) {
  dm %>%
    dm_get_def() %>%
    clean_zoom() %>%
    new_dm3()
}

clean_zoom <- function(def) {
  def %>%
    mutate(
      zoom = list(NULL),
      col_tracker_zoom = list(NULL)
    )
}

update_zoomed_pk <- function(dm) {
  old_tbl_name <- orig_name_zoomed(dm)
  tracked_cols <- get_tracked_cols(dm)
  orig_pk <- dm_get_pk_impl(dm, old_tbl_name)

  if (has_length(orig_pk) && all(get_key_cols(orig_pk) %in% tracked_cols)) {
    upd_pk <- new_pk(list(recode2(get_key_cols(orig_pk), tracked_cols)))
  } else {
    upd_pk <- new_pk()
  }

  upd_pk
}

update_zoomed_incoming_fks <- function(dm) {
  old_tbl_name <- orig_name_zoomed(dm)
  tracked_cols <- get_tracked_cols(dm)
  orig_pk <- dm_get_pk_impl(dm, old_tbl_name)

  if (has_length(orig_pk) && all(get_key_cols(orig_pk) %in% tracked_cols)) {
    def <- dm_get_def(dm)
    # Nothing to recode here -- updating zoomed table
    def$fks[[which(def$table == old_tbl_name)]]
  } else {
    new_fk()
  }
}

dm_update_zoomed_outgoing_fks <- function(dm) {
  tracked_cols <- get_tracked_cols(dm)

  def <- dm_get_def(dm)

  tbl_name <- orig_name_zoomed(dm)
  def$fks <- map(def$fks, update_zoomed_outgoing, tbl_name, tracked_cols)
  new_dm3(def)
}

update_zoomed_outgoing <- function(fks, tbl_name, tracked_cols) {
  idx <- which(fks$table == tbl_name)
  if (is_empty(idx)) {
    return(fks)
  }

  remove <- which(!map_lgl(fks$column[idx], ~ all(.x %in% tracked_cols)))
  if (has_length(remove)) {
    fks <- fks[-idx[remove], ]
    # Nontrivial shifts in idx may occur, need to recompute
    idx <- which(fks$table == tbl_name)
  }

  fks$column[idx] <- map(fks$column[idx], ~ recode2(.x, tracked_cols))
  fks
}

dm_insert_zoomed_outgoing_fks <- function(dm, new_tbl_name) {
  old_tbl_name <- orig_name_zoomed(dm)
  tracked_cols <- get_tracked_cols(dm)
  old_out_keys <- dm_get_all_fks_impl(dm) %>%
    filter(child_table == !!old_tbl_name) %>%
    select(table = parent_table, column = child_fk_cols)

  old_and_new_out_keys <-
    old_out_keys %>%
    filter(map_lgl(column, ~ all(.x %in% !!tracked_cols))) %>%
    distinct() %>%
    mutate(new_column = new_keys(map(column, ~ (!!names(tracked_cols))[match(.x, !!tracked_cols, nomatch = 0L)])))

  structure(
    reduce2(old_and_new_out_keys$new_column, old_and_new_out_keys$table, ~ dm_add_fk_impl(..1, new_tbl_name, ..2, ..3), .init = dm),
    class = c("zoomed_dm", "dm")
  )
}

get_tracked_cols <- function(dm) {
  def <- dm_get_def(dm)

  def$col_tracker_zoom[[which(def$table == orig_name_zoomed(dm))]]
}

orig_name_zoomed <- function(dm) {
  dm_get_zoomed_tbl(dm) %>% pull(table)
}

replace_zoomed_tbl <- function(dm, new_zoomed_tbl, tracked_cols = NULL) {
  table <- orig_name_zoomed(dm)
  def <- dm_get_def(dm)
  where <- which(def$table == table)
  def$zoom[[where]] <- new_zoomed_tbl
  # the tracked columns are only replaced if they changed, otherwise this function is called with default `NULL`
  if (!is_null(tracked_cols)) {
    def$col_tracker_zoom[[where]] <- tracked_cols
  }
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

check_not_zoomed <- function(dm, levels_up = -1) {
  check_dm(dm)
  if (!is_zoomed(dm)) {
    return()
  }

  fun_name <- gsub(".zoomed_dm", "", as_string(sys.call(levels_up)[[1]]))
  # if a method for `dm()` is used for a `zoomed_dm`, we don't want `fun_name = method.zoomed_dm` but rather `fun_name = method`
  fun_name <- sub("\\.zoomed_dm", "", fun_name)
  abort_only_possible_wo_zoom(fun_name)
}

# For `nest.zoomed_dm()`, we need the incoming foreign keys of the originally zoomed table
get_orig_in_fks <- function(zoomed_dm, orig_table) {
  # FIXME: maybe there is a more efficient implementation possible?
  dm_get_all_fks_impl(zoomed_dm) %>%
    filter(parent_table == orig_table) %>%
    select(-parent_table)
}

get_all_cols <- function(dm, table_name) {
  set_names(colnames(tbl(dm, table_name)))
}
