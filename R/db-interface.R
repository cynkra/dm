#' Copy data model to data source
#'
#' `copy_dm_to()` takes a [dplyr::src_dbi] object or a [`DBI::DBIConnection-class`] object as its first argument
#' and a [`dm`] object as its second argument.
#' The latter is copied to the former.
#' By default, temporary tables will be created and the key constraints will be set
#' (currently only on MSSQL and Postgres databases).
#'
#' No tables will be overwritten; passing `overwrite = TRUE` to the function will give an error.
#' Types are determined separately for each table, setting the `types` argument will
#' also throw an error.
#' The arguments are included in the signature to avoid passing them via the
#' `...` ellipsis.
#'
#' @param dest An object of class `"src"` or `"DBIConnection"`.
#' @param dm A `dm` object.
#' @param overwrite,types,indexes,unique_indexes Must remain `NULL`.
#' @param set_key_constraints Boolean variable, if `TRUE` will mirror `dm` key constraints on a database.
#' @param unique_table_names Deprecated.
#' @param temporary Boolean variable, if `TRUE`, only temporary tables will be created.
#'   These tables will vanish when disconnecting from the database.
#' @param table_names Desired names for the tables on `dest`; the names within the `dm` remain unchanged.
#'    Can be `NULL`, a named character vector, a function or a one-sided formula.
#'
#'   If left `NULL` (default), the names will be determined automatically depending on the `temporary` argument:
#'
#'   1. `temporary = TRUE` (default): unique table names based on the names of the tables in the `dm` are created.
#'   1. `temporary = FALSE`: the table names in the `dm` are used as names for the tables on `dest`.
#'
#'   If a function or one-sided formula, `table_names` is converted to a function
#'   using [rlang::as_function()].
#'   This function is called with the table names of the `dm` object
#'   as the only argument, and is expected to return a character vector
#'   of the same length.
#'   Use `table_names = ~ dbplyr::in_schema("schema_name", .x)`
#'   to specify the same schema for all tables.
#'   Use `table_names = identity` with `temporary = TRUE`
#'   to avoid giving temporary tables unique names.
#'
#'   If a named character vector,
#'   the names of this vector need to correspond to the table names in the `dm`,
#'   and its values are the desired names on `dest`.
#'   Use qualified names corresponding to your database's syntax
#'   to specify e.g. database and schema for your tables.
#' @param ... Passed on to [dplyr::copy_to()], which is used on each table.
#'
#' @family DB interaction functions
#'
#' @return A `dm` object on the given `src` with the same table names
#'   as the input `dm`.
#'
#' @examples
#' con <- DBI::dbConnect(RSQLite::SQLite())
#'
#' # Copy to temporary tables, unique table names by default:
#' temp_dm <- copy_dm_to(
#'   con,
#'   dm_nycflights13(),
#'   set_key_constraints = FALSE
#' )
#'
#' # Persist, explicitly specify table names:
#' persistent_dm <- copy_dm_to(
#'   con,
#'   dm_nycflights13(),
#'   temporary = FALSE,
#'   table_names = ~ paste0("flights_", .x)
#' )
#' dbplyr::remote_name(persistent_dm$planes)
#'
#' DBI::dbDisconnect(con)
#' @export
copy_dm_to <- function(dest, dm, ...,
                       types = NULL, overwrite = NULL,
                       indexes = NULL, unique_indexes = NULL,
                       set_key_constraints = TRUE, unique_table_names = NULL,
                       table_names = NULL,
                       temporary = TRUE) {
  # for the time being, we will be focusing on MSSQL
  # we want to
  #   1. change `dm_get_src(dm)` to `dest`
  #   2. copy the tables to `dest`
  #   3. implement the key situation within our `dm` on the DB

  if (!is_null(overwrite)) {
    abort_no_overwrite()
  }

  if (!is_null(types)) {
    abort_no_types()
  }

  if (!is_null(indexes)) {
    abort_no_indexes()
  }

  if (!is_null(unique_indexes)) {
    abort_no_unique_indexes()
  }

  if (!is_null(unique_table_names)) {
    lifecycle::deprecate_soft(
      "0.1.4", "copy_dm_to(unique_table_names = )",
      details = "Use `table_names = identity` to use unchanged names for temporary tables."
    )

    if (is.null(table_names) && temporary && !unique_table_names) {
      table_names <- identity
    }
  }

  # in case `table_names` was chosen by the user, check if the input makes sense:
  # 1. is there one name per dm-table?
  # 2. are there any duplicated table names?
  # 3. is it a named character or ident_q vector with the correct names?
  if (is_null(table_names)) {
    table_names <- repair_table_names_for_db(src_tbls(dm), temporary)
  } else {
    if (is_function(table_names) || is_bare_formula(table_names)) {
      table_name_fun <- as_function(table_names)
      table_names <- set_names(table_name_fun(src_tbls(dm)), src_tbls(dm))
    }
    check_naming(names(table_names), src_tbls(dm))
    # add the schema and create an `ident`-class object from the table names
    table_names <- dbplyr::ident_q(table_names[src_tbls(dm)])
  }

  check_not_zoomed(dm)

  # FIXME: if same_src(), can use compute() but need to set NOT NULL
  # constraints

  dest <- src_from_src_or_con(dest)
  dm <- collect(dm)

  copy_data <- build_copy_data(dm, dest, table_names)

  new_tables <- copy_list_of_tables_to(
    dest,
    copy_data = copy_data,
    temporary = temporary,
    overwrite = FALSE,
    ...
  )

  def <- dm_get_def(dm)
  def$data <- new_tables
  remote_dm <- new_dm3(def)

  if (set_key_constraints && is_src_db(remote_dm)) {
    dm_set_key_constraints(remote_dm)
  }

  invisible(debug_validate_dm(remote_dm))
}

