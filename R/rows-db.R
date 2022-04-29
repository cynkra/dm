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
#' @param returning `r lifecycle::badge("experimental")`
#'   <[`tidy-select`][tidyr_tidy_select]> Columns to return of the inserted data.
#'   Note that also columns not in `y` but automatically created when inserting
#'   into `x` can be returned, for example the `id` column.
#'
#'   Due to upstream limitations, a warning is given if this argument
#'   is passed unquoted.
#'   To avoid the warning, quote the argument manually:
#'   use e.g. `returning = quote(everything())` .
#'
#' @return A tbl object of the same structure as `x`.
#'   If `in_place = TRUE`, the underlying data is updated as a side effect,
#'   and `x` is returned, invisibly. If return columns are specified with
#'   `returning` then the resulting tibble is stored in the attribute
#'   `returned_rows`. This can be accessed with [get_returned_rows()].
#'
#' @name rows-db
#' @examplesIf rlang::is_installed("dbplyr")
#' data <- dbplyr::memdb_frame(a = 1:3, b = letters[c(1:2, NA)], c = 0.5 + 0:2)
#' data
#'
#' try(rows_insert(data, tibble::tibble(a = 4, b = "z")))
#' rows_insert(data, tibble::tibble(a = 4, b = "z"), copy = TRUE)
#' rows_update(data, tibble::tibble(a = 2:3, b = "w"), copy = TRUE, in_place = FALSE)
#' rows_patch(data, dbplyr::memdb_frame(a = 1:4, c = 0), in_place = FALSE)
#'
#' rows_insert(data, dbplyr::memdb_frame(a = 4, b = "z"), in_place = TRUE)
#' data
#' rows_update(data, dbplyr::memdb_frame(a = 2:3, b = "w"), in_place = TRUE)
#' data
#' rows_patch(data, dbplyr::memdb_frame(a = 1:4, c = 0), in_place = TRUE)
#' data
NULL

#' @rdname rows-db
rows_insert.tbl_lazy <- function(x, y, by = NULL, ...,
                                 in_place = FALSE,
                                 conflict = NULL,
                                 copy = FALSE,
                                 returning = NULL) {
  stopifnot(identical(conflict, "ignore"))

  # Expect manual quote from user, silently fall back to enexpr()
  returning_expr <- enexpr(returning)
  returning_cols <- tryCatch(
    eval_select_both(returning, colnames(x))$names,
    error = function(e) {
      eval_select_both(returning_expr, colnames(x))$names
    }
  )

  y <- auto_copy(x, y, copy = copy)
  y_key <- db_key(y, by)
  by <- names(y_key)
  x_key <- db_key(x, by)

  name <- target_table_name(x, in_place)

  if (!is_null(name)) {
    con <- dbplyr::remote_con(x)
    sql <- sql_rows_insert(x, y %>% anti_join(x, by = by), returning_cols = returning_cols)

    rows_get_or_execute(x, con, sql, returning_cols)
  } else {
    returned_x <- union_all(x, y %>% anti_join(x, by = by))

    if (!is_empty(returning_cols)) {
      # Need to `union_all()` with `x` so that all columns of `x` exist in the result
      returned_rows <- union_all(y, x %>% filter(0 == 1)) %>%
        select(returning_cols) %>%
        collect()
      returned_x <- set_returned_rows(returned_x, returned_rows)
    }

    returned_x
  }
}

#' @rdname rows-db
rows_append.tbl_lazy <- function(x, y, ...,
                                 in_place = FALSE,
                                 copy = FALSE,
                                 returning = NULL) {

  # Expect manual quote from user, silently fall back to enexpr()
  returning_expr <- enexpr(returning)
  tryCatch(
    returning_expr <- returning,
    error = identity
  )

  returning_cols <- eval_select_both(returning_expr, colnames(x))$names

  y <- auto_copy(x, y, copy = copy)

  name <- target_table_name(x, in_place)

  if (!is_null(name)) {
    con <- dbplyr::remote_con(x)
    sql <- sql_rows_insert(x, y, returning_cols = returning_cols)

    rows_get_or_execute(x, con, sql, returning_cols)
  } else {
    returned_x <- union_all(x, y)

    if (!is_empty(returning_cols)) {
      # Need to `union_all()` with `x` so that all columns of `x` exist in the result
      returned_rows <- union_all(y, x %>% filter(0 == 1)) %>%
        select(returning_cols) %>%
        collect()
      returned_x <- set_returned_rows(returned_x, returned_rows)
    }

    returned_x
  }
}

