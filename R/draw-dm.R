# in datamodelr the following colors defined:
#
# default: greyish yellow
# accent1nb: blue, no border
# accent2nb: orange, no border
# accent3nb: yellow, no border
# accent4nb: green, no border
# accent5nb: dark blue, no border
# accent6nb: light grey, no border
# accent7nb: grey, no border
# accent1: blue
# accent2: orange
# accent3: yellow
# accent4: green
# accent5: dark blue
# accent6: light grey
# accent7: grey

cdm_draw_data_model_set_colors <- function(dm, list_of_table_colors) {
  data_model <- cdm_get_data_model(dm)
  data_model <- dm_set_display(data_model, list_of_table_colors)

  dm$data_model <- data_model
  dm
}

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
