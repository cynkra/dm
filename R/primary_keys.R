# for external users: also checks if really is primary key

#' Mark a column of a table in a `dm`-object as its primary key
#'
#' @description `dm_add_primary_key()` first checks , if the given column
#' is a unique key of the given table in the `dm`-object. If yes, it then marks
#' that column as the table's primary key in the `data_model`-part of the `dm`-object.
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
#' dm_add_primary_key(nycflights_dm, "planes", "manufacturer", check_if_unique_key = FALSE)
#'
#' # the following does not work
#' dm_add_primary_key(nycflights_dm, "planes", "manufacturer")
#' }
dm_add_primary_key <- function(
  dm, table, column, check_if_unique_key = TRUE, replace_old_key = TRUE) {

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

    if (!replace_old_key) {
    old_key <- dm_get_primary_key_column_from_table(dm, table)
    if (old_key == col_name) {
      return(dm)
    } else {
      abort("If you want to change the existing primary key for a table, set `replace_old_key` == TRUE.")
    }
  }

  if (check_if_unique_key) {
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

  new_dm(dm_get_src(dm), new_data_model)
}

#' @export
dm_check_if_table_has_primary_key <- function(dm, table) {
  check_correct_input(dm, table)

  cols_from_table <- dm_get_data_model(dm)$columns$table == table
  !all(dm_get_data_model(dm)$columns$key[cols_from_table] == 0)
}

#' @export
dm_get_primary_key_column_from_table <- function(dm, table) {
  check_correct_input(dm, table)

  index_key_from_table <- dm_get_data_model(dm)$columns$table == table & dm_get_data_model(dm)$columns$key != 0
  if (sum(index_key_from_table) > 1) abort(
    paste0(
      "Please use dm_remove_primary_key() on ", table, ", more than 1 primary key is currently set for it."
      )
    )
  dm_get_data_model(dm)$columns$column[index_key_from_table]
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
