# FIXME: Adapt argument list as provided/required by the Shiny app
mw_cg_make_dm_disentangle <- function(dm, ..., table_names = NULL) {
  check_dots_empty()

  # Checks
  stopifnot(is.character(table_names))
  stopifnot(table_names %in% names(dm))
  stopifnot(length(table_names) == 1)

  # Return call object
  list(
    call = expr(dm_disentangle(
      .,
      # FIXME: Adapt signature
      !!sym(table_names)
    ))
  )
}
