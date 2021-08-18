#' Updating database tables
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' These methods provide a framework for manipulating individual rows
#' in existing tables.
#' All operations expect that both existing and new data are presented
#' in two compatible [tbl] objects.
#'
#' If `y` lives on a different data source than `x`, it can be copied automatically
#' by setting `copy = TRUE`, just like for [dplyr::left_join()].
#'
#' On mutable backends like databases, these operations manipulate the
#' underlying storage.
#' In contrast to all other operations,
#' these operations may lead to irreversible changes to the underlying database.
#' Therefore, in-place updates must be requested explicitly with `in_place = TRUE`.
#' By default, an informative message is given.
#' Unlike [compute()] or [copy_to()], no new tables are created.
#'
#' @inheritParams dplyr::rows_insert
#' @param check
#'   Set to `TRUE` to always check keys, or `FALSE` to never check.
#'   The default is to check only if `in_place` is `TRUE` or `NULL`.
#'
#'   Currently these checks are no-ops and need yet to be implemented.
#'
#' @return A tbl object of the same structure as `x`.
#'   If `in_place = TRUE`, the underlying data is updated as a side effect,
#'   and `x` is returned, invisibly.
#'
#' @name rows-db
#' @examplesIf rlang::is_installed("dbplyr")
#' data <- dbplyr::memdb_frame(a = 1:3, b = letters[c(1:2, NA)], c = 0.5 + 0:2)
#' data
#'
#' try(rows_insert(data, tibble::tibble(a = 4, b = "z")))
#' rows_insert(data, tibble::tibble(a = 4, b = "z"), copy = TRUE)
#' rows_update(data, tibble::tibble(a = 2:3, b = "w"), copy = TRUE, in_place = FALSE)
#'
#' rows_insert(data, dbplyr::memdb_frame(a = 4, b = "z"), in_place = TRUE)
#' data
#' rows_update(data, dbplyr::memdb_frame(a = 2:3, b = "w"), in_place = TRUE)
#' data
NULL

#' @export
#' @rdname rows-db
rows_insert.tbl_dbi <- function(x, y, by = NULL, ...,
                                in_place = NULL, copy = FALSE, check = NULL) {
  y <- auto_copy(x, y, copy = copy)
  y_key <- db_key(y, by)
  by <- names(y_key)
  x_key <- db_key(x, by)

  name <- target_table_name(x, in_place)

  if (!is_null(name)) {
    # Checking optional, can rely on primary key constraint
    if (is_true(check)) {
      check_db_dupes(x, y, by)
    }

    con <- dbplyr::remote_con(x)
    sql <- sql_rows_insert(x, y)
    dbExecute(con, sql, immediate = TRUE)
    invisible(x)
  } else {
    # Checking mandatory by default, opt-out
    # FIXME: contrary to doc currently also checks if `in_place = FALSE`
    if (is_null(check) || is_true(check)) {
      check_db_dupes(x, y, by)
    }
    union_all(x, y)
  }
}

#' @export
#' @rdname rows-db
rows_update.tbl_dbi <- function(x, y, by = NULL, ...,
                                in_place = NULL, copy = FALSE, check = NULL) {
  rows_update_impl(
    x, y, by = by,
    in_place = in_place,
    copy = copy,
    check = check,
    f_update = function(x, y) y
  )
}

#' @export
#' @rdname rows-db
rows_patch.tbl_dbi <- function(x, y, by = NULL, ...,
                               in_place = NULL, copy = FALSE, check = NULL) {
  rows_update_impl(
    x, y, by = by,
    in_place = in_place,
    copy = copy,
    check = check,
    f_update = f_patch
  )
}

rows_update_impl <- function(x, y, by = NULL, ...,
                             in_place = NULL, copy = FALSE, check = NULL,
                             f_update = NULL) {
  f_update <- f_update %||% function(x, y) y

  y <- auto_copy(x, y, copy = copy)
  y_key <- db_key(y, by)
  by <- names(y_key)
  x_key <- db_key(x, by)

  new_columns <- setdiff(colnames(y), by)

  name <- target_table_name(x, in_place)

  if (!is_null(name)) {
    # Checking optional, can rely on primary key constraint
    if (is_true(check)) {
      check_db_superset(x, y, by)
    }

    if (is_empty(new_columns)) {
      return(invisible(x))
    }

    con <- dbplyr::remote_con(x)
    sql <- sql_rows_update(x, y, by, f_update = f_update)
    dbExecute(con, sql, immediate = TRUE)
    invisible(x)
  } else {
    # Checking optional, can rely on primary key constraint
    # FIXME: contrary to doc currently also checks if `in_place = FALSE`
    if (is_null(check) || is_true(check)) {
      check_db_superset(x, y, by)
    }

    if (is_empty(new_columns)) {
      return(x)
    }

    existing_columns <- setdiff(colnames(x), new_columns)

    unchanged <- anti_join(x, y, by = by)
    updated <-
      x %>%
      select(!!!existing_columns) %>%
      inner_join(y, by = by)

    union_all(unchanged, updated)
  }
}

