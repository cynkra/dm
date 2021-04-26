#' Add/remove a primary key
#'
#' @description `dm_add_pk()` marks the specified columns as the primary key of the specified table.
#' If `check == TRUE`, then it will first check if
#' the given combination of columns is a unique key of the table.
#' If `force == TRUE`, the function will replace an already
#' set key.
#'
#' `dm_rm_pk()` removes a primary key from a table and leaves the [`dm`] object otherwise unaltered.
#' Foreign keys that point to the table from other tables, can be optionally removed as well.
#'
#' @section Compound keys:
#'
#' Currently, keys consisting of more than one column are not supported.
#' [This feature](https://github.com/cynkra/dm/issues/3) is planned for dm 0.2.0.
#' The syntax of these functions will be extended but will remain compatible
#' with current semantics.
#'
#' @param dm A `dm` object.
#' @param table A table in the `dm`.
#' @param columns Table columns, unquoted.
#' @param check Boolean, if `TRUE`, a check is made if the combination of columns is a unique key of the table.
#' @param force Boolean, if `FALSE` (default), an error will be thrown if there is already a primary key
#'   set for this table.
#'   If `TRUE`, a potential old `pk` is deleted before setting a new one.
#'
#' @family primary key functions
#'
#' @return For `dm_add_pk()`: An updated `dm` with an additional primary key.
#'
#' @export
#' @examplesIf rlang::is_installed("nycflights13") && rlang::is_installed("DiagrammeR")
#' nycflights_dm <- dm(
#'   planes = nycflights13::planes,
#'   airports = nycflights13::airports
#' )
#'
#' nycflights_dm %>%
#'   dm_draw()
#'
#' # the following works
#' nycflights_dm %>%
#'   dm_add_pk(planes, tailnum) %>%
#'   dm_add_pk(airports, faa, check = TRUE) %>%
#'   dm_draw()
#'
#' # the following throws an error:
#' try(
#'   nycflights_dm %>%
#'     dm_add_pk(planes, manufacturer, check = TRUE)
#' )
dm_add_pk <- function(dm, table, columns, check = FALSE, force = FALSE) {
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

  def$pks[[which(def$table == table)]] <- tibble(column = !!list(column))

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
dm_has_pk <- function(dm, table) {
  check_not_zoomed(dm)
  table_name <- dm_tbl_name(dm, {{ table }})
  dm_has_pk_impl(dm, table_name)
}

dm_has_pk_impl <- function(dm, table) {
  has_length(dm_get_pk2_impl(dm, table))
}

#' Primary key column names
#'
#' @description `dm_get_pk()` returns the names of the
#' columns marked as primary key of a table of a [`dm`] object.
#' If no primary key is
#' set for the table, an empty character vector is returned.
#'
#' @section Compound keys and multiple primary keys:
#'
#' Currently, keys consisting of more than one column are not supported.
#' [This feature](https://github.com/cynkra/dm/issues/3) is planned for dm 0.2.0.
#' Therefore the function may return vectors of length greater than one in the future.
#'
#' Similarly, each table currently can have only one primary key.
#' This restriction may be lifted in the future.
#' For this reason, and for symmetry with `dm_get_fk()`,
#' this function returns a slit of character vectors.
#'
#' @family primary key functions
#'
#' @return A list with character vectors with the column name(s) of the
#'   primary keys of `table`.
#'
#' @inheritParams dm_add_pk
#'
#' @examplesIf rlang::is_installed("nycflights13")
#' dm_nycflights13() %>%
#'   dm_get_pk(flights)
#' dm_nycflights13() %>%
#'   dm_get_pk(planes)
#' @export
dm_get_pk <- function(dm, table) {
  check_not_zoomed(dm)
  table_name <- dm_tbl_name(dm, {{ table }})
  new_keys(dm_get_pk2_impl(dm, table_name))
}

dm_get_pk_impl <- function(dm, table_name) {
  out <- dm_get_pk2_impl(dm, table_name)
  if (is_empty(out)) {
    character()
  } else {
    out[[1]]
  }
}

dm_get_pk2_impl <- function(dm, table_name) {
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
#' @section Compound keys:
#'
#' Currently, keys consisting of more than one column are not supported.
#' [This feature](https://github.com/cynkra/dm/issues/3) is planned for dm 0.2.0.
#' Therefore the `pk_cols` column may contain vectors of length greater than one.
#'
#' @family primary key functions
#'
#' @inheritParams dm_add_pk
#'
#' @return A tibble with the following columns:
#'   \describe{
#'     \item{`table`}{table name,}
#'     \item{`pk_cols`}{column name(s) of primary key.}
#'   }
#'
#' @export
#' @examplesIf rlang::is_installed("nycflights13")
#' dm_nycflights13() %>%
#'   dm_get_all_pks()
dm_get_all_pks <- function(dm) {
  check_not_zoomed(dm)
  dm_get_all_pks_impl(dm) %>%
    mutate(pk_col = new_keys(pk_col))
}

dm_get_all_pks_impl <- function(dm) {
  # FIXME: COMPOUND: Obliterate

  dm_get_def(dm) %>%
    select(table, pks) %>%
    unnest_pks(flatten = TRUE) %>%
    select(table = table, pk_col = column)
}

dm_get_all_pks2_impl <- function(dm) {
  dm_get_def(dm) %>%
    select(table, pks) %>%
    unnest_pks(flatten = FALSE) %>%
    select(table = table, pk_col = column) %>%
    mutate(pk_col = new_keys(pk_col))
}


#' Remove a primary key from a table in a [`dm`] object
#'
#' @rdname dm_add_pk
#'
#' @param rm_referencing_fks Boolean: if `FALSE` (default), will throw an error if
#'   there are foreign keys addressing the primary key that is to be removed.
#'   If `TRUE`, the function will
#'   remove, in addition to the primary key of the `table` argument, also all foreign key constraints
#'   that are pointing to it.
#'
#' @return For `dm_rm_pk()`: An updated `dm` without the indicated primary key.
#'
#' @examplesIf rlang::is_installed("nycflights13") && rlang::is_installed("DiagrammeR")
#' dm_nycflights13() %>%
#'   dm_rm_pk(airports, rm_referencing_fks = TRUE) %>%
#'   dm_draw()
#' @export
dm_rm_pk <- function(dm, table, rm_referencing_fks = FALSE) {
  check_not_zoomed(dm)
  table_name <- dm_tbl_name(dm, {{ table }})

  if (!rm_referencing_fks && dm_is_referenced(dm, !!table_name)) {
    affected <- dm_get_referencing_tables(dm, !!table_name)
    abort_first_rm_fks(table_name, affected)
  }

  dm_rm_pk_impl(dm, table_name)
}

dm_rm_pk_impl <- function(dm, table_name) {
  def <- dm_get_def(dm)

  i <- which(def$table == table_name)

  if (nrow(def$pks[[i]]) == 0 && dm_is_strict_keys(dm)) {
    abort_pk_not_defined(table_name)
  }

  def$pks[[i]] <- new_pk()
  def$fks[[i]] <- new_fk()

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
enum_pk_candidates <- function(table) {
  # a list of ayes and noes:
  if (is_dm(table) && is_zoomed(table)) table <- get_zoomed_tbl(table)

  enum_pk_candidates_impl(table) %>%
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
dm_enum_pk_candidates <- function(dm, table) {
  check_not_zoomed(dm)
  # FIXME: with "direct" filter maybe no check necessary: but do we want to check
  # for tables retrieved with `tbl()` or with `dm_get_tables()[[table_name]]`
  check_no_filter(dm)

  table_name <- dm_tbl_name(dm, {{ table }})

  table <- dm_get_tables_impl(dm)[[table_name]]
  enum_pk_candidates_impl(table) %>%
    rename(columns = column) %>%
    mutate(columns = new_keys(columns))
}

enum_pk_candidates_impl <- function(table, columns = colnames(table)) {
  map_chr(set_names(columns), function(x) check_pk(table, {{ x }})) %>%
    enframe("column", "why") %>%
    mutate(candidate = (why == "")) %>%
    select(column, candidate, why) %>%
    arrange(desc(candidate), column)
}

check_pk <- function(table, columns) {
  duplicate_values <- is_unique_key_se(table, key_to_expr(columns), commas(columns))
  if (duplicate_values$unique) {
    return("")
  }

  fun <- ~ format(.x, trim = TRUE, justify = "none")

  values <- duplicate_values$data[[1]]$value
  values_na <- is.na(values)

  if (any(values_na)) {
    missing <- "missing values"
    values <- values[!values_na]
  } else {
    missing <- NULL
  }

  if (length(values) > 0) {
    values_text <- commas(values, capped = TRUE, fun = fun)
    duplicate <- paste0("duplicate values: ", values_text)
  } else {
    duplicate <- NULL
  }

  problem <- glue_collapse(c(missing, duplicate), sep = "", last = ", and ")
  paste0("has ", problem)
}


# Error -------------------------------------------------------------------

abort_pk_not_defined <- function(table) {
  abort(error_txt_pk_not_defined(table), .subclass = dm_error_full("pk_not_defined"))
}

error_txt_pk_not_defined <- function(table) {
  glue("Table {tick(table)} does not have a primary key.")
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
    "First remove those or set `rm_referencing_fks = TRUE`."
  )
}
