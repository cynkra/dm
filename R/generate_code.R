cdm_paste <- function(dm, select = FALSE, env = .GlobalEnv) {
  check_dm(dm)
  check_no_filter(dm)
  check_not_zoomed(dm)

  table_names <- src_tbls(dm)
  pks <- cdm_get_all_pks(dm)
  fks <- cdm_get_all_fks(dm)

  tables_exist <- set_names(map_lgl(table_names, ~ exists(..1, envir = env)), table_names)
  if (!all(tables_exist)) {
    tables_not_existing <- names(tables_exist[tables_exist == FALSE])
    message(glue("The following tables do not exist in given environment: {commas(tick(tables_not_existing))}. ",
                 "Therefore, the code won't work out of the box."))
    if (select) {
      warning("Ignoring `select = TRUE`, since not all tables are available.")
    }
  } else {
    if (select) {
      tables_from_dm <- cdm_get_tables(dm)
      tables_from_envir <- set_names(map(table_names, ~eval_tidy(sym(..1), env = env)), table_names)
      code_select <- calc_code_select(tables_from_dm, tables_from_envir)
    }
  }
  # code for including the tables
  code <- paste0("dm(", paste(table_names, collapse = ", "), ") %>%\n")

  # code for selection of columns (if available)
  code <- paste0(code, code_select)

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

calc_code_select <- function(tbl_dm, tbl_envir) {
  code_select <- ""
  for (i in names(tbl_dm)) {
    t_dm <- tbl_dm[[i]]
    t_envir <- tbl_envir[[i]]
    cols_dm <- colnames(t_dm)
    cols_envir <- colnames(t_envir)
    if (!identical(cols_dm, cols_envir)) {
      if (all(cols_dm %in% cols_envir)) {
        code_select <- paste0(glue("{code_select}  cdm_select({i}, {paste0(cols_dm, collapse = ', ')}) %>% "), "\n")
      } else {warning(glue(
        "Not all columns of table {tick(i)} available in given environment. ",
        "Skipping `select` for this table, code won't work out of the box."))}
    }
  }
  code_select
}