#' @rdname rows-db
rows_update.tbl_lazy <- function(x, y, by = NULL, ...,
                                 in_place = FALSE,
                                 unmatched = NULL,
                                 copy = FALSE,
                                 returning = NULL) {
  stopifnot(identical(unmatched, "ignore"))

  # Expect manual quote from user, silently fall back to enexpr()
  returning_expr <- enexpr(returning)
  returning_cols <- tryCatch(
    eval_select_both(returning, colnames(x))$names,
    error = function(e) {
      eval_select_both(returning_expr, colnames(x))$names
    }
  )

  returning_cols <- eval_select_both(returning_expr, colnames(x))$names

  y <- auto_copy(x, y, copy = copy)
  y_key <- db_key(y, by)
  by <- names(y_key)
  x_key <- db_key(x, by)

  new_columns <- setdiff(colnames(y), by)

  name <- target_table_name(x, in_place)

  if (!is_null(name)) {
    if (is_empty(new_columns)) {
      return(invisible(x))
    }

    con <- dbplyr::remote_con(x)
    sql <- sql_rows_update(x, y, by, returning_cols = returning_cols)

    rows_get_or_execute(x, con, sql, returning_cols)
  } else {
    existing_columns <- setdiff(colnames(x), new_columns)
    updated <- x %>%
      select(!!!existing_columns) %>%
      inner_join(y, by = by)

    if (is_empty(new_columns)) {
      returned_x <- x
    } else {
      unchanged <- anti_join(x, y, by = by)
      returned_x <- union_all(unchanged, updated)
    }

    if (!is_empty(returning_cols)) {
      returned_rows <- updated %>%
        select(!!!returning_cols) %>%
        collect()
      returned_x <- set_returned_rows(returned_x, returned_rows)
    }

    returned_x
  }
}

#' @rdname rows-db
rows_patch.tbl_lazy <- function(x, y, by = NULL, ...,
                                in_place = FALSE,
                                unmatched = NULL,
                                copy = FALSE,
                                returning = NULL) {
  stopifnot(identical(unmatched, "ignore"))

  # Expect manual quote from user, silently fall back to enexpr()
  returning_expr <- enexpr(returning)
  returning_cols <- tryCatch(
    eval_select_both(returning, colnames(x))$names,
    error = function(e) {
      eval_select_both(returning_expr, colnames(x))$names
    }
  )

  returning_cols <- eval_select_both(returning_expr, colnames(x))$names

  y <- auto_copy(x, y, copy = copy)
  y_key <- db_key(y, by)
  by <- names(y_key)
  x_key <- db_key(x, by)

  new_columns <- setdiff(colnames(y), by)

  name <- target_table_name(x, in_place)

  if (!is_null(name)) {
    if (is_empty(new_columns)) {
      return(invisible(x))
    }

    con <- dbplyr::remote_con(x)
    sql <- sql_rows_patch(x, y, by, returning_cols = returning_cols)

    rows_get_or_execute(x, con, sql, returning_cols)
  } else {
    to_patch <- inner_join(
      x, y,
      by = by,
      suffix = c("", "...y")
    )

    patch_columns_y <- paste0(new_columns, "...y")
    patch_quos <- lapply(new_columns, function(.x) quo(coalesce(!!sym(.x), !!sym(patch_columns_y)))) %>%
      rlang::set_names(new_columns)
    if (is_empty(new_columns)) {
      patched <- to_patch
      returned_x <- x
    } else {
      patched <- to_patch %>%
        mutate(!!!patch_quos) %>%
        select(-all_of(patch_columns_y))
      unchanged <- anti_join(x, y, by = by)
      returned_x <- union_all(unchanged, patched)
    }

    if (!is_empty(returning_cols)) {
      returned_rows <- patched %>%
        select(!!!returning_cols) %>%
        collect()
      returned_x <- set_returned_rows(returned_x, returned_rows)
    }

    returned_x
  }
}

