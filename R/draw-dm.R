#' Draw schema of a 'dm'-object's data model
#'
#' @description `cdm_draw_data_model()` draws a schema of the data model using `datamodelr` (which in turn uses `DiagrammeR`)
#' @name cdm_draw_data_model
#' @export
cdm_draw_data_model <- function(dm, rankdir = "LR", col_attr = "column", view_type = "keys_only", columnArrows = TRUE, ...) {
  data_model <- cdm_get_data_model(dm)
  graph <- dm_create_graph(data_model,
                           rankdir = rankdir,
                           col_attr = col_attr,
                           view_type = view_type,
                           columnArrows = columnArrows,
                           ...)

  dm_render_graph(graph)
}


#' @description `cdm_draw_data_model_set_colors()` allows to define the colors in which to display the tables of the data model
#' @rdname cdm_draw_data_model
#' @export
cdm_draw_data_model_set_colors <- function(dm, list_of_table_colors) {

  names <- names(list_of_table_colors)
  if (!all(names %in% available)) {
    abort(paste0("Available color names are only: ",
                 paste0(available, " (= ", color, ")", collapse = ",\n")))
  }

  data_model <- cdm_get_data_model(dm)
  data_model <- dm_set_display(data_model, list_of_table_colors)

  dm$data_model <- data_model
  dm
}

#' @description `cdm_draw_data_model_print_colors()` prints an overview of the available colors and their names
#' @rdname cdm_draw_data_model
#' @export
cdm_draw_data_model_print_colors <- function() {
  cat(paste0("'", available, "'", " (= ", color, ")"), sep = ",\n")
}

available <- c("default",
               "accent1nb",
               "accent2nb",
               "accent3nb",
               "accent4nb",
               "accent5nb",
               "accent6nb",
               "accent7nb",
               "accent1",
               "accent2",
               "accent3",
               "accent4",
               "accent5",
               "accent6",
               "accent7")

color <- c("greyish yellow",
           "blue, no border",
           "orange, no border",
           "yellow, no border",
           "green, no border",
           "dark blue, no border",
           "light grey, no border",
           "grey, no border",
           "blue",
           "orange",
           "yellow",
           "green",
           "dark blue",
           "light grey",
           "grey")

