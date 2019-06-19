#' Copy a 'dm'-object to a 'src'/'con'
#'
#' @description `cdm_copy_to()` takes a `src`- or `con`-object as a first argument,
#' and a `dm`-object as a second. The latter is copied to the former. By default
#' the key constraints will be set (for now only on MSSQL- and Postgres-DBs).
#' By default temporary tables will be created.
#'
#' @param dest A `src` or `con` object like e.g. a database.
#' @param dm A `dm` object.
#' @param set_key_constraints Boolean variable, if `TRUE` will mirror `dm` key constraints on a database.
#' @param table_names Character vector containing the names for the DB-tables.
#' @param temporary Boolean variable, if `TRUE` will only create temporary tables, which will vanish when connection is interrupted.
#' @param ... Possible further arguments passed to [dplyr::copy_to()] (which is used on each table)
#'
#' @examples
#' \dontrun{
#' src_postgres <- dplyr::src_postgres()
#' cdm_copy_to(src_postgres, as_dm(list(iris = iris)))
#' }
#' @export
cdm_copy_to <- function(dest, dm, set_key_constraints = TRUE, table_names = NULL, temporary = TRUE, ...) {
# for now focusing on MSSQL
# we expect the src (dest) to already point to the correct schema
# we want to
#   1. change `dm$src` to `dest`
#   2. copy the tables to `dest`
#   3. implement the key situation within our `dm` on the DB

if (is_true(list(...)$overwrite)) {
  abort_no_overwrite()
}

if (is_null(table_names)) {
  list_of_unique_names <- tibble(table_names = src_tbls(dm),
                                 unique_names = map_chr(src_tbls(dm), unique_db_table_name)
  )
} else {
  stopifnot(length(table_names) == length(src_tbls(dm)))
  list_of_unique_names <- tibble(table_names = src_tbls(dm),
                                 unique_names = table_names
  )
}
name_vector <- pull(list_of_unique_names, unique_names)

new_tables <- copy_list_of_tables_to(
  dest,
  list_of_tables = cdm_get_tables(dm),
  name_vector = name_vector,
  temporary = temporary,
  ...)

new_src <- src_from_src_or_con(dest)

remote_dm <- new_dm(
  src = new_src,
  tables = new_tables,
  data_model = cdm_get_data_model(dm)
  )

if (set_key_constraints) cdm_set_key_constraints(remote_dm)

invisible(remote_dm)
}

#' Set key constraints on a DB for a `dm`-obj with keys.
#'
#' @description `cdm_set_key_constraints()` takes a `dm`-object that lives on a DB (so far
#' it works exclusively for MSSQL and Postgres) and mirrors the `dm` key constraints
#' on the database.
#'
#' @inheritParams cdm_copy_to
#'
#' @examples
#' \dontrun{
#' src_postgres <- dplyr::src_postgres()
#' iris_dm <- cdm_copy_to(
#'   src_postgres,
#'   as_dm(list(iris = iris)),
#'   set_key_constraints = FALSE)
#'
#' # there are no key constraints in `as_dm(list(iris = iris))`,
#' # but if there were, this would do something:
#' cdm_set_key_constraints(iris_dm)
#' }
#' @export
cdm_set_key_constraints <- function(dm) {

  if (!is_src_db(dm) && !is_this_a_test()) abort_src_not_db()
  db_table_names <- get_db_table_names(dm)

  tables_w_pk <- cdm_get_all_pks(dm)
  if (nrow(tables_w_pk) > 0) {
    pk_info <- tables_w_pk %>%
      left_join(db_table_names, by = c("table" = "table_name"))
  } else pk_info <- NULL

  if (nrow(cdm_get_all_fks(dm)) > 0) {
    fk_info <-
      cdm_get_all_fks(dm) %>%
      left_join(tables_w_pk, by = c("parent_table" = "table")) %>%
      left_join(db_table_names, by = c("child_table" = "table_name")) %>%
      rename(db_child_table = remote_name) %>%
      left_join(db_table_names, by = c("parent_table" = "table_name")) %>%
      rename(db_parent_table = remote_name)
  } else fk_info <- NULL

  con <- con_from_src_or_con(cdm_get_src(dm))
  queries <- create_queries(con, pk_info, fk_info)
  if (!is_empty(queries)) walk(queries, ~dbExecute(con, .))

  invisible(dm)
}