#' Set key constraints on a DB for a `dm`-obj with keys
#'
#' @description `dm_set_key_constraints()` takes a `dm` object that is constructed from tables in a database
#' (this is currently only implemented for MSSQL and Postgres databases), and mirrors the `dm` key constraints
#' on the database.
#'
#' @inheritParams copy_dm_to
#'
#' @family DB interaction functions
#'
#' @return Returns the `dm`, invisibly. Side effect: installing key constraints on DB.
#'
#' @examples
#' src_sqlite <- dplyr::src_sqlite(":memory:", create = TRUE)
#' iris_dm <- copy_dm_to(
#'   src_sqlite,
#'   as_dm(list(iris = iris)),
#'   set_key_constraints = FALSE
#' )
#'
#' # there are no key constraints in `as_dm(list(iris = iris))`
#' # but if there were, and if we had already implemented setting key
#' # constraints for SQLite, the following command would do something:
#' dm_set_key_constraints(iris_dm)
#' @noRd
dm_set_key_constraints <- function(dm) {
  if (!is_src_db(dm) && !is_this_a_test()) abort_key_constraints_need_db()
  db_table_names <- get_db_table_names(dm)

  tables_w_pk <- dm_get_all_pks(dm)

  fk_info <-
    dm_get_all_fks(dm) %>%
    left_join(tables_w_pk, by = c("parent_table" = "table")) %>%
    left_join(db_table_names, by = c("child_table" = "table_name")) %>%
    rename(db_child_table = remote_name) %>%
    left_join(db_table_names, by = c("parent_table" = "table_name")) %>%
    rename(db_parent_table = remote_name)

  con <- con_from_src_or_con(dm_get_src(dm))
  queries <- create_queries(con, fk_info)
  walk(queries, ~ dbExecute(con, .))

  invisible(dm)
}

check_naming <- function(table_names, dm_table_names) {
  if (!identical(sort(table_names), sort(dm_table_names))) {
    abort_copy_dm_to_table_names()
  }
}


# Errors ------------------------------------------------------------------

abort_copy_dm_to_table_names <- function(problems) {
  abort(error_txt_copy_dm_to_table_names(), .subclass = dm_error_full("copy_dm_to_table_names"))
}

error_txt_copy_dm_to_table_names <- function() {
  "`table_names` must have names that are the same as the table names in `dm`."
}
