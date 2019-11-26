#' Reverse engineer code for creation of a [`dm`]
#'
#' `cdm_paste` takes an existing `dm` and produces the code necessary for its creation
#'
#' @inheritParams cdm_add_pk
#' @param select Boolean, default `FALSE`. If `TRUE` will try to produce code for reducing to necessary columns.
#' @param env The environment to search for the tables for the creation of the `dm`. Defaults to the global environment.
#'
#' @details At the very least (if no keys exist in the given [`dm`]) a `dm()` statement is produced that -- when executed --
#' produces the same `dm`. In addition, the code for setting the existing primary keys as well as the relations between the
#' tables is produced. Should the tables not be available in the given environment, a warning is issued. The code won't work
#' as is in this case. If `select = TRUE`, the column names of the `dm` tables are compared with the column names
#' of the tables of the same name in the given environment. For each table:
#' 1. If the `dm` tables have less columns and all of them exist in the tables in the given environment, appropriate `cdm_select()` statements are created
#' 1. If the `dm` tables have extra columns, the table is skipped and a warning is issued.
#'
#' @return Code for producing the given `dm`
#'
#' @export
cdm_paste <- function(dm, select = FALSE, env = .GlobalEnv) {
  check_dm(dm)
  check_no_filter(dm)
  check_not_zoomed(dm)

  table_names <- src_tbls(dm)
  pks <- cdm_get_all_pks(dm)
  fks <- cdm_get_all_fks(dm)

  tables_exist <- set_names(map_lgl(table_names, ~ exists(..1, envir = env)), table_names)
  # code for including the tables
  code <- paste0("dm(", paste(table_names, collapse = ", "), ") %>%\n")

  if (!all(tables_exist)) {
    tables_not_existing <- names(tables_exist[tables_exist == FALSE])
    warning(glue("The following tables do not exist in given environment: {commas(tick(tables_not_existing))}. ",
                 "Therefore, the code won't work out of the box."))
    if (select) {
      # FIXME: should we ignore `select` only for those tables that do not exist
      warning("Ignoring `select = TRUE`, since not all tables are available.")
    }
  } else {
    if (select) {
      tables_from_dm <- cdm_get_tables(dm)
      tables_from_envir <- set_names(map(table_names, ~eval_tidy(sym(..1), env = env)), table_names)
      code_select <- calc_code_select(tables_from_dm, tables_from_envir)
      # code for selection of columns (if available)
      code <- paste0(code, code_select)
    }
  }


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
        code_select <- paste0(glue("{code_select}  cdm_select({i}, {paste0(cols_dm, collapse = ', ')}) %>%"), "\n")
      } else {warning(glue(
        "Not all columns of table {tick(i)} available in given environment. ",
        "Skipping `select` for this table, code won't work out of the box."))}
    }
  }
  code_select
}
