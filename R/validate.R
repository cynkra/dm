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

  if (!identical(names(unclass(x)), "def")) abort_dm_invalid("A `dm` needs to be a list of one item named `def`.")
  def <- dm_get_def(x)

  table_names <- def$table
  if (any(table_names == "")) abort_dm_invalid("Not all tables are named.")
  check_col_classes(def)

  if (!all(map_lgl(def$data, ~ {
    inherits(., "data.frame") || inherits(., "tbl_dbi")
  }))) {
    abort_dm_invalid(
      "Not all entries in `def$data` are of class `data.frame` or `tbl_dbi`. Check `dm_get_tables()`."
    )
  }
  if (!all_same_source(def$data)) abort_dm_invalid(error_txt_not_same_src())

  if (nrow(def) == 0) {
    return(invisible(x))
  }
  if (ncol(def) != 9) {
    abort_dm_invalid(
      glue(
        "Number of columns of tibble defining `dm` is wrong: {as.character(ncol(def))} ",
        "instead of 9."
      )
    )
  }

  inner_names <- map(def, names)
  if (!all(map_lgl(inner_names, is.null))) {
    abort_dm_invalid("`def` must not have inner names.")
  }

  fks <-
    def$fks %>%
    map_dfr(I) %>%
    unnest(column)
  check_fk_child_tables(fks$table, table_names)
  dm_col_names <- set_names(map(def$data, colnames), table_names)
  check_colnames(fks, dm_col_names, "FK")
  pks <-
    select(def, table, pks) %>%
    unnest(pks) %>%
    unnest(column)
  check_colnames(pks, dm_col_names, "PK")
  check_one_zoom(def, is_zoomed(x))
  if (!all(map_lgl(def$zoom, ~ {
    inherits(., "data.frame") || inherits(., "tbl_dbi") || inherits(., "NULL")
  }))) {
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

check_col_classes <- function(def) {
  # Called for its side effect of checking type compatibility
  vctrs::vec_ptype2(def, dm_get_def(new_dm()))

  invisible()
}

check_fk_child_tables <- function(child_tables, dm_tables) {
  if (!all(map_lgl(child_tables, ~ {
    . %in% dm_tables
  }))) {
    abort_dm_invalid("FK child table names not in `dm` table names.")
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
