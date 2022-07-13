#' Check if column(s) can be used as keys
#'
#' @description
#' `check_key()` accepts a data frame and, optionally, columns.
#' It throws an error
#' if the specified columns are NOT a unique key of the data frame.
#' If the columns given in the ellipsis ARE a key, the data frame itself is returned silently, so that it can be used for piping.
#'
#' @param x The data frame whose columns should be tested for key properties.
#' @param ... The names of the columns to be checked, processed with
#'   [dplyr::select()]. If omitted, all columns will be checked.
#' @param .data Deprecated.
#'
#' @return Returns `x`, invisibly, if the check is passed.
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
#' check_key(data)
check_key <- function(x, ..., .data = deprecated()) {
  if (!is_missing(.data)) {
    deprecate_soft("1.0.0", "check_key(.data = )", "check_key(x = )")
    return(check_key_impl0({{ .data }}, {{ x }}, ...))
  }

  check_key_impl({{ x }}, ...)
}

check_key_impl <- function(.data, ...) {
  data_q <- enquo(.data)
  .data <- eval_tidy(data_q)

  if (dots_n(...) > 0) {
    .data <- .data %>% select(...)
  }

  check_key_impl0(.data, as_label(data_q))
}

check_key_impl0 <- function(x, x_label) {
  orig_names <- colnames(x)
  cols_chosen <- syms(set_names(orig_names, glue("...{seq_along(orig_names)}")))

  if (inherits(x, "data.frame")) {
    any_duplicate_rows <- vctrs::vec_duplicate_any(x)
  } else {
    duplicate_rows <-
      x %>%
      safe_count(!!!cols_chosen) %>%
      select(n) %>%
      filter(n > 1) %>%
      head(1) %>%
      collect()
    any_duplicate_rows <- nrow(duplicate_rows) != 0
  }

  if (any_duplicate_rows) {
    abort_not_unique_key(x_label, orig_names)
  }
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

  any_value_na_expr <-
    syms(val_names) %>%
    map(call2, .fn = quote(is.na)) %>%
    reduce(call2, .fn = quote(`|`))

  if (inherits(.data, "data.frame")) {
    count_tbl <-
      .data %>%
      select(!!!col_syms) %>%
      vctrs::vec_count() %>%
      unpack(key) %>%
      rename(n = count)
  } else {
    count_tbl <-
      .data %>%
      safe_count(!!!col_syms)
  }
  res_tbl <-
    count_tbl %>%
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
#' @description
#' `check_set_equality()` is a wrapper of [check_subset()].
#'
#' It tests if one table is a subset of another and vice versa, i.e., if both sets are the same.
#' If not, it throws an error.
#'
#' @param x,y A data frame or lazy table.
#' @inheritParams rlang::args_dots_empty
#' @param x_select,y_select Key columns to restrict the check, processed with
#'   [dplyr::select()].
#'   If omitted, columns in `x` and `y` are matched by position.
#'
#' @return Returns `x`, invisibly, if the check is passed.
#'   Otherwise an error is thrown and the reason for it is explained.
#'
#' @export
#' @examples
#' data_1 <- tibble::tibble(a = c(1, 2, 1), b = c(1, 4, 1), c = c(5, 6, 7))
#' data_2 <- tibble::tibble(a = c(1, 2, 3), b = c(4, 5, 6), c = c(7, 8, 9))
#' # this is failing:
#' try(check_set_equality(data_1, data_2, x_select = a, y_select = a))
#'
#' data_3 <- tibble::tibble(a = c(2, 1, 2), b = c(4, 5, 6), c = c(7, 8, 9))
#' # this is passing:
#' check_set_equality(data_1, data_3, x_select = a, y_select = a)
#' # this is still failing:
#' try(check_set_equality(data_2, data_3))
check_set_equality <- function(x, y,
                               ...,
                               x_select = NULL, y_select = NULL,
                               by_position = NULL) {
  check_api(
    {{ x }}, {{ y }}, ...,
    x_select = {{ x_select }},
    y_select = {{ y_select }},
    by_position = by_position,
    target = check_set_equality_impl0
  )
  invisible(x)
}

check_set_equality_impl0 <- function(x, y, x_label, y_label) {
  catcher_1 <- tryCatch(
    {
      check_subset_impl0(x, y, x_label, y_label)
      NULL
    },
    error = identity
  )

  catcher_2 <- tryCatch(
    {
      check_subset_impl0(y, x, y_label, x_label)
      NULL
    },
    error = identity
  )

  catchers <- compact(list(catcher_1, catcher_2))

  if (length(catchers) > 0) {
    abort_sets_not_equal(map_chr(catchers, conditionMessage))
  }
}

#' Check column values for subset
#'
#' @description
#' `check_subset()` tests if `x` is a subset of `y`.
#' For convenience, the `x_select` and `y_select` arguments allow restricting the check
#' to a set of key columns without affecting the return value.
#'
#' @inheritParams check_set_equality
#'
#' @return Returns `x`, invisibly, if the check is passed.
#'   Otherwise an error is thrown and the reason for it is explained.
#'
#' @export
#' @examples
#' data_1 <- tibble::tibble(a = c(1, 2, 1), b = c(1, 4, 1), c = c(5, 6, 7))
#' data_2 <- tibble::tibble(a = c(1, 2, 3), b = c(4, 5, 6), c = c(7, 8, 9))
#' # this is passing:
#' check_subset(data_1, data_2, x_select = a, y_select = a)
#'
#' # this is failing:
#' try(check_subset(data_2, data_1))
check_subset <- function(x, y,
                         ...,
                         x_select = NULL, y_select = NULL,
                         by_position = NULL) {
  check_api(
    {{ x }}, {{ y }}, ...,
    x_select = {{ x_select }},
    y_select = {{ y_select }},
    by_position = by_position,
    target = check_subset_impl0
  )
  invisible(x)
}

check_subset_impl0 <- function(x, y, x_label, y_label) {
  # not using `is_subset()`, since then we would do the same job of finding
  # missing values/combinations twice
  res <- anti_join(x, y, by = set_names(colnames(y), colnames(x)))
  if (pull(count(head(res, 1))) == 0) {
    return()
  }

  # collect() for robust test output
  print(collect(head(res, n = 10)))

  abort_not_subset_of(x_label, colnames(x), y_label, colnames(y))
}

# similar to `check_subset()`, but evaluates to a boolean
is_subset <- function(t1, c1, t2, c2) {
  t1q <- enquo(t1)
  t2q <- enquo(t2)

  t1s <- eval_tidy(t1q) %>% select({{ c1 }})
  t2s <- eval_tidy(t2q) %>% select({{ c2 }})

  is_subset_se(t1s, t2s)
}

is_subset_se <- function(x, y) {
  res <- anti_join(x, y, by = set_names(colnames(y), colnames(x)))
  pull(count(head(res, 1))) == 0
}

check_api <- function(x, y,
                      ...,
                      x_select = NULL, y_select = NULL,
                      by_position = NULL,
                      call = caller_env(),
                      target = exprs) {
  if (dots_n(...) >= 2) {
    name <- as.character(frame_call(call)[[1]] %||% "check_api")
    # deprecate_soft("1.0.0", paste0(name, "(c1 = )"), paste0(name, "(x_select = )"),
    #   details = "Use `y_select` instead of `c2`, and `x` and `y` instead of `t1` and `t2`."
    # )
    stopifnot(is.null(by_position))
    check_api_impl(
      {{ x }}, {{ y }}, ...,
      by_position = TRUE,
      target = target
    )
  } else {
    check_dots_empty(call = call)
    check_api_impl(
      {{ x }}, {{ x_select }}, {{ y }}, {{ y_select }},
      by_position = by_position %||% FALSE,
      target = target
    )
  }
}

check_api_impl <- function(t1, c1, t2, c2, ..., by_position, target) {
  t1q <- enquo(t1)
  t2q <- enquo(t2)

  c1q <- enquo(c1)
  c2q <- enquo(c2)

  if (!quo_is_null(c1q)) {
    t1 <- t1 %>% select(!!c1q)
  }

  if (!quo_is_null(c2q)) {
    t2 <- t2 %>% select(!!c2q)
  }

  if (!isTRUE(by_position)) {
    y_idx <- match(colnames(t2), colnames(t1))
    if (anyNA(y_idx)) {
      abort("`by_position = FALSE` or `by_position = NULL` require matching column names.")
    }

    t2 <- t2[y_idx]
  }

  target(x = t1, y = t2, x_label = as_label(t1q), y_label = as_label(t2q))
}
