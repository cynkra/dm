#' Validator
#'
#' `validate_dm()` checks the internal consistency of a `dm` object.
#'
#' @param x An object.
#'
#' @return For `validate_dm()`: Returns the `dm`, invisibly, after finishing all checks.
#'
#' @rdname dm
#' @export
validate_dm <- function(x) {
  check_dm(x)

  if (!identical(names(unclass(x)), "def")) {
    abort_dm_invalid("A `dm` needs to be a list of one item named `def`.")
  }

  def <- dm_get_def(x)

  boilerplate <- dm_get_def(new_dm2(validate = FALSE))

  table_names <- def$table
  if (any(table_names == "")) abort_dm_invalid("Not all tables are named.")

  check_df_structure(def, boilerplate, "dm definition")

  if (!all(map_lgl(def$data, ~ inherits(., "data.frame") || inherits(., "tbl_dbi")))) {
    abort_dm_invalid(
      "Not all entries in `def$data` are of class `data.frame` or `tbl_dbi`. Check `dm_get_tables()`."
    )
  }
  if (!all_same_source(def$data)) {
    abort_dm_invalid(error_txt_not_same_src())
  }

  check_df_structure(c_list_of(def$pks), c_list_of(boilerplate$pks), "`pks` column")
  check_df_structure(c_list_of(def$fks), c_list_of(boilerplate$fks), "`fks` column")
  check_df_structure(c_list_of(def$filters), c_list_of(boilerplate$filters), "`filters` column")

  dm_col_names <- set_names(map(def$data, colnames), table_names)

  fks <- c_list_of(def$fks)
  check_fk_child_tables(fks$table, table_names)

  fks %>%
    unnest_col("column", character()) %>%
    check_colnames(dm_col_names, "FK")

  pks <-
    def %>%
    select(table, pks) %>%
    unnest_list_of_df("pks")

  pks %>%
    unnest_col("column", character()) %>%
    check_colnames(dm_col_names, "PK")

  check_one_zoom(def, is_zoomed(x))
  if (!all(map_lgl(compact(def$zoom), ~ inherits(., "data.frame") || inherits(., "tbl_dbi")))) {
    abort_dm_invalid(
      "Not all entries in `def$zoom` are of class `data.frame`, `tbl_dbi` or `NULL`."
    )
  }

  invisible(x)
}

debug_validate_dm <- function(dm) {
  # Uncomment to enable validation for troubleshooting
  # validate_dm(dm)
  dm
}

check_dm <- function(dm) {
  if (!is_dm(dm)) {
    abort_is_not_dm(class(dm))
  }
}

check_df_structure <- function(check, boilerplate, where) {
  force(where)

  if (!identical(names(check), names(boilerplate))) {
    abort_dm_invalid(glue("Inconsistent column names in {where}: {commas(names(check), Inf)} vs. {commas(names(boilerplate), Inf)}."))
  }

  if (!identical(check[0, ], boilerplate[0, ])) {
    abort_dm_invalid(glue("Inconsistent column types in {where}."))
  }

  inner_names <- map(check, vec_names)
  if (!all(map_lgl(inner_names, is.null))) {
    abort_dm_invalid(glue("Inner names in {where}."))
  }
}

check_fk_child_tables <- function(child_tables, dm_tables) {
  if (!all(map_lgl(child_tables, ~ .x %in% dm_tables))) {
    abort_dm_invalid("FK child table names not in `dm` table names.")
  }
}

check_colnames <- function(key_tibble, dm_col_names, which) {
  if (!all(map2_lgl(key_tibble$table, key_tibble$column, ~ ..2 %in% dm_col_names[[..1]]))) {
    abort_dm_invalid(glue("At least one {which} column name not in `dm` tables' column names."))
  }
}

check_one_zoom <- function(def, zoomed) {
  if (zoomed) {
    if (sum(!map_lgl(def$zoom, is_null)) > 1) {
      abort_dm_invalid("More than one table is zoomed.")
    }
    if (sum(!map_lgl(def$zoom, is_null)) < 1) {
      abort_dm_invalid("Class is `zoomed_dm` but no zoomed table available.")
    }
    if (sum(!map_lgl(def$col_tracker_zoom, is_null)) > 1) {
      abort_dm_invalid("Key tracking is active for more than one zoomed table.")
    }
    if (sum(!map_lgl(def$col_tracker_zoom, is_null)) < 1) {
      abort_dm_invalid("No key tracking is active despite `dm` a `zoomed_dm`.")
    }
  } else {
    if (sum(!map_lgl(def$zoom, is_null)) != 0) {
      abort_dm_invalid("Zoomed table(s) available despite `dm` not a `zoomed_dm`.")
    }
    if (sum(!map_lgl(def$col_tracker_zoom, is_null)) != 0) {
      abort_dm_invalid("Key tracker for zoomed table activated despite `dm` not a `zoomed_dm`.")
    }
  }
}

# dm invalid --------------------------------------------------------------

abort_dm_invalid <- function(why) {
  abort(error_txt_dm_invalid(why), .subclass = dm_error_full("dm_invalid"))
}

error_txt_dm_invalid <- function(why) {
  glue("This `dm` is invalid, reason: {why}")
}
