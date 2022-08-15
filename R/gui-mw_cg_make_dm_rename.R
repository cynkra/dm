mw_cg_make_dm_rename <- function(dm, ..., table_names = NULL, column_names = NULL, new_column_names = NULL) {
  check_dots_empty()

  # Checks
  stopifnot(!is.null(table_names))
  stopifnot(length(table_names) == 1)
  stopifnot(table_names %in% names(dm))
  stopifnot(inherits(column_names, "character"))
  stopifnot(length(column_names) == 1)
  stopifnot(inherits(new_column_names, "character"))
  stopifnot(length(new_column_names) == 1)

  rename_col <- set_names(column_names, new_column_names)

  # Return call object
  list(
    call = expr(dm_rename(
      .,
      !!sym(table_names),
      !!!syms(rename_col)
    ))
  )
}
