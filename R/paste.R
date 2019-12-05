#' Reverse engineer code for creation of a [`dm`]
#'
#' `dm_paste` takes an existing `dm` and produces the code necessary for its creation
#'
#' @inheritParams dm_add_pk
#' @param select Boolean, default `FALSE`. If `TRUE` will try to produce code for reducing to necessary columns.
#' @param tab_width Indentation width for code from the second line onwards
#'
#' @details At the very least (if no keys exist in the given [`dm`]) a `dm()` statement is produced that -- when executed --
#' produces the same `dm`. In addition, the code for setting the existing primary keys as well as the relations between the
#' tables is produced. If `select = TRUE`, statements are included to select the respective columns of each table of the `dm` (useful if
#' only a subset of the columns of the original tables is used for the `dm`).
#'
#' Mind, that it is assumed, that the tables of the existing `dm` are available in the global environment under their names
#' within the `dm`.
#'
#' @return Code for producing the given `dm`.
#'
#' @export
dm_paste <- function(dm, select = FALSE, tab_width = 2) {
  check_dm(dm)
  check_no_filter(dm)
  check_not_zoomed(dm)

  # we assume the tables exist and have the necessary columns
  # code for including the tables
  code <- glue("dm({paste(tick_if_needed({src_tbls(dm)}), collapse = ', ')})")
  tab <- paste0(rep(" ", tab_width), collapse = "")

  if (select) {
    # adding code for selection of columns
    tbl_select <- tibble(tbl_name = src_tbls(dm), tbls = dm_get_tables(dm)) %>%
      mutate(cols = map(tbls, colnames)) %>%
      mutate(code = map2_chr(
        tbl_name,
        cols,
        ~ glue("{tab}dm_select({..1}, {paste0(tick_if_needed(..2), collapse = ', ')})")
      ))
    code_select <- if (nrow(tbl_select)) summarize(tbl_select, code = glue_collapse(code, sep = " %>%\n")) %>% pull() else character()
    code <- glue_collapse(c(code, code_select), sep = " %>%\n")
  }
  # adding code for establishing PKs
  tbl_pks <- dm_get_all_pks(dm) %>%
    mutate(code = glue("{tab}dm_add_pk({table}, {pk_col})"))
  code_pks <- if (nrow(tbl_pks)) summarize(tbl_pks, code = glue_collapse(code, sep = " %>%\n")) %>% pull() else character()

  # adding code for establishing FKs
  tbl_fks <- dm_get_all_fks(dm) %>%
    mutate(code = glue("{tab}dm_add_fk({child_table}, {child_fk_col}, {parent_table})"))
  code_fks <- if (nrow(tbl_fks)) summarize(tbl_fks, code = glue_collapse(code, sep = " %>%\n")) %>% pull() else character()

  # without "\n" in the end it looks weird when a warning is issued
  cat(glue_collapse(c(code, code_pks, code_fks), sep = " %>%\n"), "\n")
  invisible(dm)
}
