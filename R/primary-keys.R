# for external users: also checks if a column really is primary key

#' Mark a column of a table in a [`dm`] object as its primary key
#'
#' @description `dm_add_pk()` marks the specified column as the primary key of the specified table.
#' If `check == TRUE`, then it will first check if
#' the given column is a unique key of the table.
#' If `force == TRUE`, the function will replace an already
#' set key.
#'
#' @param dm A `dm` object.
#' @param table A table in the `dm`.
#' @param column A column of that table.
#' @param check Boolean, if `TRUE`, a check is made if the column is a unique key of the table.
#' @param force Boolean, if `FALSE` (default), an error will be thrown if there is already a primary key
#'   set for this table.
#'   If `TRUE`, a potential old `pk` is deleted before setting a new one.
#'
#' @family primary key functions
#' @export
#' @examples
#' library(dplyr)
#'
#'
#' nycflights_dm <- dm_from_src(src_df(pkg = "nycflights13"))
#'
#' # the following works
#' dm_add_pk(nycflights_dm, planes, tailnum)
#' dm_add_pk(nycflights_dm, airports, faa)
#' dm_add_pk(nycflights_dm, planes, manufacturer, check = FALSE)
#'
#' # the following does not work (throws an error)
#' try(dm_add_pk(nycflights_dm, planes, manufacturer))
dm_add_pk <- function(dm, table, column, check = FALSE, force = FALSE) {
  table_name <- as_name(ensym(table))

  check_correct_input(dm, table_name)

  col_expr <- ensym(column)
  col_name <- as_name(col_expr)
  check_col_input(dm, table_name, col_name)

  if (check) {
    table_from_dm <- dm_get_filtered_table(dm, table_name)
    check_key(table_from_dm, !!col_expr)
  }

  dm_add_pk_impl(dm, table_name, col_name, force)
}

# both "table" and "column" must be characters
# in {datamodelr}, a primary key may consist of more than one columns
# a key will be added, regardless of whether it is a unique key or not; not to be exported
# the "cdm" just means "cynkra-dm", to distinguish it from {datamodelr}-functions
dm_add_pk_impl <- function(dm, table, column, force) {
  def <- dm_get_def(dm)
  i <- which(def$table == table)

  if (!force && NROW(def$pks[[i]]) > 0) {
    abort_key_set_force_false()
  }

  def$pks[[which(def$table == table)]] <- tibble(column = !!list(column))

  new_dm3(def)
}

#' Does a table of a [`dm`] object have a column set as primary key?
#'
#' @description `cdm_has_pk()` checks in the `data_model` part
#' of the [`dm`] object if a given table has a column marked as its primary key.
#'
#' @inheritParams dm_add_pk
#'
#' @family primary key functions
#'
#' @examples
#' library(dplyr)
#' nycflights_dm <- dm_nycflights13()
#'
#' nycflights_dm %>%
#'   cdm_has_pk(planes)
#' @export
cdm_has_pk <- function(dm, table) {
  has_length(cdm_get_pk(dm, {{ table }}))
}

#' Retrieve the name of the primary key column of a `dm` table
#'
#' @description `cdm_get_pk()` returns the name of the
#' column marked as primary key of a table of a [`dm`] object.
#' If no primary key is
#' set for the table, an empty character vector is returned.
#'
#' @family primary key functions
#'
#' @inheritParams dm_add_pk
#'
#' @examples
#' library(dplyr)
#' nycflights_dm <- dm_nycflights13()
#'
#' nycflights_dm %>%
#'   cdm_get_pk(planes)
#' @export
cdm_get_pk <- function(dm, table) {
  table_name <- as_name(ensym(table))
  check_correct_input(dm, table_name)

  pks <- dm_get_data_model_pks(dm)
  pks$column[pks$table == table_name]
}

