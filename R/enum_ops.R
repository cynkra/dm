enum_ops <- function(dm = NULL, ..., table_names = NULL, op_name = NULL) {
  if (!is.null(table_names) && !is.null(op_name)) {
    return(list2(
      table_names = table_names,
      op_name = op_name,
      !!!exec(paste0("enum_ops_", op_name), dm = dm, ..., table_names = table_names, op_name = op_name)
    ))
  }

  check_dots_empty()

  out <- list(
    table_names = names(dm),
    op_name = c(
      "dm_add_pk", # only if not all tables have PK
      "dm_add_fk",
      NULL
    )
  )

  if (!is.null(table_names)) {
    if (length(table_names) == 1) {
      out$op_name <- setdiff(out$op_name, "dm_add_fk")
    } else if (length(table_names) == 2) {
      out$op_name <- setdiff(out$op_name, "dm_add_pk")
    } else {
      out$op_name <- setdiff(out$op_name, c("dm_add_pk", "dm_add_fk"))
    }

    out$table_names <- table_names
  }

  if (!is.null(op_name)) {
    # FIXME: Restrict table_names based on selected operation

    out$op_name <- op_name
  }

  out
}

enum_ops_dm_add_pk <- function(dm = NULL, ..., table_names = NULL) {
  if (is.null(table_names)) {
    check_dots_empty()
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

enum_ops_dm_add_pk_table <- function(dm = NULL, ..., op_name, table_names, column_names = NULL) {
  stopifnot(length(table_names) == 1)

  if (is.null(column_names)) {
    check_dots_empty()
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
