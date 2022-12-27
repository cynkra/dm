#' Add a unique key
#'
#' @description
#' `dm_add_uk()` marks the specified columns as a unique key of the specified table.
#' If `check == TRUE`, then it will first check if
#' the given combination of columns is a unique key of the table.
#'
#' @inheritParams dm_add_pk
#'
#' @details The difference between a primary key (PK) and a unique key (UK) consists in the following:
#' - when a local `dm` is copied to a database (DB) with `copy_dm_to()`, a PK will be set on the DB by default
#' - a PK can be set as an `autoincrement` key (also implemented on certain DBMS when the `dm` is transferred to the DB)
#' - there can be only one PK for each table, whereas there can be unlimited UKs
#' - a UK will be used, if the same table has an autoincrement PK in addition, to ensure that during delta load processes on the DB
#'   the foreign keys are updated accordingly. If no UK is available, the insertion is done row-wise, which also ensures a correct
#'   matching, but can be much slower.
#' - a UK can generally enhance the data model by adding additional information
#' - if a foreign key is added to point at a table without a PK and a UK, a UK is automatically added to that table.
#'
#' @family primary key functions
#'
#' @return An updated `dm` with an additional unqiue key.
#'
#' @examplesIf rlang::is_installed("nycflights13") && rlang::is_installed("DiagrammeR")
#'
#' nycflights_dm <- dm(
#'   planes = nycflights13::planes,
#'   airports = nycflights13::airports,
#'   weather = nycflights13::weather
#' )
#'
#' # Create unique keys:
#' nycflights_dm %>%
#'   dm_add_uk(planes, tailnum) %>%
#'   dm_add_uk(airports, faa, check = TRUE) %>%
#'   dm_add_uk(weather, c(origin, time_hour)) %>%
#'   dm_get_all_uks()
#'
#' # Keys can be checked during creation:
#' try(
#'   nycflights_dm %>%
#'     dm_add_uk(planes, manufacturer, check = TRUE)
#' )
#' @export
dm_add_uk <- function(dm, table, columns, ..., check = FALSE) {
  check_dots_empty()

  check_not_zoomed(dm)

  table_name <- dm_tbl_name(dm, {{ table }})
  table <- dm_get_tables_impl(dm)[[table_name]]

  check_required(columns)
  col_expr <- enexpr(columns)
  col_name <- names(eval_select_indices(col_expr, colnames(table)))

  if (check) {
    table_from_dm <- dm_get_filtered_table(dm, table_name)
    eval_tidy(expr(check_key(!!sym(table_name), !!col_expr)), list2(!!table_name := table_from_dm))
  }

  dm_add_uk_impl(dm, table_name, col_name)
}

# both "table" and "column" must be characters
# in {datamodelr}, a primary key may consist of more than one columns
# a key will be added, regardless of whether it is a unique key or not; not to be exported
dm_add_uk_impl <- function(dm, table, column) {
  def <- dm_get_def(dm)
  i <- which(def$table == table)

  def$uks[[i]] <- vctrs::vec_rbind(
    def$uks[[i]],
    tibble(column = !!list(column))
  )

  new_dm3(def)
}

#' Check for unique key
#'
#' @description
#' `dm_has_uk()` checks if a given table has columns marked as its unique key.
#'
#' @inheritParams dm_add_uk
#'
#' @family primary key functions
#'
#' @return A logical value: `TRUE` if the given table has a unique key, `FALSE` otherwise.
#'
#' @examplesIf rlang::is_installed("nycflights13")
#' dm_nycflights13() %>%
#'   dm_has_uk(flights)
#' dm_nycflights13() %>%
#'   dm_has_uk(planes)
#' @export
dm_has_uk <- function(dm, table, ...) {
  check_dots_empty()
  check_not_zoomed(dm)
  table_name <- dm_tbl_name(dm, {{ table }})
  dm_has_uk_impl(dm, table_name)
}

dm_has_uk_impl <- function(dm, table) {
  has_length(dm_get_uk_impl(dm, table))
}

dm_get_uk_impl <- function(dm, table_name) {
  # Optimized
  def <- dm_get_def(dm)
  uks <- def$uks[[which(def$table == table_name)]]
  uks$column
}

