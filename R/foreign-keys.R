#' Add/remove foreign keys
#'
#' @description `dm_add_fk()` marks the specified columns as the foreign key of table `table` with
#' respect to the primary key of table `ref_table`.
#' If `check == TRUE`, then it will first check if the values in columns `columns` are a subset
#' of the values of the primary key in table `ref_table`.
#'
#' @section Compound keys:
#'
#' Currently, keys consisting of more than one column are not supported.
#' [This feature](https://github.com/cynkra/dm/issues/3) is planned for dm 0.2.0.
#' The syntax of these functions will be extended but will remain compatible
#' with current semantics.
#'
#' @inheritParams dm_add_pk
#' @param columns For `dm_add_fk()`: The columns of `table` which are to become the foreign key columns that
#'   reference the primary key of `ref_table`.
#'
#'   For `dm_rm_fk()`: The columns of `table` that should no longer be referencing the primary key of `ref_table`.
#'   If `NULL`, all columns will be evaluated.
#' @param ref_table For `dm_add_fk()`: The table which `table` will be referencing.
#'   This table needs to have a primary key set.
#'
#'   For `dm_rm_fk()`: The table that `table` is referencing.
#' @param check Boolean, if `TRUE`, a check will be performed to determine if the values of
#'   `column` are a subset of the values of the primary key column of `ref_table`.
#'
#' @family foreign key functions
#'
#' @rdname dm_add_fk
#'
#' @return For `dm_add_fk()`: An updated `dm` with an additional foreign key relation.
#'
#' @export
#' @examplesIf rlang::is_installed("nycflights13") && rlang::is_installed("DiagrammeR")
#' nycflights_dm <- dm(
#'   planes = nycflights13::planes,
#'   flights = nycflights13::flights
#' )
#'
#' nycflights_dm %>%
#'   dm_draw()
#'
#' nycflights_dm %>%
#'   dm_add_pk(planes, tailnum) %>%
#'   dm_add_fk(flights, tailnum, planes) %>%
#'   dm_draw()
dm_add_fk <- function(dm, table, columns, ref_table, check = FALSE) {
  check_not_zoomed(dm)
  table_name <- dm_tbl_name(dm, {{ table }})
  ref_table_name <- dm_tbl_name(dm, {{ ref_table }})

  table <- dm_get_tables_impl(dm)[[table_name]]
  col_expr <- enexpr(columns)
  col_name <- names(eval_select_indices(col_expr, colnames(table)))

  ref_key <- dm_get_pk_impl(dm, ref_table_name)

  if (is_empty(ref_key)) {
    abort_ref_tbl_has_no_pk(ref_table_name)
  }

  ref_col_name <- get_key_cols(ref_key)

  # FIXME: COMPOUND:: Clean check with proper error message
  stopifnot(length(ref_col_name) == length(col_name))

  if (check) {
    tbl_obj <- dm_get_tables(dm)[[table_name]]
    ref_tbl_obj <- dm_get_tables(dm)[[ref_table_name]]

    if (!is_subset(tbl_obj, !!col_name, ref_tbl_obj, !!ref_col_name)) {
      abort_not_subset_of(table_name, col_name, ref_table_name, ref_col_name)
    }
  }

  dm_add_fk_impl(dm, table_name, col_name, ref_table_name)
}


dm_add_fk_impl <- function(dm, table, column, ref_table) {
  def <- dm_get_def(dm)

  i <- which(def$table == ref_table)

  fks <- def$fks[[i]]

  existing <- fks$table == table & !is.na(vctrs::vec_match(fks$column, list(column)))
  if (any(existing)) {
    if (dm_is_strict_keys(dm)) {
      abort_fk_exists(table, column, ref_table)
    }

    return(dm)
  }

  def$fks[[i]] <- vctrs::vec_rbind(
    fks,
    new_fk(table, list(column))
  )

  new_dm3(def)
}

#' Check if foreign keys exists
#'
#' `dm_has_fk()` checks if a foreign key reference exists between two tables in a `dm`.
#'
#' @inheritParams dm_add_fk
#' @param ref_table The table to be checked if it is referred to.
#'
#' @return A boolean value: `TRUE` if a reference from `table` to `ref_table` exists, `FALSE` otherwise.
#'
#' @family foreign key functions
#'
#' @export
#' @examplesIf rlang::is_installed("nycflights13")
#' dm_nycflights13() %>%
#'   dm_has_fk(flights, airports)
#' dm_nycflights13() %>%
#'   dm_has_fk(airports, flights)
dm_has_fk <- function(dm, table, ref_table) {
  check_not_zoomed(dm)
  table_name <- dm_tbl_name(dm, {{ table }})
  ref_table_name <- dm_tbl_name(dm, {{ ref_table }})
  dm_has_fk_impl(dm, table_name, ref_table_name)
}

