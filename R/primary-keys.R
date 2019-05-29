# for external users: also checks if really is primary key

#' Mark a column of a table in a `dm`-object as its primary key
#'
#' @description `cdm_add_pk()` marks the given column as the given table's primary key
#' in the `data_model`-part of the `dm`-object. If `check == TRUE`, it also first checks if
#' the given column is a unique key of the table. If `force == TRUE`, it replaces an already
#' set key.
#'
#' @export
#' @examples
#' \dontrun{
#' library(nycflights13)
#' library(dplyr)
#'
#' nycflights_dm <- dm(src_df(pkg = "nycflights13"))
#'
#' # the following works
#' cdm_add_pk(nycflights_dm, planes, tailnum)
#' cdm_add_pk(nycflights_dm, airports, faa)
#' cdm_add_pk(nycflights_dm, planes, manufacturer, check = FALSE)
#'
#' # the following does not work
#' cdm_add_pk(nycflights_dm, planes, manufacturer)
#' }
cdm_add_pk <- function(dm, table, column, check = TRUE, force = FALSE) {

  table_name <- as_name(enquo(table))

  check_correct_input(dm, table_name)

  if (is_symbol(enexpr(column))) {
    col_expr <- enexpr(column)
    col_name <- as_name(col_expr)
  } else if (is_character(column)) {
    col_name <- column
    col_expr <- ensym(column)
  } else {
    abort_wrong_col_args()
  }

  if (cdm_has_pk(dm, !!table_name)) {
    if (!force) {
      old_key <- cdm_get_pk(dm, !!table_name)
      if (old_key == col_name) {
        return(dm)
      }
      abort_key_set_force_false()
    }
  }

  if (check) {
    table_from_dm <- tbl(dm, table_name)
    check_key(table_from_dm, !!col_expr)
  }

  cdm_rm_pk(dm, !!table_name) %>% cdm_add_pk_impl(table_name, col_name)
}

# "table" and "column" has to be character
# in {datamodelr} a primary key can also consists of more than one column
# only adds key, independent if it is unique key or not; not to be exported
# the "cdm" just means "cynkra-dm", to distinguish it from {datamodelr}-functions
cdm_add_pk_impl <- function(dm, table, column) {
  new_data_model <- cdm_get_data_model(dm) %>%
    datamodelr::dm_set_key(table, column)

  new_dm(cdm_get_src(dm), cdm_get_tables(dm), new_data_model)
}

#' Does a table of a `dm`-object have a column set as primary key?
#'
#' @description `cdm_has_pk()` checks in the `data_model` part
#' of the `dm`-object if a given table has a column marked as primary key.
#'
#' @examples
#' \dontrun{
#' library(nycflights13)
#' library(dplyr)
#'
#' nycflights_dm <- dm(src_df(pkg = "nycflights13"))
#' cdm_obj_with_keys <- cdm_add_pk(nycflights_dm, planes, tailnum)
#'
#' cdm_obj_with_keys %>%
#'   cdm_has_pk(planes)
#' }
#'
#' @export
cdm_has_pk <- function(dm, table) {
  table_name <- as_name(enquo(table))

  check_correct_input(dm, table_name)

  cdm_data_model <- cdm_get_data_model(dm)

  cols_from_table <- cdm_data_model$columns$table == table_name
  if (sum(cdm_data_model$columns$key[cols_from_table] > 0) > 1) {
    abort_multiple_pks(table_name)
  }
  !all(cdm_data_model$columns$key[cols_from_table] == 0)
}

#' Retrieve the name of the column marked as primary key of a table of a `dm`-object
#'
#' @description `cdm_get_pk()` returns the name of the
#' column marked as primary key of a table of a `dm`-object. If no primary key is
#' set for the table, an empty character variable is returned.
#'
#' @examples
#' \dontrun{
#' library(nycflights13)
#' library(dplyr)
#'
#' nycflights_dm <- dm(src_df(pkg = "nycflights13"))
#' cdm_obj_with_keys <- cdm_add_pk(nycflights_dm, planes, tailnum)
#'
#' cdm_obj_with_keys %>%
#'   cdm_get_pk(planes)
#' }
#'
#' @export
cdm_get_pk <- function(dm, table) {

  table_name <- as_name(enquo(table))

  check_correct_input(dm, table_name)
  cdm_data_model <- cdm_get_data_model(dm)

  index_key_from_table <- cdm_data_model$columns$table == table_name & cdm_data_model$columns$key != 0
  if (sum(index_key_from_table) > 1) {
    abort_multiple_pks(table_name)
  }
  cdm_data_model$columns$column[index_key_from_table]
}

#' Remove primary key from a table in a `dm`-object
#'
#' @description `cdm_rm_pk()` removes a potentially set primary key from a table in the
#' underlying `data_model`-object and otherwise leaves the `dm`-object untouched.
#'
#' @examples
#' \dontrun{
#' library(nycflights13)
#' library(dplyr)
#'
#' nycflights_dm <- dm(src_df(pkg = "nycflights13"))
#'
#' cdm_obj_with_keys <-
#'   nycflights_dm %>%
#'   cdm_add_pk(planes, tailnum) %>%
#'   cdm_add_pk(airports, faa)
#'
#' cdm_obj_with_keys %>%
#'   cdm_rm_pk(airports) %>%
#'   cdm_has_pk(planes)
#'
#' cdm_obj_with_keys %>%
#'   cdm_rm_pk(planes) %>%
#'   cdm_has_pk(planes)
#' }
#'
#' @export
cdm_rm_pk <- function(dm, table) {
  table_name <- as_name(enquo(table))

  check_correct_input(dm, table_name)

  update_cols <- dm$data_model$columns$table == table_name
  dm$data_model$columns$key[update_cols] <- 0

  dm
}


#' Which columns are candidates for a primary key column of a `dm`-object's table?
#'
#' @description `cdm_check_for_pk_candidates()` checks for each column of a
#' table of a `dm`-object if this column contains only unique values and is therefore
#' a unique key of this table.
#'
#' @examples
#' \dontrun{
#' library(nycflights13)
#' library(dplyr)
#'
#' nycflights_dm <- dm(src_df(pkg = "nycflights13"))
#'
#' nycflights_dm %>% cdm_check_for_pk_candidates(flights)
#' nycflights_dm %>% cdm_check_for_pk_candidates(airports)
#' }
#'
#' @export
cdm_check_for_pk_candidates <- function(dm, table) {
  table_name <- as_name(enquo(table))

  check_correct_input(dm, table_name)

  tbl <- cdm_get_tables(dm)[[table_name]]
  tbl_colnames <- colnames(tbl)

  # list of ayes and noes:
  map(tbl_colnames, ~ is_unique_key(tbl, eval_tidy(.x))) %>%
    set_names(tbl_colnames) %>%
    as_tibble() %>%
    collect() %>%
    gather(
      key = "column",
      value = "candidate"
    ) %>%
    select(candidate, column)
}
