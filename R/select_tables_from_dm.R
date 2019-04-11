#' @export
dm_select_table <- function(dm, table) {
  if (!is_dm(dm)) abort("'dm' has to be of class 'dm'")
  if (!is_bare_character(table)) abort("Argument 'table' has to be given as character vector")

  map(table, ~ tbl(dm, .x)) %>% set_names(table)
}
