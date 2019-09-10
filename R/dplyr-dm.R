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

  quos <- enquos(...)
  if (is_empty(quos)) {
    return(dm)
  } # valid table and empty ellipsis provided

  select_cols(dm, table_name, quos, prune = prune)
}

# need to take care of deselecting key columns, depending on `prune`
select_cols <- function(dm, table_name, quos, prune = prune) {
  list_of_tables <- cdm_get_tables(dm)
  table <- list_of_tables[[table_name]]

  # create new table using `dplyr::select()`
  new_table <- select(table, !!!quos)
  list_of_tables[[table_name]] <- new_table

  # find out which columns were deselected and which ones were renamed
  unquos <- as.character(quos) %>% map_chr(~str_replace(., "~", ""))
  ind_deselected <- which(str_detect(unquos, "^-"))
  # in case a select-helper was used it needs to be ignored for the rename-check
  ind_select_helper_call <- which(str_detect(unquos, "\\(.*\\)"))
  quos_not_deselect <- quos[setdiff(seq_along(unquos), c(ind_deselected, ind_select_helper_call))]
  list_of_ren_sel <- map_chr(quos_not_deselect, as_name)
  list_of_renames <- list_of_ren_sel[which(names(list_of_ren_sel) != "")]

  update_dm_after_rename(dm, list_of_tables, table_name, list_of_renames, prune)
}

# get all key columns (PK & FK) for a table in a `dm`
get_key_cols <- function(dm, table_name) {
  pk <- cdm_get_pk(dm, !!table_name)
  fks <- cdm_get_all_fks(dm) %>%
    filter(child_table == !!table_name) %>%
    pull(child_fk_col)
  c(pk, fks)
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
