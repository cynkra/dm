# for external users: also checks if really is primary key

#' Mark a column of a table in a `dm`-object as its primary key
#'
#' @description `dm_add_primary_key()` marks the given column as the given table's primary key
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
#' dm_add_primary_key(nycflights_dm, "planes", "tailnum")
#' dm_add_primary_key(nycflights_dm, "airports", faa)
#' dm_add_primary_key(nycflights_dm, "planes", "manufacturer", check = FALSE)
#'
#' # the following does not work
#' dm_add_primary_key(nycflights_dm, "planes", "manufacturer")
#' }
dm_add_primary_key <- function(
  dm, table, column, check = TRUE, force = TRUE) {

  check_correct_input(dm, table)

  if (is_symbol(enexpr(column))) {
    col_expr <- enexpr(column)
    col_name <- as_name(col_expr)
  } else if (is_character(column)) {
    col_name <- column
    col_expr <- ensym(column)
  } else {
    abort("Argument 'column' has to be given as character variable or unquoted and may only contain 1 element.")
  }

  if (!force) {
    old_key <- dm_get_primary_key_column_from_table(dm, table)
    if (old_key == col_name) {
      return(dm)
    } else {
      abort("If you want to change the existing primary key for a table, set `force` == TRUE.")
    }
  }

  if (check) {
    table_from_dm <- tbl(dm, table)
    check_key(table_from_dm, !! col_expr)
  }

  dm_remove_primary_key(dm, table) %>% cdm_add_key(table, col_name)
}

# "table" and "column" has to be character
# in {datamodelr} a primary key can also consists of more than one column
# only adds key, independent if it is unique key or not; not to be exported
# the "cdm" just means "cynkra-dm", to distinguish it from {datamodelr}-functions
cdm_add_key <- function(dm, table, column) {

  new_data_model <- dm_get_data_model(dm) %>%
    dm_set_key(table, column)

  new_dm(dm_get_src(dm), dm_get_tables(dm), new_data_model)
}

#' Does a table of a `dm`-object have a column set as primary key?
#'
#' @description `dm_check_if_table_has_primary_key()` checks in the `data_model` part
#' of the `dm`-object if a given table has a column marked as primary key.
#'
#' @examples
#' \dontrun{
#' library(nycflights13)
#' library(dplyr)
#'
#' nycflights_dm <- dm(src_df(pkg = "nycflights13"))
#' dm_obj_with_keys <- dm_add_primary_key(nycflights_dm, "planes", "tailnum")
#'
#' dm_obj_with_keys %>%
#'   dm_check_if_table_has_primary_key("planes")
#' }
#'
#' @export
dm_check_if_table_has_primary_key <- function(dm, table) {
  check_correct_input(dm, table)
  dm_data_model <- dm_get_data_model(dm)

  cols_from_table <- dm_data_model$columns$table == table
  if (sum(dm_data_model$columns$key[cols_from_table] > 0) > 1) {
    abort(
      paste0(
        "Please use dm_remove_primary_key() on ", table, ", more than 1 primary key is currently set for it."
        )
      )
  }
  !all(dm_data_model$columns$key[cols_from_table] == 0)
}

#' Retrieve the name of the column marked as primary key of a table of a `dm`-object
#'
#' @description `dm_get_primary_key_column_from_table()` returns the name of the
#' column marked as primary key of a table of a `dm`-object. If no primary key is
#' set for the table, an empty character variable is returned.
#'
#' @examples
#' \dontrun{
#' library(nycflights13)
#' library(dplyr)
#'
#' nycflights_dm <- dm(src_df(pkg = "nycflights13"))
#' dm_obj_with_keys <- dm_add_primary_key(nycflights_dm, "planes", "tailnum")
#'
#' dm_obj_with_keys %>%
#'   dm_get_primary_key_column_from_table("planes")
#' }
#'
#' @export
dm_get_primary_key_column_from_table <- function(dm, table) {
  check_correct_input(dm, table)
  dm_data_model <- dm_get_data_model(dm)

  index_key_from_table <- dm_data_model$columns$table == table & dm_data_model$columns$key != 0
  if (sum(index_key_from_table) > 1) abort(
    paste0(
      "Please use dm_remove_primary_key() on ", table, ", more than 1 primary key is currently set for it."
      )
    )
  dm_data_model$columns$column[index_key_from_table]
}

#' Remove primary key from a table in a `dm`-object
#'
#' @description `dm_remove_primary_key()` removes a potentially set primary key from a table in the
#' underlying `data_model`-object and otherwise leaves the `dm`-object untouched.
#'
#' @examples
#' \dontrun{
#' library(nycflights13)
#' library(dplyr)
#'
#' nycflights_dm <- dm(src_df(pkg = "nycflights13"))
#'
#' # the following works
#' dm_obj_with_keys <- dm_add_primary_key(nycflights_dm, "planes", "tailnum") %>%
#'   dm_add_primary_key("airports", faa)
#'
#' dm_obj_with_keys %>%
#'   dm_remove_primary_key("airports") %>%
#'   dm_check_if_table_has_primary_key("planes")
#'
#' dm_obj_with_keys %>%
#'   dm_remove_primary_key("planes") %>%
#'   dm_check_if_table_has_primary_key("planes")
#' }
#'
#' @export
dm_remove_primary_key <- function(dm, table) {
  check_correct_input(dm, table)

  update_cols <- dm$data_model$columns$table == table
  dm$data_model$columns$key[update_cols] <- 0

  dm

}


#' Which columns are candidates for a primary key column of a `dm`-object's table?
#'
#' @description `dm_check_for_primary_key_candidates()` checks for each column of a
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
#' nycflights_dm %>% dm_check_for_primary_key_candidates("flights")
#' nycflights_dm %>% dm_check_for_primary_key_candidates("airports")
#' }
#'
#' @export
dm_check_for_primary_key_candidates <- function(dm, table) {
  check_correct_input(dm, table)

  tbl <- tbl(dm$src, table)
  tbl_colnames <- colnames(tbl)

  # list of ayes and noes:
  map(tbl_colnames, ~ is_unique_key(tbl, eval_tidy(.x))) %>%
    set_names(tbl_colnames) %>%
    as_tibble() %>%
    collect() %>%
    gather(
      key = "column",
      value = "candidate"
      )
}

dm_create_surrogate_key_for_table <- function(dm, table, new_id_column = paste0(table, "_id")) {
  check_correct_input(dm, table)
  if (dm_check_if_table_has_primary_key(dm, table)) {
    abort(paste0("Table `", table, "` already has a primary key. If you really want to",
                 " add a surrogate key column and set it as primary key, please use ",
                 "`dm_remove_primary_key()` first."))
  }

  new_tbl <-
    dm_get_tables(dm) %>%
    extract2(table) %>%
    mutate(!! new_id_column := row_number()) %>%
    select(!! new_id_column, everything())

  dm$tables[[table]] <- new_tbl

  old_dm <- dm_get_data_model(dm)

  ind_cols_from_table <- old_dm$columns$table == table
  temp_dm_columns <- old_dm$columns[!ind_cols_from_table,]

  dm_cols_table <- bind_rows(
    c("column" = new_id_column,
    "type" = "integer",
    "table" = table,
    "ref" = "<NA>"),
    old_dm$columns[ind_cols_from_table,]
    )

  new_dm_columns <-  bind_rows(temp_dm_columns, dm_cols_table)
  dm$data_model$columns <- new_dm_columns

  dm_add_primary_key(dm, table, eval_tidy(new_id_column))
}
