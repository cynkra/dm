#' Check if column(s) can be used as keys
#'
#' @description `check_key()` accepts a data frame and, optionally, columns.
#' It throws an error
#' if the specified columns are NOT a unique key of the data frame.
#' If the columns given in the ellipsis ARE a key, the data frame itself is returned silently, so that it can be used for piping.
#'
#' @param .data The data frame whose columns should be tested for key properties.
#' @param ... The names of the columns to be checked.
#'
#'   One or more unquoted expressions separated by commas.
#'   Variable names can be treated as if they were positions, so you
#'   can use expressions like x:y to select ranges of variables.
#'
#'   The arguments in ... are automatically quoted and evaluated in a context where column names represent column positions.
#'   They also support
#'   unquoting and splicing.
#'   See vignette("programming") for an introduction to these concepts.
#'
#'   See select helpers for more details and examples about tidyselect helpers such as starts_with(), everything(), ...
#'
#' @return Returns `.data`, invisibly, if the check is passed.
#'   Otherwise an error is thrown and the reason for it is explained.
#'
#' @export
#' @examples
#' data <- tibble::tibble(a = c(1, 2, 1), b = c(1, 4, 1), c = c(5, 6, 7))
#' # this is failing:
#' try(check_key(data, a, b))
#'
#' # this is passing:
#' check_key(data, a, c)
check_key <- function(.data, ...) {
  data_q <- enquo(.data)
  .data <- eval_tidy(data_q)

  # No special handling for no columns
  cols_chosen <- eval_select_indices(quo(c(...)), colnames(.data))
  orig_names <- names(cols_chosen)
  names(cols_chosen) <- glue("...{seq_along(cols_chosen)}")

  duplicate_rows <-
    .data %>%
    select(!!!cols_chosen) %>%
    safe_count(!!!syms(names(cols_chosen))) %>%
    select(n) %>%
    filter(n > 1) %>%
    head(1) %>%
    collect()

  if (nrow(duplicate_rows) != 0) {
    abort_not_unique_key(as_label(data_q), orig_names)
  }

  invisible(.data)
}

# an internal function to check if a column is a unique key of a table
is_unique_key <- function(.data, column) {
  col_q <- enexpr(column)
  col_name <- names(eval_select_indices(col_q, colnames(.data)))

  is_unique_key_se(.data, col_name)
}

is_unique_key_se <- function(.data, colname) {
  val_names <- paste0("value", seq_along(colname))
  col_syms <- syms(colname)
  names(col_syms) <- val_names

  # FIXME: Build expression instead of paste() + parse()
  any_value_na_expr <- parse(text = paste0("is.na(", val_names, ")", collapse = " | "))[[1]]

  res_tbl <-
    .data %>%
    safe_count(!!!col_syms) %>%
    mutate(any_na = if_else(!!any_value_na_expr, 1L, 0L)) %>%
    filter(n != 1 | any_na != 0L) %>%
    arrange(desc(n), !!!syms(val_names)) %>%
    utils::head(MAX_COMMAS + 1) %>%
    collect()

  res_tbl[val_names] <- map(res_tbl[val_names], format, trim = TRUE, justify = "none")
  res_tbl[val_names[-1]] <- map(res_tbl[val_names[-1]], ~ paste0(", ", .x))
  res_tbl$value <- if_else(res_tbl$any_na != 0, NA_character_, exec(paste0, !!!res_tbl[val_names]))

  duplicate_rows <-
    res_tbl %>%
    {
      # https://github.com/tidyverse/tidyr/issues/734
      tibble(data = list(.))
    } %>%
    mutate(unique = map_lgl(data, ~ nrow(.) == 0))

  duplicate_rows
}

