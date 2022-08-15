# FIXME: Adapt argument list as provided/required by the Shiny app
mw_cg_make_dm_set_colors <- function(dm, ..., table_names = NULL, color_name = NULL) {
  check_dots_empty()
  # Checks
  stopifnot(is.character(table_names))
  stopifnot(table_names %in% names(dm))

  if (length(table_names) == 1) {
    table_sym <- sym(table_names)
  } else {
    table_sym <- expr(c(!!!syms(table_names)))
  }

  table_syms <- exprs(!!sym(color_name) := !!table_sym)

  list(
    call = expr(dm_set_colors(
      .,
      !!!table_syms
    ))
  )
}
