# FIXME: Adapt argument list as provided/required by the Shiny app
mw_cg_make_dm_rm_fk <- function(dm, ..., edge_table) {
  check_dots_empty()

  # Checks
  stopifnot(is.character(edge_table$child_table))
  stopifnot(is.character(edge_table$parent_table))
  stopifnot(edge_table$child_table %in% names(dm))
  stopifnot(edge_table$parent_table %in% names(dm))

  # FIXME: check also cols
  purrr::pmap(
    edge_table,
    function(child_table, child_fk_cols, parent_table, parent_key_cols) {
      if (length(child_fk_cols) > 1) {
        call = expr(dm_rm_fk(
          .,
          table = !!sym(child_table),
          columns = c(!!!syms(child_fk_cols)),
          ref_table = !!sym(parent_table),
          ref_columns = c(!!!syms(parent_key_cols))
        ))
      } else {
        call = expr(dm_rm_fk(
          .,
          table = !!sym(child_table),
          columns = !!sym(child_fk_cols),
          ref_table = !!sym(parent_table),
          ref_columns = !!sym(parent_key_cols)
        ))
      }
    }
  )
}
