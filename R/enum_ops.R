enum_ops <- function(dm = NULL, ..., table_names = NULL, column_names = NULL, op_name = NULL) {
  # FIXME: Implement choosing dm or connection object from .GlobalEnv
  stopifnot(!is.null(dm))

  if (!is.null(table_names) && !is.null(op_name)) {
    return(
      list2(
        input = list2(
          dm = dm,
          table_names = table_names,
          column_names = column_names,
          op_name = op_name,
          ...,
        ),
        !!!exec(
          paste0("enum_ops_", op_name),
          dm = dm, ...,
          table_names = table_names,
          column_names = column_names,
          op_name = op_name
        )
      )
    )
  }

  check_dots_empty()

  input <- list(dm = dm)

  if (is.null(op_name)) {
    op_name <- character()
    if (length(table_names) == 1) {
      op_name <- c(op_name, "dm_add_pk")
    } else if (length(table_names) == 2) {
      op_name <- c(op_name, "dm_add_fk")
    }

    if (length(dm) > 0 && is.null(column_names)) {
      op_name <- c(op_name, "dm_rm_fk")
    }
  } else {
    input <- c(input, op_name = op_name)
    op_name <- NULL
  }

  if (is.null(table_names)) {
    # FIXME: Restrict table_names based on selected operation

    table_names <- names(eval_tidy(dm))
  } else {
    if (length(table_names) == 1) {
      if (is.null(column_names)) {
        column_names <- colnames(eval_tidy(dm)[[table_names]])
      } else {
        input <- c(input, column_names = column_names)
        column_names <- NULL
      }
    } else {
      stopifnot(is.null(column_names))
    }

    input <- c(input, table_names = table_names)
    table_names <- NULL
  }

  list(
    input = input,
    single = compact(list2(
      op_name = op_name,
    )),
    multiple = compact(list2(
      table_names = table_names,
      column_names = column_names,
    ))
  )
}

enum_ops_dm_add_pk <- function(dm = NULL, ..., table_names = NULL) {
  if (is.null(table_names)) {
    check_dots_empty()
    # enumerate all tables that don't have a pk
    list(single = list(
      table_names = names(dm)
    ))
  } else {
    stopifnot(length(table_names) == 1)

    enum_ops_dm_add_pk_table(dm, ..., table_names = table_names)
  }
}

enum_ops_dm_add_pk_table <- function(dm = NULL, ..., op_name, table_names, column_names = NULL) {
  stopifnot(length(table_names) == 1)

  if (is.null(column_names)) {
    check_dots_empty()
    # enumerate all columns that are not list
    return(list(multiple = list(
      column_names = colnames(dm[[table_names]])
    )))
  }

  if (length(column_names) > 1) {
    out <- list2(
      call = expr(dm_add_pk(., !!sym(table_names), c(!!!syms(column_names))))
    )
  } else {
    out <- list2(
      call = expr(dm_add_pk(., !!sym(table_names), !!sym(column_names)))
    )
  }

  if (dm_has_pk(eval_tidy(dm), !!sym(table_names))) {
    out$call <- as.call(c(as.list(out$call), force = TRUE))
    out$confirmation_message <- "This table already has a primary key. Please confirm overwriting the existing primary key."
  }

  out
}