#' @export
#' @rdname rows-db
rows_delete.tbl_dbi <- function(x, y, by = NULL, ...,
                                in_place = NULL, copy = FALSE, check = NULL) {
  y <- auto_copy(x, y, copy = copy)
  y_key <- db_key(y, by)
  by <- names(y_key)
  x_key <- db_key(x, by)

  name <- target_table_name(x, in_place)

  if (!is_null(name)) {
    # Checking optional, can rely on primary key constraint
    if (is_true(check)) {
      check_db_superset(x, y, by)
    }

    con <- dbplyr::remote_con(x)
    sql <- sql_rows_delete(x, y, by)
    dbExecute(con, sql, immediate = TRUE)
    invisible(x)
  } else {
    # Checking optional, can rely on primary key constraint
    # FIXME: contrary to doc currently also checks if `in_place = FALSE`
    if (is_null(check) || is_true(check)) {
      check_db_superset(x, y, by)
    }

    anti_join(x, y, by = by)
  }
}

target_table_name <- function(x, in_place) {
  name <- dbplyr::remote_name(x)

  # Only write if requested
  if (!is_null(name) && is_true(in_place)) {
    return(name)
  }

  # Abort if requested but can't write
  if (is_null(name) && is_true(in_place)) {
    abort("Can't determine name for target table. Set `in_place = FALSE` to return a lazy table.")
  }

  # Verbose by default
  if (is_null(in_place)) {
    if (is_null(name)) {
      inform("Result is returned as lazy table, because `x` does not correspond to a table that can be updated. Use `in_place = FALSE` to mute this message.")
    } else {
      inform("Result is returned as lazy table. Use `in_place = FALSE` to mute this message, or `in_place = TRUE` to write to the underlying table.")
    }
  }

  # Never write unless handled above
  NULL
}


db_key <- function(y, by) {
  if (is_null(by)) {
    set_names(1L, colnames(y)[[1]])
  } else {
    idx <- match(by, colnames(y))
    set_names(idx, by)
  }
}

check_db_dupes <- function(x, y, by) {
  # FIXME
}

check_db_superset <- function(x, y, by) {
  # FIXME
}

#' @description
#' The `sql_rows_*()` functions return the SQL used for the corresponding
#' `rows_*()` function with `in_place = FALSE`.
#' `y` needs to be located on the same data source as `x`.
#'
#' @export
#' @rdname rows-db
sql_rows_insert <- function(x, y, ...) {
  ellipsis::check_dots_used()
  # FIXME: check here same src for x and y? if not -> error.
  UseMethod("sql_rows_insert")
}

#' @export
sql_rows_insert.tbl_sql <- function(x, y, ...) {
  con <- dbplyr::remote_con(x)
  name <- dbplyr::remote_name(x)

  columns_q <- DBI::dbQuoteIdentifier(con, colnames(y))
  columns_qq <- paste(columns_q, collapse = ", ")

  sql <- paste0(
    "INSERT INTO ", name, " (", columns_qq, ")\n",
    dbplyr::remote_query(y)
  )
  glue::as_glue(sql)
}

#' @export
#' @rdname rows-db
sql_rows_update <- function(x, y, by, ..., f_update) {
  ellipsis::check_dots_used()
  # FIXME: check here same src for x and y? if not -> error.
  UseMethod("sql_rows_update")
}

#' @export
sql_rows_update.tbl_SQLiteConnection <- function(x, y, by, ..., f_update) {
  con <- dbplyr::remote_con(x)

  p <- sql_rows_update_prep(x, y, by, f_update)

  sql <- paste0(
    "WITH ", p$y_name, "(", p$y_columns_qq, ") AS (\n",
    dbplyr::sql_render(y),
    "\n)\n",
    #
    "UPDATE ", p$name, "\n",
    "SET (", p$new_columns_qq, ") = (\n",
    "SELECT ", p$new_columns_qual_qq, "\n",
    "FROM ", p$y_name, "\n",
    "WHERE (", p$compare_qual_qq, "))\n",
    "WHERE EXISTS (SELECT * FROM ", p$y_name, " WHERE ", p$compare_qual_qq, ")"
  )
  glue::as_glue(sql)
}

