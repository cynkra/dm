#' Persisting data for database tables
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
#' Therefore, persistence must be requested explicitly with `.persist = TRUE`.
#' By default, an informative message is given.
#' Unlike [compute()] or [copy_to()], no new tables are created.
#'
#' @inheritParams rows
#' @param .persist
#'   Set to `FALSE` for running the operation without persisting.
#'   In this mode, a modified version of `.data` is returned.
#'   This allows verifying the results of an operation before actually
#'   applying it.
#'   Set to `TRUE` to perform the update on the database table.
#'   The default is `FALSE` with an informative message.
#' @param .copy
#'   Set to `TRUE` to automatically copy the new data to the database if
#'   necessary.
#' @param .check
#'   Set to `TRUE` to always check keys, or `FALSE` to never check.
#'   The default is to check only if `.persist` is `TRUE` or `NULL`.
#'
#' @return A tbl object of the same structure as `.data`.
#'   If `.persist = TRUE`, [invisible] and identical to `.data`.
#'
#' @name rows-db
#' @example example/rows-db.R
NULL

#' @export
#' @rdname rows-db
rows_insert.tbl_SQLiteConnection <- function(.data, .key = NULL, ...,
                                             .persist = NULL,
                                             .copy = NULL, .check = NULL) {

  .key <- tidyselect::eval_select(
    enexpr(.key),
    tibble(!!!set_names(colnames(.data)))
  )

  # Copy to database if permitted and needed
  source <- copy_dots_to_db(.data, .key, .copy, ...)

  # Message if .persist is NULL
  .persist <- validate_persist(.persist)

  # Also in dry-run mode, for early notification of problems
  name <- target_table_name(.data, .persist)

  if (.persist) {
    # Checking optional, can rely on primary key constraint
    if (is_true(.check)) {
      check_db_dupes(.data, source, .key)
    }

    columns_q <- colnames(source)
    columns_qq <- paste(columns_q, collapse = ", ")

    sql <- paste0(
      "INSERT INTO ", name, " (", columns_qq, ")\n",
      dbplyr::remote_query(source)
    )
    dbExecute(dbplyr::remote_con(.data), sql)
    invisible(NULL)
  } else {
    # Checking mandatory by default, opt-out
    if (is_null(.check) || is_true(.check)) {
      check_db_dupes(.data, source, .key)
    }
    union_all(.data, source)
  }
}

#' @export
#' @rdname rows-db
rows_update.tbl_SQLiteConnection <- function(.data, .key = NULL, ...,
                                             .persist = NULL,
                                             .copy = NULL, .check = NULL) {

  .key <- tidyselect::eval_select(
    enexpr(.key),
    tibble(!!!set_names(colnames(.data)))
  )

  # Copy to database if permitted and needed
  source <- copy_dots_to_db(.data, .key, .copy, ...)

  # Message if .persist is NULL
  .persist <- validate_persist(.persist)

  # Also in dry-run mode, for early notification of problems
  name <- target_table_name(.data, .persist)

  # FIXME: Case when source has no extra columns
  new_columns <- setdiff(colnames(source), names(.key))

  if (.persist) {
    # Checking optional, can rely on primary key constraint
    if (is_true(.check)) {
      check_db_superset(.data, source, .key)
    }

    con <- dbplyr::remote_con(.data)

    # https://stackoverflow.com/a/47753166/946850
    source_name <- DBI::dbQuoteIdentifier(con, "...source")
    source_columns_qq <- paste(
      DBI::dbQuoteIdentifier(con, colnames(source)),
      collapse = ", "
    )

    new_columns_q <- DBI::dbQuoteIdentifier(con, setdiff(colnames(source), names(.key)))
    new_columns_qq <- paste(new_columns_q, collapse = ", ")
    new_columns_qual_qq <- paste0(
      source_name, ".", new_columns_q,
      collapse = ", "
    )

    key_columns_q <- DBI::dbQuoteIdentifier(con, names(.key))
    compare_qual_qq <- paste0(
      source_name, ".", key_columns_q,
      " = ",
      name, ".", key_columns_q,
      collapse = " AND "
    )

    sql <- paste0(
      "WITH ", source_name, "(", source_columns_qq, ") AS (\n",
      sql_render(source),
      "\n)\n",

      "UPDATE ", name, "\n",
      "SET (", new_columns_qq, ") = (\n",
      "SELECT ", new_columns_qual_qq, "\n",
      "FROM ", source_name, "\n",
      "WHERE (", compare_qual_qq, "))\n",
      "WHERE EXISTS (SELECT * FROM ", source_name, " WHERE ", compare_qual_qq, ")"
    )
    dbExecute(dbplyr::remote_con(.data), sql)
    invisible(.data)
  } else {
    # Checking optional, can rely on primary key constraint
    if (is_null(.check) || is_true(.check)) {
      check_db_superset(.data, source, .key)
    }

    existing_columns <- setdiff(colnames(.data), new_columns)

    unchanged <- anti_join(.data, source, by = names(.key))
    updated <-
      .data %>%
      select(!!!existing_columns) %>%
      inner_join(source, by = names(.key))

    union_all(unchanged, updated)
  }
}

validate_persist <- function(persist) {
  if (is_null(persist)) {
    message('Not persisting, use `.persist = FALSE` to turn off this message. See `?"rows-db" for details.')
    persist <- FALSE
  }
  is_true(persist)
}

target_table_name <- function(x, persist) {
  name <- dbplyr::remote_name(x)
  if (is.null(name)) {
    raise <- if (persist) abort else warn
    raise("Can't determine name for target table.")
  }
  name
}

copy_dots_to_db <- function(.data, .key, .copy, ...) {
  df <- dots_to_df(.data, .key, ...)
  if (is_null(.copy)) {
    .copy <- FALSE
  }
  auto_copy(.data, df, copy = .copy)
}

check_db_dupes <- function(.data, source, .key) {
  # FIXME
}

check_db_superset <- function(.data, source, .key) {
  # FIXME
}
