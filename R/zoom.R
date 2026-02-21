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
#' Functions from `dplyr` that are supported for a `dm_zoomed`: [group_by()], [summarise()], [mutate()],
#' [transmute()], [filter()], [select()], [rename()] and [ungroup()].
#' You can use these functions just like you would
#' with a normal table.
#'
#' Calling [filter()] on a zoomed `dm` is different from calling [dm_filter()]:
#' only with the latter, the filter expression is added to the list of table filters stored in the dm.
#'
#' Furthermore, different `join()`-variants from \pkg{dplyr} are also supported,
#' e.g. [left_join()] and [semi_join()].
#' (Support for [nest_join()] is planned.)
#' The join-methods for `dm_zoomed` infer the columns to join by from the primary and foreign keys,
#' and have an extra argument `select` that allows choosing the columns of the RHS table.
#'
#' And -- last but not least -- also the \pkg{tidyr}-functions [unite()] and [separate()] are supported for `dm_zoomed`.
#'
#' @rdname dm_zoom_to
#' @aliases zoomed_df
#' @aliases dm_zoomed_df
#'
#' @return For `dm_zoom_to()`: A `dm_zoomed` object.
#'
#' @export
#' @examplesIf rlang::is_installed(c("nycflights13", "DiagrammeR"))
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

  def <- dm_get_def(dm)
  where <- which(def$table == zoom)
  stopifnot(length(where) == 1)

  zoomed_keyed_tbl <- tbl_def_impl(def, where, keyed = TRUE)
  def$zoom[[where]] <- zoomed_keyed_tbl
  def$col_tracker_zoom[[where]] <- set_names(colnames(zoomed_keyed_tbl))

  dm_from_def(def, zoomed = TRUE)
}

is_zoomed <- function(dm) {
  inherits(dm, c("dm_zoomed", "zoomed_dm"))
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

  zoomed <- dm_get_zoom(dm, c("table", "display", "zoom", "filters"))
  old_tbl_name <- zoomed$table
  keyed_tbl <- zoomed$zoom[[1]]
  keys_info <- keyed_get_info(keyed_tbl)
  new_tbl <- unclass_keyed_tbl(keyed_tbl)

  # filters need to be split: old_filters belong to the old table, new filters to the inserted table
  all_filters <- zoomed$filters[[1]]
  old_filters <- all_filters %>% filter(!zoomed)
  new_filters <-
    all_filters %>%
    filter(zoomed) %>%
    mutate(zoomed = FALSE)

  # rename dm in case of name repair
  names_list <- repair_table_names(
    old_names = src_tbls_impl(dm),
    new_names = new_tbl_name_chr,
    repair,
    quiet
  )

  dm_unzoomed <-
    dm %>%
    update_filter(old_tbl_name, list_of(old_filters)) %>%
    dm_clean_zoomed() %>%
    dm_select_tbl_impl(names_list$new_old_names)

  new_tbl_name_chr <- names_list$new_names
  old_tbl_name <- names_list$old_new_names[[old_tbl_name]]

  # PK from keyed table
  if (!is.null(keys_info$pk)) {
    upd_pk <- new_pk(list(keys_info$pk))
  } else {
    upd_pk <- new_pk()
  }

  # UKs from keyed table
  upd_uk <- keys_info$uks

  # Incoming FKs from keyed table's fks_in
  def <- dm_get_def(dm)
  orig_where <- which(def$table == zoomed$table)
  upd_fks <- keyed_fks_in_to_dm_fk(keys_info$fks_in, def, orig_where)

  dm_wo_outgoing_fks <-
    dm_unzoomed %>%
    dm_add_tbl_impl(
      new_tbl,
      new_tbl_name_chr,
      filters = list_of(new_filters),
      pks = list_of(upd_pk),
      uks = list_of(upd_uk),
      fks = list_of(upd_fks)
    )

  # Outgoing FKs from keyed table's fks_out
  new_dm <- dm_insert_zoomed_outgoing_fks_keyed(
    dm_wo_outgoing_fks, new_tbl_name_chr, keys_info$fks_out, def
  )

  if (!is.na(zoomed$display)) {
    new_dm %>%
      dm_set_colors(!!!set_names(new_tbl_name_chr, zoomed$display))
  } else {
    new_dm
  }
}

