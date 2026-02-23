#' Add info about a dm's tables
#'
#' @description
#' When creating a diagram from a `dm` using [dm_draw()] the table descriptions set with `dm_set_table_description()` will be displayed.
#'
#' @inheritParams dm_draw
#' @param ...
#' For `dm_set_table_description()`: Descriptions for tables to set in the form `description = table`.
#' `tidyselect` is supported, see [dplyr::select()] for details on the semantics.
#'
#' For `dm_get_table_description()` and `dm_reset_table_description()`: These dots are for future extensions and must be empty.
#'
#' @details
#' Multi-line descriptions can be achieved using the newline symbol `\n`.
#' Descriptions are set with `dm_set_table_description()`.
#' The currently set descriptions can be checked using `dm_get_table_description()`.
#' Descriptions can be removed using `dm_reset_table_description()`.
#'
#' @return For `dm_set_table_description()`: A `dm` object containing descriptions for specified tables.
#' @export
#'
#' @examplesIf rlang::is_installed(c("nycflights13", "labelled", "DiagrammeR"))
#' desc_flights <- rlang::set_names(
#'   "flights",
#'   paste(
#'     "On-time data for all flights",
#'     "that departed NYC (i.e. JFK, LGA or EWR) in 2013.",
#'     sep = "\n"
#'   )
#' )
#' nyc_desc <- dm_nycflights13() %>%
#'   dm_set_table_description(
#'     !!desc_flights,
#'     "Weather at the airport of\norigin at time of departure" = weather
#'   )
#' nyc_desc %>%
#'   dm_draw()
#'
#' dm_get_table_description(nyc_desc)
#' dm_reset_table_description(nyc_desc, flights) %>%
#'   dm_draw(font_size = c(header = 18L, table_description = 9L, column = 15L))
#'
#' pull_tbl(nyc_desc, flights) %>%
#'   labelled::label_attribute()
dm_set_table_description <- function(dm, ...) {
  dm_local_error_call()
  check_not_zoomed(dm)

  check_suggested("labelled (>= 2.12.0)", "dm_set_table_description")

  def <- dm_get_def(dm, quiet = TRUE)
  selected <- eval_select_indices(quo(c(...)), src_tbls_impl(dm))
  labels <- names(selected)

  out <- dm_set_table_description_impl(def, selected, labels)
  dm_from_def(out)
}

dm_set_table_description_impl <- function(def, selected, labels) {
  reduce2(
    selected,
    labels,
    function(def, table, desc) {
      labelled::label_attribute(def$data[[table]]) <- desc
      def
    },
    .init = def
  )
}


#' @rdname dm_set_table_description
#'
#' @return For `dm_get_table_description`: A named vector of tables, with the descriptions in the names.
#'
#' @export
dm_get_table_description <- function(dm, table = NULL, ...) {
  check_dots_empty()
  check_not_zoomed(dm)

  check_suggested("labelled (>= 2.12.0)", "dm_get_table_description")

  table_expr <- enexpr(table) %||% src_tbls_impl(dm, quiet = TRUE)
  tables <- eval_select_indices(table_expr, set_names(src_tbls_impl(dm, quiet = TRUE)))

  dm_get_table_description_impl(dm, tables)
}

dm_get_table_description_impl <- function(dm, tables) {
  # FIXME: Is this correct?
  if (!is_installed("labelled")) {
    return(set_names(character()))
  }

  def <- dm_get_def(dm, quiet = TRUE)
  map(
    tables,
    ~ labelled::label_attribute(def$data[[.x]])
  ) %>%
    purrr::discard(is.null) %>%
    prep_recode()
}

#' @inheritParams dm_get_all_pks
#' @rdname dm_set_table_description
#' @param table One or more table names, unquoted, for which to
#'
#' 1. get information about the current description(s) with [dm_get_table_description()].
#' 2. remove descriptions with [dm_reset_table_description()].
#'
#' In both cases the default applies to all tables in the `dm`.
#'
#' @return For `dm_reset_table_description()`: A `dm` object without descriptions for specified tables.
#' @export
dm_reset_table_description <- function(dm, table = NULL, ...) {
  check_dots_empty()
  check_not_zoomed(dm)

  check_suggested("labelled (>= 2.12.0)", "dm_reset_table_description")

  table_expr <- enexpr(table) %||% src_tbls_impl(dm, quiet = TRUE)
  def <- dm_get_def(dm, quiet = TRUE)
  tables <- eval_select_indices(table_expr, set_names(src_tbls_impl(dm, quiet = TRUE)))
  labels <- rep(list(NULL), length(tables))

  out <- dm_set_table_description_impl(def, tables, labels)
  dm_from_def(out)
}
