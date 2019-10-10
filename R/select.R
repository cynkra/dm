#' Rename one or more columns of a [`dm`] table
#'
#' Rename columns of your [`dm`] with a similar syntax to `dplyr::rename()`.
#'
#' @inheritParams cdm_filter
#' @param ... One or more unquoted expressions separated by commas. You can treat
#' variable names like they are positions, so you can use expressions like x:y
#' to select ranges of variables.
#'
#' Use named arguments, e.g. new_name = old_name, to rename selected variables.
#'
#' The arguments in ... are automatically quoted and evaluated in a context where
#' column names represent column positions. They also support unquoting and splicing.
#' See `vignette("programming", package = "dplyr")` for an introduction to these concepts.
#'
#' See select helpers for more details and examples about tidyselect helpers such as starts_with(), everything(), ...
#'
#' @details If key columns are renamed the meta-information of the `dm` is updated accordingly
#'
#' @examples
#' cdm_nycflights13() %>%
#'   cdm_rename(airports, code = faa, altitude = alt)
#' @export
cdm_rename <- function(dm, table, ...) {
  # FIXME: Document on same page as cdm_select()

  check_no_filter(dm)

  # tbl() is efficient because no filter is set
  table_name <- as_string(ensym(table))
  old_cols <- colnames(tbl(dm, table_name))
  selected <- tidyselect::vars_rename(old_cols, ...)

  cdm_select_impl(dm, table_name, selected, check_keys = FALSE)
}

#' Select and/or rename one or more columns of a [`dm`] table
#'
#' Select columns of your [`dm`] with a similar syntax to `dplyr::select()`.
#'
#' @inheritParams cdm_rename
#'
#' @examples
#' cdm_nycflights13() %>%
#'   cdm_select(airports, code = faa, altitude = alt)
#' @details If key columns are renamed the meta-information of the `dm` is updated accordingly.
#' If key columns would be removed, `cdm_select()` makes sure they are re-added to the table.
#'
#' @export
cdm_select <- function(dm, table, ...) {
  check_no_filter(dm)

  # tbl() is efficient because no filter is set
  table_name <- as_string(ensym(table))
  old_cols <- colnames(tbl(dm, table_name))
  selected <- tidyselect::vars_select(old_cols, ...)

  cdm_select_impl(dm, table_name, selected)
}

# need to take care of
# 1. adding key columns if they are deselected
# 2. updating renamed key columns in data model
cdm_select_impl <- function(dm, table_name, selected, check_keys = TRUE) {
  # check keys only necessary for `cdm_select()`, rename preserves all columns
  if (check_keys) {
    all_keys <- get_all_keys(dm, table_name)

    # if the selection does not contain all keys, add the missing ones and inform the user
    if (!all(all_keys %in% selected)) {
      keys_to_add <- setdiff(all_keys, selected) %>% set_names()
      message(paste0("Adding missing key columns: ", commas(tick(keys_to_add))))
      selected <- c(selected, keys_to_add)
    }
  }

  # FIXME: if key columns are removed, this can affect foreign and primary keys

  # create new table using `dplyr::select()`
  list_of_tables <- cdm_get_tables(dm)
  table <- list_of_tables[[table_name]]
  new_table <- select(table, !!!selected)

  def <- cdm_get_def(dm)
  table_idx <- which(def$table == table_name)
  def$data[[table_idx]] <- new_table
  def$pks[[table_idx]] <- apply_col_select(def$pks[[table_idx]], selected)
  def$fks <- map(def$fks, apply_col_select_where, selected, table_name)
  new_dm3(def)
}

get_all_keys <- function(dm, table_name) {
  fks <- cdm_get_all_fks(dm) %>%
    filter(child_table == !!table_name) %>%
    pull(child_fk_col)
  pk <- cdm_get_pk(dm, !!table_name)
  c(pk, fks)
}

apply_col_select <- function(df, selected) {
  selected_recode <- prep_recode(selected)
  df$column <- map(df$column, ~ recode(., !!!selected_recode))
  df
}

apply_col_select_where <- function(df, selected, table_name) {
  selected_recode <- prep_recode(selected)
  idx <- which(df$table == table_name)
  df$column[idx] <- map(df$column[idx], ~ recode(., !!!selected_recode))
  df
}
