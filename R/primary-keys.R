# for external users: also checks if really is primary key

#' Mark a column of a table in a [`dm`] object as its primary key
#'
#' @description `cdm_add_pk()` marks the given column as the given table's primary key
#' in the `data_model`-part of the [`dm`] object. If `check == TRUE`, it also first checks if
#' the given column is a unique key of the table. If `force == TRUE`, it replaces an already
#' set key.
#'
#' @param dm A `dm` object.
#' @param table A table in the `dm`
#' @param column A column of that table
#' @param check Boolean, if `TRUE` (default), a check is made if the column is a unique key of the table.
#' @param force Boolean, if `FALSE` (default), an error will be thrown, if there is
#' already a primary key set for this table. If `TRUE` a potential old `pk` is deleted before setting the new one.
#'
#' @family Primary key functions
#' @export
#' @examples
#' library(dplyr)
#'
#'
#' nycflights_dm <- dm(src_df(pkg = "nycflights13"))
#'
#' # the following works
#' cdm_add_pk(nycflights_dm, planes, tailnum)
#' cdm_add_pk(nycflights_dm, airports, faa)
#' cdm_add_pk(nycflights_dm, planes, manufacturer, check = FALSE)
#'
#' # the following does not work
#' try(cdm_add_pk(nycflights_dm, planes, manufacturer))
cdm_add_pk <- function(dm, table, column, check = TRUE, force = FALSE) {
  table_name <- as_name(enquo(table))

  check_correct_input(dm, table_name)

  if (is_symbol(enexpr(column))) {
    col_expr <- enexpr(column)
    col_name <- as_name(col_expr)
  } else if (is_character(column)) {
    col_name <- column
    col_expr <- ensym(column)
  } else {
    abort_wrong_col_args()
  }

  if (cdm_has_pk(dm, !!table_name)) {
    if (!force) {
      old_key <- cdm_get_pk(dm, !!table_name)
      if (old_key == col_name) {
        return(dm)
      }
      abort_key_set_force_false()
    }
  }

  if (check) {
    table_from_dm <- tbl(dm, table_name)
    check_key(table_from_dm, !!col_expr)
  }

  cdm_rm_pk(dm, !!table_name) %>% cdm_add_pk_impl(table_name, col_name)
}

# "table" and "column" has to be character
# in {datamodelr} a primary key can also consists of more than one column
# only adds key, independent if it is unique key or not; not to be exported
# the "cdm" just means "cynkra-dm", to distinguish it from {datamodelr}-functions
cdm_add_pk_impl <- function(dm, table, column) {
  new_data_model <- cdm_get_data_model(dm) %>%
    datamodelr::dm_set_key(table, column)

  new_dm(cdm_get_src(dm), cdm_get_tables(dm), new_data_model)
}

#' Does a table of a [`dm`] object have a column set as primary key?
#'
#' @description `cdm_has_pk()` checks in the `data_model` part
#' of the [`dm`] object if a given table has a column marked as primary key.
#'
#' @inheritParams cdm_add_pk
#'
#' @family Primary key functions
#'
#' @examples
#' library(dplyr)
#' nycflights_dm <- cdm_nycflights13()
#'
#' nycflights_dm %>%
#'   cdm_has_pk(planes)
#' @export
cdm_has_pk <- function(dm, table) {
  table_name <- as_name(enquo(table))

  check_correct_input(dm, table_name)

  cdm_data_model <- cdm_get_data_model(dm)

  cols_from_table <- cdm_data_model$columns$table == table_name
  if (sum(cdm_data_model$columns$key[cols_from_table] > 0) > 1) {
    abort_multiple_pks(table_name)
  }
  !all(cdm_data_model$columns$key[cols_from_table] == 0)
}

#' Retrieve the name of the column marked as primary key of a table of a [`dm`] object
#'
#' @description `cdm_get_pk()` returns the name of the
#' column marked as primary key of a table of a [`dm`] object. If no primary key is
#' set for the table, an empty character variable is returned.
#'
#' @family Primary key functions
#'
#' @inheritParams cdm_add_pk
#'
#' @examples
#' library(dplyr)
#' nycflights_dm <- cdm_nycflights13()
#'
#' nycflights_dm %>%
#'   cdm_get_pk(planes)
#' @export
cdm_get_pk <- function(dm, table) {
  table_name <- as_name(enquo(table))

  check_correct_input(dm, table_name)
  cdm_data_model <- cdm_get_data_model(dm)

  index_key_from_table <- cdm_data_model$columns$table == table_name & cdm_data_model$columns$key != 0
  if (sum(index_key_from_table) > 1) {
    abort_multiple_pks(table_name)
  }
  cdm_data_model$columns$column[index_key_from_table]
}

