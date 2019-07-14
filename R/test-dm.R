# Loads `dm` objects into one or more registered sources
#
# @description Works like `dbplyr::test_load()`, just for `dm`_objects.
#
# @param x
#
# @examples
# dbplyr::test_register_src("df", dplyr::src_df(env = new.env()))
# dbplyr::test_register_src("sqlite", dplyr::src_sqlite(":memory:", create = TRUE))
#
# cdm_test_obj <- cdm_nycflights13(cycle = TRUE)
# cdm_test_obj_srcs <- cdm_test_load(cdm_test_obj)
cdm_test_load <- function(x,
                          db_names = NULL, # NULL results in the same name on the src for each table as the current table name in the `dm` object
                          srcs = dbplyr:::test_srcs$get(), # FIXME: nto exported from {dplyr}... could also "borrow" source code as new function here!?
                          ignore = character()) {
  stopifnot(is.character(ignore))
  srcs <- srcs[setdiff(names(srcs), ignore)]
  cdm_table_names <- src_tbls(x)
  if (is_null(db_names)) db_names <- map(cdm_table_names, unique_db_table_name)

  tables <- cdm_get_tables(x)

  remote_tbls <- map(srcs, ~ copy_list_of_tables_to(src = .x, list_of_tables = tables, name_vector = db_names))
  map2(srcs, remote_tbls, ~ new_dm(.x, .y, cdm_get_data_model(x)))
}


# internal helper functions:
# validates, that object `dm` is of class `dm` and that `table` is character and is part of the `dm` object
check_correct_input <- function(dm, table) {
  if (!is_dm(dm)) abort("'dm' has to be of class 'dm'")
  if (!is_bare_character(table, n = 1)) {
    abort("Argument 'table' has to be given as 1 element character variable")
  }
  cdm_table_names <- src_tbls(dm)
  if (!table %in% cdm_table_names) abort_table_not_in_dm(table, cdm_table_names)
}

# validates, that the given column is indeed part of the table of the `dm` object.
check_col_input <- function(dm, table, column) {
  tbl_colnames <- cdm_get_tables(dm) %>%
    extract2(table) %>%
    colnames()
  if (!column %in% tbl_colnames) abort_wrong_col_names(table, tbl_colnames, column)
}


is_this_a_test <- function() {
  # Only run if the top level call is devtools::test() or testthat::test_check()

  calls <-
    sys.calls() %>%
    as.list() %>%
    map(as.list) %>%
    map(1) %>%
    map_chr(as_label)

  is_test_call <- any(calls %in% c("devtools::test", "testthat::test_check"))

  is_testing <- rlang::is_installed("testthat") && testthat::is_testing()

  is_test_call || is_testing
}

h <- function(formula, env = rlang::caller_env()) {
  rlang::eval_tidy(rlang::as_quosure(formula, env = env))
}
