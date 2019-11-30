#' Decompose a table into two linked tables
#'
#' @description Perform table surgery by extracting a 'parent table' from a table, linking the original table and the new table by a key, and returning both tables.
#'
#' `decompose_table()` accepts a data frame, a name for the 'ID column' that will be newly created, and the names
#' of the columns that will be extracted into the new data frame.
#'
#' It creates a 'parent table', which consists of the columns specified in the ellipsis, and a new 'ID column'.
#' Then it removes those
#' columns from the original table, which is now called the 'child table, and adds the 'ID column'.
#'
#' @param .data Data frame from which columns `...` are to be extracted.
#' @param new_id_column Name of the identifier column (primary key column) for the parent table.
#'   A column of this name is also added in 'child table'.
#' @param ... The columns to be extracted from the `.data`.
#'
#'   One or more unquoted expressions separated by commas.
#'   You can treat variable names as if they were positions, so you
#'   can use expressions like x:y to select ranges of variables.
#'
#'   The arguments in ... are automatically quoted and evaluated in a context where column names represent column positions.
#'   They also support
#'   unquoting and splicing.
#'   See vignette("programming") for an introduction to those concepts.
#'
#'   See select helpers for more details, and the examples about tidyselect helpers, such as starts_with(), everything(), ...
#'
#' @family table surgery functions
#'
#' @examples
#' library(magrittr)
#'
#' decomposed_table <- decompose_table(mtcars, new_id, am, gear, carb)
#' decomposed_table$child_table
#' decomposed_table$parent_table
#' @export
decompose_table <- function(.data, new_id_column, ...) {
  table_name <- deparse(substitute(.data))
  avail_cols <- colnames(.data)
  id_col_q <- ensym(new_id_column)

  if (as_string(id_col_q) %in% avail_cols) {
    abort_dupl_new_id_col_name(table_name)
  }

  sel_vars <- tryCatch(
    tidyselect::vars_select(avail_cols, ...),
    error = function(e) {
      if (inherits(e, "simpleError")) {
        # FIXME: what if a different `simpleError` occurs?
        wrong_col <- gsub("^.*'(.*)'.*$", "\\1", e$message)
        abort_wrong_col_names(table_name, avail_cols, wrong_col)
      } else abort(e$message)
    })

  parent_table <-
    select(.data, !!!sel_vars) %>%
    distinct() %>%
    # Without as.integer(), RPostgres creates integer64 column (#15)
    arrange(!!!syms(names(sel_vars))) %>%
    mutate(!!id_col_q := as.integer(row_number())) %>%
    select(!!id_col_q, everything())

  non_key_names <-
    setdiff(avail_cols, sel_vars)

  child_table <-
    .data %>%
    left_join(
      parent_table,
      by = prep_recode(sel_vars)
    ) %>%
    select(non_key_names, !!id_col_q)
  # FIXME: Think about a good place for the target column,
  # perhaps if this operation is run in a data model?

  list("child_table" = child_table, "parent_table" = parent_table)
}

#' Merge two tables that are linked by a foreign key relation
#'
#' @description Perform table fusion by combining two tables by a common (key) column, and then removing this column.
#'
#' `reunite_parent_child()`: After joining the two tables by the column `id_column`, this column will be removed.
#' The transformation is roughly the
#' inverse of what `decompose_table()` does.
#'
#' @param child_table Table (possibly created by `decompose_table()`) that references `parent_table`
#' @param parent_table Table (possibly created by `decompose_table()`).
#' @param id_column Identical name of referencing / referenced column in `child_table`/`parent_table`.
#'
#' @family table surgery functions
#'
#' @name reunite_parent_child
#' @export
reunite_parent_child <- function(child_table, parent_table, id_column) {
  id_col_q <- ensym(id_column)

  id_col_chr <-
    as_name(id_col_q)

  child_table %>%
    left_join(parent_table, by = id_col_chr) %>%
    select(-!!id_col_q)
}

#' Merge two tables that are linked by a foreign key relation
#'
#' @description `reunite_parent_child_from_list()`: After joining the two tables
#' by the column `id_column`, `id_column` is removed.
#'
#' This function is almost exactly the inverse of `decompose_table()` (the order
#' of the columns is not retained, and the original row names are lost).
#'
#' @param list_of_parent_child_tables Cf arguments `child_table` and `parent_table` from
#'   `reunite_parent_child()`, but both in a named list (as created by `decompose_table()`).
#'
#' @family table surgery functions
#'
#' @rdname reunite_parent_child
#' @export
reunite_parent_child_from_list <- function(list_of_parent_child_tables, id_column) {
  id_col_q <- ensym(id_column)

  id_col_chr <-
    as_name(id_col_q)

  child_table <- list_of_parent_child_tables %>%
    extract2("child_table")

  parent_table <- list_of_parent_child_tables %>%
    extract2("parent_table")

  child_table %>%
    left_join(parent_table, by = id_col_chr) %>%
    select(-!!id_col_q)
}
