cdm_add_tbl <- function(dm, table, table_name = NULL) {
  # FIXME: following line needs to be replaced using check_dm() after PR 86 merged
  if (!is_dm(dm)) abort("First parameter in `cdm_add_tbl()` needs to be of class `dm`")

  if (is_null(table_name)) {
    table_name <- deparse(substitute(table))
    if (table_name == ".") {
      warning("New table called 'new_table' introduced by adding table to `dm` in a pipe without giving it an explicit name.")
      table_name <- "new_table"
    }
  }

  cdm_add_tbl_impl(cdm_get_def(dm), table, table_name)
}

cdm_add_tbl_impl <- function(def, tbl, table_name) {
  def_0 <- tibble(
    table = table_name,
    data = list(tbl),
    segment = NA,
    display = NA_character_,
    pks = vctrs::list_of(tibble(column = list())),
    fks = vctrs::list_of(tibble(table = character(), column = list())),
    name = NA_character_,
    filters = vctrs::list_of(tibble(filter_quo = list()))
    )

  new_dm3(vctrs::vec_rbind(def_0, def))
}
