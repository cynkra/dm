#' @export
cdm_filter <- function(dm, table, ...) {
  table_name <- as_name(enexpr(table))
  check_correct_input(dm, table_name)

  tables_obj <- cdm_get_tables(dm)
  orig_tbl <- tables_obj[[table_name]]

  if (!cdm_has_pk(dm, !!table_name)) {
    abort(paste0(
      "Table '", table_name, "' needs primary key for the filtering to work. ",
      "Please set one using cdm_add_pk()."))
  }

  pk_name_orig <- cdm_get_pk(dm, !!table_name)
  filtered_tbl_pk <- filter(orig_tbl, ...) %>%
    select(!!pk_name_orig) %>%
    compute()

  by = pk_name_orig

  filtered_tbl <- left_join(
    filtered_tbl_pk,
    orig_tbl,
    by = by
    )

  tables_obj[[table_name]] <- filtered_tbl
  new_dm(
    src = cdm_get_src(dm),
    tables = tables_obj,
    data_model = cdm_get_data_model(dm)
  )
}

compute_join <- function(dm, filtered_table, table_to_filter) {
  filtered_table_name <- as_name(enexpr(filtered_table))
  table_to_filter_name <- as_name(enexpr(table_to_filter))

  if (!(cdm_has_fk(dm, !!filtered_table_name, !!table_to_filter_name) |
        cdm_has_fk(dm, !!table_to_filter_name, !!filtered_table_name))) {
    abort(paste0("No foreign key relation exists between table '", filtered_table_name,
                 "' and table ", table_to_filter_name, ", joining not possible."))
  }

  if (cdm_has_fk(dm, !!filtered_table_name, !!table_to_filter_name)) {
    filtered_table_col <- cdm_get_fk(dm, !!filtered_table_name, !!table_to_filter_name)
    table_to_filter_col <- cdm_get_pk(dm, !!table_to_filter_name)
  } else {
    filtered_table_col <- cdm_get_pk(dm, !!filtered_table_name)
    table_to_filter_col <- cdm_get_fk(dm, !!table_to_filter_name, !!filtered_table_name)
  }
  by <- filtered_table_col
  names(by) <- table_to_filter_col

  tables_obj <- cdm_get_tables(dm)
  filtered_table_obj <- tables_obj[[filtered_table_name]]
  table_to_filter_obj <- tables_obj[[table_to_filter_name]]

  semi_join(table_to_filter_obj, filtered_table_obj, by = by)
}
