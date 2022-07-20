mw_cg_make_dm_select_tbl <- function(dm, ..., table_names = NULL, rm = FALSE) {
  check_dots_empty()

  # Checks
  check_is_character_vec(table_names)
  check_tbl_in_dm(dm, table_names)

  tbl_names_sel_rm <- syms(table_names)

  if (rm) {
    if (length(tbl_names_sel_rm) == 1) {
      tbl_names_sel_rm <- exprs(-!!tbl_names_sel_rm[[1]])
    } else {
      tbl_names_sel_rm <- exprs(-c(!!!tbl_names_sel_rm))
    }
  }

  # Return call object
  list(
    call = expr(dm_select_tbl(
      .,
      !!!tbl_names_sel_rm
    ))
  )
}
