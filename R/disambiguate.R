#' Avoid column name conflicts
#'
#' This function checks all tables for column names that are not unique (across the entire `dm` object) and renames
#' those columns by prefixing the respective table name and a separator.
#' Key columns will not be renamed, since only one column should remain, when two tables
#' linked by a key relation are joined.
#'
#' @inheritParams cdm_add_pk
#' @param sep The character variable separating the table names and the ambiguous column names
#' @param quiet Boolean. By default this function lists the renamed columns in a message, pass `FALSE` to suppress this message.
#'
#' @examples
#' cdm_disambiguate_cols(cdm_nycflights13())
#' @export
cdm_disambiguate_cols <- function(dm, sep = ".", quiet = FALSE) {
  cdm_disambiguate_cols_impl(dm, tables = NULL, sep = sep, quiet = quiet)
}

cdm_disambiguate_cols_impl <- function(dm, tables, sep = ".", quiet = FALSE) {
  table_colnames <- get_table_colnames(dm, tables)
  recipe <- compute_disambiguate_cols_recipe(table_colnames, sep = sep)
  if (!quiet) explain_col_rename(recipe)
  col_rename(dm, recipe)
}

get_table_colnames <- function(dm, tables = NULL) {
  def <- cdm_get_def(dm)

  if (!is.null(tables)) {
    def <-
      def %>%
      filter(table %in% !!tables)
  }

  table_colnames <-
    def %>%
    mutate(column = map(data, colnames)) %>%
    select(table, column) %>%
    unnest(column)

  pks <-
    cdm_get_all_pks(dm) %>%
    rename(column = pk_col)

  table_colnames %>%
    # in case of flattening, primary key columns will never be responsible for the name
    # of the resulting column in the end, so they do not need to be disambiguated
    anti_join(pks, by = c("table", "column"))
}

compute_disambiguate_cols_recipe <- function(table_colnames, sep) {
  table_colnames %>%
    add_count(column) %>%
    filter(n > 1) %>%
    mutate(new_name = paste0(table, sep, column)) %>%
    select(table, new_name, column) %>%
    nest(renames = -table) %>%
    mutate(renames = map(renames, deframe))
}

explain_col_rename <- function(recipe) {
  if (nrow(recipe) == 0) return()

  msg_core <-
    recipe %>%
    mutate(renames = map(renames, ~ enframe(., "new", "old"))) %>%
    unnest(renames) %>%
    nest(data = -old) %>%
    mutate(sub_text = map_chr(data, ~ paste0(.$table, "$", .$new, collapse = ", "))) %>%
    mutate(text = paste0("* ", old, " -> ", sub_text)) %>%
    pull()

  message("Renamed columns:\n", paste(msg_core, collapse = "\n"))
}

col_rename <- function(dm, recipe) {
  reduce2(recipe$table,
    recipe$renames,
    ~ cdm_rename(..1, !!..2, !!!..3),
    .init = dm
  )
}
