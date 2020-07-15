dm_merge <- function(...) {
  if (dots_n(...) == 0) abort_empty_ellipsis("dm_merge()")
  dms <- list2(...)
  walk(dms, check_dm)
  walk(dms, check_not_zoomed)

  table_names <- map(dms, src_tbls) %>% flatten_chr()
  if (anyDuplicated(table_names)) abort_need_unique_names(
    table_names[duplicated(table_names)]
  )

  dms_def <- map(dms, dm_get_def)
  reduce(dms_def, bind_rows) %>%
    new_dm3()
}


# error handling ----------------------------------------------------------

abort_empty_ellipsis <- function(function_name) {
  abort(
    glue("No argument provided for `...` in {tick(function_name)}."),
    class = dm_error_full("empty_ellipsis")
  )
}
