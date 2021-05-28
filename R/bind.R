#' Merge several `dm`
#'
#' Create a single `dm` from two or more `dm` objects.
#'
#' @param ... `dm` objects to bind together.
#' @inheritParams dm_add_tbl
#'
#' @details The `dm` objects have to share the same `src`. By default table names need to be unique.
#'
#' @return `dm` containing the tables and key relations of all `dm` objects.
#' @export
#'
#' @examplesIf rlang::is_installed("nycflights13")
#' dm_1 <- dm_nycflights13()
#' dm_2 <- dm(mtcars, iris)
#' dm_bind(dm_1, dm_2)
dm_bind <- function(..., repair = "check_unique", quiet = FALSE) {
  # special case empty ellipsis, cause otherwise we get an empty data.frame of class `dm`
  if (dots_n(...) == 0) return(dm())
  dms <- list2(...)

  walk(dms, check_dm)
  walk(dms, check_not_zoomed)
  if (!all_same_source(map(dms, dm_get_tables_impl) |> flatten())) {
    abort_not_same_src(dm_bind = TRUE)
  }

  # repair table names
  table_names <- map(dms, src_tbls_impl) |> flatten_chr()
  new_table_names <- repair_names_vec(table_names, repair, quiet)
  # need to individually rename tables for each `dm`
  ntables_dms <- map(dms, length)
  dms_indices <-
    map2(lag(cumsum(ntables_dms), default = 0), map(ntables_dms, seq_len), `+`)
  renaming_recipe <- map(dms_indices, ~ set_names(table_names[.x], new_table_names[.x]))

  dms_renamed <- map2(dms, renaming_recipe, dm_rename_tbl)

  new_defs <- map(dms_renamed, dm_get_def)
  vec_rbind(!!!new_defs) |>
    new_dm3()
}
