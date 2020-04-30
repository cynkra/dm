#' Updating database tables
#'
#' @description
#' \lifecycle{experimental}
#'
#' These methods provide a framework for manipulating individual rows
#' in existing tables.
#' All operations expect that both existing and new data are presented
#' in two compatible [tbl] objects on the same data source.
#'
#' On mutable backends like databases, these operations manipulate the
#' underlying storage.
#' In contrast to all other operations,
#' these operations may lead to irreversible changes to the underlying database.
#' Therefore, in-place updates must be requested explicitly with `in_place = TRUE`.
#' By default, an informative message is given.
#' Unlike [compute()] or [copy_to()], no new tables are created.
#'
#' @inheritParams rows
#' @param check
#'   Set to `TRUE` to always check keys, or `FALSE` to never check.
#'   The default is to check only if `in_place` is `TRUE` or `NULL`.
#'
#' @return A tbl object of the same structure as `x`.
#'   If `in_place = TRUE`, [invisible] and identical to `x`.
#'
#' @name rows-db
#' @example example/rows-db.R
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

    columns_q <- colnames(y)
    columns_qq <- paste(columns_q, collapse = ", ")

    sql <- paste0(
      "INSERT INTO ", name, " (", columns_qq, ")\n",
      dbplyr::remote_query(y)
    )
    dbExecute(dbplyr::remote_con(x), sql)
    invisible(x)
  } else {
    # Checking mandatory by default, opt-out
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
  y <- auto_copy(x, y, copy = copy)
  y_key <- db_key(y, by)
  by <- names(y_key)
  x_key <- db_key(x, by)

  # FIXME: Case when y has no extra columns
  new_columns <- setdiff(colnames(y), by)

  name <- target_table_name(x, in_place)

  if (!is_null(name)) {
    # Checking optional, can rely on primary key constraint
    if (is_true(check)) {
      check_db_superset(x, y, by)
    }

    con <- dbplyr::remote_con(x)

    # https://stackoverflow.com/a/47753166/946850
    y_name <- DBI::dbQuoteIdentifier(con, "...y")
    y_columns_qq <- paste(
      DBI::dbQuoteIdentifier(con, colnames(y)),
      collapse = ", "
    )

    new_columns_q <- DBI::dbQuoteIdentifier(con, setdiff(colnames(y), by))
    new_columns_qq <- paste(new_columns_q, collapse = ", ")
    new_columns_qual_qq <- paste0(
      y_name, ".", new_columns_q,
      collapse = ", "
    )

    key_columns_q <- DBI::dbQuoteIdentifier(con, by)
    compare_qual_qq <- paste0(
      y_name, ".", key_columns_q,
      " = ",
      name, ".", key_columns_q,
      collapse = " AND "
    )

    sql <- paste0(
      "WITH ", y_name, "(", y_columns_qq, ") AS (\n",
      sql_render(y),
      "\n)\n",

      "UPDATE ", name, "\n",
      "SET (", new_columns_qq, ") = (\n",
      "SELECT ", new_columns_qual_qq, "\n",
      "FROM ", y_name, "\n",
      "WHERE (", compare_qual_qq, "))\n",
      "WHERE EXISTS (SELECT * FROM ", y_name, " WHERE ", compare_qual_qq, ")"
    )
    dbExecute(con, sql)
    invisible(x)
  } else {
    # Checking optional, can rely on primary key constraint
    if (is_null(check) || is_true(check)) {
      check_db_superset(x, y, by)
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
