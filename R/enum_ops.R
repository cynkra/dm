# FIXME: Implement choosing dm or connection object from .GlobalEnv
enum_ops <- function(dm, ..., table_names = NULL, column_names = NULL, op_name = NULL) {
  check_dots_empty()
  if (any_null(table_names, column_names, op_name)) {
    enum_ops_(op_name, dm, table_names, column_names)
  } else {
    list2(
      input = list(
        dm = dm,
        table_names = table_names,
        column_names = column_names,
        op_name = op_name
      ),
      !!!enum(op_name)(dm, table_names, column_names)
    )
  }
}

enum_ops_ <- function(op, dm, tbls, cols) {
  op %>%
    add_single(dm, tbls, cols) %>%
    add_multiple(dm, tbls, cols)
}

add_single <- function(op, dm, tbls, cols) {
  if (is.null(op)) {
    if (length(tbls) == 1) {
      op <- "dm_add_pk"
    } else if (length(tbls) == 2) {
      op <- "dm_add_fk"
    }
    if (length(dm) > 0 && is.null(cols)) {
      op <- c(op, "dm_rm_fk")
    }
    list(input = list(dm = dm), single = list(op_name = op))
  } else {
    nil <- set_names(list(), character())
    list(input = list(dm = dm, op_name = op), single = nil)
  }
}

add_multiple <- function(e, dm, tbls, cols) {
  e[["multiple"]] <- list(table_names = NULL, column_names = NULL)
  if (is.null(tbls)) {
    # FIXME: Restrict table_names based on selected operation
    e[["multiple"]][["table_names"]] <- names(eval_tidy(dm))
    e[["multiple"]][["column_names"]] <- cols
  } else {
    if (length(tbls) == 1) {
      if (is.null(cols)) {
        e[["multiple"]][["column_names"]] <- colnames(eval_tidy(dm)[[tbls]])
      } else {
        e[["input"]][["column_names"]] <- cols
      }
    }
    e[["input"]][["table_names"]] <- tbls
  }
  e[["multiple"]] <- compact(e[["multiple"]])
  e
}

# TODO: Add more operators
enum <- function(op) {
  switch(op,
    dm_add_pk = enum_ops_dm_add_pk
  )
}

enum_ops_dm_add_pk <- function(dm, tbls, cols) {
  stopifnot(length(tbls) == 1)
  columns <- if (length(cols) == 1) sym(cols) else expr(c(!!!syms(cols)))
  out <- list(call = expr(dm_add_pk(., !!sym(tbls), !!columns)))
  if (dm_has_pk(eval_tidy(dm), !!sym(tbls))) {
    out[["call"]] <- as.call(c(as.list(out[["call"]]), force = TRUE))
    out[["confirmation_message"]] <- paste(
      "This table already has a primary key.",
      "Please confirm overwriting the existing primary key."
    )
  }
  out
}

any_null <- function(...) {
  detect_index(list(...), is.null) != 0
}
