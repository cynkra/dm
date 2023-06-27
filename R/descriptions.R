
#' Add info about a dm's tables
#'
#' @inheritParams dm_draw
#' @param ... Descriptions for tables to set in the form `description = table`.
#' These descriptions will be displayed when creating a diagram with [dm_draw()].
#' Multi-line descriptions can be achieved using the newline symbol `\n`.
#' The currently set descriptions can be checked using [dm_get_table_description()].
#' Descriptions can be removed using `NULL = table`.
#'
#' `tidyselect` is supported, see [dplyr::select()] for details on the semantics.
#'
#' @return A `dm` object containing descriptions for specified tables.
#' @export
#'
#' @examples
dm_set_table_description <- function(dm, ...) {
  check_not_zoomed(dm)
  selected <- eval_select_both(quo(c(...)), src_tbls_impl(dm))$indices
  def <- dm_get_def(dm, quiet = TRUE)

  dm_set_table_description_impl(def, selected, names = names(selected))
}

dm_set_table_description_impl <- function(def, selected, names) {
  reduce2(
    selected,
    names,
    function(def, table, desc) {
      labelled::label_attribute(def$data[[table]]) <- desc
      def
    },
    .init = def
  ) %>%
    new_dm3()
}


#' @inheritParams dm_add_pk
#' @rdname dm_set_table_description
#'
#' @return A named vector of tables, with the descriptions in the names.
#'
#' @export
#'
#' @examples
dm_get_table_description <- function(dm, table = NULL, ...) {
  check_dots_empty()
  check_not_zoomed(dm)

  table_expr <- enexpr(table) %||% src_tbls_impl(dm, quiet = TRUE)
  tables <- eval_select_both(table_expr, set_names(src_tbls_impl(dm, quiet = TRUE)))

  dm_get_table_description_impl(dm, tables$indices)
}

dm_get_table_description_impl <- function(dm, tables) {
  def <- dm_get_def(dm, quiet = TRUE)
  map(
    tables,
    ~ labelled::label_attribute(def$data[[.x]])
  ) %>%
    purrr::discard(is.null) %>%
    prep_recode()
}

dm_reset_table_description <- function(dm, table = NULL, ...) {
  check_dots_empty()
  check_not_zoomed(dm)

  table_expr <- enexpr(table) %||% src_tbls_impl(dm, quiet = TRUE)
  tables <- eval_select_both(table_expr, set_names(src_tbls_impl(dm, quiet = TRUE)))$indices
  def <- dm_get_def(dm, quiet = TRUE)

  dm_set_table_description_impl(def, tables, names = rep(list(NULL), length(tables)))
}
