#' Loads `dm`-objects into one or more registered sources
#'
#' @description Works like `dbplyr::test_load()`, just for `dm`_objects.
#'
#' @examples
#' dbplyr::test_register_src("df", dplyr::src_df(env = new.env()))
#' dbplyr::test_register_src("sqlite", dplyr::src_sqlite(":memory:", create = TRUE))
#'
#' cdm_test_obj <- dm(dplyr::src_df(pkg = "nycflights13"))
#' cdm_test_obj_srcs <- cdm_test_load(cdm_test_obj)
#' @export
cdm_test_load <- function(x,
                         name = NULL, # NULL results in the same name on the src for each table as the current table name in the `dm`-object
                         srcs = dbplyr:::test_srcs$get(), # FIXME: nto exported from {dplyr}... could also "borrow" source code as new function here!?
                         ignore = character()) {
  stopifnot(is.character(ignore))
  srcs <- srcs[setdiff(names(srcs), ignore)]
  cdm_table_names <- src_tbls(x)
  if (is_null(name)) name <- cdm_table_names

  tables <- map(cdm_table_names, ~ tbl(cdm_get_src(x), .x)) %>% set_names(cdm_table_names) # FIXME: should be replaced by `cdm_select_tables()` once it exists

  tbls <- map(srcs, ~ copy_list_of_tables_to(src = .x, list_of_tables = tables, overwrite = TRUE))
  map2(srcs, tbls, ~ new_dm(.x, .y, cdm_get_data_model(x)))
}

# FIXME: should this be exported?
copy_list_of_tables_to <- function(src, list_of_tables,
                                   name_vector = names(list_of_tables),
                                   overwrite = FALSE, ...) {
  map2(list_of_tables, name_vector, copy_to, dest = src, overwrite = overwrite, ...)
}

# internal helper functions:
# validates, that object `dm` is of class `dm` and that `table` is character and is part of the `dm`-object
check_correct_input <- function(dm, table) {
  if (!is_dm(dm)) abort("'dm' has to be of class 'dm'")
  if (!is_bare_character(table, n = 1)) {
    abort("Argument 'table' has to be given as 1 element character variable")
  }
  cdm_table_names <- src_tbls(dm)
  if (!table %in% cdm_table_names) {
    abort(
      paste0(
        "Table: ",
        table,
        " not in `dm`-object. Available table names are: ",
        paste0(cdm_table_names, collapse = ", ")
      )
    )
  }
}

# validates, that the given column is indeed part of the table of the `dm` object.
check_col_input <- function(dm, table, column) {
  tbl_colnames <- cdm_get_tables(dm) %>% extract2(table) %>% colnames()
  if (!column %in% tbl_colnames) abort(
    paste0("'", column, "' is not a column of '", table, "'. Its columns are: \n'", paste0(tbl_colnames, collapse = "', '"), "'"))
}
