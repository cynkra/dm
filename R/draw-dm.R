#' Draw schema of a [`dm`]-object's data model
#'
#' @param dm A [`dm`] object
#' @param table_names Tables to consider in the model visualisation.
#' If `NULL` (default), there is no constraint.
#' @inheritParams datamodelr::dm_create_graph
#'
#' @description `cdm_draw()` draws a schema of the data model using `datamodelr` (which in turn uses `DiagrammeR`)
#' @name cdm_draw
#'
#' @examples
#' library(dplyr)
#' cdm_draw(cdm_nycflights13())
#' cdm_draw(cdm_nycflights13(cycle = TRUE))
#'
#' @export
cdm_draw <- function(
                     dm,
                     table_names = NULL,
                     rankdir = "LR",
                     col_attr = "column",
                     view_type = "keys_only",
                     columnArrows = TRUE,
                     graph_attrs = "",
                     node_attrs = "",
                     edge_attrs = "",
                     focus = NULL,
                     graph_name = "Data Model") {
  data_model <- cdm_get_data_model(dm)

  if (!is_null(table_names)) {
    walk(
      table_names,
      ~ check_correct_input(dm, .x)
    )

    all_table_names <- names(cdm_get_tables(dm))
    if (!(length(table_names) == length(all_table_names))) {
      unwanted_tables <- setdiff(all_table_names, table_names)
      data_model <- rm_table_from_data_model(data_model, unwanted_tables)
    }
  }
  graph <- dm_create_graph(
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
  dm_render_graph(graph)
}


#' cdm_set_colors()
#'
#' `cdm_set_colors()` allows to define the colors in which to display the tables of the data model.
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
#'     weather = "dark_blue") %>%
#'     cdm_draw()
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
  data_model <- cdm_get_data_model(dm)
  display <- color_quos_to_display(...)

  new_dm(
    cdm_get_src(dm),
    cdm_get_tables(dm),
    dm_set_display(data_model, display)
  )
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
    abort_wrong_color(paste0("'", colors$dm, "' ", colors$nb))
  }
  new_values <- rev(colors$datamodelr[match(values, colors$dm)])

  tibble(tables = names(quos), colors = new_values[idx]) %>%
    nest(-colors) %>%
    deframe() %>%
    map(pull)
}

#' cdm_get_colors()
#'
#' `cdm_get_colors()` returns the colors defined for a data model.
#'
#' @return For `cdm_get_colors()`, a two-column tibble with one row per table.
#'
#' @rdname cdm_draw
#' @export
cdm_get_colors <- function(dm) h(~ {
    data_model <- cdm_get_data_model(dm)
    cdm_get_tables(data_model) %>%
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
