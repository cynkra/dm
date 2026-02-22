#' Mark table for manipulation (v2)
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `dm_zoom2_to()` zooms to the given table, returning a keyed table
#' that has the dm object as an attribute.
#' Key column tracking (primary and foreign) is the responsibility
#' of the `dm_keyed_tbl` object.
#'
#' `dm_update_zoom2ed()` overwrites the originally zoomed table
#' with the manipulated table.
#'
#' `dm_insert_zoom2ed()` adds the manipulated table as a new table to the dm.
#'
#' `dm_discard_zoom2ed()` discards the zoomed table and returns the
#' original `dm` as it was before zooming.
#'
#' @inheritParams dm_zoom_to
#'
#' @return For `dm_zoom2_to()`: A `dm_keyed_tbl` object with zoom2 info
#'   stored in `dm_key_info`.
#'
#' @noRd
#' @examplesIf rlang::is_installed(c("nycflights13", "DiagrammeR"))
#' flights_keyed <- dm_zoom2_to(dm_nycflights13(), flights)
#'
#' flights_keyed
#'
#' flights_keyed_transformed <-
#'   flights_keyed %>%
#'   mutate(am_pm_dep = ifelse(dep_time < 1200, "am", "pm"))
#'
#' # replace table `flights` with the zoomed table
#' flights_keyed_transformed %>%
#'   dm_update_zoom2ed()
#'
#' # insert the zoomed table as a new table
#' flights_keyed_transformed %>%
#'   dm_insert_zoom2ed("extended_flights")
#'
#' # discard changes and return original dm
#' flights_keyed_transformed %>%
#'   dm_discard_zoom2ed()
dm_zoom2_to <- function(dm, table) {
  check_not_zoomed(dm)
  table_name <- dm_tbl_name(dm, {{ table }})

  keyed_tables <- dm_get_keyed_tables_impl(dm)
  keyed_tbl <- keyed_tables[[table_name]]

  # Store zoom2 info inside dm_key_info so it survives all dplyr/tidyr verbs
  keys_info <- keyed_get_info(keyed_tbl)
  keys_info$zoom2 <- list(dm = dm, table_name = table_name)
  attr(keyed_tbl, "dm_key_info") <- keys_info

  keyed_tbl
}

#' @rdname dm_zoom2_to
#' @param zoomed_tbl A `dm_keyed_tbl` object returned by `dm_zoom2_to()`
#'   or modified via dplyr operations.
#'
#' @return For `dm_update_zoom2ed()`, `dm_insert_zoom2ed()` and
#'   `dm_discard_zoom2ed()`: A `dm` object.
#'
#' @noRd
dm_update_zoom2ed <- function(zoomed_tbl) {
  zoom2_info <- zoom2_get_info(zoomed_tbl)
  dm <- zoom2_info$dm
  table_name <- zoom2_info$table_name

  keyed_tables <- dm_get_keyed_tables_impl(dm)
  keyed_tables[[table_name]] <- zoom2_clean_keys_info(zoomed_tbl)

  # Preserve table order by using names from original keyed_tables
  new_dm(keyed_tables)
}

#' @rdname dm_zoom2_to
#' @param new_tbl_name Name of the new table.
#' @inheritParams vctrs::vec_as_names
#'
#' @noRd
dm_insert_zoom2ed <- function(zoomed_tbl, new_tbl_name = NULL, repair = "unique", quiet = FALSE) {
  zoom2_info <- zoom2_get_info(zoomed_tbl)
  dm <- zoom2_info$dm
  table_name <- zoom2_info$table_name

  if (is.null(new_tbl_name)) {
    new_tbl_name <- table_name
  }

  keyed_tables <- dm_get_keyed_tables_impl(dm)

  # Repair names if needed
  names_list <- repair_table_names(
    old_names = names(keyed_tables),
    new_names = new_tbl_name,
    repair,
    quiet
  )

  # Rename existing tables if name repair occurred
  names(keyed_tables) <- names_list$old_new_names[names(keyed_tables)]
  new_tbl_name <- names_list$new_names

  # Add the new table
  keyed_tables[[new_tbl_name]] <- zoom2_clean_keys_info(zoomed_tbl)

  out <- new_dm(keyed_tables)

  # Transfer color from original table to new table
  orig_def <- dm_get_def(dm)
  orig_display <- orig_def$display[orig_def$table == table_name]
  if (!is.na(orig_display)) {
    out <- dm_set_colors(out, !!!set_names(new_tbl_name, orig_display))
  }

  out
}

#' @rdname dm_zoom2_to
#' @noRd
dm_discard_zoom2ed <- function(zoomed_tbl) {
  zoom2_info <- zoom2_get_info(zoomed_tbl)
  zoom2_info$dm
}


# Internal helpers --------------------------------------------------------

zoom2_get_info <- function(zoomed_tbl) {
  if (!is_dm_keyed_tbl(zoomed_tbl)) {
    cli::cli_abort("This object was not created by {.fn dm_zoom2_to}.")
  }

  keys_info <- keyed_get_info(zoomed_tbl)
  zoom2 <- keys_info$zoom2

  if (is.null(zoom2)) {
    cli::cli_abort("This object was not created by {.fn dm_zoom2_to}.")
  }

  zoom2
}

zoom2_clean_keys_info <- function(x) {
  if (is_dm_keyed_tbl(x)) {
    keys_info <- keyed_get_info(x)
    keys_info$zoom2 <- NULL
    attr(x, "dm_key_info") <- keys_info
  }
  x
}
