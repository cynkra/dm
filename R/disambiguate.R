#' Resolve column name ambiguities
#'
#' This function ensures that all columns in a `dm` have unique names.
#'
#' The function first checks if there are any column names that are not unique.
#' If there are, those columns will be assigned new, unique, names by prefixing their existing name
#' with the name of their table and a separator.
#' Columns that act as primary or foreign keys will not be renamed
#' because only the foreign key column will remain when two tables are joined,
#' making that column name "unique" as well.
#'
#' @inheritParams dm_add_pk
#' @param sep The character variable that separates the names of the table and the names of the ambiguous columns.
#' @param quiet Boolean.
#'   By default, this function lists the renamed columns in a message, pass `TRUE` to suppress this message.
#'
#' @return A `dm` whose column names are unambiguous.
#'
#' @examplesIf rlang::is_installed("nycflights13")
#' dm_nycflights13() %>%
#'   dm_disambiguate_cols()
#' @export
dm_disambiguate_cols <- function(dm, sep = ".", quiet = FALSE) {
  check_not_zoomed(dm)
  dm_disambiguate_cols_impl(dm, tables = NULL, sep = sep, quiet = quiet)
}

dm_disambiguate_cols_impl <- function(dm, tables, sep = ".", quiet = FALSE) {
  table_colnames <- get_table_colnames(dm, tables)
  recipe <- compute_disambiguate_cols_recipe(table_colnames, sep = sep)
  if (!quiet) explain_col_rename(recipe)
  col_rename(dm, recipe)
}

get_table_colnames <- function(dm, tables = NULL) {
  def <- dm_get_def(dm)

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

  pks <- dm_get_all_pks2_def_impl(def)

  if (nrow(pks) == 0) {
    return(table_colnames)
  }

  keep_colnames <-
    pks %>%
    rename(column = pk_col) %>%
    unnest(column)

  table_colnames %>%
    # in case of flattening, the primary key columns will never be responsible for the name
    # of the resulting column in the end, so they do not need to be disambiguated
    anti_join(keep_colnames, by = c("table", "column"))
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
  if (nrow(recipe) == 0) {
    return()
  }

  msg_core <-
    recipe %>%
    mutate(renames = map(renames, ~ enframe(., "new", "old"))) %>%
    unnest(renames) %>%
    nest(data = -old) %>%
    mutate(sub_text = map_chr(data, ~ paste0(.x$new, collapse = ", "))) %>%
    mutate(text = paste0("* ", old, " -> ", sub_text)) %>%
    pull()

  message("Renamed columns:\n", paste(msg_core, collapse = "\n"))
}

col_rename <- function(dm, recipe) {
  reduce2(recipe$table,
    recipe$renames,
    ~ dm_rename(..1, !!..2, !!!..3),
    .init = dm
  )
}
