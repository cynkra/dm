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
dm_add_primary_key <- function(dm, table, column, check_if_unique_key = TRUE) {

  if (!is_dm(dm)) abort("'dm' has to be of class 'dm'")
  if (!is_bare_character(table) || length(table) > 1) {
    abort("Argument 'table' has to be given as 1 element character variable")
  }

  if (is_symbol(enexpr(column))) {
    col_expr <- enexpr(column)
    col_name <- as_name(col_expr)
  } else if (is_character(column)) {
    col_name <- column
    col_expr <- ensym(column)
  } else {
    abort("Argument 'column' has to be given as 1 element character variable or unquoted")
  }

  if (check_if_unique_key) {
    table_from_dm <- tbl(dm, table)
    check_key(table_from_dm, !! col_expr)
  }

  cdm_add_key(dm, table, col_name)
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
