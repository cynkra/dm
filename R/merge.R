#' Merge several `dm`
#'
#' Create a single `dm` from one or more `dm`-objects.
#'
#' @param ... `dm`-objects to merge. If left empty, an error will be thrown.
#' @inheritParams dm_add_tbl
#'
#' @details By default table names need to be unique.
#'
#' @return `dm` containing the tables and key relations of all `dm`-objects.
#' @export
#'
#' @examples
#' dm_1 <- dm_nycflights13()
#' dm_2 <- dm(mtcars, iris)
#' dm_merge(dm_1, dm_2)
dm_merge <- function(..., repair = "check_unique", quiet = FALSE) {
  if (dots_n(...) == 0) return(dm())
  dms <- list2(...)

  walk(dms, check_dm)
  walk(dms, check_not_zoomed)

  # repair table names
  table_names <- map(dms, src_tbls) %>% flatten_chr()
  new_table_names <- repair_names_vec(table_names, repair, quiet)
  # need to individually rename tables for each `dm`
  ntables_dms <- map(dms, length)
  dms_indices <-
    map2(lag(cumsum(ntables_dms), default = 0), map(ntables_dms, seq_len), `+`)
  renaming_recipe <- map(dms_indices, ~ set_names(table_names[.x], new_table_names[.x]))

  dms_renamed <- map2(dms, renaming_recipe, dm_rename_tbl)

  new_defs <- map(dms_renamed, dm_get_def)
  vctrs::vec_rbind(!!!new_defs) %>%
    new_dm3()
}


# error handling ----------------------------------------------------------

abort_empty_ellipsis <- function(function_name) {
  abort(
    glue("No argument provided for `...` in {tick(function_name)}."),
    class = dm_error_full("empty_ellipsis")
  )
}
