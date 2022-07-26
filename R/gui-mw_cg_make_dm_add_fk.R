mw_cg_make_dm_add_fk <- function(dm, ..., table_names = NULL,
                                 column_names = NULL, other_column_names = NULL) {
  # Checks
  check_dots_empty()
  stopifnot(length(table_names) == 2)
  table_name <- table_names[[1]]
  other_table_name <- table_names[[2]]
  table <- dm[[table_name]]
  other_table <- dm[[other_table_name]]

  stopifnot(length(column_names) >= 1)
  stopifnot(length(other_column_names) %in% c(0, length(column_names)))
  stopifnot(column_names %in% colnames(table))
  stopifnot(other_column_names %in% colnames(other_table))

  # Call generation
  if (length(column_names) == 1) {
    column_names_sym <- sym(column_names)
  } else {
    column_names_sym <- expr(c(!!!syms(column_names)))
  }

  if (length(other_column_names) == 0) {
    list(
      call = expr(dm_add_fk(
        .,
        !!sym(table_name),
        !!column_names_sym,
        !!sym(other_table_name)
      ))
    )
  } else {
    if (length(other_column_names) == 1) {
      other_column_names_sym <- sym(other_column_names)
    } else {
      other_column_names_sym <- expr(c(!!!syms(other_column_names)))
    }

    list(
      call = expr(dm_add_fk(
        .,
        !!sym(table_name),
        !!column_names_sym,
        !!sym(other_table_name),
        !!other_column_names_sym
      ))
    )
  }
}