dm_has_fk_impl <- function(dm, table_name, ref_table_name) {
  has_length(dm_get_fk_impl(dm, table_name, ref_table_name))
}

#' Foreign key column names
#'
#' @description `dm_get_fk()` returns the names of the
#' columns marked as foreign key of table `table` with respect to table `ref_table` within a [`dm`] object.
#' If no foreign key is set between the tables, an empty character vector is returned.
#'
#' @section Compound keys:
#'
#' Currently, keys consisting of more than one column are not supported.
#' [This feature](https://github.com/cynkra/dm/issues/3) is planned for dm 0.2.0.
#' Therefore the function may return vectors of length greater than one in the future.
#'
#' @inheritParams dm_has_fk
#' @param ref_table The table that is referenced from `table`.
#'
#' @family foreign key functions
#'
#' @return A list of character vectors with the column name(s) of `table`,
#' pointing to the primary key of `ref_table`.
#'
#' @export
#' @examplesIf rlang::is_installed("nycflights13")
#' dm_nycflights13() %>%
#'   dm_get_fk(flights, airports)
#' dm_nycflights13(cycle = TRUE) %>%
#'   dm_get_fk(flights, airports)
dm_get_fk <- function(dm, table, ref_table) {
  check_not_zoomed(dm)

  table_name <- dm_tbl_name(dm, {{ table }})
  ref_table_name <- dm_tbl_name(dm, {{ ref_table }})

  new_keys(dm_get_fk_impl(dm, table_name, ref_table_name))
}

dm_get_fk_impl <- function(dm, table_name, ref_table_name) {
  def <- dm_get_def(dm)
  i <- which(def$table == ref_table_name)

  fks <- def$fks[[i]]
  fks %>%
    filter(table == !!table_name) %>%
    pull(column)
}

#' Get foreign key constraints
#'
#' Get a summary of all foreign key relations in a [`dm`].
#'
#' @section Compound keys:
#'
#' Currently, keys consisting of more than one column are not supported.
#' [This feature](https://github.com/cynkra/dm/issues/3) is planned for dm 0.2.0.
#' Therefore the `child_fk_cols` column may contain vectors of length greater than one.
#'
#' @return A tibble with the following columns:
#'   \describe{
#'     \item{`child_table`}{child table,}
#'     \item{`child_fk_cols`}{foreign key column in child table,}
#'     \item{`parent_table`}{parent table.}
#'   }
#'
#' @inheritParams dm_has_fk
#'
#' @family foreign key functions
#'
#' @examplesIf rlang::is_installed("nycflights13")
#' dm_nycflights13() %>%
#'   dm_get_all_fks()
#' @export
dm_get_all_fks <- function(dm) {
  check_not_zoomed(dm)
  dm_get_all_fks_impl(dm)
}

dm_get_all_fks_impl <- function(dm) {
  dm_get_data_model_fks(dm) %>%
    mutate(child_fk_cols = new_keys(child_fk_cols), parent_pk_cols = new_keys(parent_pk_cols)) %>%
    arrange(child_table, child_fk_cols)
}

#' Remove the reference(s) from one [`dm`] table to another
#'
#' @description `dm_rm_fk()` can remove either one reference between two tables, or all references at once, if argument `columns = NULL`.
#' All arguments may be provided quoted or unquoted.
#'
#' @rdname dm_add_fk
#'
#' @family foreign key functions
#'
#' @return For `dm_rm_fk()`: An updated `dm` without the given foreign key relation.
#'
#' @export
#' @examplesIf rlang::is_installed("nycflights13") && rlang::is_installed("DiagrammeR")
#' dm_nycflights13(cycle = TRUE) %>%
#'   dm_rm_fk(flights, dest, airports) %>%
#'   dm_draw()
dm_rm_fk <- function(dm, table, columns, ref_table) {
  check_not_zoomed(dm)

  column_quo <- enquo(columns)

  if (quo_is_missing(column_quo)) {
    abort_rm_fk_col_missing()
  }
  table_name <- dm_tbl_name(dm, {{ table }})
  ref_table_name <- dm_tbl_name(dm, {{ ref_table }})

  fk_cols <- dm_get_fk_impl(dm, table_name, ref_table_name)
  if (is_empty(fk_cols)) {
    # FIXME: Simplify, check is already done in dm_rm_fk_impl()
    abort_is_not_fkc(table_name, fk_cols, ref_table_name)
  }

  if (quo_is_null(column_quo)) {
    cols <- fk_cols
  } else {
    col_idx <- eval_select_indices(column_quo, colnames(dm_get_tables(dm)[[table_name]]))
    cols <- list(names(col_idx))
  }

  dm_rm_fk_impl(dm, table_name, cols, ref_table_name)
}