#' @rdname dm_zoom_to
#' @export
dm_update_zoomed <- function(dm) {
  check_zoomed(dm)

  def <- dm_get_def(dm)

  where <- which(!map_lgl(def$zoom, is.null))
  table_name <- def$table[[where]]

  keyed_tbl <- def$zoom[[where]]
  keys_info <- keyed_get_info(keyed_tbl)

  upd_filter <- def$filters[[where]]
  upd_filter$zoomed <- FALSE

  new_def <- def
  new_def$data[[where]] <- unclass_keyed_tbl(keyed_tbl)
  new_def$filters[[where]] <- upd_filter

  # Update PK from keyed table
  if (!is.null(keys_info$pk)) {
    new_def$pks[[where]] <- new_pk(list(keys_info$pk))
  } else {
    new_def$pks[[where]] <- new_pk()
  }

  # Update UKs from keyed table
  new_def$uks[[where]] <- keys_info$uks

  # Update incoming FKs from keyed table's fks_in
  new_def$fks[[where]] <- keyed_fks_in_to_dm_fk(keys_info$fks_in, def, where)

  # Update outgoing FKs from keyed table's fks_out
  new_def <- keyed_update_outgoing_fks(new_def, where, table_name, keys_info$fks_out, def)

  new_def %>%
    clean_zoom() %>%
    dm_from_def()
}

#' @rdname dm_zoom_to
#' @export
#' @autoglobal
dm_discard_zoomed <- function(dm) {
  if (!is_zoomed(dm)) {
    return(dm)
  }

  def <- dm_get_def(dm)

  where <- which(lengths(def$zoom) != 0)
  old_tbl_name <- def$table[[where]]
  upd_filter <-
    def$filters[[where]] %>%
    filter(zoomed == FALSE)

  def$filters[[where]] <- upd_filter

  def %>%
    clean_zoom() %>%
    dm_from_def()
}

dm_clean_zoomed <- function(dm) {
  dm %>%
    dm_get_def() %>%
    clean_zoom() %>%
    dm_from_def()
}

clean_zoom <- function(def) {
  empty <- rep(list(NULL), length(def$data))
  def$zoom <- empty
  def$col_tracker_zoom <- empty
  def
}

# Convert keyed table's fks_in to dm FK format, preserving on_delete from original def.
keyed_fks_in_to_dm_fk <- function(fks_in, def, where) {
  if (nrow(fks_in) == 0) {
    return(new_fk())
  }

  uuid_to_table <- set_names(def$table, def$uuid)
  orig_fks <- def$fks[[where]]

  tables <- unname(uuid_to_table[fks_in$child_uuid])
  ref_columns <- as.list(fks_in$parent_key_cols)
  columns <- as.list(fks_in$child_fk_cols)

  on_deletes <- character(length(tables))
  for (j in seq_along(tables)) {
    match_idx <- which(
      orig_fks$table == tables[j] &
        map_lgl(orig_fks$column, ~ identical(sort(as.character(.x)), sort(as.character(columns[[j]]))))
    )
    if (length(match_idx) > 0) {
      on_deletes[j] <- orig_fks$on_delete[match_idx[1]]
    } else {
      on_deletes[j] <- "no_action"
    }
  }

  new_fk(
    ref_column = ref_columns,
    table = tables,
    column = columns,
    on_delete = on_deletes
  )
}

# Update outgoing FKs in the dm def using keyed table's fks_out.
keyed_update_outgoing_fks <- function(new_def, where, table_name, fks_out, orig_def) {
  # Remove all existing outgoing FK entries for the zoomed table
  for (i in seq_along(new_def$fks)) {
    if (i == where) next
    fks_i <- new_def$fks[[i]]
    if (nrow(fks_i) > 0) {
      keep <- fks_i$table != table_name
      new_def$fks[[i]] <- fks_i[keep, ]
    }
  }

  # Add new FK entries from keyed table's fks_out
  if (nrow(fks_out) > 0) {
    for (j in seq_len(nrow(fks_out))) {
      parent_uuid <- fks_out$parent_uuid[[j]]
      parent_idx <- which(orig_def$uuid == parent_uuid)

      if (length(parent_idx) == 1) {
        child_fk_cols <- fks_out$child_fk_cols[[j]]
        parent_key_cols <- fks_out$parent_key_cols[[j]]

        # Look up on_delete from original def
        orig_parent_fks <- orig_def$fks[[parent_idx]]
        match_rows <- which(
          orig_parent_fks$table == table_name &
            map_lgl(
              orig_parent_fks$ref_column,
              ~ identical(sort(as.character(.x)), sort(as.character(parent_key_cols)))
            )
        )

        if (length(match_rows) > 0) {
          on_delete <- orig_parent_fks$on_delete[match_rows[1]]
        } else {
          on_delete <- "no_action"
        }

        new_def$fks[[parent_idx]] <- vec_rbind(
          new_def$fks[[parent_idx]],
          new_fk(
            ref_column = list(parent_key_cols),
            table = table_name,
            column = list(child_fk_cols),
            on_delete = on_delete
          )
        )
      }
    }
  }

  new_def
}

