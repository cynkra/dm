# FIXME: Adapt argument list as provided/required by the Shiny app
mw_cg_make_dm_select <- function(dm, ..., table_names = NULL, column_names = NULL, rm = FALSE) {
  check_dots_empty()

  # Checks
  stopifnot(is.character(table_names))
  stopifnot(table_names %in% names(dm))
  stopifnot(length(table_names) == 1)

  col_names_sel_rm <- if (rm) {
    sapply(syms(column_names), function(x) {
      call("-", x)
    })
  } else {
    syms(column_names)
  }

  list(
    call = expr(dm_select(
      .,
      !!sym(table_names),
      !!!col_names_sel_rm
    ))
  )
}
