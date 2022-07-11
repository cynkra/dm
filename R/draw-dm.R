#' Draw a diagram of the data model
#'
#' @description
#' `r lifecycle::badge("stable")`
#'
#' `dm_draw()` draws a diagram, a visual representation of the data model.
#'
#' @details
#' Currently, \pkg{dm} uses \pkg{DiagrammeR} to draw diagrams.
#' Use [DiagrammeRsvg::export_svg()] to convert the diagram to an SVG file.
#'
#' The backend for drawing the diagrams might change in the future.
#' If you rely on DiagrammeR, pass an explicit value for the `backend` argument.
#'
#' @param dm A [`dm`] object.
#' @param rankdir Graph attribute for direction (e.g., 'BT' = bottom --> top).
#' @param col_attr Deprecated, use `colummn_types` instead.
#' @param view_type Can be "keys_only" (default), "all" or "title_only".
#'   It defines the level of details for rendering tables
#'   (only primary and foreign keys, all columns, or no columns).
#' @param graph_name The name of the graph.
#' @param graph_attrs Additional graph attributes.
#' @param node_attrs Additional node attributes.
#' @param edge_attrs Additional edge attributes.
#' @param focus A list of parameters for rendering (table filter).
#' @param columnArrows Edges from columns to columns (default: `TRUE`).
#' @inheritParams rlang::args_dots_empty
#' @param column_types Set to `TRUE` to show column types.
#' @param backend Currently, only the default `"DiagrammeR"` is accepted.
#'   Pass this value explicitly if your code not only uses this function
#'   to display a data model but relies on the type of the return value.
#'
#'
#' @seealso [dm_set_colors()] for defining the table colors.
#'
#' @export
#'
#' @return An object with a [print()] method, which,
#' when printed, produces the output seen in the viewer as a side effect.
#' Currently, this is an object of class `grViz` (see also
#' [DiagrammeR::grViz()]), but this is subject to change.
#'
#' @examplesIf rlang::is_installed("nycflights13") && rlang::is_installed("DiagrammeR")
#' dm_nycflights13() %>%
#'   dm_draw()
#'
#' dm_nycflights13(cycle = TRUE) %>%
#'   dm_draw(view_type = "title_only")
#'
#' head(dm_get_available_colors())
#' length(dm_get_available_colors())
#'
#' dm_nycflights13() %>%
#'   dm_get_colors()
dm_draw <- function(dm,
                    rankdir = "LR",
                    ...,
                    col_attr = NULL,
                    view_type = c("keys_only", "all", "title_only"),
                    columnArrows = TRUE,
                    graph_attrs = "",
                    node_attrs = "",
                    edge_attrs = "",
                    focus = NULL,
                    graph_name = "Data Model",
                    column_types = NULL,
                    backend = "DiagrammeR") {
  #
  check_not_zoomed(dm)
  check_dots_empty()

  view_type <- arg_match(view_type)

  if (!is.null(col_attr)) {
    deprecate_soft("0.1.13", "dm::dm_draw(col_attr = )", "dm::dm_draw(column_types = )")
    if (is.null(column_types) && "type" %in% col_attr) {
      column_types <- TRUE
    }
  }

  stopifnot(identical(backend, "DiagrammeR"))

  if (is_empty(dm)) {
    message("The dm cannot be drawn because it is empty.")
    return(invisible(NULL))
  }

  column_types <- isTRUE(column_types)

  data_model <- dm_get_data_model(dm, column_types)

  graph <- bdm_create_graph(
    data_model,
    rankdir = rankdir,
    col_attr = c("column", if (column_types) "type"),
    view_type = view_type,
    columnArrows = columnArrows,
    graph_attrs = graph_attrs,
    node_attrs = node_attrs,
    edge_attrs = edge_attrs,
    focus = focus,
    graph_name = graph_name
  )
  bdm_render_graph(graph, top_level_fun = "dm_draw")
}

#' Get data_model
#'
#' `dm_get_data_model()` converts a `dm` to a \pkg{datamodelr}
#' data model object for drawing.
#'
#' @noRd
dm_get_data_model <- function(x, column_types = FALSE) {
  def <- dm_get_def(x)

  tables <- data.frame(
    table = def$table,
    segment = def$segment,
    display = def$display,
    stringsAsFactors = FALSE
  )

  references_for_columns <-
    dm_get_all_fks_impl(x, id = TRUE) %>%
    transmute(table = child_table, column = format(child_fk_cols), ref = parent_table, ref_col = format(parent_key_cols), keyId = id)

  references <-
    references_for_columns %>%
    mutate(ref_id = row_number(), ref_col_num = 1L)

  keys_pk <-
    dm_get_all_pks_impl(x) %>%
    mutate(column = format(pk_cols)) %>%
    select(table, column) %>%
    mutate(key = 1L)

  keys_fk <-
    dm_get_all_fks_impl(x) %>%
    mutate(column = format(parent_key_cols)) %>%
    select(table = parent_table, column) %>%
    mutate(key_fk = 2L)

  if (column_types) {
    types <- dm_get_all_column_types(x)
  } else {
    types <- dm_get_all_columns(x)
  }

  columns <-
    types %>%
    full_join(keys_pk, by = c("table", "column")) %>%
    full_join(keys_fk, by = c("table", "column")) %>%
    full_join(references_for_columns, by = c("table", "column")) %>%
    # Order matters: key == 2 if foreign key points to non-default primary key
    mutate(key = coalesce(key, key_fk, 0L)) %>%
    select(-key_fk) %>%
    # I don't understand why this is necessary
    distinct() %>%
    # for compatibility with print method from {datamodelr}
    as.data.frame()

  new_data_model(
    tables,
    columns,
    references
  )
}

