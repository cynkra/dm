# FIXME: Adapt argument list as provided/required by the Shiny app
mw_cg_make_dm_set_colors <- function(dm, ..., table_names = NULL, color_name = NULL) {
  check_dots_empty()
  # Checks
  stopifnot(is.character(table_names))
  stopifnot(table_names %in% names(dm))

  table_color <- set_names(table_names, color_name)

  list(
    call = expr(dm_set_colors(
      .,
      !!!syms(table_color)
    ))
  )
}
