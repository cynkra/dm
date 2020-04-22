#' Persisting data
#'
#' @description
#' \lifecycle{experimental}
#'
#' These methods provide a framework for manipulating individual rows
#' in existing tables, modeled after the SQL operations
#' `INSERT`, `UPDATE` and `DELETE`.
#' All operations expect existing and new data to be compatible.
#'
#' @param .data Target table object.
#' @param .key Key columns, unquoted.
#' @param ... New data.
#'   If unnamed, must be a single object of the same class as `.data`.
#'   If named, will be passed on to [tibble()].
#'
#' @return A tbl object of the same structure as `.data`.
#'
#' @name rows
#' @example example/rows.R
NULL


#' rows_insert
#'
#' `rows_insert()` adds new rows.
#' This operation corresponds to `INSERT` in SQL.
#' If `.key` is given, no two rows with the same values in the key columns
#' are permitted.
#' @param .sort Should the output be sorted by the key columns?
#' @rdname rows
#' @export
rows_insert <- function(.data, .key = NULL, ...) {
  UseMethod("rows_insert", .data)
}

#' @export
#' @rdname rows
rows_insert.data.frame <- function(.data, .key = NULL, ..., .sort = NULL) {
  .key <- tidyselect::eval_select(enexpr(.key), .data)

  source <- dots_to_df(.data, .key, ...)
  stopifnot(!anyDuplicated(vctrs::vec_rbind(.data[.key], source[names(.key)])))
  out <- vctrs::vec_rbind(.data, source)
  if (isTRUE(.sort)) {
    # FIXME: Faster implementation, sort before binding
    out <- arrange(out, !!!.key)
  }
  out
}

#' rows_update
#'
#' `rows_update()` updates existing rows.
#' This operation corresponds to `UPDATE` in SQL.
#' `.key` is mandatory.
#' No two rows with the same values may exist in the new data.
#' Each row in the new data must have exactly one corresponding row
#' in the existing data.
#' @rdname rows
#' @export
rows_update <- function(.data, .key, ...) {
  UseMethod("rows_update", .data)
}

#' @export
rows_update.data.frame <- function(.data, .key, ...) {
  .key <- tidyselect::eval_select(enexpr(.key), .data)

  source <- dots_to_df(.data, .key, ...)

  idx <- vctrs::vec_match(source[names(.key)], .data[.key])
  # FIXME: Check key in .data?
  .data[idx, names(source)] <- source
  .data
}

#' rows_patch
#'
#' `rows_patch()` replaces missing values in existing rows.
#' This operation corresponds to `UPDATE` using `COALESCE` expressions in SQL.
#' It is similar to `rows_update()`, leaves non-missing values untouched.
#' `.key` is mandatory.
#' No two rows with the same values may exist in the new data.
#' Each row in the new data must have exactly one corresponding row
#' in the existing data.
#' @rdname rows
#' @export
rows_patch <- function(.data, .key, ...) {
  UseMethod("rows_patch", .data)
}

#' @export
rows_patch.data.frame <- function(.data, .key, ...) {
  .key <- tidyselect::eval_select(enexpr(.key), .data)
  source <- dots_to_df(.data, .key, ...)

  idx <- vctrs::vec_match(source[names(.key)], .data[.key])
  # FIXME: Check key in .data?

  # FIXME: Do we need vec_coalesce()
  new_data <- map2(.data[idx, names(source)], source, coalesce)

  .data[idx, names(source)] <- new_data
  .data
}

#' rows_upsert
#'
#' `rows_upsert()` updates matching rows and adds new rows for mismatches.
#' This operation corresponds to `INSERT ON DUPLICATE KEY UPDATE` or
#' `INSERT ON CONFLICT` in some SQL variants.
#' `.key` is mandatory.
#' No two rows with the same values may exist in the new data.
#' Each row in the new data must have exactly one corresponding row
#' in the existing data.
#' @rdname rows
#' @export
rows_upsert <- function(.data, .key, ...) {
  UseMethod("rows_upsert", .data)
}

#' @export
rows_upsert.data.frame <- function(.data, .key, ..., .sort = NULL) {
  .key <- tidyselect::eval_select(enexpr(.key), .data)
  source <- dots_to_df(.data, .key, ...)

  idx <- vctrs::vec_match(source[names(.key)], .data[.key])
  # FIXME: Check key in .data?

  new <- is.na(idx)
  idx_existing <- idx[!new]
  idx_new <- idx[new]

  .data[idx_existing, names(source)] <- source[!new, ]
  out <- vctrs::vec_rbind(.data, source[new, ])
  if (isTRUE(.sort)) {
    # FIXME: Faster implementation, sort before binding
    out <- arrange(out, !!!.key)
  }
  out
}

#' rows_delete
#'
#' `rows_delete()` deletes existing rows.
#' This operation corresponds to `DELETE` in SQL.
#' `.key` is mandatory, extra data in `...` is ignored.
#' @rdname rows
#' @export
rows_delete <- function(.data, .key, ...) {
  UseMethod("rows_delete", .data)
}

#' @export
rows_delete.data.frame <- function(.data, .key, ...) {
  .key <- tidyselect::eval_select(enexpr(.key), .data)
  source <- dots_to_df(.data, .key, ...)

  idx <- vctrs::vec_match(source[names(.key)], .data[.key])
  # FIXME: Check key in .data?
  .data[-idx[!is.na(idx)], ]
}

#' rows_truncate
#'
#' `rows_truncate()` removes all rows.
#' This operation corresponds to `TRUNCATE` in SQL.
#' `.key` and `...` are ignored.
#' @rdname rows
#' @export
rows_truncate <- function(.data, .key, ...) {
  UseMethod("rows_truncate", .data)
}

#' @export
rows_truncate.data.frame <- function(.data, .key = NULL, ...) {
  .data[integer(), ]
}





dots_to_df <- function(.data, .key, ...) {
  dots <- enquos(...)
  if (length(dots) == 1 && names2(dots) == "") {
    source <- ..1
  } else {
    stopifnot(is_named(dots))
    # Remove arguments that start with a dot, for extensibility
    dots <- dots[grepl("^[^.]", names(dots))]
    source <- tibble(!!!dots)
  }

  stopifnot(is_empty(setdiff(colnames(source), colnames(.data))))
  # Matched by tidyselect for .data
  stopifnot(all(names(.key) %in% colnames(source)))

  source
}
