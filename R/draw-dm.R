#' Draw a diagram of a [`dm`]-object's data model
#'
#' `dm_draw()` uses \pkg{DiagrammeR} to draw diagrams.
#'
#' @param dm A [`dm`] object.
#' @param view_type Can be "keys_only" (default), "all" or "title_only".
#'   It defines the level of details for rendering tables
#'   (only primary and foreign keys, all columns, or no columns).
#' @param rankdir Graph attribute for direction (e.g., 'BT' = bottom --> top).
#' @param graph_name The name of the graph.
#' @param graph_attrs Additional graph attributes.
#' @param node_attrs Additional node attributes.
#' @param edge_attrs Additional edge attributes.
#' @param focus A list of parameters for rendering (table filter).
#' @param col_attr Column atributes to display.
#'   By default only the column name (\code{"column"}) is displayed.
#' @param columnArrows Edges from columns to columns (default: `TRUE`).
#' @export
#'
#' @return For `dm_draw()`: returns an object of class `grViz` (see also [DiagrammeR::grViz()]), which,
#' when printed, produces the output seen in the viewer as a side effect.
#'
#' @examples
#' library(dplyr)
#' dm_draw(dm_nycflights13())
#' dm_draw(dm_nycflights13(cycle = TRUE))
#' dm_get_available_colors()
#' dm_get_colors(dm_nycflights13())
dm_draw <- function(dm,
                    rankdir = "LR",
                    col_attr = "column",
                    view_type = "keys_only",
                    columnArrows = TRUE,
                    graph_attrs = "",
                    node_attrs = "",
                    edge_attrs = "",
                    focus = NULL,
                    graph_name = "Data Model") {
  #
  check_dm(dm)
  if (is_empty(dm)) {
    message("The dm cannot be drawn because it is empty.")
    return(invisible(NULL))
  }

  data_model <- dm_get_data_model(dm)

  graph <- bdm_create_graph(
    data_model,
    rankdir = rankdir,
    col_attr = col_attr,
    view_type = view_type,
    columnArrows = columnArrows,
    graph_attrs = graph_attrs,
    node_attrs = node_attrs,
    edge_attrs = edge_attrs,
    focus = focus,
    graph_name = graph_name
  )
  bdm_render_graph(graph)
}

#' Get data_model
#'
#' `dm_get_data_model()` converts a `dm` to a \pkg{datamodelr}
#' data model object for drawing.
#'
#' @noRd
dm_get_data_model <- function(x) {
  def <- dm_get_def(x)

  tables <- data.frame(
    table = def$table,
    segment = def$segment,
    display = def$display,
    stringsAsFactors = FALSE
  )

  references_for_columns <- dm_get_data_model_fks(x)

  references <-
    references_for_columns %>%
    mutate(ref_id = row_number(), ref_col_num = 1L)

  keys <-
    dm_get_data_model_pks(x) %>%
    mutate(key = 1L)

  columns <-
    dm_get_all_columns(x) %>%
    # Hack: datamodelr requires `type` column
    mutate(type = "integer") %>%
    left_join(keys, by = c("table", "column")) %>%
    mutate(key = coalesce(key, 0L)) %>%
    left_join(references_for_columns, by = c("table", "column")) %>%
    # for compatibility with print method from {datamodelr}
    as.data.frame()

  new_data_model(
    tables,
    columns,
    references
  )
}

dm_get_all_columns <- function(x) {
  dm_get_tables(x) %>%
    map(colnames) %>%
    map(~ enframe(., "id", "column")) %>%
    enframe("table") %>%
    unnest(value)
}

