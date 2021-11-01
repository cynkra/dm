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
  table_colnames <- get_table_colnames(dm, tables, exclude_pk = FALSE)
  recipe <- compute_disambiguate_cols_recipe(table_colnames, sep = sep)
  if (!quiet) explain_col_rename(recipe)
  col_rename(dm, recipe)
}

get_table_colnames <- function(dm, tables = NULL, exclude_pk = TRUE) {
  def <- dm_get_def(dm)

  if (!is.null(tables)) {
    def <- def[def$table %in% tables, ]
  }

  table_colnames <-
    tibble(table = def$table, column = map(def$data, colnames)) %>%
    unnest_col("column", character())

  if(exclude_pk) {
  pks <- dm_get_all_pks_def_impl(def)

  keep_colnames <-
    pks[c("table", "pk_col")] %>%
    set_names(c("table", "column")) %>%
    unnest_col("column", character())

  table_colnames <-
    table_colnames %>%
    # in case of flattening, the primary key columns will never be responsible for the name
    # of the resulting column in the end, so they do not need to be disambiguated
    anti_join(keep_colnames, by = c("table", "column"))
  }
  table_colnames
}

compute_disambiguate_cols_recipe <- function(table_colnames, sep) {
  dupes <- vec_duplicate_detect(table_colnames$column)
  dup_colnames <- table_colnames[dupes, ]

  dup_colnames$new_name <- paste0(dup_colnames$table, sep, dup_colnames$column)
  dup_data <- dup_colnames[c("new_name", "column")]
  dup_data$column <- syms(dup_data$column)

  dup_nested <-
    vec_split(dup_data, dup_colnames$table) %>%
    set_names("table", "renames")

  dup_nested$renames <- map(dup_nested$renames, deframe)
  as_tibble(dup_nested)
}

explain_col_rename <- function(recipe) {
  if (nrow(recipe) == 0) {
    return()
  }

  msg_base <-
    recipe %>%
    mutate(renames = map(renames, ~ enframe(., "new", "old"))) %>%
    unnest_df("renames", tibble(new = character(), old = syms(character()))) %>%
    nest(data = -old)

  sub_text <- map_chr(msg_base$data, ~ paste0(.x$new, collapse = ", "))
  msg_core <- paste0("* ", msg_base$old, " -> ", sub_text)

  message("Renamed columns:\n", paste(msg_core, collapse = "\n"))
}

col_rename <- function(dm, recipe) {
  reduce2(recipe$table,
    recipe$renames,
    ~ dm_rename(..1, !!..2, !!!..3),
    .init = dm
  )
}