#' @export
`sql_rows_update.tbl_Microsoft SQL Server` <- function(x, y, by, ...) {
  con <- dbplyr::remote_con(x)

  p <- sql_rows_update_prep(x, y, by)

  # https://stackoverflow.com/a/2334741/946850
  sql <- paste0(
    "WITH ", p$y_name, "(", p$y_columns_qq, ") AS (\n",
    dbplyr::sql_render(y),
    "\n)\n",
    #
    "UPDATE ", p$name, "\n",
    "SET\n",
    paste0(
      "  ", unlist(p$new_columns_qq_list),
      " = ", unlist(p$new_columns_qual_qq_list),
      collapse = ",\n"
    ),
    "\n",
    "FROM ", p$name, "\n",
    "  INNER JOIN ", p$y_name, "\n",
    "  ON ", p$compare_qual_qq
  )
  glue::as_glue(sql)
}

#' @export
sql_rows_update.tbl_MariaDBConnection <- function(x, y, by, ...) {
  con <- dbplyr::remote_con(x)

  p <- sql_rows_update_prep(x, y, by)

  # https://stackoverflow.com/a/19346375/946850
  sql <- paste0(
    "UPDATE ", p$name, "\n",
    "  INNER JOIN (\n", dbplyr::sql_render(y), "\n) AS ", p$y_name, "\n",
    "  ON ", p$compare_qual_qq, "\n",
    "SET\n",
    paste0("  ", p$target_columns_qual_qq, " = ", p$new_columns_qual_qq, collapse = ",\n")
  )
  glue::as_glue(sql)
}

#' @export
sql_rows_update.tbl_PqConnection <- function(x, y, by, ...) {
  con <- dbplyr::remote_con(x)

  p <- sql_rows_update_prep(x, y, by)

  # https://www.postgresql.org/docs/9.5/sql-update.html
  sql <- paste0(
    "WITH ", p$y_name, " AS (\n",
    dbplyr::sql_render(y),
    "\n)\n",
    #
    "UPDATE ", p$name, "\n",
    "SET\n",
    paste0(
      "  ", unlist(p$new_columns_qq_list),
      " = ", unlist(p$new_columns_qual_qq_list),
      collapse = ",\n"
    ),
    "\n",
    "FROM ", p$y_name, "\n",
    "WHERE ", p$compare_qual_qq
  )
  glue::as_glue(sql)
}

#' @export
sql_rows_update.tbl_duckdb_connection <- sql_rows_update.tbl_SQLiteConnection

sql_rows_patch <- function(x, y, by, ...) {
  sql_rows_update(x, y, by, ..., f_update = f_patch)
}

f_patch <- function(x, y) {
  paste0("COALESCE(", x, ", ", y, ")")
}

sql_rows_update_prep <- function(x, y, by, f_update = function(x, y) y) {
  con <- dbplyr::remote_con(x)
  name <- dbplyr::remote_name(x)

  # https://stackoverflow.com/a/47753166/946850
  y_name <- DBI::dbQuoteIdentifier(con, "...y")
  y_columns_qq <- paste(
    DBI::dbQuoteIdentifier(con, colnames(y)),
    collapse = ", "
  )

  new_columns_q <- DBI::dbQuoteIdentifier(con, setdiff(colnames(y), by))
  new_columns_qq <- paste(new_columns_q, collapse = ", ")
  new_columns_qq_list <- list(new_columns_q)

  new_columns_qual_qq_list <- list(f_update(
    x = paste0(name, ".", new_columns_q),
    y = paste0(y_name, ".", new_columns_q)
  ))
  new_columns_qual_qq <- paste0(new_columns_qual_qq_list, collapse = ", ")

  key_columns_q <- DBI::dbQuoteIdentifier(con, by)
  compare_qual_qq <- paste0(
    y_name, ".", key_columns_q,
    " = ",
    name, ".", key_columns_q,
    collapse = " AND "
  )

  tibble(
    name, y_name,
    y_columns_qq,
    new_columns_qq, new_columns_qq_list,
    new_columns_qual_qq, new_columns_qual_qq_list,
    compare_qual_qq
  )
}

#' @export
#' @rdname rows-db
sql_rows_delete <- function(x, y, by, ...) {
  ellipsis::check_dots_used()
  # FIXME: check here same src for x and y? if not -> error.
  UseMethod("sql_rows_delete")
}

#' @export
sql_rows_delete.tbl_sql <- function(x, y, by, ...) {
  con <- dbplyr::remote_con(x)

  p <- sql_rows_update_prep(x, y, by)

  sql <- paste0(
    "WITH ", p$y_name, "(", p$y_columns_qq, ") AS (\n",
    dbplyr::sql_render(y),
    "\n)\n",
    #
    "DELETE FROM ", p$name, "\n",
    "WHERE EXISTS (SELECT * FROM ", p$y_name, " WHERE ", p$compare_qual_qq, ")"
  )
  glue::as_glue(sql)
}