#' `dm_set_colors()`
#'
#' `dm_set_colors()` allows to define the colors that will be used to display the tables of the data model.
#'
#' @param ... Colors to set in the form `color = table`.
#' Allowed colors are all hex coded colors (quoted) and the color names from `dm_get_available_colors()`.
#' `tidyselect` is supported, see [`dplyr::select()`] for details on the semantics.
#' @return For `dm_set_colors()`: the updated data model.
#'
#' @rdname dm_draw
#' @examples
#'
#' dm_nycflights13(color = FALSE) %>%
#'   dm_set_colors(
#'     darkblue = starts_with("air"),
#'     "#5986C4" = flights
#'   ) %>%
#'   dm_draw()
#'
#' # Splicing is supported:
#' nyc_cols <- dm_get_colors(dm_nycflights13())
#'
#' nyc_cols
#' #>    #FFA07A    #FFA07A    #ADD8E6    #FFA07A    #90EE90
#' #> "airlines" "airports"  "flights"   "planes"  "weather"
#'
#' dm_nycflights13(color = FALSE) %>%
#'   dm_set_colors(!!!nyc_cols) %>%
#'   dm_draw()
#' @export
dm_set_colors <- function(dm, ...) {
  quos <- enquos(...)
  if (any(names(quos) == "")) abort_only_named_args("dm_set_colors", "the colors")
  cols <- names(quos)
  if (!all(cols[!is_hex_color(cols)] %in% dm_get_available_colors()) &&
    all(cols %in% src_tbls(dm))) {
    abort_wrong_syntax_set_cols()
  }

  # need to set names for avail_tables, since `tidyselect::eval_select` needs named vector
  avail_tables <- set_names(src_tbls(dm))
  # get table names for each color (name_spec argument is not needed)
  selected_tables <-
    if_pkg_version(
      "tidyselect",
      "0.2.99.9000",
      map(
        quos,
        function(quos_sel) unname(avail_tables[tidyselect::eval_select(quos_sel, avail_tables)])
      ),
      map(
        quos,
        function(quos_sel) tidyselect::vars_select(avail_tables, !!quos_sel)
      )
    )

  display_df <-
    selected_tables %>%
    enframe(name = "new_display", value = "table") %>%
    unnest(cols = table) %>%
    # convert color names to hex color codes (if already hex code this is a no-op)
    mutate(new_display = col_to_hex(new_display)) %>%
    # needs to be done like this, cause `distinct()` would keep the first one
    filter(!duplicated(table, fromLast = TRUE))

  def <-
    dm_get_def(dm) %>%
    left_join(display_df, by = "table") %>%
    mutate(display = coalesce(new_display, display)) %>%
    select(-new_display)

  new_dm3(def)
}



dm_set_colors2 <- function(dm, ...) {
  display_df <- color_quos_to_display(...)

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

  if (!all(values %in% colors$dm)) {
    abort_wrong_color()
  }
  new_values <- rev(colors$datamodelr[match(values, colors$dm)])

  tibble(table = names(quos), new_display = new_values[idx])
}

#' dm_get_colors()
#'
#' `dm_get_colors()` returns the colors defined for a data model.
#'
#' @return For `dm_get_colors()`, a two-column tibble with one row per table.
#'
#' @rdname dm_draw
#' @export
dm_get_colors <- nse(function(dm) {
  dm_get_def(dm) %>%
    select(table, display) %>%
    select(display, table) %>%
    deframe()
})

#' dm_get_available_colors()
#'
#' `dm_get_available_colors()` returns an overview of the names of the available colors
#' These are the standard colors also returned by `grDevices::colors()` plus a default
#' table color with the name "default".
#'
#' @return For `dm_get_available_colors()`, a vector with the available colors.
#'
#' @rdname dm_draw
#' @export
dm_get_available_colors <- function() {
  c("default", colors())
}

# still needed for legacy `cdm_set/get_colors()`
colors <- tibble::tribble(
  ~dm, ~datamodelr, ~nb,
  "default", "default", "(border)",
  "blue_nb", "accent1nb", "(no border)",
  "orange_nb", "accent2nb", "(no border)",
  "yellow_nb", "accent3nb", "(no border)",
  "green_nb", "accent4nb", "(no border)",
  "dark_blue_nb", "accent5nb", "(no border)",
  "light_grey_nb", "accent6nb", "(no border)",
  "grey_nb", "accent7nb", "(no border)",
  "blue", "accent1", "(border)",
  "orange", "accent2", "(border)",
  "yellow", "accent3", "(border)",
  "green", "accent4", "(border)",
  "dark_blue", "accent5", "(border)",
  "light_grey", "accent6", "(border)",
  "grey", "accent7", "(border)"
)
