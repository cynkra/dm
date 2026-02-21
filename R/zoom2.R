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
#' @inheritParams dm_zoom_to
#'
#' @return For `dm_zoom2_to()`: A `dm_keyed_tbl` object with `"dm_zoom2"` attributes.
#'
#' @export
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
dm_zoom2_to <- function(dm, table) {
  check_not_zoomed(dm)
  table_name <- dm_tbl_name(dm, {{ table }})

  keyed_tables <- dm_get_keyed_tables_impl(dm)
  keyed_tbl <- keyed_tables[[table_name]]

  attr(keyed_tbl, "dm_zoom2_src_dm") <- dm
  attr(keyed_tbl, "dm_zoom2_src_name") <- table_name
  attr(keyed_tbl, "dm_zoom2_col_tracker") <- set_names(colnames(keyed_tbl))

  keyed_tbl
}

#' @rdname dm_zoom2_to
#' @param zoomed_tbl A `dm_keyed_tbl` object returned by `dm_zoom2_to()`
#'   or modified via dplyr operations.
#'
#' @return For `dm_update_zoom2ed()` and `dm_insert_zoom2ed()`: A `dm` object.
#'
#' @export
dm_update_zoom2ed <- function(zoomed_tbl) {
  zoom2_info <- zoom2_get_info(zoomed_tbl)
  dm <- zoom2_info$dm
  table_name <- zoom2_info$table_name

  keyed_tables <- dm_get_keyed_tables_impl(dm)

  # Preserve key info from zoomed_tbl if it's still a keyed_tbl,
  # otherwise wrap it
  if (!is_dm_keyed_tbl(zoomed_tbl)) {
    zoomed_tbl <- zoom2_clean_attrs(zoomed_tbl)
    keyed_tables[[table_name]] <- zoomed_tbl
  } else {
    keyed_tables[[table_name]] <- zoom2_clean_attrs(zoomed_tbl)
  }

  # Preserve table order by using names from original keyed_tables
  new_dm(keyed_tables)
}

#' @rdname dm_zoom2_to
#' @param new_tbl_name Name of the new table.
#' @inheritParams vctrs::vec_as_names
#'
#' @export
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
  cleaned_tbl <- zoom2_clean_attrs(zoomed_tbl)
  keyed_tables[[new_tbl_name]] <- cleaned_tbl

  out <- new_dm(keyed_tables)

  # Transfer color from original table to new table
  orig_def <- dm_get_def(dm)
  orig_display <- orig_def$display[orig_def$table == table_name]
  if (!is.na(orig_display)) {
    out <- dm_set_colors(out, !!!set_names(new_tbl_name, orig_display))
  }

  out
}


# Internal helpers --------------------------------------------------------

zoom2_get_info <- function(zoomed_tbl) {
  dm <- attr(zoomed_tbl, "dm_zoom2_src_dm")
  table_name <- attr(zoomed_tbl, "dm_zoom2_src_name")

  if (is.null(dm) || is.null(table_name)) {
    abort("This object was not created by `dm_zoom2_to()`.")
  }

  list(dm = dm, table_name = table_name)
}

zoom2_clean_attrs <- function(x) {
  attr(x, "dm_zoom2_src_dm") <- NULL
  attr(x, "dm_zoom2_src_name") <- NULL
  attr(x, "dm_zoom2_col_tracker") <- NULL
  x
}