dm_rm_fk_impl <- function(dm, table_name, cols, ref_table_name) {
  def <- dm_get_def(dm)
  i <- which(def$table == ref_table_name)

  fks <- def$fks[[i]]

  ii <- fks$table != table_name | is.na(vctrs::vec_match(fks$column, unclass(cols)))
  if (all(ii)) {
    abort_is_not_fkc(table_name, cols, ref_table_name)
  }

  fks <- fks[ii, ]
  def$fks[[i]] <- fks

  new_dm3(def)
}

#' Foreign key candidates
#'
#' @description `r lifecycle::badge("questioning")`
#'
#' Determine which columns would be good candidates to be used as foreign keys of a table,
#' to reference the primary key column of another table of the [`dm`] object.
#'
#' @inheritParams dm_add_fk
#' @param table The table whose columns should be tested for suitability as foreign keys.
#' @param ref_table A table with a primary key.
#'
#' @details `dm_enum_fk_candidates()` first checks if `ref_table` has a primary key set,
#' if not, an error is thrown.
#'
#' If `ref_table` does have a primary key, then a join operation will be tried using
#' that key as the `by` argument of join() to match it to each column of `table`.
#' Attempting to join incompatible columns triggers an error.
#'
#' The outcome of the join operation determines the value of the `why` column in the result:
#'
#' - an empty value for a column of `table` that is a suitable foreign key candidate
#' - the count and percentage of missing matches for a column that is not suitable
#' - the error message triggered for unsuitable candidates that may include the types of mismatched columns
#'
#' @section Life cycle:
#' These functions are marked "questioning" because we are not yet sure about
#' the interface, in particular if we need both `dm_enum...()` and `enum...()`
#' variants.
#' Changing the interface later seems harmless because these functions are
#' most likely used interactively.
#'
#' @return A tibble with the following columns:
#'   \describe{
#'     \item{`columns`}{columns of `table`,}
#'     \item{`candidate`}{boolean: are these columns a candidate for a foreign key,}
#'     \item{`why`}{if not a candidate for a foreign key, explanation for for this.}
#'   }
#'
#' @family foreign key functions
#'
#' @examplesIf rlang::is_installed("nycflights13")
#' dm_nycflights13() %>%
#'   dm_enum_fk_candidates(flights, airports)
#'
#' dm_nycflights13() %>%
#'   dm_zoom_to(flights) %>%
#'   enum_fk_candidates(airports)
#' @export
dm_enum_fk_candidates <- function(dm, table, ref_table) {
  check_not_zoomed(dm)
  # FIXME: with "direct" filter maybe no check necessary: but do we want to check
  # for tables retrieved with `tbl()` or with `dm_get_tables()[[table_name]]`
  check_no_filter(dm)
  table_name <- dm_tbl_name(dm, {{ table }})
  ref_table_name <- dm_tbl_name(dm, {{ ref_table }})

  ref_tbl_pk <- dm_get_pk_impl(dm, ref_table_name)

  ref_tbl <- tbl(dm, ref_table_name)
  tbl <- tbl(dm, table_name)

  enum_fk_candidates_impl(table_name, tbl, ref_table_name, ref_tbl, ref_tbl_pk) %>%
    rename(columns = column) %>%
    mutate(columns = new_keys(columns))
}

#' @details `enum_fk_candidates()` works like `dm_enum_fk_candidates()` with the zoomed table as `table`.
#'
#' @rdname dm_enum_fk_candidates
#' @param zoomed_dm A `dm` with a zoomed table.
#' @export
enum_fk_candidates <- function(zoomed_dm, ref_table) {
  check_zoomed(zoomed_dm)
  check_no_filter(zoomed_dm)

  table_name <- orig_name_zoomed(zoomed_dm)
  ref_table_name <- dm_tbl_name(zoomed_dm, {{ ref_table }})

  ref_tbl_pk <- dm_get_pk_impl(zoomed_dm, ref_table_name)

  ref_tbl <- dm_get_tables_impl(zoomed_dm)[[ref_table_name]]
  enum_fk_candidates_impl(table_name, get_zoomed_tbl(zoomed_dm), ref_table_name, ref_tbl, ref_tbl_pk) %>%
    rename(columns = column) %>%
    mutate(columns = new_keys(columns))
}

