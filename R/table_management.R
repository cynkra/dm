cdm_add_tbls <- function(dm, ...) {
  # FIXME: following line needs to be replaced using check_dm() after PR 86 merged
  if (!is_dm(dm)) abort("First parameter in `cdm_add_tbls()` needs to be of class `dm`")

  orig_tbls <- src_tbls(dm)

  new_names <- names(exprs(..., .named = TRUE))
  new_tables <- list(...)
  # this function has a secondary effect and returns a value; generally not good style, but it is more convenient
  new_names <- check_new_tbls(dm, new_tables, new_names)
  if (any(new_names %in% src_tbls(dm))) abort_table_already_exists(new_names[new_names %in% src_tbls(dm)])

  reduce2(
    rev(new_tables),
    rev(new_names),
    ~ cdm_add_tbl_impl(cdm_get_def(..1), ..2, ..3),
    .init = dm
    )
}


cdm_add_tbl <- function(dm, table, table_name = NULL) {
  # FIXME: following line needs to be replaced using check_dm() after PR 86 merged
  if (!is_dm(dm)) abort("First parameter in `cdm_add_tbl()` needs to be of class `dm`")

  if (is_null(table_name)) {
    table_name <- as_string(ensym(table))
  }
  # this function has a secondary effect and returns a value; generally not good style, but it is more convenient
  table_name <- check_new_tbls(dm, table, table_name)
  if (table_name %in% src_tbls(dm)) abort_table_already_exists(table_name)

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

check_new_tbls <- function(dm, tbls, name) {
  orig_tbls <- cdm_get_tables(dm)
  # are all new tables on the same source as the original ones?
  if (!all_same_source(flatten(list(cdm_get_tables(dm), tbls)))) abort_not_same_src()

  if ("." %in% name) {
    warning("New table called `new_table` introduced by adding table to `dm` in a pipe without giving it an explicit name.")
    "new_table"
  } else name
}
