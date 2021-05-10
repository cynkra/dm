#' Add a primary key
#'
#' @description
#' `dm_add_pk()` marks the specified columns as the primary key of the specified table.
#' If `check == TRUE`, then it will first check if
#' the given combination of columns is a unique key of the table.
#' If `force == TRUE`, the function will replace an already
#' set key, without altering foreign keys previously pointing to that primary key.
#'
#' @inheritParams ellipsis::dots_empty
#' @param dm A `dm` object.
#' @param table A table in the `dm`.
#' @param columns Table columns, unquoted.
#'   To define a compound key, use `c(col1, col2)`.
#' @param check Boolean, if `TRUE`, a check is made if the combination of columns is a unique key of the table.
#' @param force Boolean, if `FALSE` (default), an error will be thrown if there is already a primary key
#'   set for this table.
#'   If `TRUE`, a potential old `pk` is deleted before setting a new one.
#'
#' @family primary key functions
#'
#' @return An updated `dm` with an additional primary key.
#'
#' @export
#' @examplesIf rlang::is_installed("nycflights13") && rlang::is_installed("DiagrammeR")
#' nycflights_dm <- dm(
#'   planes = nycflights13::planes,
#'   airports = nycflights13::airports,
#'   weather = nycflights13::weather
#' )
#'
#' nycflights_dm %>%
#'   dm_draw()
#'
#' # Create primary keys:
#' nycflights_dm %>%
#'   dm_add_pk(planes, tailnum) %>%
#'   dm_add_pk(airports, faa, check = TRUE) %>%
#'   dm_add_pk(weather, c(origin, time_hour)) %>%
#'   dm_draw()
#'
#' # Keys can be checked during creation:
#' try(
#'   nycflights_dm %>%
#'     dm_add_pk(planes, manufacturer, check = TRUE)
#' )
dm_add_pk <- function(dm, table, columns, ..., check = FALSE, force = FALSE) {
  check_dots_empty()
  check_not_zoomed(dm)
  table_name <- dm_tbl_name(dm, {{ table }})

  table <- dm_get_tables_impl(dm)[[table_name]]
  col_expr <- enexpr(columns)
  col_name <- names(eval_select_indices(col_expr, colnames(table)))

  if (check) {
    table_from_dm <- dm_get_filtered_table(dm, table_name)
    eval_tidy(expr(check_key(!!sym(table_name), !!col_expr)), list2(!!table_name := table_from_dm))
  }

  dm_add_pk_impl(dm, table_name, col_name, force)
}

# both "table" and "column" must be characters
# in {datamodelr}, a primary key may consist of more than one columns
# a key will be added, regardless of whether it is a unique key or not; not to be exported
dm_add_pk_impl <- function(dm, table, column, force) {
  def <- dm_get_def(dm)
  i <- which(def$table == table)

  if (!force && NROW(def$pks[[i]]) > 0) {
    if (!dm_is_strict_keys(dm) &&
      identical(def$pks[[i]]$column[[1]], column)) {
      return(dm)
    }

    abort_key_set_force_false(table)
  }

  def$pks[[i]] <- tibble(column = !!list(column))

  new_dm3(def)
}

#' Check for primary key
#'
#' @description `dm_has_pk()` checks if a given table has columns marked as its primary key.
#'
#' @inheritParams dm_add_pk
#'
#' @family primary key functions
#'
#' @return A logical value: `TRUE` if the given table has a primary key, `FALSE` otherwise.
#'
#' @examplesIf rlang::is_installed("nycflights13")
#' dm_nycflights13() %>%
#'   dm_has_pk(flights)
#' dm_nycflights13() %>%
#'   dm_has_pk(planes)
#' @export
dm_has_pk <- function(dm, table, ...) {
  check_dots_empty()
  check_not_zoomed(dm)
  table_name <- dm_tbl_name(dm, {{ table }})
  dm_has_pk_impl(dm, table_name)
}

dm_has_pk_impl <- function(dm, table) {
  has_length(dm_get_pk_impl(dm, table))
}

#' Primary key column names
#'
#' @description `dm_get_pk()` returns the names of the
#' columns marked as primary key of a table of a [`dm`] object.
#' If no primary key is
#' set for the table, an empty character vector is returned.
#'
#' @section Multiple primary keys:
#'
#' Each table can have only one primary key.
#' For symmetry with `dm_get_fk()`,
#' this function still returns a list of character vectors.
#'
#' @family primary key functions
#'
#' @return A list with character vectors with the column name(s) of the
#'   primary keys of `table`.
#'   The contained character vectors have length greater than one for compound keys.
#'
#' @inheritParams dm_add_pk
#'
#' @examplesIf rlang::is_installed("nycflights13")
#' dm_nycflights13() %>%
#'   dm_get_pk(flights)
#' dm_nycflights13() %>%
#'   dm_get_pk(planes)
#' @export
dm_get_pk <- function(dm, table, ...) {
  check_dots_empty()
  check_not_zoomed(dm)
  table_name <- dm_tbl_name(dm, {{ table }})
  new_keys(dm_get_pk_impl(dm, table_name))
}

