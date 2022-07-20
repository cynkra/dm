mw_cg_make_dm_add_pk <- function(dm, ..., table_names = NULL, column_names = NULL) {
  # Checks
  check_dots_empty()
  stopifnot(length(table_names) == 1)
  table <- dm[[table_names]]

  check_at_least_one_col(column_names)
  stopifnot(column_names %in% colnames(table))

  # Call generation
  if (length(column_names) == 1) {
    column_names_sym <- sym(column_names)
  } else {
    column_names_sym <- expr(c(!!!syms(column_names)))
  }

  list(
    call = expr(dm_add_pk(
      .,
      !!sym(table_names),
      !!column_names_sym,
      force = TRUE # we want to change the pks interactively, otherwise error
    ))
  )
}
