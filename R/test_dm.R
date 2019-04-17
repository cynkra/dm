#' Loads `dm`-objects into one or more registered sources
#'
#' @description Works like `dbplyr::test_load()`, just for `dm`_objects.
#'
#' @examples
#' dbplyr::test_register_src("df", dplyr::src_df(env = new.env()))
#' dbplyr::test_register_src("sqlite", dplyr::src_sqlite(":memory:", create = TRUE))
#'
#' dm_test_obj <- dm(dplyr::src_df(pkg = "nycflights13"))
#' dm_test_obj_srcs <- dm_test_load(dm_test_obj)
#'
#' @export
dm_test_load <-
  function(
    x,
    name = NULL, # NULL results in the same name on the src for each table as the current table name in the `dm`-object
    srcs = dbplyr:::test_srcs$get(), # FIXME: nto exported from {dplyr}... could also "borrow" source code as new function here!?
    ignore = character()) {

    stopifnot(is.character(ignore))
    srcs <- srcs[setdiff(names(srcs), ignore)]
    dm_table_names <- src_tbls(x)
    if (is_null(name)) name <- dm_table_names
    current_data_model <- dm_get_data_model(x)
    tables <- map(dm_table_names, ~ tbl(dm_get_src(x), .x)) %>% set_names(dm_table_names) # FIXME: should be replaced by `dm_select_tables()` once it exists

    walk(srcs, ~ copy_list_of_tables_to(src = .x, list_of_tables = tables, overwrite = TRUE))
    map(srcs, ~ dm(.x, current_data_model))
  }

# FIXME: should this be exported?
copy_list_of_tables_to <-
  function(src, list_of_tables, name_vector = names(list_of_tables), overwrite = FALSE, ...) {
    map2(list_of_tables, name_vector, copy_to, dest = src, overwrite = overwrite, ...)
  }

# internal helper function:
# validates, that object `dm` is of class `dm` and that `table` is character and is part of the `dm`-object
check_correct_input <- function(dm, table) {
  if (!is_dm(dm)) abort("'dm' has to be of class 'dm'")
  if (!is_bare_character(table, n = 1)) {
    abort("Argument 'table' has to be given as 1 element character variable")
  }
  dm_table_names <- src_tbls(dm)
  if (!table %in% dm_table_names) abort(
    paste0(
      "Table: ",
      table,
      " not in `dm`-object. Available table names are: ",
      paste0(dm_table_names, collapse = ", ")
    )
  )
}