#' @rdname rows-db
rows_upsert.tbl_lazy <- function(x, y, by = NULL, ...,
                                 in_place = FALSE,
                                 copy = FALSE,
                                 returning = NULL) {

  # Expect manual quote from user, silently fall back to enexpr()
  returning_expr <- enexpr(returning)
  returning_cols <- tryCatch(
    eval_select_both(returning, colnames(x))$names,
    error = function(e) {
      eval_select_both(returning_expr, colnames(x))$names
    }
  )

  returning_cols <- eval_select_both(enquo(returning), colnames(x))$names

  y <- auto_copy(x, y, copy = copy)
  y_key <- db_key(y, by)
  by <- names(y_key)
  x_key <- db_key(x, by)

  new_columns <- setdiff(colnames(y), by)

  name <- target_table_name(x, in_place)

  if (!is_null(name)) {
    if (is_empty(new_columns)) {
      return(invisible(x))
    }

    con <- dbplyr::remote_con(x)
    sql <- sql_rows_upsert(x, y, by, returning_cols = returning_cols)

    rows_get_or_execute(x, con, sql, returning_cols)
  } else {
    existing_columns <- setdiff(colnames(x), new_columns)

    unchanged <- anti_join(x, y, by = by)
    inserted <- anti_join(y, x, by = by)
    updated <-
      x %>%
      select(!!!existing_columns) %>%
      inner_join(y, by = by)
    upserted <- union_all(updated, inserted)

    returned_x <- union_all(unchanged, upserted)

    if (!is_empty(returning_cols)) {
      returned_rows <- upserted %>%
        select(!!!returning_cols) %>%
        collect()
      returned_x <- set_returned_rows(returned_x, returned_rows)
    }

    returned_x
  }
}

