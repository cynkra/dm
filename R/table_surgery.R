#' Perform table surgery by extracting a 'parent table' from a table, returning both and linking them by a key
#'
#'
#' @export
decompose_table <- function(.data, new_id_column,...) {


  .data_q <- enquo(.data)
  cols_q <- enexprs(...)
  id_col_q <- enexpr(new_id_column)

  cols_chr <-
    cols_q %>%
    map_chr(~ paste(.))

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
    select(!!id_col_q, non_key_names) %>%
    select(2, everything()) # 2 was originally first column in ".data" after extracting child table. It is therefore assumed to be key to table ".data"

  return(list("child_table" = child_table, "parent_table" = parent_table))
}