dm_get_pk_impl <- function(dm, table_name) {
  # Optimized
  def <- dm_get_def(dm)
  pks <- def$pks[[which(def$table == table_name)]]
  pks$column
}

#' Get all primary keys of a [`dm`] object
#'
#' @description `dm_get_all_pks()` checks the `dm` object for set primary keys and
#' returns the tables, the respective primary key columns and their classes.
#'
#' @family primary key functions
#'
#' @inheritParams dm_add_pk
#'
#' @return A tibble with the following columns:
#'   \describe{
#'     \item{`table`}{table name,}
#'     \item{`pk_cols`}{column name(s) of primary key, as list of character vectors.}
#'   }
#'
#' @export
#' @examplesIf rlang::is_installed("nycflights13")
#' dm_nycflights13() %>%
#'   dm_get_all_pks()
dm_get_all_pks <- function(dm, ...) {
  check_dots_empty()
  check_not_zoomed(dm)
  dm_get_all_pks_impl(dm)
}

dm_get_all_pks_impl <- function(dm) {
  dm %>%
    dm_get_def() %>%
    dm_get_all_pks_def_impl()
}

dm_get_all_pks_def_impl <- function(def) {
  # Optimized for speed
  out <-
    def[c("table", "pks")] %>%
    unnest_df("pks", tibble(column = list())) %>%
    set_names(c("table", "pk_col"))

  out$pk_col <- new_keys(out$pk_col)
  out
}


#' Remove a primary key
#'
#' `dm_rm_pk()` removes one or more primary keys from a table and leaves the [`dm`] object otherwise unaltered.
#' An error is thrown if no private key matches the selection criteria.
#' If the selection criteria are ambiguous, a message with unambiguous replacement code is shown.
#' Foreign keys are never removed.
#'
#' @inheritParams dm_add_pk
#' @param table A table in the `dm`.
#'   Pass `NULL` to remove all matching keys.
#' @param columns Table columns, unquoted.
#'   To refer to a compound key, use `c(col1, col2)`.
#'   Pass `NULL` (the default) to remove all matching keys.
#' @param fail_fk
#'   Boolean: if `TRUE` (default), will throw an error
#'   if there are foreign keys addressing the primary key that is to be removed.
#'
#' @family primary key functions
#'
#' @return An updated `dm` without the indicated primary key(s).
#'
#' @export
#' @examplesIf rlang::is_installed("nycflights13") && rlang::is_installed("DiagrammeR")
#' dm_nycflights13() %>%
#'   dm_rm_pk(airports, fail_fk = FALSE) %>%
#'   dm_draw()
dm_rm_pk <- function(dm, table = NULL, columns = NULL, ..., fail_fk = TRUE) {
  if (missing(fail_fk)) {
    fail_fk <- NULL
  }
  dm_rm_pk_(dm, {{ table }}, {{ columns }}, ..., fail_fk = fail_fk)
}

dm_rm_pk_ <- function(dm, table, columns, ..., rm_referencing_fks = NULL, fail_fk = NULL) {
  check_dots_empty()
  check_not_zoomed(dm)

  if (!is.null(rm_referencing_fks)) {
    deprecate_soft("0.2.1", "dm::dm_rm_pk(rm_referencing_fks = )", "dm::dm_rm_pk(fail_fk = )",
                   details = "Note the different semantics: `fail_fk = FALSE` roughly corresponds to `rm_referencing_fks = TRUE`, but foreign keys are no longer removed."
    )
    if (is.null(fail_fk)) {
      fail_fk <- !rm_referencing_fks
    }
  }

  if (is.null(fail_fk)) {
    fail_fk <- TRUE
  }

  table_name <- dm_tbl_name_null(dm, {{ table }})
  columns <- enexpr(columns)

  dm_rm_pk_impl(dm, table_name, columns, fail_fk)
}