#' Get all primary keys of a [`dm`] object
#'
#' @description
#' `dm_get_all_uks()` checks the `dm` object for unique keys and
#' returns the tables and the respective unique key columns.
#'
#' @family primary key functions
#' @param table One or more table names, as character vector,
#'   to return primary key information for.
#'   If given, primary keys are returned in that order.
#'   The default `NULL` returns information for all tables.
#'
#' @inheritParams dm_add_uk
#'
#' @return A tibble with the following columns:
#'   \describe{
#'     \item{`table`}{table name,}
#'     \item{`uk_col`}{column name(s) of primary key, as list of character vectors.}
#'   }
#'
#' @export
#' @examplesIf rlang::is_installed("nycflights13")
#' dm_nycflights13() %>%
#'   dm_get_all_uks()
dm_get_all_uks <- function(dm, table = NULL, ...) {
  check_dots_empty()
  check_not_zoomed(dm)
  dm_get_all_uks_impl(dm, table)
}

dm_get_all_uks_impl <- function(dm, table = NULL) {
  dm %>%
    dm_get_def() %>%
    dm_get_all_uks_def_impl(table)
}

dm_get_all_uks_def_impl <- function(def, table = NULL) {
  # Optimized for speed

  def_sub <- def[c("table", "uks")]

  if (!is.null(table)) {
    idx <- match(table, def_sub$table)
    if (anyNA(idx)) {
      abort(paste0("Table not in dm object: ", parent_table[which(is.na(idx))[[1]]]))
    }
    def_sub <- def_sub[match(table, def_sub$table), ]
  }

  out <-
    def_sub %>%
    unnest_df("uks", tibble(column = list())) %>%
    set_names(c("table", "uk_col"))

  out$uk_col <- new_keys(out$uk_col)
  out
}

#' Remove a unique key
#'
#' @description
#' `dm_rm_uk()` removes one or more unique keys from a table and leaves the [`dm`] object otherwise unaltered.
#' An error is thrown if no unique key matches the selection criteria.
#' If the selection criteria are ambiguous, a message with unambiguous replacement code is shown.
#' Foreign keys are never removed.
#'
#' @inheritParams dm_rm_pk
#' @param fail_fk
#'   Boolean: if `TRUE` (default), will throw an error
#'   if there are foreign keys addressing the unique key that is to be removed.
#'
#' @family primary key functions
#'
#' @return An updated `dm` without the indicated unique key(s).
#'
#' @export
#' @examplesIf rlang::is_installed("nycflights13") && rlang::is_installed("DiagrammeR")
#' dm_nycflights13() %>%
#'   dm_rm_uk(airports, fail_fk = FALSE) %>%
#'   dm_draw()
dm_rm_uk <- function(dm, table = NULL, columns = NULL, ..., fail_fk = TRUE) {
  if (missing(fail_fk)) {
    fail_fk <- NULL
  }
  dm_rm_uk_(dm, {{ table }}, {{ columns }}, ..., fail_fk = fail_fk)
}

dm_rm_uk_ <- function(dm, table, columns, ..., fail_fk = NULL) {
  check_dots_empty()
  check_not_zoomed(dm)

  if (is.null(fail_fk)) {
    fail_fk <- TRUE
  }

  table_name <- dm_tbl_name_null(dm, {{ table }})
  columns <- enexpr(columns)

  dm_rm_uk_impl(dm, table_name, columns, fail_fk)
}

dm_rm_uk_impl <- function(dm, table_name, columns, fail_fk) {
  def <- dm_get_def(dm)

  if (is.null(table_name)) {
    i <- which(map_int(def$uks, vec_size) > 0)
  } else {
    i <- which(def$table == table_name)
    if (nrow(def$uks[[i]]) == 0) {
      i <- integer()
    }
  }

  if (!quo_is_null(columns)) {
    ii <- map2_lgl(def$data[i], def$uks[i], ~ tryCatch(
      {
        vars <- eval_select_indices(columns, colnames(.x))
        identical(names(vars), .y$column[[1]])
      },
      error = function(e) {
        FALSE
      }
    ))

    i <- i[ii]
  }

  if (length(i) == 0 && dm_is_strict_keys(dm)) {
    abort_uk_not_defined()
  }

  pwalk(list(def$fks[i], def$uks[i], def$table[i]), ~ {
    is_match <- !is.na(vec_match(..1$ref_column, ..2$column))
    if (fail_fk && any(is_match)) {
      abort_first_rm_fks(..3, ..1$table[is_match])
    }
  })

  # Talk about it
  if (is.null(table_name)) {
    message("Removing unique keys: %>%")
    message("  ", glue_collapse(glue("dm_rm_uk({tick_if_needed(def$table[i])})"), " %>%\n  "))
  }

  # Execute
  def$uks[i] <- list_of(new_uk())

  new_dm3(def)
}

# Error -------------------------------------------------------------------

abort_uk_not_defined <- function() {
  abort(error_txt_uk_not_defined(), class = dm_error_full("uk_not_defined"))
}

error_txt_uk_not_defined <- function() {
  glue("No unique keys to remove.")
}
