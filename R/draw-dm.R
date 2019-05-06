#' Draw schema of a 'dm'-object's data model
#'
#' @description `cdm_draw_data_model()` draws a schema of the data model using `datamodelr` (which in turn uses `DiagrammeR`)
#' @name cdm_draw_data_model
#' @export
cdm_draw_data_model <- function(
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


#' @description `cdm_draw_data_model_set_colors()` allows to define the colors in which to display the tables of the data model
#' @rdname cdm_draw_data_model
#' @export
cdm_draw_data_model_set_colors <- function(dm, list_of_table_colors) {

  names <- names(list_of_table_colors)
  if (!all(names %in% available_dm)) {
    abort(paste0("Available color names are only: \n",
                 paste0("'", available_dm, "' ", nb, collapse = ",\n")
                 )
          )
  }
  new_names <- available_datamodelr[map_int(names, ~ which(available_dm == .x))]
  names(list_of_table_colors) <- new_names

  data_model <- cdm_get_data_model(dm)
  data_model <- dm_set_display(data_model, list_of_table_colors)

  dm$data_model <- data_model
  dm
}

#' @description `cdm_draw_data_model_print_colors()` prints an overview of the available colors and their names
#' @rdname cdm_draw_data_model
#' @export
cdm_draw_data_model_print_colors <- function() {
  cat(paste0("'", available_dm, "' ", nb), sep = ",\n")
}

colors <- tibble::tribble(
              ~dm, ~datamodelr,           ~nb,
        "default",   "default",    "(border)",
        "blue_nb", "accent1nb", "(no border)",
      "orange_nb", "accent2nb", "(no border)",
      "yellow_nb", "accent3nb", "(no border)",
       "green_nb", "accent4nb", "(no border)",
   "dark_blue_nb", "accent5nb", "(no border)",
  "light_grey_nb", "accent6nb", "(no border)",
        "grey_nb", "accent7nb", "(no border)",
           "blue",   "accent1",    "(border)",
         "orange",   "accent2",    "(border)",
         "yellow",   "accent3",    "(border)",
          "green",   "accent4",    "(border)",
      "dark_blue",   "accent5",    "(border)",
     "light_grey",   "accent6",    "(border)",
           "grey",   "accent7",    "(border)"
)

available_dm <- colors$dm
available_datamodelr <- colors$datamodelr
nb <- colors$nb