update_zoomed_pk <- function(dm) {
  old_tbl_name <- orig_name_zoomed(dm)
  tracked_cols <- col_tracker_zoomed(dm)
  orig_pk <- dm_get_pk_impl(dm, old_tbl_name)

  if (has_length(orig_pk) && all(get_key_cols(orig_pk) %in% tracked_cols)) {
    upd_pk <- new_pk(list(recode2(get_key_cols(orig_pk), tracked_cols)))
  } else {
    upd_pk <- new_pk()
  }

  upd_pk
}

update_zoomed_uk <- function(dm) {
  old_tbl_name <- orig_name_zoomed(dm)
  tracked_cols <- col_tracker_zoomed(dm)
  orig_uk <- dm %>%
    dm_get_def() %>%
    dm_get_all_uks_def_impl(old_tbl_name)
  if (has_length(orig_uk$uk_col) && all(get_key_cols(orig_uk$uk_col) %in% tracked_cols)) {
    upd_uk <- new_uk(map(orig_uk$uk_col, ~ recode2(get_key_cols(.x), tracked_cols)))
  } else {
    upd_uk <- new_uk()
  }

  upd_uk
}

update_zoomed_incoming_fks <- function(dm) {
  old_tbl_name <- orig_name_zoomed(dm)
  tracked_cols <- col_tracker_zoomed(dm)
  def <- dm_get_def(dm)

  orig_idx <- which(def$table == old_tbl_name)
  orig_fk <- def$fks[[orig_idx]]

  orig_fk$ref_column <- map(
    orig_fk$ref_column,
    ~ {
      if (all(.x %in% tracked_cols)) {
        recode2(.x, tracked_cols)
      } else {
        NULL
      }
    }
  )

  orig_fk[lengths(orig_fk$ref_column) > 0, ]
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

update_zoomed_fks <- function(dm, old_tbl_name, tracked_cols) {
  dm_get_all_fks_impl(dm) %>%
    filter(child_table == !!old_tbl_name) %>%
    filter(map_lgl(child_fk_cols, ~ all(.x %in% !!tracked_cols))) %>%
    distinct() %>%
    mutate(
      child_fk_cols = new_keys(map(
        child_fk_cols,
        ~ (!!names(tracked_cols))[match(.x, !!tracked_cols, nomatch = 0L)]
      ))
    )
}

dm_insert_zoomed_outgoing_fks <- function(dm, new_tbl_name, old_tbl_name, tracked_cols) {
  new_out_keys <- update_zoomed_fks(dm, old_tbl_name, tracked_cols)

  dm %>%
    dm_add_fk_impl(
      rep_len(new_tbl_name, length(new_out_keys$child_fk_cols)),
      new_out_keys$child_fk_cols,
      new_out_keys$parent_table,
      new_out_keys$parent_key_cols,
      new_out_keys$on_delete
    )
}

# Add outgoing FKs for an inserted zoomed table using keyed table's fks_out.
dm_insert_zoomed_outgoing_fks_keyed <- function(dm, new_tbl_name, fks_out, orig_def) {
  if (nrow(fks_out) == 0) {
    return(dm)
  }

  uuid_to_table <- set_names(orig_def$table, orig_def$uuid)
  parent_tables <- unname(uuid_to_table[fks_out$parent_uuid])
  child_fk_cols <- fks_out$child_fk_cols
  parent_key_cols <- fks_out$parent_key_cols

  # Look up on_delete from original def
  on_deletes <- character(nrow(fks_out))
  for (j in seq_len(nrow(fks_out))) {
    parent_idx <- which(orig_def$uuid == fks_out$parent_uuid[[j]])
    if (length(parent_idx) == 1) {
      orig_parent_fks <- orig_def$fks[[parent_idx]]
      orig_table <- orig_def$table[!map_lgl(orig_def$zoom, is.null)]
      match_rows <- which(
        orig_parent_fks$table == orig_table &
          map_lgl(
            orig_parent_fks$ref_column,
            ~ identical(sort(as.character(.x)), sort(as.character(parent_key_cols[[j]])))
          )
      )
      if (length(match_rows) > 0) {
        on_deletes[j] <- orig_parent_fks$on_delete[match_rows[1]]
      } else {
        on_deletes[j] <- "no_action"
      }
    } else {
      on_deletes[j] <- "no_action"
    }
  }

  dm %>%
    dm_add_fk_impl(
      rep_len(new_tbl_name, length(child_fk_cols)),
      child_fk_cols,
      parent_tables,
      parent_key_cols,
      on_deletes
    )
}

col_tracker_zoomed <- function(dm) {
  dm_get_zoom(dm, "col_tracker_zoom")[[1]][[1]]
}

tbl_zoomed <- function(dm, quiet = FALSE) {
  dm_get_zoom(dm, "zoom", quiet = quiet)[[1]][[1]]
}

orig_name_zoomed <- function(dm) {
  dm_get_zoom(dm, "table")[[1]]
}

filters_zoomed <- function(dm) {
  dm_get_zoom(dm, "filters")[[1]][[1]]
}

replace_zoomed_tbl <- function(dm, new_zoomed_tbl) {
  table <- orig_name_zoomed(dm)
  def <- dm_get_def(dm)
  where <- which(def$table == table)
  def$zoom[[where]] <- new_zoomed_tbl
  dm_from_def(def, zoomed = TRUE)
}

check_zoomed <- function(dm) {
  check_dm(dm)
  if (is_zoomed(dm)) {
    return()
  }

  fun_name <- as_string(sys.call(-1)[[1]])
  # if a method for `dm_zoomed()` is used for a `dm`, we don't want `fun_name = method.dm` but rather `fun_name = method`
  fun_name <- sub("\\.dm", "", fun_name)
  abort_only_possible_w_zoom(fun_name)
}

check_not_zoomed <- function(dm) {
  check_dm(dm)
  if (!is_zoomed(dm)) {
    return()
  }

  fun_name <- gsub(".dm_zoomed", "", as_string(sys.call(-1)[[1]]))
  # if a method for `dm()` is used for a `dm_zoomed`, we don't want `fun_name = method.dm_zoomed` but rather `fun_name = method`
  fun_name <- sub("\\.dm_zoomed", "", fun_name)
  abort_only_possible_wo_zoom(fun_name)
}

# For `nest.dm_zoomed()`, we need the incoming foreign keys of the originally zoomed table
get_orig_in_fks <- function(dm_zoomed, orig_table) {
  # FIXME: maybe there is a more efficient implementation possible?
  dm_zoomed %>%
    dm_get_all_fks_impl() %>%
    filter(parent_table == orig_table) %>%
    select(-parent_table)
}

# Use keyed table's FK info to determine join columns.
# Returns a named character vector suitable as `by` argument for joins.
keyed_get_by <- function(keyed_tbl, x_orig_name, y_name, def) {
  keys_info <- keyed_get_info(keyed_tbl)
  y_uuid <- def$uuid[def$table == y_name]

  # Check outgoing FKs (zoomed table is child, y is parent)
  out_match <- which(keys_info$fks_out$parent_uuid == y_uuid)

  # Check incoming FKs (zoomed table is parent, y is child)
  in_match <- which(keys_info$fks_in$child_uuid == y_uuid)

  n_matches <- length(out_match) + length(in_match)

  if (n_matches == 0) {
    abort_tables_not_neighbors(x_orig_name, y_name)
  }

  if (n_matches > 1) {
    abort(
      paste0("Column(s) Column(s) of FK between '", x_orig_name, "' and '", y_name, "' ambiguous."),
      class = "multiple_fk"
    )
  }

  if (length(out_match) > 0) {
    set_names(
      as.character(keys_info$fks_out$parent_key_cols[[out_match[1]]]),
      as.character(keys_info$fks_out$child_fk_cols[[out_match[1]]])
    )
  } else {
    set_names(
      as.character(keys_info$fks_in$child_fk_cols[[in_match[1]]]),
      as.character(keys_info$fks_in$parent_key_cols[[in_match[1]]])
    )
  }
}

get_all_cols <- function(dm, table_name) {
  set_names(colnames(tbl_impl(dm, table_name)))
}