enum_fk_candidates_impl <- function(table_name, tbl, ref_table_name, ref_tbl, ref_tbl_pk) {
  if (is_empty(ref_tbl_pk)) {
    abort_ref_tbl_has_no_pk(ref_table_name)
  }
  ref_tbl_cols <- get_key_cols(ref_tbl_pk)

  tbl_colnames <- colnames(tbl)
  tibble(
    column = tbl_colnames,
    why = map_chr(column, ~ check_fk(tbl, table_name, .x, ref_tbl, ref_table_name, ref_tbl_cols))
  ) %>%
    mutate(candidate = ifelse(why == "", TRUE, FALSE)) %>%
    select(column, candidate, why) %>%
    arrange(desc(candidate))
}

check_fk <- function(t1, t1_name, colname, t2, t2_name, pk) {
  stopifnot(length(colname) == length(pk))

  val_names <- paste0("value", seq_along(colname))
  t1_vals <- syms(colname)
  names(t1_vals) <- val_names
  t2_vals <- syms(pk)
  names(t2_vals) <- val_names

  t1_join <-
    t1 %>%
    count(!!!t1_vals) %>%
    ungroup()
  t2_join <-
    t2 %>%
    count(!!!t2_vals) %>%
    ungroup()

  # FIXME: Build expression instead of paste() + parse()
  any_value_na_expr <- parse(text = paste0("is.na(", val_names, ")", collapse = " | "))[[1]]

  res_tbl <- tryCatch(
    t1_join %>%
      # if value* is NULL, this also counts as a match -- consistent with fk semantics
      filter(!(!!any_value_na_expr)) %>%
      anti_join(t2_join, by = val_names) %>%
      arrange(desc(n), !!!syms(val_names)) %>%
      head(MAX_COMMAS + 1L) %>%
      collect(),
    error = identity
  )

  # return error message if error occurred (possibly types didn't match etc.)
  if (is_condition(res_tbl)) {
    return(conditionMessage(res_tbl))
  }

  # return empty character if candidate
  if (nrow(res_tbl) == 0) {
    return("")
  }

  res_tbl[val_names] <- map(res_tbl[val_names], format, trim = TRUE, justify = "none")
  res_tbl[val_names[-1]] <- map(res_tbl[val_names[-1]], ~ paste0(", ", .x))
  res_tbl$value <- exec(paste0, !!!res_tbl[val_names])

  vals_formatted <- commas(
    glue('{res_tbl$value} ({res_tbl$n})'),
    capped = TRUE
  )
  glue(
    "values of ",
    "{commas(tick(glue('{t1_name}${colname}')), Inf)} not in {commas(tick(glue('{t2_name}${pk}')), Inf)}: {vals_formatted}"
  )
}


# Errors ------------------------------------------------------------------

abort_fk_exists <- function(child_table_name, colnames, parent_table_name) {
  abort(
    error_txt_fk_exists(
      child_table_name, colnames, parent_table_name
    ),
    .subclass = dm_error_full("fk_exists")
  )
}

error_txt_fk_exists <- function(child_table_name, colnames, parent_table_name) {
  glue(
    "({commas(tick(colnames))}) is alreay a foreign key of table ",
    "{tick(child_table_name)} into table {tick(parent_table_name)}."
  )
}

abort_is_not_fkc <- function(child_table_name, colnames,
                             parent_table_name) {
  abort(
    error_txt_is_not_fkc(
      child_table_name, colnames, parent_table_name
    ),
    .subclass = dm_error_full("is_not_fkc")
  )
}

error_txt_is_not_fkc <- function(child_table_name, colnames,
                                 parent_table_name) {
  glue(
    "({commas(tick(colnames))}) is not a foreign key of table ",
    "{tick(child_table_name)} into table {tick(parent_table_name)}."
  )
}

abort_rm_fk_col_missing <- function() {
  abort(error_txt_rm_fk_col_missing(), .subclass = dm_error_full("rm_fk_col_missing"))
}

error_txt_rm_fk_col_missing <- function() {
  "Parameter `columns` has to be set. Pass `NULL` for removing all references."
}
