# TODO: Rethink when #30 is available
cdm_create_surrogate_key_for_table <- function(dm, table, new_id_column = paste0(table, "_id")) {
  check_correct_input(dm, table)
  if (cdm_has_pk(dm, table)) {
    abort(paste0(
      "Table `", table, "` already has a primary key. If you really want to",
      " add a surrogate key column and set it as primary key, please use ",
      "`cdm_rm_pk()` first."
    ))
  }

  new_tbl <-
    cdm_get_tables(dm) %>%
    extract2(table) %>%
    mutate(!!new_id_column := row_number()) %>%
    select(!!new_id_column, everything())

  cdm_get_tables(dm)[[table]] <- new_tbl

  old_dm <- cdm_get_data_model(dm)

  ind_cols_from_table <- old_dm$columns$table == table
  temp_dm_columns <- old_dm$columns[!ind_cols_from_table, ]

  cdm_cols_table <- bind_rows(
    c(
      "column" = new_id_column,
      "type" = "integer",
      "table" = table,
      "ref" = "<NA>"
    ),
    old_dm$columns[ind_cols_from_table, ]
  )

  new_dm_columns <- bind_rows(temp_dm_columns, cdm_cols_table)
  dm$data_model$columns <- new_dm_columns

  cdm_add_pk(dm, table, eval_tidy(new_id_column))
}