#' @rdname rows-db
rows_delete.tbl_lazy <- function(x, y, by = NULL, ...,
                                 in_place = FALSE,
                                 unmatched = NULL,
                                 copy = FALSE,
                                 returning = NULL) {
  stopifnot(identical(unmatched, "ignore"))

  # Expect manual quote from user, silently fall back to enexpr()
  returning_expr <- enexpr(returning)
  returning_cols <- tryCatch(
    eval_select_both(returning, colnames(x))$names,
    error = function(e) {
      eval_select_both(returning_expr, colnames(x))$names
    }
  )

  y <- auto_copy(x, y, copy = copy)
  y_key <- db_key(y, by)
  by <- names(y_key)
  x_key <- db_key(x, by)

  name <- target_table_name(x, in_place)

  if (!is_null(name)) {
    con <- dbplyr::remote_con(x)
    sql <- sql_rows_delete(x, y, by, returning_cols = returning_cols)
    rows_get_or_execute(x, con, sql, returning_cols)
  } else {
    returned_x <- anti_join(x, y, by = by)

    if (!is_empty(returning_cols)) {
      returned_rows <- semi_join(x, y, by = by) %>%
        select(returning_cols) %>%
        collect()
      returned_x <- set_returned_rows(returned_x, returned_rows)
    }

    returned_x
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

check_returning_cols_possible <- function(returning_cols, in_place) {
  if (is_false(in_place) & !is_empty(returning_cols)) {
    abort("`returning` only works if `in_place` is true.")
  }
}


#' @description
#' The `sql_rows_*()` functions return the SQL used for the corresponding
#' `rows_*()` function with `in_place = FALSE`.
#' `y` needs to be located on the same data source as `x`.
#'
#' @param returning_cols A character vector of unquote column names
#'   to return, created from the `returning` argument.
#'   Methods for database that do not support this should raise an error.
#'
#' @rdname rows-db
sql_rows_insert <- function(x, y, ..., returning_cols = NULL) {
  ellipsis::check_dots_used()
  # FIXME: check here same src for x and y? if not -> error.
  UseMethod("sql_rows_insert")
}

#' @export
sql_rows_insert.tbl_sql <- function(x, y, ..., returning_cols = NULL) {
  con <- dbplyr::remote_con(x)
  name <- dbplyr::remote_name(x)

  columns_q <- DBI::dbQuoteIdentifier(con, colnames(y))
  columns_qq <- paste(columns_q, collapse = ", ")

  sql <- paste0(
    "INSERT INTO ", name, " (", columns_qq, ")\n",
    sql_output_cols(x, returning_cols), "\n",
    dbplyr::remote_query(y),
    sql_returning_cols(x, returning_cols)
  )

  glue::as_glue(sql)
}

#' @rdname rows-db
sql_rows_update <- function(x, y, by, ..., returning_cols = NULL) {
  ellipsis::check_dots_used()
  # FIXME: check here same src for x and y? if not -> error.
  UseMethod("sql_rows_update")
}

#' @export
sql_rows_update.tbl_sql <- function(x, y, by, ..., returning_cols = NULL) {
  # * avoid CTEs for the general case as they do not work everywhere
  con <- dbplyr::remote_con(x)

  p <- sql_rows_prep(x, y, by)

  sql <- paste0(
    "UPDATE ", p$name, "\n",
    "SET\n",
    paste0(
      "  ", unlist(p$new_columns_qq_list),
      " = ", unlist(p$new_columns_qual_qq_list),
      collapse = ",\n"
    ), "\n",
    "FROM (\n",
    "    ", dbplyr::sql_render(y), "\n",
    "  ) AS ", p$y_name, "\n",
    "WHERE (", p$compare_qual_qq, ")\n",
    sql_returning_cols(x, returning_cols)
  )

  glue::as_glue(sql)
}

#' @export
`sql_rows_update.tbl_Microsoft SQL Server` <- function(x, y, by, ..., returning_cols = NULL) {
  con <- dbplyr::remote_con(x)

  p <- sql_rows_prep(x, y, by)

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
    sql_output_cols(x, returning_cols),
    "FROM ", p$name, "\n",
    "  INNER JOIN ", p$y_name, "\n",
    "  ON ", p$compare_qual_qq
  )

  glue::as_glue(sql)
}

#' @export
sql_rows_update.tbl_MariaDBConnection <- function(x, y, by, ..., returning_cols = NULL) {
  con <- dbplyr::remote_con(x)

  p <- sql_rows_prep(x, y, by)

  # https://stackoverflow.com/a/19346375/946850
  sql <- paste0(
    "UPDATE ", p$name, "\n",
    "  INNER JOIN (\n", dbplyr::sql_render(y), "\n) AS ", p$y_name, "\n",
    "  ON ", p$compare_qual_qq, "\n",
    "SET\n",
    paste0("  ", p$new_columns_qual_qq, " = ", p$new_columns_qual_qq, collapse = ",\n"),
    sql_returning_cols(x, returning_cols)
  )

  glue::as_glue(sql)
}

sql_rows_upsert <- function(x, y, by, ..., returning_cols = NULL) {
  ellipsis::check_dots_used()
  # FIXME: check here same src for x and y? if not -> error.
  UseMethod("sql_rows_upsert")
}

# nocov start
# exclude from coverage because no database in the workflow supports MERGE
#' @export
sql_rows_upsert.tbl_sql <- function(x, y, by, ..., returning_cols = NULL) {
  con <- dbplyr::remote_con(x)

  p <- sql_rows_prep(x, y, by)

  update_clause <- paste0(
    unlist(p$new_columns_qq_list), " = ", "excluded.", unlist(p$new_columns_qq_list),
    collapse = ",\n"
  )

  sql <- paste0(
    "MERGE INTO ", p$name, "\n",
    "USING (", dbplyr::sql_render(y), ") AS ", p$y_name, "\n",
    "ON (", p$compare_qual_qq, ")\n",
    "WHEN MATCHED THEN\n",
    "  UPDATE SET", update_clause, "\n",
    "WHEN NOT MATCHED THEN\n",
    "  INSERT (", p$y_columns_qq, ")\n",
    "  VALUES (", p$y_columns_qual_qq, ")\n",
    sql_returning_cols(x, returning_cols)
  )

  glue::as_glue(sql)
}
# nocov end

# nocov start
# exclude from coverage because MERGE somehow doesn't work with MS SQL 2017
#' @export
`sql_rows_upsert.tbl_Microsoft SQL Server` <- function(x, y, by, ..., returning_cols = NULL) {
  con <- dbplyr::remote_con(x)

  p <- sql_rows_prep(x, y, by)

  update_clause <- paste0(
    unlist(p$new_columns_qq_list), " = ", "excluded.", unlist(p$new_columns_qq_list),
    collapse = ",\n"
  )

  sql <- paste0(
    "MERGE INTO ", p$name, "\n",
    "USING (", dbplyr::sql_render(y), ") AS ", p$y_name, "\n",
    "ON (", p$compare_qual_qq, ")\n",
    "WHEN MATCHED THEN\n",
    "  UPDATE SET", update_clause, "\n",
    "WHEN NOT MATCHED THEN\n",
    "  INSERT (", p$y_columns_qq, ")\n",
    "  VALUES (", p$y_columns_qual_qq, ")\n",
    sql_output_cols(x, returning_cols),
    ";"
  )

  glue::as_glue(sql)
}
# nocov end

#' @export
sql_rows_upsert.tbl_duckdb_connection <- function(x, y, by, ..., returning_cols = NULL) {
  abort("upsert is not supported for DuckDB")
}

#' @export
sql_rows_upsert.tbl_PqConnection <- function(x, y, by, ..., returning_cols = NULL) {
  con <- dbplyr::remote_con(x)

  p <- sql_rows_prep(x, y, by)

  update_clause <- paste0(
    unlist(p$new_columns_qq_list), " = ", "excluded.", unlist(p$new_columns_qq_list),
    collapse = ",\n"
  )

  sql <- paste0(
    "WITH ", p$y_name, "(", p$y_columns_qq, ") AS (\n",
    dbplyr::sql_render(y),
    "\n)\n",
    "INSERT INTO ", p$name, " (", p$y_columns_qq, ")\n",
    "SELECT * FROM ", p$y_name, "\n",
    "WHERE true\n",
    "ON CONFLICT (", p$by_columns_qq, ")\n",
    "DO UPDATE\n",
    "SET ", update_clause, "\n",
    sql_returning_cols(x, returning_cols)
  )

  glue::as_glue(sql)
}

#' @export
sql_rows_upsert.tbl_SQLiteConnection <- sql_rows_upsert.tbl_PqConnection

#' @export
sql_rows_upsert.tbl_MariaDBConnection <- function(x, y, by, ..., returning_cols = NULL) {
  con <- dbplyr::remote_con(x)

  p <- sql_rows_prep(x, y, by)

  update_clause <- paste0(
    p$new_columns_qq_list, " = ", p$new_columns_qual_qq_list,
    collapse = ",\n"
  )

  # MariaDB has the order: first INSERT then CTE
  # https://www.itjungle.com/2016/08/16/fhg081616-story02/
  sql <- paste0(
    "INSERT INTO ", p$name, "\n",
    "WITH ", p$y_name, "(", p$y_columns_qq, ") AS (\n",
    dbplyr::sql_render(y),
    "\n)\n",
    "SELECT * FROM ", p$y_name, "\n",
    "WHERE true\n",
    "ON DUPLICATE KEY UPDATE\n",
    update_clause, "\n",
    sql_returning_cols(x, returning_cols)
  )

  glue::as_glue(sql)
}

#' @rdname rows-db
sql_rows_patch <- function(x, y, by, ..., returning_cols = NULL) {
  ellipsis::check_dots_used()
  # FIXME: check here same src for x and y? if not -> error.
  UseMethod("sql_rows_patch")
}

#' @export
sql_rows_patch.tbl_sql <- function(x, y, by, ..., returning_cols = NULL) {
  # * avoid CTEs for the general case as they do not work everywhere
  con <- dbplyr::remote_con(x)

  p <- sql_rows_prep(x, y, by)

  sql <- paste0(
    "UPDATE ", p$name, "\n",
    "SET\n",
    paste0(
      "  ", unlist(p$new_columns_qq_list),
      " = ", unlist(p$new_columns_patch_qq_list),
      collapse = ",\n"
    ), "\n",
    "FROM (\n",
    "    ", dbplyr::sql_render(y), "\n",
    "  ) AS ", p$y_name, "\n",
    "WHERE (", p$compare_qual_qq, ")\n",
    sql_returning_cols(x, returning_cols)
  )

  glue::as_glue(sql)
}

#' @export
`sql_rows_patch.tbl_Microsoft SQL Server` <- function(x, y, by, ..., returning_cols = NULL) {
  con <- dbplyr::remote_con(x)

  p <- sql_rows_prep(x, y, by)

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
      " = ", unlist(p$new_columns_patch_qq_list),
      collapse = ",\n"
    ),
    "\n",
    sql_output_cols(x, returning_cols),
    "FROM ", p$name, "\n",
    "  INNER JOIN ", p$y_name, "\n",
    "  ON ", p$compare_qual_qq
  )

  glue::as_glue(sql)
}

