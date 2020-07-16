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

  table_names <- map(dms, src_tbls) %>% flatten_chr()
  new_table_names <- repair_names_vec(table_names, repair, quiet)

  dms_def <- map(dms, dm_get_def)
  vec_rbind(dms_def) %>%
    mutate(table = new_table_names) %>%
    new_dm3()
}


# error handling ----------------------------------------------------------

abort_empty_ellipsis <- function(function_name) {
  abort(
    glue("No argument provided for `...` in {tick(function_name)}."),
    class = dm_error_full("empty_ellipsis")
  )
}
