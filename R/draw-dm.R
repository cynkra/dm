#' Draw a schema of a [`dm`]-object's data model
#'
#' `cdm_draw()` draws a schema of the data model using `datamodelr` (which in turn uses `DiagrammeR`).
#'
#' @param dm A [`dm`] object
#' @param view_type Can be "keys_only" (default), "all" or "title_only".
#'   It defines the level of details for rendering tables
#'   (only primary and foreign keys, all columns, or no columns)
#' @param rankdir Graph attribute for direction (eg. 'BT' = bottom --> top)
#' @param graph_name The name of the graph
#' @param graph_attrs Additional graph attributes
#' @param node_attrs Additional node attributes
#' @param edge_attrs Additional edge attributes
#' @param focus A list of parameters for rendering (table filter)
#' @param col_attr Column atributes to display.
#'   Only column names (\code{column}) are included by default.
#' @param columnArrows Edges from columns to columns (default: FALSE)
#' @export
#'
#' @examples
#' library(dplyr)
#' cdm_draw(cdm_nycflights13())
#' cdm_draw(cdm_nycflights13(cycle = TRUE))
cdm_draw <- function(dm,
                     rankdir = "LR",
                     col_attr = "column",
                     view_type = "keys_only",
                     columnArrows = TRUE,
                     graph_attrs = "",
                     node_attrs = "",
                     edge_attrs = "",
                     focus = NULL,
                     graph_name = "Data Model") {

  check_dm(dm)
  if (is_empty(dm)) {
    message("The dm cannot be drawn because it is empty.")
    return(invisible(NULL))
  }
  # FIXME: here the color scheme is set with an options(...)-call;
  # should have some schemes available for the user to choose from
  if (is_null(getOption("datamodelr.scheme"))) bdm_set_color_scheme(bdm_color_scheme)

  data_model <- cdm_get_data_model(dm)

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

#' Get data_model component
#'
#' `cdm_get_data_model()` returns the \pkg{datamodelr} data model component of a `dm`
#' object.
#'
#' @noRd
cdm_get_data_model <- function(x) {
  def <- cdm_get_def(x)

  tables <- data.frame(
    table = def$table,
    segment = def$segment,
    display = def$display,
    stringsAsFactors = FALSE
  )

  references_for_columns <- cdm_get_data_model_fks(x)

  references <-
    references_for_columns %>%
    mutate(ref_id = row_number(), ref_col_num = 1L)

  keys <-
    cdm_get_data_model_pks(x) %>%
    mutate(key = 1L)

  columns <-
    cdm_get_all_columns(x) %>%
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

cdm_get_all_columns <- function(x) {
  cdm_get_tables(x) %>%
    map(colnames) %>%
    map(~ enframe(., "id", "column")) %>%
    enframe("table") %>%
    unnest(value)
}

#' cdm_set_colors()
#'
#' `cdm_set_colors()` allows to define the colors that will be used to display the tables of the data model.
#'
#' @param ... Colors to set in the form `table = "<color>"` . Fall-through syntax similarly to
#'   [switch()] is supported: `table1 = , table2 = "<color>"` sets the color for both `table1`
#'   and `table2` . This argument supports splicing.
#' @return For `cdm_set_colors()`: the updated data model.
#'
#' @rdname cdm_draw
#' @examples
#' cdm_nycflights13(color = FALSE) %>%
#'   cdm_set_colors(
#'     airports = ,
#'     airlines = ,
#'     planes = "yellow",
#'     weather = "dark_blue"
#'   ) %>%
#'   cdm_draw()
#'
#' # Splicing is supported:
#' new_colors <- c(
#'   airports = "yellow", airlines = "yellow", planes = "yellow",
#'   weather = "dark_blue"
#' )
#' cdm_nycflights13(color = FALSE) %>%
#'   cdm_set_colors(!!!new_colors) %>%
#'   cdm_draw()
#' @export
cdm_set_colors <- function(dm, ...) {
  display_df <- color_quos_to_display(...)

  def <-
    cdm_get_def(dm) %>%
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
    abort_wrong_color(paste0("`", colors$dm, "` ", colors$nb))
  }
  new_values <- rev(colors$datamodelr[match(values, colors$dm)])

  tibble(table = names(quos), new_display = new_values[idx])
}

#' cdm_get_colors()
#'
#' `cdm_get_colors()` returns the colors defined for a data model.
#'
#' @return For `cdm_get_colors()`, a two-column tibble with one row per table.
#'
#' @rdname cdm_draw
#' @export
cdm_get_colors <- nse_function(c(dm), ~ {
  cdm_get_def(dm) %>%
    select(table, display) %>%
    as_tibble() %>%
    mutate(color = colors$dm[match(display, colors$datamodelr)]) %>%
    select(-display)
})

#' cdm_get_available_colors()
#'
#' `cdm_get_available_colors()` returns an overview of the available colors and their names
#' as a tibble.

#'
#' @return For `cdm_get_available_colors()`, a tibble with the color in the first
#'   column and auxiliary information in other columns.
#'
#' @rdname cdm_draw
#' @export
cdm_get_available_colors <- function() {
  colors
}

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
