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
#' @examples
#' cdm_nycflights13() %>%
#'   cdm_rename(airports, code = faa, altitude = alt)
#'
#' @export
cdm_rename <- function(dm, table, ...) {
  table_name <- as_name(enexpr(table))
  check_correct_input(dm, table_name)

  quos <- enquos(...)
  if (is_empty(quos)) {
    return(dm)
  } # valid table and empty ellipsis provided

  rename_cols(dm, table_name, quos)
}

rename_cols <- function(dm, table_name, quos) {
  list_of_tables <- cdm_get_tables(dm)
  table <- list_of_tables[[table_name]]
  new_table <- rename(table, !!!quos)

  list_of_tables[[table_name]] <- new_table

  list_of_renames <- map_chr(quos, as_name)

  update_dm_after_rename(dm, list_of_tables, table_name, list_of_renames)

}

cdm_select <- function(dm, table, ..., prune = FALSE) {
  table_name <- as_name(enexpr(table))
  check_correct_input(dm, table_name)

  old_cols <- colnames(tbl(dm, table_name))
  selected <- tidyselect::vars_select(old_cols, ...)

  select_cols(dm, table_name, selected)
}

# need to take care of
# 1. adding key columns if they are deselected
# 2. updating renamed key columns in data model
select_cols <- function(dm, table_name, selected) {
  list_of_tables <- cdm_get_tables(dm)
  table <- list_of_tables[[table_name]]
  fk_cols <- fks <- cdm_get_all_fks(dm) %>%
    filter(child_table == !!table_name) %>%
    pull(child_fk_col)
  renamed_fks <- find_renamed(fk_cols, selected)
  pk_col <- cdm_get_pk(dm, !!table_name)
  renamed_pk <- find_renamed(pk_col, selected)
  all_keys <- c(pk_col, fk_cols)

  pks_upd <-
    upd_pks_after_rename(
      cdm_get_data_model_pks(dm),
      table_name,
      renamed_pk
    )

  fks_upd <- upd_fks_after_rename(
      cdm_get_data_model_fks(dm),
      table_name,
      renamed_fks
    )

  # if the selection does not contain all keys, add the missing ones and inform the user
  if (!all(all_keys %in% selected)) {
    keys_to_add <- setdiff(all_keys, selected)
    message(paste0("Adding missing key columns: `", paste0(keys_to_add, collapse = ", "), "`"))
    selected <- c(keys_to_add, selected)
  }

  # create new table using `dplyr::select()`
  new_table <- select(table, selected)
  list_of_tables[[table_name]] <- new_table

  new_dm2(
    tables = list_of_tables,
    pks = pks_upd,
    fks = fks_upd,
    base_dm = dm
    )
}

update_dm_after_rename <- function(dm, list_of_tables, table_name, list_of_renames, prune = FALSE) {

  pks_upd <-
    upd_pks_after_rename(
      cdm_get_data_model_pks(dm),
      table_name,
      list_of_renames
    )

  fks_upd <-
    upd_fks_after_rename(
      cdm_get_data_model_fks(dm),
      table_name,
      list_of_renames
    )

  # if not all updated pks and fks are part of the actual table and `prune == FALSE`, then abort
  pks <- filter(pks_upd, table == table_name) %>% pull(column)
  fks <- filter(fks_upd, table == table_name) %>% pull(column)
  pks_in_cols <- pks %in% colnames(list_of_tables[[table_name]])
  fks_in_cols <- fks %in% colnames(list_of_tables[[table_name]])
  if (!all(pks_in_cols)) abort_pk_col_missing(table_name, cdm_get_pk(dm, !!table_name))
  if (!all(fks_in_cols)) {
    missing_fks <- fks[!fks_in_cols]
    if (!prune) abort_fk_cols_missing(table_name, missing_fks)
    fks_upd <- filter(fks_upd, !(fks_upd$table == table_name & fks_upd$column %in% missing_fks))
    tables_to_remove <- cdm_get_all_fks(dm) %>%
      filter(child_table == !!table_name, child_fk_col %in% fks[!fks_in_cols]) %>%
      pull(parent_table)
    list_of_tables <- list_of_tables[setdiff(src_tbls(dm), tables_to_remove)]
    pks_upd <- filter(pks_upd, !(table %in% tables_to_remove))
    data_model_tables_upd <- cdm_get_data_model_tables(dm) %>%
      filter(!(table %in% tables_to_remove))
  }

  new_dm2(
    tables = list_of_tables,
    data_model_tables = data_model_tables_upd,
    pks = pks_upd,
    fks = fks_upd,
    base_dm = dm
  )

}

# get elements where value and its name don't match and name is not NULL
find_renamed <- function(names, selected) {
  l <- map(names, ~selected[selected == . & names(selected) != . & !is.null(names(selected))])
  unlist(l[map_lgl(l, ~!is_empty(.))])
}
