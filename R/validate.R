#' Validator
#'
#' `dm_validate()` checks the internal consistency of a `dm` object.
#'
#' In theory, with the exception of [new_dm()], all `dm` objects
#' created or modified by functions in this package should be valid,
#' and this function should not be needed.
#' Please file an issue if any dm operation creates an invalid object.
#'
#' @param x An object.
#'
#' @return Returns the `dm`, invisibly, after finishing all checks.
#'
#' @export
#' @examples
#' dm_validate(dm())
#'
#' bad_dm <- structure(list(bad = "dm"), class = "dm")
#' try(dm_validate(bad_dm))
dm_validate <- function(x) {
  check_dm(x)

  if (!identical(names(unclass(x)), "def")) {
    abort_dm_invalid("A `dm` needs to be a list of one item named `def`.")
  }

  def <- dm_get_def(x)

  boilerplate <- new_dm_def()

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

  fks <-
    def %>%
    select(ref_table = table, fks) %>%
    unnest_list_of_df("fks")

  check_fk_child_tables(fks$table, table_names)

  fks %>%
    unnest_col("column", character()) %>%
    check_colnames(dm_col_names, "FK")

  fks %>%
    unnest_col("ref_column", character()) %>%
    select(table = ref_table, column = ref_column) %>%
    check_colnames(dm_col_names, "Parent key")

  # FIXME: what's the correct check here? Both of these produce errors.
  # stopifnot(lengths(def$pks) %in% 0:1)
  # stopifnot(NROW(def$pks) %in% 0:1)
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

  check_no_nulls(def)

  invisible(x)
}

#' Validator
#'
#' `validate_dm()` has been replaced by `dm_validate()` for consistency.
#'
#' @param x An object.
#'
#' @export
#' @rdname deprecated
#' @keywords internal
validate_dm <- function(x) {
  deprecate_soft("0.3.0", "dm::validate_dm()", "dm::dm_validate()")
  dm_validate(x)
}

debug_dm_validate <- function(dm) {
  # Uncomment to enable validation for troubleshooting
  # dm_validate(dm)
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
  good <- map2_lgl(key_tibble$table, key_tibble$column, ~ ..2 %in% dm_col_names[[..1]])
  if (!all(good)) {
    bad_key <- key_tibble[which(!good)[[1]], ]
    abort_dm_invalid(glue("{which} column name not in `dm` tables' column names: `{bad_key$table}`$`{bad_key$column}`"))
  }
}

check_one_zoom <- function(def, zoomed) {
  if (zoomed) {
    if (sum(!map_lgl(def$zoom, is_null)) > 1) {
      abort_dm_invalid("More than one table is zoomed.")
    }
    if (sum(!map_lgl(def$zoom, is_null)) < 1) {
      abort_dm_invalid("Class is `dm_zoomed` but no zoomed table available.")
    }
    if (sum(!map_lgl(def$col_tracker_zoom, is_null)) > 1) {
      abort_dm_invalid("Key tracking is active for more than one zoomed table.")
    }
    if (sum(!map_lgl(def$col_tracker_zoom, is_null)) < 1) {
      abort_dm_invalid("No key tracking is active despite `dm` a `dm_zoomed`.")
    }
  } else {
    if (sum(!map_lgl(def$zoom, is_null)) != 0) {
      abort_dm_invalid("Zoomed table(s) available despite `dm` not a `dm_zoomed`.")
    }
    if (sum(!map_lgl(def$col_tracker_zoom, is_null)) != 0) {
      abort_dm_invalid("Key tracker for zoomed table activated despite `dm` not a `dm_zoomed`.")
    }
  }
}

check_no_nulls <- function(def) {
  check_no_nulls_col(def$fks, "foreign keys")
  check_no_nulls_col(def$pks, "primary keys")
  check_no_nulls_col(def$filters, "filter conditions")
}

check_no_nulls_col <- function(x, where) {
  if (any(map_lgl(x, is.null))) {
    abort_dm_invalid(paste0("Found `NULL` entry in ", where, "."))
  }
}

# dm invalid --------------------------------------------------------------

abort_dm_invalid <- function(why) {
  abort(error_txt_dm_invalid(why), class = dm_error_full("dm_invalid"))
}

error_txt_dm_invalid <- function(why) {
  glue("This `dm` is invalid, reason: {why}")
}
