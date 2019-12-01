#' Loads `dm` objects into one or more registered sources
#'
#' @description Works like `dbplyr::test_load()`, just for `dm`_objects.
#'
#' @noRd
#' @examples
#' dbplyr::test_register_src("df", dplyr::src_df(env = new.env()))
#' dbplyr::test_register_src("sqlite", dplyr::src_sqlite(":memory:", create = TRUE))
#'
#' cdm_test_obj <- cdm_nycflights13(cycle = TRUE)
#' cdm_test_obj_srcs <- cdm_test_load(cdm_test_obj)
cdm_test_load <- function(x,
                          srcs = dbplyr:::test_srcs$get(), # FIXME: not exported from {dplyr}... could also "borrow" source code as new function here!?
                          ignore = character(),
                          set_key_constraints = TRUE) {
  stopifnot(is.character(ignore))
  srcs <- srcs[setdiff(names(srcs), ignore)]

  map(srcs, ~ cdm_copy_to(., dm = x, unique_table_names = TRUE, set_key_constraints = set_key_constraints))
}


# internal helper functions:

# validates, that object `dm` is of class `dm` and that `table` is character and is part of the `dm` object
check_correct_input <- function(dm, table, n = NULL) {
  check_dm(dm)
  if (!is_character(table, n)) {
    if (is.null(n)) {
      abort("`table` must be a character vector.")
    } else {
      abort(paste0("`table` must be a character vector of length ", n, "."))
    }
  }
  if (!all(table %in% src_tbls(dm))) {
    abort_table_not_in_dm(setdiff(table, src_tbls(dm)), src_tbls(dm))
  }
}

check_dm <- function(dm) {
  if (!is_dm(dm)) abort_is_not_dm(class(dm))
}

# validates that the given column is indeed part of the table of the `dm` object
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

  is_test_call <- any(calls %in% c("devtools::test", "testthat::test_check", "testthat::test_file", "testthis:::test_this"))

  is_testing <- rlang::is_installed("testthat") && testthat::is_testing()

  is_test_call || is_testing
}

check_fk_child_tables <- function(child_tables, dm_tables) {
  if (!all(map_lgl(child_tables, ~ {
    . %in% dm_tables
  }))) {
    abort_dm_invalid("FK child table names not in `dm` table names.")
  }
}

check_colnames <- function(key_tibble, dm_col_names, which) {
  if (!all(map2_lgl(key_tibble$table, key_tibble$column, ~ {
    ..2 %in% dm_col_names[[..1]]
  }))) {
    abort_dm_invalid(glue("At least one {which} column name(s) not in `dm` tables' column names."))
  }
}

check_col_classes <- function(def) {
  # Called for its side effect of checking type compatibility
  vctrs::vec_ptype2(def, cdm_get_def(new_dm()))

  invisible()
}

check_one_zoom <- function(def, zoomed) {
  if (zoomed) {
    if (sum(!map_lgl(def$zoom, is_null)) > 1) {
      abort_dm_invalid("More than one table is zoomed.")
    }
    if (sum(!map_lgl(def$zoom, is_null)) < 1) {
      abort_dm_invalid("Class is `zoomed_dm` but no zoomed table available.")
    }
    if (sum(!map_lgl(def$key_tracker_zoom, is_null)) > 1) {
      abort_dm_invalid("Key tracking is active for more than one zoomed table.")
    }
    if (sum(!map_lgl(def$key_tracker_zoom, is_null)) < 1) {
      abort_dm_invalid("No key tracking is active despite `dm` a `zoomed_dm`.")
    }
  } else {
    if (sum(!map_lgl(def$zoom, is_null)) != 0) {
      abort_dm_invalid("Zoomed table(s) available despite `dm` not a `zoomed_dm`.")
    }
    if (sum(!map_lgl(def$key_tracker_zoom, is_null)) != 0) {
      abort_dm_invalid("Key tracker for zoomed table activated despite `dm` not a `zoomed_dm`.")
    }
  }
}
