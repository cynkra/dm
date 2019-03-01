#' Perform table surgery by extracting a 'parent table' from a table, linking original and new table by a key and returning both.
#'
#' @description `decompose_table()` accepts a data frame, a name for an 'ID column' that will be newly created, and the names
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
#' @examples
#' \dontrun{
#' decomposed_table <- decompose_table(mtcars, new_id, am, gear, carb)
#' child_table <- decomposed_table %>%
#'   magrittr::extract("child_table") %>%
#'   purrr::flatten_dfr()
#' parent_table <- decomposed_table %>%
#'   magrittr::extract("parent_table") %>%
#'   purrr::flatten_dfr()
#' }
#' @export
decompose_table <- function(.data, new_id_column,...) {


  .data_q <- enquo(.data)
  cols_q <- enexprs(...)
  id_col_q <- enexpr(new_id_column)

  cols_chr <-
    cols_q %>%
    map_chr(~ as_name(.))

  if (as_label(id_col_q) %in% names(eval_tidy(.data_q))) stop(
    paste0("`new_id_column` can not have an identical name as one of the columns of ", as_label(.data_q))
    )
  if (!(length(cols_q))) stop(paste0("Columns of ", as_label(.data_q), " need to be specified in ellipsis"))
  if (!all(cols_q %in% names(eval_tidy(.data_q)))) stop(
    paste0("Not all specified variables `", paste(cols_chr, collapse = ", "), "` are columns of ", as_label(.data_q),
    ". These columns are: `", paste(names(eval_tidy(.data_q)), collapse = ", "), "`.")
  )
  if (length(cols_q) == length(eval_tidy(.data_q))) stop(
    paste0("Number of columns to be extracted has to be less than total number of columns of ", as_label(.data_q))
    )

  parent_table <-
    select(eval_tidy(.data_q), !!!cols_q) %>%
    distinct() %>%
    mutate(!!id_col_q := row_number()) %>%
    select(!!id_col_q, everything())

  cols_chr <-
    cols_q %>%
    map_chr(~ paste(.))

  names_data <-
    eval_tidy(.data_q) %>% names()

  non_key_names <-
    setdiff(names_data, cols_chr)

  child_table <-
    eval_tidy(.data_q) %>%
    left_join(
      parent_table, by = cols_chr
    ) %>%
    select(non_key_names, !!id_col_q) %>%
    select(1, !!id_col_q, everything())
  # 1 was originally first column in ".data" after extracting child table. It is therefore assumed to be a key to table ".data"

  return(list("child_table" = child_table, "parent_table" = parent_table))
}


reunite_parent_child <- function(child_table, parent_table, id_column) {

  id_col_q <- enexpr(id_column)

  id_col_chr <-
    as_name(id_col_q)

  child_table %>%
    left_join(parent_table, by = id_col_chr) %>%
    select(-!!id_col_q)

}


reunite_parent_child_from_list <- function(list_of_child_tables, id_column) {

  id_col_q <- enexpr(id_column)

  id_col_chr <-
    as_name(id_col_q)

  child_table <- list_of_child_tables %>%
      extract("child_table") %>%
      flatten_dfr()
    parent_table <- list_of_child_tables %>%
      magrittr::extract("parent_table") %>%
      flatten_dfr()

  child_table %>%
    left_join(parent_table, by = id_col_chr) %>%
    select(-!!id_col_q)

}
