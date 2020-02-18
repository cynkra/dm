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
#' @param table_names A named character vector, containing the names that you want the tables in the `dm` to have
#'   after copying them to the database.
#'   The table names within the `dm` will remain unchanged.
#'   The name of each element of the vector needs to be one of the table names of the `dm`.
#'   Those tables of the `dm` that are not addressed will be called by their original name on the database.
#' @param overwrite,types,indexes,unique_indexes Must remain `NULL`.
#' @param set_key_constraints Boolean variable, if `TRUE` will mirror `dm` key constraints on a database.
#' @param unique_table_names Boolean, if `FALSE` (default), the original table names will be used, if `TRUE`,
#'   unique table names will be created based on the original table names.
#' @param temporary Boolean variable, if `TRUE`, only temporary tables will be created.
#'   These tables will vanish when disconnecting from the database.
#' @param ... Possible further arguments passed to [dplyr::copy_to()], which is used on each table.
#'
#' @family DB interaction functions
#'
#' @return A `dm` object on the given `src`.
#'
#' @examples
#' src_sqlite <- dplyr::src_sqlite(":memory:", create = TRUE)
#' iris_dm <- copy_dm_to(
#'   src_sqlite,
#'   as_dm(list(iris = iris)),
#'   set_key_constraints = FALSE
#' )
#' @export
copy_dm_to <- function(dest, dm, ...,
                       types = NULL, overwrite = NULL,
                       indexes = NULL, unique_indexes = NULL,
                       set_key_constraints = TRUE, unique_table_names = FALSE,
                       table_names = NULL,
                       temporary = TRUE) {
  # for the time being, we will be focusing on MSSQL
  # we expect the src (dest) to already point to the correct schema
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

  if (!is.null(table_names)) {
    if (unique_table_names) {
      abort_unique_table_names_or_table_names()
    }

    not_found <- setdiff(names2(table_names), src_tbls(dm))
    if (has_length(not_found)) {
      if (any(not_found == "")) abort_need_named_vec(src_tbls(dm))
      abort_table_not_in_dm(unique(not_found), src_tbls(dm))
    }
  }

  check_not_zoomed(dm)

  # FIXME: if same_src(), can use compute() but need to set NOT NULL
  # constraints

  dest <- src_from_src_or_con(dest)
  dm <- collect(dm)

  copy_data <- build_copy_data(dm, dest, table_names, unique_table_names)

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