#' Check column values for set equality
#'
#' @description `check_set_equality()` is a wrapper of `check_subset()`.
#' It tests if one value set is a subset of another and vice versa, i.e., if both sets are the same.
#' If not, it throws an error.
#'
#' @param t1 The data frame that contains the columns `c1`.
#' @param c1 The columns of `t1` that should only contain values that are also present in columns `c2` of data frame `t2`. Multiple columns can be chosen using `c(col1, col2)`.
#' @param t2 The data frame that contains the columns `c2`.
#' @param c2 The columns of `t2` that should only contain values that are also present in columns `c1` of data frame `t1`. Multiple columns can be chosen using `c(col1, col2)`.
#'
#' @return Returns `t1`, invisibly, if the check is passed.
#'   Otherwise an error is thrown and the reason for it is explained.
#'
#' @export
#' @examples
#' data_1 <- tibble::tibble(a = c(1, 2, 1), b = c(1, 4, 1), c = c(5, 6, 7))
#' data_2 <- tibble::tibble(a = c(1, 2, 3), b = c(4, 5, 6), c = c(7, 8, 9))
#' # this is failing:
#' try(check_set_equality(data_1, a, data_2, a))
#'
#' data_3 <- tibble::tibble(a = c(2, 1, 2), b = c(4, 5, 6), c = c(7, 8, 9))
#' # this is passing:
#' check_set_equality(data_1, a, data_3, a)
check_set_equality <- function(t1, c1, t2, c2) {
  t1q <- enquo(t1)
  t2q <- enquo(t2)

  c1q <- enexpr(c1)
  c2q <- enexpr(c2)

  catcher_1 <- tryCatch(
    {
      check_subset(!!t1q, !!c1q, !!t2q, !!c2q)
      NULL
    },
    error = identity
  )

  catcher_2 <- tryCatch(
    {
      check_subset(!!t2q, !!c2q, !!t1q, !!c1q)
      NULL
    },
    error = identity
  )

  catchers <- compact(list(catcher_1, catcher_2))

  if (length(catchers) > 0) {
    abort_sets_not_equal(map_chr(catchers, conditionMessage))
  }

  invisible(eval_tidy(t1q))
}

#' Check column values for subset
#'
#' @description `check_subset()` tests if the values of the chosen columns `c1` of data frame `t1` are a subset of the values
#' of columns `c2` of data frame `t2`.
#'
#' @inheritParams check_set_equality
#' @param c2 The columns of the second data frame which have to contain all values of `c1` to avoid an error. Multiple columns can be chosen using `c(col1, col2)`.
#'
#' @return Returns `t1`, invisibly, if the check is passed.
#'   Otherwise an error is thrown and the reason for it is explained.
#'
#' @export
#' @examples
#' data_1 <- tibble::tibble(a = c(1, 2, 1), b = c(1, 4, 1), c = c(5, 6, 7))
#' data_2 <- tibble::tibble(a = c(1, 2, 3), b = c(4, 5, 6), c = c(7, 8, 9))
#' # this is passing:
#' check_subset(data_1, a, data_2, a)
#'
#' # this is failing:
#' try(check_subset(data_2, a, data_1, a))
check_subset <- function(t1, c1, t2, c2) {
  t1q <- enquo(t1)
  t2q <- enquo(t2)

  c1q <- enexpr(c1)
  c2q <- enexpr(c2)
  col_names_1 <- names(eval_select_indices(c1q, colnames(eval_tidy(t1q))))
  col_names_2 <- names(eval_select_indices(c2q, colnames(eval_tidy(t2q))))

  # not using `is_subset()`, since then we would do the same job of finding
  # missing values/combinations twice
  res <- anti_join(eval_tidy(t1q), eval_tidy(t2q), by = set_names(col_names_2, col_names_1))
  if (pull(count(head(res, 1))) == 0) {
    return(invisible(eval_tidy(t1q)))
  }

  # collect() for robust test output
  print(collect(head(res, n = 10)))

  abort_not_subset_of(as_label(t1q), col_names_1, as_label(t2q), col_names_2)
}

# similar to `check_subset()`, but evaluates to a boolean
is_subset <- function(t1, c1, t2, c2) {
  t1q <- enquo(t1)
  t2q <- enquo(t2)

  c1q <- enexpr(c1)
  c2q <- enexpr(c2)
  col_names_1 <- names(eval_select_indices(c1q, colnames(eval_tidy(t1q))))
  col_names_2 <- names(eval_select_indices(c2q, colnames(eval_tidy(t2q))))

  res <- anti_join(eval_tidy(t1q), eval_tidy(t2q), by = set_names(col_names_2, col_names_1))
  pull(count(head(res, 1))) == 0
}