#' @export
sql_rows_patch.tbl_MariaDBConnection <- function(x, y, by, ..., returning_cols = NULL) {
  con <- dbplyr::remote_con(x)

  p <- sql_rows_prep(x, y, by)

  # https://stackoverflow.com/a/19346375/946850
  sql <- paste0(
    "UPDATE ", p$name, "\n",
    "  INNER JOIN (\n", dbplyr::sql_render(y), "\n) AS ", p$y_name, "\n",
    "  ON ", p$compare_qual_qq, "\n",
    "SET\n",
    paste0("  ", p$new_columns_qq, " = ", p$new_columns_patch_qq, collapse = ",\n"),
    sql_returning_cols(x, returning_cols)
  )

  glue::as_glue(sql)
}

sql_coalesce <- function(x, y) {
  paste0("COALESCE(", x, ",", y, ")")
}

#' @rdname rows-db
sql_rows_delete <- function(x, y, by, ..., returning_cols = NULL) {
  ellipsis::check_dots_used()
  # FIXME: check here same src for x and y? if not -> error.
  UseMethod("sql_rows_delete")
}

#' @export
sql_rows_delete.tbl_sql <- function(x, y, by, ..., returning_cols = NULL) {
  con <- dbplyr::remote_con(x)

  p <- sql_rows_prep(x, y, by)

  sql <- paste0(
    "DELETE FROM ", p$name, "\n",
    sql_output_cols(x, returning_cols, output_delete = TRUE),
    "WHERE EXISTS (\n",
    "  SELECT * FROM (\n",
    "    ", dbplyr::sql_render(y), "\n",
    "  ) AS ", p$y_name, "\n",
    "  WHERE ", p$compare_qual_qq, "\n",
    ")",
    sql_returning_cols(x, returning_cols)
  )

  glue::as_glue(sql)
}