# FIXME: export?
#' Get all primary keys of a [`dm`] object
#'
#' @description `cdm_get_all_pks()` checks the `dm` object for set primary keys and
#' returns the tables, the respective primary key columns and their classes.
#'
#' @family primary key functions
#'
#' @inheritParams dm_add_pk
#'
#' @export
cdm_get_all_pks <- nse(function(dm) {
  dm_get_data_model_pks(dm) %>%
    select(table = table, pk_col = column)
})

#' Remove a primary key from a table in a [`dm`] object
#'
#' @description `cdm_rm_pk()` removes a potentially set primary key from a table in the
#' underlying `data_model`-object; leaves the [`dm`] object unaltered otherwise.
#'
#' Foreign keys that point to the table from other tables, can be optionally removed as well.
#'
#' @family primary key functions
#'
#' @inheritParams dm_add_pk
#' @param rm_referencing_fks Boolean: if `FALSE` (default), will throw an error if
#'   there are foreign keys addressing the primary key that is to be removed.
#'   If `TRUE`, the function will
#'   remove, in addition to the primary key of the `table` argument, also all foreign key constraints
#'   that are pointing to it.
#'
#' @examples
#' library(dplyr)
#' nycflights_dm <- dm_nycflights13()
#'
#' nycflights_dm %>%
#'   cdm_rm_pk(airports, rm_referencing_fks = TRUE) %>%
#'   cdm_has_pk(planes)
#'
#' nycflights_dm %>%
#'   cdm_rm_pk(planes, rm_referencing_fks = TRUE) %>%
#'   cdm_has_pk(planes)
#' @export
cdm_rm_pk <- function(dm, table, rm_referencing_fks = FALSE) {
  table <- as_name(ensym(table))
  check_correct_input(dm, table)

  def <- dm_get_def(dm)

  if (!rm_referencing_fks && dm_is_referenced(dm, !!table)) {
    affected <- dm_get_referencing_tables(dm, !!table)
    abort_first_rm_fks(table, affected)
  }
  def$pks[def$table == table] <- list(new_pk())
  def$fks[def$table == table] <- list(new_fk())

  new_dm3(def)
}


#' Which columns are candidates for a primary key column?
#'
#' @description `enum_pk_candidates()` checks for each column of a
#' table if the column contains only unique values, and is thus
#' a suitable candidate for a primary key of the table.
#'
#' @export
#' @examples
#' nycflights13::flights %>% enum_pk_candidates()
enum_pk_candidates <- nse(function(table) {
  # a list of ayes and noes:
  if (is_dm(table) && is_zoomed(table)) table <- get_zoomed_tbl(table)

  map(set_names(colnames(table)), function(x) is_unique_key(table, {{ x }})) %>%
    enframe("column") %>%
    # Workaround: Can't call bind_rows() here with dplyr < 0.9.0
    # Can't call unnest() either for an unknown reason
    mutate(candidate = map_lgl(value, "unique"), data = map(value, list("data", 1))) %>%
    select(-value) %>%
    mutate(values = map_chr(data, ~ commas(format(.$value, trim = TRUE, justify = "none")))) %>%
    select(-data) %>%
    mutate(why = if_else(candidate, "", paste0("has duplicate values: ", values))) %>%
    select(-values) %>%
    arrange(desc(candidate), column)
})


#' @description `cdm_enum_pk_candidates()` performs these checks
#' for a table in a [dm] object.
#'
#' @family primary key functions
#'
#' @inheritParams dm_add_pk
#'
#' @rdname enum_pk_candidates
#' @export
#' @examples
#'
#' dm_nycflights13() %>% cdm_enum_pk_candidates(flights)
#' dm_nycflights13() %>% cdm_enum_pk_candidates(airports)
cdm_enum_pk_candidates <- nse(function(dm, table) {
  # FIXME: with "direct" filter maybe no check necessary: but do we want to check
  # for tables retrieved with `tbl()` or with `dm_get_tables()[[table_name]]`
  check_no_filter(dm)

  table_name <- as_name(ensym(table))
  check_correct_input(dm, table_name)

  tbl <- dm_get_tables(dm)[[table_name]]
  enum_pk_candidates(tbl)
})
