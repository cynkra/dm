enum_ops <- function(dm = NULL, ..., op_name = NULL) {
  if (is.null(op_name)) {
    list(
      op_name = c(
        "dm_add_pk", # only if not all tables have PK
        "dm_add_fk",
        NULL
      )
    )
  } else {
    list2(
      op_name = op_name,
      !!!exec(paste0("enum_ops_", op_name), dm = dm, ...)
    )
  }
}

enum_ops_dm_add_pk <- function(dm = NULL, ..., table_names = NULL) {
  if (is.null(table_names)) {
    # enumerate all tables that don't have a pk
    list(table_names = names(dm))
  } else {
    stopifnot(length(table_names) == 1)

    list2(
      table_names = table_names,
      !!!enum_ops_dm_add_pk_table(dm, ..., table_names = table_names)
    )
  }
}

enum_ops_dm_add_pk_table <- function(dm = NULL, ..., table_names, column_names = NULL) {
  stopifnot(length(table_names) == 1)

  if (is.null(column_names)) {
    # enumerate all columns that are not list
    list(column_names = colnames(dm[[table_names]]))
  } else if (length(column_names) > 1) {
    list2(
      column_names = column_names,
      call = expr(dm_add_pk(., !!sym(table_names), c(!!!syms(column_names))))
    )
  } else {
    list2(
      column_names = column_names,
      call = expr(dm_add_pk(., !!sym(table_names), !!sym(column_names)))
    )
  }
}