sql_rows_prep <- function(x, y, by) {
  con <- dbplyr::remote_con(x)
  name <- dbplyr::remote_name(x)

  # https://stackoverflow.com/a/47753166/946850
  y_name <- DBI::dbQuoteIdentifier(con, "...y")
  y_q <- DBI::dbQuoteIdentifier(con, colnames(y))
  by_q <- DBI::dbQuoteIdentifier(con, by)

  y_columns_qq <- sql_list(y_q)
  y_columns_qual_qq <- sql_list(paste(y_name, ".", y_q))

  by_columns_qq <- sql_list(by_q)

  new_columns_q <- setdiff(y_q, by_q)
  new_columns_qual_q <- paste0(y_name, ".", new_columns_q)
  old_columns_qual_q <- paste0(name, ".", new_columns_q)

  new_columns_qq <- sql_list(new_columns_q)
  new_columns_qq_list <- list(new_columns_q)

  new_columns_qual_qq <- sql_list(new_columns_qual_q)
  new_columns_qual_qq_list <- list(new_columns_qual_q)

  new_columns_patch <- sql_coalesce(old_columns_qual_q, new_columns_qual_q)
  new_columns_patch_qq <- sql_list(new_columns_patch)
  new_columns_patch_qq_list <- list(new_columns_patch)

  compare_qual_qq <- paste0(
    y_name, ".", by_q,
    " = ",
    name, ".", by_q,
    collapse = " AND "
  )

  tibble(
    name, y_name,
    y_columns_qq,
    y_columns_qual_qq,
    by_columns_qq,
    new_columns_qq, new_columns_qq_list,
    new_columns_qual_qq, new_columns_qual_qq_list,
    new_columns_patch_qq, new_columns_patch_qq_list,
    compare_qual_qq
  )
}

