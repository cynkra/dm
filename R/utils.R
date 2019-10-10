MAX_COMMAS <- 6L

commas <- function(x) {
  if (is_empty(x)) {
    x <- ""
  } else if (length(x) > MAX_COMMAS) {
    length(x) <- MAX_COMMAS + 1L
    x[[MAX_COMMAS + 1L]] <- cli::symbol$ellipsis
  }

  glue_collapse(x, sep = ", ")
}

tick <- function(x) {
  paste0("`", x, "`")
}

default_local_src <- function() {
  src_df(env = .GlobalEnv)
}


clean_up_dm <- function(dm, tables, gotta_rename) {
  start <- tables[1]
  # filters need to be empty, for the disambiguation to work
  # the renaming will be minimized, if we reduce the `dm` to the necessary tables here
  red_dm <-
    cdm_reset_all_filters(dm) %>%
    cdm_select_tbl(tables)

  if (gotta_rename) {
    recipe <-
      compute_disambiguate_cols_recipe(red_dm, tables, sep = ".")
    explain_col_rename(recipe)
    # prepare `dm` by disambiguating columns (on a reduced dm)
    clean_dm <-
      col_rename(red_dm, recipe)
    # the column names of start_tbl need to be updated, since taken from `dm` and not `clean_dm`,
    # therefore we need a named variable containing the new and old names
    renames <-
      recipe %>% filter(table == !!start) %>% pull() %>% flatten_chr()
  } else {
    # for `anti_join()` and `semi_join()` no renaming necessary
    clean_dm <- red_dm
    renames <- character(0)
  }
  list(clean_dm, renames)
}