# FIXME: export?
#' Get all primary keys of a [`dm`] object
#'
#' @description `cdm_get_all_pks()` checks the `dm` object for set primary keys and
#' returns the tables, the respective primary key columns and their classes.
#'
#' @family Primary key functions
#'
#' @inheritParams cdm_add_pk
#'
#' @export
cdm_get_all_pks <- nse_function(c(dm), ~ {
  cdm_get_data_model_pks(dm) %>%
    select(table = table, pk_col = column)
})

#' Remove primary key from a table in a [`dm`] object
#'
#' @description `cdm_rm_pk()` removes a potentially set primary key from a table in the
#' underlying `data_model`-object and otherwise leaves the [`dm`] object untouched.
#'
#' Foreign keys pointing to the table from other tables can optionally be removed as well.
#'
#' @family Primary key functions
#'
#' @inheritParams cdm_add_pk
#' @param rm_referencing_fks Boolean: if `FALSE` (default), will throw an error, if
#' there are foreign keys addressing the primary key to be removed. If `TRUE`, will
#' in addition to the primary key of parameter `table`, also remove all foreign key constraints
#' that are pointing to it.
#'
#' @examples
#' library(dplyr)
#' nycflights_dm <- cdm_nycflights13()
#'
#' nycflights_dm %>%
#'   cdm_rm_pk(airports, rm_referencing_fks = TRUE) %>%
#'   cdm_has_pk(planes)
#'
#' nycflights_dm %>%
#'   cdm_rm_pk(planes, rm_referencing_fks = TRUE) %>%
#'   cdm_has_pk(planes)
#' @export
cdm_rm_pk <- nse_function(c(dm, table, rm_referencing_fks = FALSE), ~ {
  table_name <- as_name(enquo(table))
  check_correct_input(dm, table_name)

  fks <- cdm_get_data_model_fks(dm)
  affected_fks <-
    fks %>%
    filter(ref == !!table_name)
  new_fks <- fks

  if (nrow(affected_fks) > 0) {
    if (rm_referencing_fks) {
      new_fks <-
        fks %>%
        filter(ref != !!table_name)
    } else {
      abort_first_rm_fks(affected_fks)
    }
  }

  new_pks <-
    cdm_get_data_model_pks(dm) %>%
    filter(table != !!table_name)

  new_dm2(
    pks = new_pks,
    fks = new_fks,
    base_dm = dm
  )
})


#' Which columns are candidates for a primary key column?
#'
#' @description `enum_pk_candidates()` checks for each column of a
#' table if this column contains only unique values and is therefore
#' a candidate for a primary key of this table.
#'
#' @export
#' @examples
#' nycflights13::flights %>% enum_pk_candidates()
enum_pk_candidates <- nse_function(c(table), ~ {
  tbl_colnames <- colnames(table)

  # list of ayes and noes:
  map_dfr(tbl_colnames, ~ is_unique_key(table, {{ .x }})) %>%
    rename(candidate = unique) %>%
    mutate(values = map_chr(data, ~ commas(format(.$value)))) %>%
    select(-data) %>%
    mutate(why = if_else(candidate, "", paste0("has duplicate values: ", values))) %>%
    select(-values)
})


#' @description `cdm_enum_pk_candidates()` performs these checks
#' for a table in a [dm] object.
#'
#' @family Primary key functions
#'
#' @inheritParams cdm_add_pk
#'
#' @rdname enum_pk_candidates
#' @export
#' @examples
#'
#' cdm_nycflights13() %>% cdm_enum_pk_candidates(flights)
#' cdm_nycflights13() %>% cdm_enum_pk_candidates(airports)
cdm_enum_pk_candidates <- nse_function(c(dm, table), ~ {
  table_name <- as_name(enquo(table))

  check_correct_input(dm, table_name)

  tbl <- cdm_get_tables(dm)[[table_name]]
  enum_pk_candidates(tbl)
})
