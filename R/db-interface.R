#' Copy a `dm`-object to a `src`/`con`
#'
#' `cdm_copy_to()` takes a `src`- or `con`-object as a first argument,
#' and a [`dm`] object as a second. The latter is copied to the former. By default
#' the key constraints will be set (for now only on MSSQL- and Postgres-DBs).
#' By default temporary tables will be created.
#'
#' No tables will be overwritten, passing `overwrite = TRUE` gives an error.
#' Types are determined separately for each table, setting the `types` argument
#' also gives an error.
#' The arguments are included in the signature to avoid passing them via the
#' `...` ellipsis.
#'
#' @param dest A `src` or `con` object like e.g. a database.
#' @param dm A `dm` object.
#' @param table_names A named character vector, containing the names you want the tables in the `dm` to have
#' after copying them to the database. The table names within the `dm` will remain unchanged.
#' The name of each element of the vector needs to be one of the table names of the `dm`.
#' Those tables of the `dm` that are not addressed will be called by their original name on the database.
#' @param overwrite,types,indexes,unique_indexes Must remain `NULL`.
#' @param set_key_constraints Boolean variable, if `TRUE` will mirror `dm` key constraints on a database.
#' @param unique_table_names Boolean, if `FALSE` (default), original table names will be used, if `TRUE`,
#'   unique table names will be created based on the original table names.
#' @param temporary Boolean variable, if `TRUE` will only create temporary tables, which will vanish when connection is interrupted.
#' @param ... Possible further arguments passed to [dplyr::copy_to()] (which is used on each table)
#'
#' @family DB interaction functions
#'
#' @examples
#' src_sqlite <- dplyr::src_sqlite(":memory:", create = TRUE)
#' iris_dm <- cdm_copy_to(
#'   src_sqlite,
#'   as_dm(list(iris = iris)),
#'   set_key_constraints = FALSE
#' )
#' @export
cdm_copy_to <- nse_function(c(dest, dm, ...,
                              types = NULL, overwrite = NULL,
                              indexes = NULL, unique_indexes = NULL,
                              set_key_constraints = TRUE, unique_table_names = FALSE,
                              table_names = NULL,
                              temporary = TRUE), ~
{
  # for now focusing on MSSQL
  # we expect the src (dest) to already point to the correct schema
  # we want to
  #   1. change `cdm_get_src(dm)` to `dest`
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
      if (any(not_found == "")) abort_need_named_vec(dm)
      abort_table_not_in_dm(unique(not_found), dm)
    }
  }

  # FIXME: if same_src(), can use compute(), but need to set NOT NULL
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

  new_src <- src_from_src_or_con(dest)

  remote_dm <- new_dm2(
    data = new_tables,
    base_dm = dm
  )

  if (set_key_constraints && is_src_db(remote_dm)) {
    cdm_set_key_constraints(remote_dm)
  }

  invisible(remote_dm)
})

#' Set key constraints on a DB for a `dm`-obj with keys.
#'
#' @description `cdm_set_key_constraints()` takes a `dm` object that lives on a DB (so far
#' it works exclusively for MSSQL and Postgres) and mirrors the `dm` key constraints
#' on the database.
#'
#' @inheritParams cdm_copy_to
#'
#' @family DB interaction functions
#'
#' @examples
#' src_sqlite <- dplyr::src_sqlite(":memory:", create = TRUE)
#' iris_dm <- cdm_copy_to(
#'   src_sqlite,
#'   as_dm(list(iris = iris)),
#'   set_key_constraints = FALSE
#' )
#'
#' # there are no key constraints in `as_dm(list(iris = iris))`,
#' # but if there were, and if we had already implemented setting key
#' # constraints for SQLite, this would do something:
#' cdm_set_key_constraints(iris_dm)
#' @noRd
cdm_set_key_constraints <- nse_function(c(dm), ~ {
  if (!is_src_db(dm) && !is_this_a_test()) abort_src_not_db()
  db_table_names <- get_db_table_names(dm)

  tables_w_pk <- cdm_get_all_pks(dm)

  fk_info <-
    cdm_get_all_fks(dm) %>%
    left_join(tables_w_pk, by = c("parent_table" = "table")) %>%
    left_join(db_table_names, by = c("child_table" = "table_name")) %>%
    rename(db_child_table = remote_name) %>%
    left_join(db_table_names, by = c("parent_table" = "table_name")) %>%
    rename(db_parent_table = remote_name)

  con <- con_from_src_or_con(cdm_get_src(dm))
  queries <- create_queries(con, fk_info)
  walk(queries, ~ dbExecute(con, .))

  invisible(dm)
})
