#' Reverse engineer code for creation of a [`dm`]
#'
#' `cdm_paste` takes an existing `dm` and produces the code necessary for its creation
#'
#' @inheritParams cdm_add_pk
#' @param select Boolean, default `FALSE`. If `TRUE` will try to produce code for reducing to necessary columns.
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
cdm_paste <- function(dm, select = FALSE) {
  check_dm(dm)
  check_no_filter(dm)
  check_not_zoomed(dm)

  # we assume the tables exist and have the necessary columns
  # code for including the tables
  code <- glue("dm({paste(tibble:::tick_if_needed({src_tbls(dm)}), collapse = ', ')})")

  if (select) {
    # adding code for selection of columns
    code_select <- tibble(tbl_name = src_tbls(dm), tbls = cdm_get_tables(dm)) %>%
      mutate(cols = map(tbls, colnames)) %>%
      mutate(code = map2_chr(
        tbl_name,
        cols,
        ~glue("{paste0(' %>% \n')}  cdm_select({..1}, {paste0(tibble:::tick_if_needed(..2), collapse = ', ')})"))
        ) %>%
      summarize(code = glue_collapse(code)) %>%
      pull()
    code <- paste0(code, code_select)
  }

  # adding code for establishing PKs
  code_pks <- cdm_get_all_pks(dm) %>%
    mutate(code = glue("{paste0(' %>% \n')}  cdm_add_pk({table}, {pk_col})")) %>%
    summarize(code = glue_collapse(code)) %>%
    pull()

  # adding code for establishing FKs
  code_fks <- cdm_get_all_fks(dm) %>%
    mutate(code = glue("{paste0(' %>% \n')}  cdm_add_fk({child_table}, {child_fk_col}, {parent_table})")) %>%
    summarize(code = glue_collapse(code)) %>%
    pull()

  # without "\n" in the end it looks weird when a warning is issued
  cat(code, code_pks, code_fks)
  invisible(dm)
}
