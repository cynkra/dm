#' Decompose a table into two linked tables
#'
#' @description Perform table surgery by extracting a 'parent table' from a table, linking original and new table by a key and returning both.
#'
#' `decompose_table()` accepts a data frame, a name for an 'ID column' that will be newly created, and the names
#' of the columns which will be extracted into the new data frame.
#'
#' It creates the 'parent table', consisting of the columns specified in the ellipsis and the new 'ID column'. Then it removes the
#' said columns from the now called 'child table' (the original table) and also adds the 'ID column' here appropriately.
#'
#' @param .data Data frame from which columns `...` are to be extracted.
#' @param new_id_column Name of the identifier column (primary key column) for the parent table. A column of this name is also added in 'child table'.
#' @param ... The columns to be extracted from the `.data`.
#'
#' One or more unquoted expressions separated by commas. You can treat variable names like they are positions, so you
#' can use expressions like x:y to select ranges of variables.
#'
#' The arguments in ... are automatically quoted and evaluated in a context where column names represent column positions. They also support
#' unquoting and splicing. See vignette("programming") for an introduction to these concepts.
#'
#' See select helpers for more details and examples about tidyselect helpers such as starts_with(), everything(), ...
#'
#' @family Table surgery functions
#'
#' @examples
#' library(magrittr)
#'
#' decomposed_table <- decompose_table(mtcars, new_id, am, gear, carb)
#' decomposed_table$child_table
#' decomposed_table$parent_table
#' @export
decompose_table <- function(.data, new_id_column, ...) {
  .data_q <- enquo(.data)
  cols_q <- enexprs(...)
  id_col_q <- enexpr(new_id_column)

  cols_chr <-
    cols_q %>%
    map_chr(~ as_name(.))

  table_name <- as_label(.data_q)

  if (as_label(id_col_q) %in% colnames(eval_tidy(.data_q))) {
    abort_dupl_new_id_col_name(table_name)
  }
  if (!(length(cols_q))) abort(paste0("Columns of ", table_name, " need to be specified in ellipsis"))
  if (!all(cols_q %in% colnames(eval_tidy(.data_q)))) {
    abort_wrong_col_names(as_label(.data_q), colnames(eval_tidy(.data_q)), cols_chr)
  }

  if (length(cols_q) >= length(colnames(eval_tidy(.data_q)))) abort_too_many_cols(table_name)

  parent_table <-
    select(eval_tidy(.data_q), !!!cols_q) %>%
    distinct() %>%
    # Without as.integer(), RPostgres creates integer64 column (#15)
    arrange(!!!cols_q) %>%
    mutate(!!id_col_q := as.integer(row_number())) %>%
    select(!!id_col_q, everything())

  cols_chr <-
    cols_q %>%
    map_chr(~ paste(.))

  names_data <-
    eval_tidy(.data_q) %>%
    colnames()

  non_key_names <-
    setdiff(names_data, cols_chr)

  child_table <-
    eval_tidy(.data_q) %>%
    left_join(
      parent_table,
      by = cols_chr
    ) %>%
    select(non_key_names, !!id_col_q)
    # FIXME: Think about a good place for the target column,
    # perhaps if this operation is run in a data model?

  list("child_table" = child_table, "parent_table" = parent_table)
}

#' Merge two tables linked by a foreign key relation
#'
#' @description Perform table fusion by combining two tables by a common (key) column and then removing this column.
#'
#' `reunite_parent_child()`: After joining the two tables by the column `id_column`, this column is removed. The transformation is roughly the
#' inverse of what `decompose_table()` does.
#'
#' @param child_table Table (possibly created by `decompose_table()`) that references `parent_table`
#' @param parent_table Table (possibly created by `decompose_table()`).
#' @param id_column Identical name of referencing/referenced column in `child_table`/`parent_table`
#'
#' @family Table surgery functions
#'
#' @name reunite_parent_child
#' @export
reunite_parent_child <- function(child_table, parent_table, id_column) {
  id_col_q <- enexpr(id_column)

  id_col_chr <-
    as_name(id_col_q)

  child_table %>%
    left_join(parent_table, by = id_col_chr) %>%
    select(-!!id_col_q)
}

#' Merge two tables linked by a foreign key relation
#'
#' @description `reunite_parent_child_from_list()`: After joining the two tables
#' by the column `id_column`, this column is removed.
#'
#' The function is almost exactly the inverse of `decompose_table()` (the order
#' of the columns is not retained and original rownames are lost).
#'
#' @inheritParams reunite_parent_child
#' @param list_of_parent_child_tables Cf arguments `child_table` and `parent_table` from
#' `reunite_parent_child()`, but both in a named list (as created by `decompose_table()`).
#'
#' @family Table surgery functions
#'
#' @rdname reunite_parent_child
#' @export
reunite_parent_child_from_list <- function(list_of_parent_child_tables, id_column) {
  id_col_q <- enexpr(id_column)

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
