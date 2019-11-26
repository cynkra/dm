# FIXME: maybe argument `envir` so we can better search for the tables?
cdm_paste <- function(dm, select = FALSE) {
  check_dm(dm)
  check_no_filter(dm)
  check_not_zoomed(dm)

  table_names <- src_tbls(dm)
  pks <- cdm_get_all_pks(dm)
  fks <- cdm_get_all_fks(dm)

  tables_exist <- set_names(map_lgl(table_names, ~ exists(..1, envir = .GlobalEnv)), table_names)
  if (!all(tables_exist)) {
    tables_not_existing <- names(tables_exist[tables_exist == FALSE])
    message(glue("The following tables do not exist in the global environment: {commas(tick(tables_not_existing))}. ",
                 "Therefore, the code won't work out of the box."))
  }

  # code for including the tables
  code <- paste0("dm(", paste(table_names, collapse = ", "), ") %>%\n")
  # adding code for establishing PKs
  code <- reduce2(pks$table, pks$pk_col, ~ paste0(..1, glue("  cdm_add_pk({..2}, {..3}) %>%"), "\n"), .init = code)
  if (nrow(fks)) {
    ct <- fks$child_table
    fk_col <- fks$child_fk_col
    pt <- fks$parent_table

    for (i in seq_along(ct)) {
      code <- paste0(code, glue("  cdm_add_fk({ct[i]}, {fk_col[i]}, {pt[i]}) %>%"), "\n")
    }
  }

  # without "\n" in the end it looks weird when a warning is issued
  cat(strtrim(code, nchar(code) - 5), "\n")
  invisible(dm)
}