dm_rm_pk_impl <- function(dm, table_name, columns, fail_fk) {
  def <- dm_get_def(dm)

  if (is.null(table_name)) {
    i <- which(map_int(def$pks, vec_size) > 0)
  } else {
    i <- which(def$table == table_name)
    if (nrow(def$pks[[i]]) == 0) {
      i <- integer()
    }
  }

  if (!quo_is_null(columns)) {
    ii <- map2_lgl(def$data[i], def$pks[i], ~ tryCatch(
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
    abort_pk_not_defined()
  }

  pwalk(list(def$fks[i], def$pks[i], def$table[i]),  ~ {
    is_match <- !is.na(vec_match(..1$ref_column, ..2$column))
    if (fail_fk && any(is_match)) {
      abort_first_rm_fks(..3, ..1$table[is_match])
    }
  })

  # Talk about it
  if (is.null(table_name)) {
    message("Removing primary keys: %>%")
    message("  ", glue_collapse(glue("dm_rm_pk({tick_if_needed(def$table[i])})"), " %>%\n  "))
  }

  # Execute
  def$pks[i] <- list_of(new_pk())

  new_dm3(def)
}


#' Primary key candidate
#'
#' @description `r lifecycle::badge("questioning")`
#'
#' `enum_pk_candidates()` checks for each column of a
#' table if the column contains only unique values, and is thus
#' a suitable candidate for a primary key of the table.
#'
#' @return A tibble with the following columns:
#'   \describe{
#'     \item{`columns`}{columns of `table`,}
#'     \item{`candidate`}{boolean: are these columns a candidate for a primary key,}
#'     \item{`why`}{if not a candidate for a primary key column, explanation for this.}
#'   }
#'
#' @section Life cycle:
#' These functions are marked "questioning" because we are not yet sure about
#' the interface, in particular if we need both `dm_enum...()` and `enum...()`
#' variants.
#' Changing the interface later seems harmless because these functions are
#' most likely used interactively.
#'
#' @export
#' @examplesIf rlang::is_installed("nycflights13")
#' nycflights13::flights %>%
#'   enum_pk_candidates()
enum_pk_candidates <- function(table, ...) {
  check_dots_empty()
  # a list of ayes and noes:
  if (is_dm(table) && is_zoomed(table)) {
    table <- tbl_zoomed(table)
  }

  table %>%
    enum_pk_candidates_impl() %>%
    rename(columns = column) %>%
    mutate(columns = new_keys(columns))
}

#' @description `dm_enum_pk_candidates()` performs these checks
#' for a table in a [dm] object.
#'
#' @family primary key functions
#'
#' @inheritParams dm_add_pk
#'
#' @rdname enum_pk_candidates
#' @export
#' @examplesIf rlang::is_installed("nycflights13")
#'
#' dm_nycflights13() %>%
#'   dm_enum_pk_candidates(airports)
dm_enum_pk_candidates <- function(dm, table, ...) {
  check_dots_empty()
  check_not_zoomed(dm)
  # FIXME: with "direct" filter maybe no check necessary: but do we want to check
  # for tables retrieved with `tbl()` or with `dm_get_tables()[[table_name]]`
  check_no_filter(dm)

  table_name <- dm_tbl_name(dm, {{ table }})

  table <- dm_get_tables_impl(dm)[[table_name]]
  table %>%
    enum_pk_candidates_impl() %>%
    rename(columns = column) %>%
    mutate(columns = new_keys(columns))
}

enum_pk_candidates_impl <- function(table, columns = new_keys(colnames(table))) {
  tibble(column = new_keys(columns)) %>%
    mutate(why = map_chr(column, ~ check_pk(table, .x))) %>%
    mutate(candidate = (why == "")) %>%
    select(column, candidate, why) %>%
    arrange(desc(candidate), column)
}

check_pk <- function(table, columns) {
  duplicate_values <- is_unique_key_se(table, columns)
  if (duplicate_values$unique) {
    return("")
  }

  dup_data <- duplicate_values$data[[1]]

  fun <- ~ format(.x, trim = TRUE, justify = "none")

  values <- dup_data$value
  n <- dup_data$n
  values_na <- is.na(values)

  if (any(values_na)) {
    missing <- paste0(sum(n[values_na]), " missing values")
    values <- values[!values_na]
    n <- n[!values_na]
  } else {
    missing <- NULL
  }

  if (length(values) > 0) {
    values_count <- paste0(values, " (", n[!values_na], ")")
    values_text <- commas(values_count, capped = TRUE, fun = fun)
    duplicate <- paste0("duplicate values: ", values_text)
  } else {
    duplicate <- NULL
  }

  problem <- glue_collapse(c(missing, duplicate), sep = "", last = ", and ")
  paste0("has ", problem)
}


# Error -------------------------------------------------------------------

abort_pk_not_defined <- function() {
  abort(error_txt_pk_not_defined(), .subclass = dm_error_full("pk_not_defined"))
}

error_txt_pk_not_defined <- function() {
  glue("No primary keys to remove.")
}

abort_key_set_force_false <- function(table) {
  abort(error_txt_key_set_force_false(table), .subclass = dm_error_full("key_set_force_false"))
}

error_txt_key_set_force_false <- function(table) {
  glue("Table {tick(table)} already has a primary key. Use `force = TRUE` to change the existing primary key.")
}

abort_first_rm_fks <- function(table, fk_tables) {
  abort(error_txt_first_rm_fks(table, fk_tables), .subclass = dm_error_full("first_rm_fks"))
}

error_txt_first_rm_fks <- function(table, fk_tables) {
  glue(
    "There are foreign keys pointing from table(s) {commas(tick(fk_tables))} to table {tick(table)}. ",
    "First remove those, or set `fail_fk = FALSE`."
  )
}