dm_get_all_columns <- function(x) {
  x %>%
    dm_get_tables_impl() %>%
    map(colnames) %>%
    map(~ enframe(., "id", "column")) %>%
    enframe("table") %>%
    unnest_df("value", tibble(id = integer(), column = character())) %>%
    select(table, column, id)
}

dm_get_all_column_types <- function(x) {
  x %>%
    dm_get_tables_impl() %>%
    map(
      ~ mutate(
        enframe(as.list(collect(head(.x, 0))), "column"),
        id = row_number()
      )
    ) %>%
    enframe("table") %>%
    unnest_df("value", tibble(column = character(), value = list(), id = integer())) %>%
    mutate(type = map_chr(value, vec_ptype_abbr), .keep = "unused")
}

#' Color in database diagrams
#'
#' @description
#' `r lifecycle::badge("stable")`
#'
#' `dm_set_colors()` allows to define the colors that will be used to display the tables of the data model with [dm_draw()].
#' The colors can either be either specified with hex color codes or using the names of the built-in R colors.
#' An overview of the colors corresponding to the standard color names can be found at
#' the bottom of
#' [http://rpubs.com/krlmlr/colors](http://rpubs.com/krlmlr/colors).
#'
#' @inheritParams dm_draw
#' @param ... Colors to set in the form `color = table`.
#' Allowed colors are all hex coded colors (quoted) and the color names from `dm_get_available_colors()`.
#' `tidyselect` is supported, see [dplyr::select()] for details on the semantics.
#' @return For `dm_set_colors()`: the updated data model.
#'
#' @export
#' @examplesIf rlang::is_installed("nycflights13") && rlang::is_installed("DiagrammeR")
#' dm_nycflights13(color = FALSE) %>%
#'   dm_set_colors(
#'     darkblue = starts_with("air"),
#'     "#5986C4" = flights
#'   ) %>%
#'   dm_draw()
#'
#' # Splicing is supported:
#' nyc_cols <-
#'   dm_nycflights13() %>%
#'   dm_get_colors()
#' nyc_cols
#'
#' dm_nycflights13(color = FALSE) %>%
#'   dm_set_colors(!!!nyc_cols) %>%
#'   dm_draw()
dm_set_colors <- function(dm, ...) {
  quos <- enquos(...)
  if (any(names(quos) == "")) abort_only_named_args("dm_set_colors", "the colors")
  cols <- names(quos)
  if (!all(cols[!is_hex_color(cols)] %in% dm_get_available_colors()) &&
    all(cols %in% src_tbls_impl(dm))) {
    abort_wrong_syntax_set_cols()
  }

  # get table names for each color (name_spec argument is not needed)
  selected_tables <- eval_select_table(quo(c(...)), src_tbls_impl(dm), unique = FALSE)

  # convert color names to hex color codes (if already hex code this is a no-op)
  # avoid error from mutate()
  names(selected_tables) <- col_to_hex(names(selected_tables))

  display_df <-
    selected_tables %>%
    enframe(name = "new_display", value = "table") %>%
    # needs to be done like this, `distinct()` would keep the first one
    filter(!duplicated(table, fromLast = TRUE))

  def <-
    dm_get_def(dm) %>%
    left_join(display_df, by = "table") %>%
    mutate(display = coalesce(new_display, display)) %>%
    select(-new_display)

  new_dm3(def)
}

color_quos_to_display <- function(...) {
  quos <- enquos(..., .named = TRUE, .ignore_empty = "none", .homonyms = "error")
  missing <- map_lgl(quos, quo_is_missing)
  if (has_length(missing) && missing[[length(missing)]]) {
    abort_last_col_missing()
  }
  avail <- !missing
  idx <- rev(cumsum(rev(avail)))
  values <- map_chr(quos[avail], eval_tidy)

  set_names(names(quos), rev(values)[idx])
}

#' dm_get_colors()
#'
#' `dm_get_colors()` returns the colors defined for a data model.
#'
#' @return For `dm_get_colors()`, a named character vector of table names
#'   with the colors in the names.
#'   This allows calling `dm_set_colors(!!!dm_get_colors(...))`.
#'   Use [tibble::enframe()] to convert this to a tibble.
#'
#' @rdname dm_set_colors
#' @export
dm_get_colors <- function(dm) {
  dm %>%
    dm_get_def() %>%
    select(table, display) %>%
    select(display, table) %>%
    mutate(display = coalesce(display, "default")) %>%
    deframe()
}

#' dm_get_available_colors()
#'
#' `dm_get_available_colors()` returns an overview of the names of the available colors
#' These are the standard colors also returned by [grDevices::colors()] plus a default
#' table color with the name "default".
#'
#' @return For `dm_get_available_colors()`, a vector with the available colors.
#'
#' @rdname dm_set_colors
#' @export
dm_get_available_colors <- function() {
  c("default", colors())
}