sql_list <- function(x) {
  paste(x, collapse = ", ")
}

rows_get_or_execute <- function(x, con, sql, returning_cols) {
  if (is_empty(returning_cols)) {
    dbExecute(con, sql, immediate = TRUE)
  } else {
    returned_rows <- dbGetQuery(con, sql, immediate = TRUE)
    x <- set_returned_rows(x, returned_rows)
  }

  invisible(x)
}

set_returned_rows <- function(x, returned_rows) {
  attr(x, "returned_rows") <- as_tibble(returned_rows)
  x
}

#' Extract and check the RETURNING rows
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `get_returned_rows()` extracts the RETURNING rows produced by
#' [rows_insert()], [rows_update()], [rows_upsert()], or [rows_delete()]
#' if called with the `returning` argument.
#' An error is raised if this information is not available.
#'
#' @param x A lazy tbl.
#'
#' @return For `get_returned_rows()`, a tibble.
#'
#' @export
get_returned_rows <- function(x) {
  out <- attr(x, "returned_rows", TRUE)
  if (is.null(out)) {
    abort("No returned rows available.")
  }
  out
}

#' has_returned_rows()
#'
#' `has_returned_rows()` checks if `x` has stored RETURNING rows produced by
#' [rows_insert()], [rows_update()], [rows_upsert()], or [rows_delete()].
#'
#' @param x A lazy tbl.
#'
#' @return For `has_returned_rows()`, a scalar logical.
#'
#' @rdname get_returned_rows
#' @export
has_returned_rows <- function(x) {
  !identical(attr(x, "returned_rows"), NULL)
}

#' sql_returning_cols
#'
#' `sql_returning_cols()` and `sql_output_cols()` construct the SQL
#' required to support the `returning` argument.
#' Two methods are required, because the syntax for SQL Server
#' (and some other databases) is vastly different from Postgres and other
#' more standardized DBs.
#' @rdname rows-db
sql_returning_cols <- function(x, returning_cols, ...) {
  if (is_empty(returning_cols)) {
    return(NULL)
  }

  check_dots_empty()
  UseMethod("sql_returning_cols")
}

#' @export
sql_returning_cols.tbl_lazy <- function(x, returning_cols, ...) {
  con <- dbplyr::remote_con(x)
  returning_cols <- sql_named_cols(con, returning_cols, table = dbplyr::remote_name(x))

  paste0("RETURNING ", returning_cols)
}

#' @export
sql_returning_cols.tbl_duckdb_connection <- function(x, returning_cols, ...) {
  abort("DuckDB does not support the `returning` argument.")
}

#' @export
`sql_returning_cols.tbl_Microsoft SQL Server` <- function(x, returning_cols, ...) {
  NULL
}

#' @param output_delete For `sql_output_cols()`, construct the SQL
#'   for a `DELETE` operation.
#' @rdname rows-db
sql_output_cols <- function(x, returning_cols, output_delete = FALSE, ...) {
  if (is_empty(returning_cols)) {
    return(NULL)
  }

  UseMethod("sql_output_cols")
}

#' @export
sql_output_cols.default <- function(x, returning_cols, output_delete = FALSE, ...) {
  NULL
}

#' @export
`sql_output_cols.tbl_Microsoft SQL Server` <- function(x, returning_cols, output_delete = FALSE, ...) {
  con <- dbplyr::remote_con(x)
  returning_cols <- sql_named_cols(
    con, returning_cols,
    table = if (output_delete) "DELETED" else "INSERTED"
  )

  paste0("OUTPUT ", returning_cols)
}

sql_named_cols <- function(con, cols, table = NULL) {
  nms <- names2(cols)
  nms[nms == cols] <- ""

  cols <- DBI::dbQuoteIdentifier(con, cols)
  if (!is.null(table)) {
    cols <- paste0(table, ".", cols)
  }

  cols[nms != ""] <- paste0(cols, " AS ", DBI::dbQuoteIdentifier(con, nms[nms != ""]))
  paste0(cols, collapse = ", ")
}
