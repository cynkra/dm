#' Check table relations
#'
#' @description
#' `r lifecycle::badge("stable")`
#'
#' All `check_cardinality_*()` functions test the following conditions:
#' 1. Are all rows in `x` unique?
#' 1. Are the rows in `y` a subset of the rows in `x`?
#' 1. Does the relation between `x` and `y` meet the cardinality requirements?
#'     One row from `x` must correspond to the requested number of rows in `y`,
#'     e.g. `_0_1` means that there must be zero or one rows in `y` for each
#'     row in `x`.
#'
#' `examine_cardinality()` also checks the first two points and subsequently determines the type of cardinality.
#'
#' For convenience, the `x_select` and `y_select` arguments allow restricting the check
#' to a set of key columns without affecting the return value.
#'
#' @details
#' All cardinality functions accept a parent and a child table (`x` and `y`).
#' All rows in `x` must be unique, and all rows in `y` must be a subset of the
#' rows in `x`.
#' The `x_select` and `y_select` arguments allow restricting the check
#' to a set of key columns without affecting the return value.
#' If given, both arguments must refer to the same number of key columns.
#'
#' The cardinality specifications "0_n", "1_n", "0_1", "1_1" refer to the expected relation that the child table has with the parent table.
#' "0", "1" and "n" refer to the occurrences of value combinations
#' in `y` that correspond to each combination in the
#' columns of the parent table.
#' "n" means "more than one" in this context, with no upper limit.
#'
# FIXME: Should/do we check that there is at least one with 0, 1 or 2 matches?
#' **"0_n"**: no restrictions, each row in `x` has at least 0 and at most
#' n corresponding occurrences in `y`.
#'
#' **"1_n"**: each row in `x` has at least 1 and at most
#' n corresponding occurrences in `y`.
#' This means that there is a "surjective" mapping from the child table
#' to the parent table, i.e. each parent table row exists at least once in the
#' child table.
#'
#' **"0_1"**: each row in `x` has at least 0 and at most
#' 1 corresponding occurrence in `y`.
#' This means that there is a "injective" mapping from the child table
#' to the parent table, i.e. no combination of values in the
#' parent table columns is addressed multiple times.
#' But not all parent table rows have to be referred to.
#'
#' **"1_1"**: each row in `x` occurs exactly once in `y`.
#' This means that there is a "bijective" ("injective" AND "surjective") mapping
#' between the child table and the parent table, i.e. the
#' sets of rows are identical.
#'
#' Finally, `examine_cardinality()` tests for and returns the nature of the relationship
#' (injective, surjective, bijective, or none of these)
#' between the two given sets of columns.
#' If either `x` is not unique or there are rows in `y` that are missing from `x`,
#' the requirements for a cardinality test is not fulfilled.
#' No error will be thrown, but
#' the result will contain the information which prerequisite was violated.
#' @param x Parent table, data frame or lazy table.
#' @param y Child table, data frame or lazy table.
#' @param x_select,y_select Names of key columns, processed with
#'   [tidyselect::eval_select()], to restrict the check.
#'
#' @family cardinality functions
#'
#' @name examine_cardinality
#'
#' @return `check_cardinality_...()` return `x`, invisibly,
#' if the check is passed, to support pipes.
#' Otherwise an error is thrown and the reason for it is explained.
#'
#' For `examine_cardinality()`: Returns a character variable specifying the type of relationship between the two columns.
#'
#' @aliases check_cardinality_...
#' @export
#' @examples
#' d1 <- tibble::tibble(a = 1:5)
#' d2 <- tibble::tibble(c = c(1:5, 5))
#' d3 <- tibble::tibble(c = 1:4)
#' # This does not pass, `c` is not unique key of d2:
#' try(check_cardinality_0_n(d2, c, d1, a))
#'
#' # This passes, multiple values in d2$c are allowed:
#' check_cardinality_0_n(d1, a, d2, c)
#'
#' # This does not pass, injectivity is violated:
#' try(check_cardinality_1_1(d1, a, d2, c))
#'
#' # This passes:
#' check_cardinality_0_1(d1, a, d3, c)
check_cardinality_0_n <- function(x, y, ..., x_select = NULL, y_select = NULL) {
  check_card_api({{ x }}, {{ y }}, ..., x_select = {{ x_select }}, y_select = {{ y_select }}, target = check_cardinality_0_n_impl0)
}

check_cardinality_0_n_impl0 <- function(x, y, x_label, y_label) {
  check_key_impl0(x, x_label)

  check_subset_impl0(y, x, y_label, x_label)

  invisible(x)
}

#' @rdname examine_cardinality
#' @export
check_cardinality_1_n <- function(x, y, ..., x_select = NULL, y_select = NULL) {
  check_card_api({{ x }}, {{ y }}, ..., x_select = {{ x_select }}, y_select = {{ y_select }}, target = check_cardinality_1_n_impl0)
}

check_cardinality_1_n_impl0 <- function(x, y, x_label, y_label) {
  check_key_impl0(x, x_label)

  check_set_equality_impl0(y, x, y_label, x_label)

  invisible(x)
}

#' @rdname examine_cardinality
#' @export
check_cardinality_1_1 <- function(x, y, ..., x_select = NULL, y_select = NULL) {
  check_card_api({{ x }}, {{ y }}, ..., x_select = {{ x_select }}, y_select = {{ y_select }}, target = check_cardinality_1_1_impl0)
}

check_cardinality_1_1_impl0 <- function(x, y, x_label, y_label) {
  check_key_impl0(x, x_label)

  check_set_equality_impl0(y, x, y_label, x_label)

  tryCatch(
    {
      check_key_impl0(y, y_label)
      NULL
    },
    error = function(e) abort_not_bijective(y_label, colnames(y))
  )

  invisible(x)
}

#' @rdname examine_cardinality
#' @export
check_cardinality_0_1 <- function(x, y, ..., x_select = NULL, y_select = NULL) {
  check_card_api({{ x }}, {{ y }}, ..., x_select = {{ x_select }}, y_select = {{ y_select }}, target = check_cardinality_0_1_impl0)
}

check_cardinality_0_1_impl0 <- function(x, y, x_label, y_label) {
  check_key_impl0(x, x_label)

  check_subset_impl0(y, x, y_label, x_label)

  tryCatch(
    {
      check_key_impl0(y, y_label)
      NULL
    },
    error = function(e) abort_not_injective(y_label, colnames(y))
  )

  invisible(x)
}

#' @rdname examine_cardinality
#' @export
#' @examples
#'
#' # Returns the kind of cardinality
#' examine_cardinality(d1, a, d2, c)
examine_cardinality <- function(x, y, ..., x_select = NULL, y_select = NULL) {
  check_card_api({{ x }}, {{ y }}, ..., x_select = {{ x_select }}, y_select = {{ y_select }}, target = examine_cardinality_impl0)
}

examine_cardinality_impl0 <- function(x, y, x_label, y_label) {
  if (!is_unique_key_se(x, colnames(x))$unique) {
    plural <- s_if_plural(colnames(x))
    return(
      glue(
        "Column{plural['n']} ({commas(tick(colnames(x)))}) not ",
        "a unique key of {tick(x_label)}."
      )
    )
  }
  if (!is_subset_se(y, x)) {
    plural <- s_if_plural(colnames(x))
    return(
      glue(
        "Column{plural['n']} ({commas(tick(colnames(y)))}) of table {tick(y_label)} not ",
        "a subset of column{plural['n']} ({commas(tick(colnames(x)))}) of table {tick(x_label)}."
      )
    )
  }
  min_1 <- is_subset_se(x, y)
  max_1 <- pull(is_unique_key_se(y, colnames(y)), unique)

  if (min_1 && max_1) {
    return("bijective mapping (child: 1 -> parent: 1)")
  } else if (min_1) {
    return("surjective mapping (child: 1 to n -> parent: 1)")
  } else if (max_1) {
    return("injective mapping (child: 0 or 1 -> parent: 1)")
  }
  "generic mapping (child: 0 to n -> parent: 1)"
}


check_card_api <- function(x, y,
                           ...,
                           x_select = NULL, y_select = NULL,
                           call = caller_env(),
                           target = exprs) {
  if (dots_n(...) >= 2) {
    name <- as.character(frame_call(call)[[1]] %||% "check_card_api")
    # deprecate_soft("1.0.0", paste0(name, "(pk_column)"), paste0(name, "(x_select = )"),
    #   details = "Use `y_select` instead of `fk_column`, and `x` and `y` instead of `parent_table` and `child_table`."
    # )
    check_card_api_impl(
      {{ x }}, {{ y }}, ...,
      target = target
    )
  } else {
    check_dots_empty(call = call)
    check_card_api_impl(
      {{ x }}, {{ x_select }}, {{ y }}, {{ y_select }},
      target = target
    )
  }
}

check_card_api_impl <- function(parent_table, pk_column, child_table, fk_column, ..., target) {
  ptq <- enquo(parent_table)
  ctq <- enquo(child_table)

  pkcq <- enquo(pk_column)
  fkcq <- enquo(fk_column)

  if (quo_is_null(pkcq)) {
    stopifnot(quo_is_null(fkcq))
  } else {
    parent_table <- parent_table %>% select(!!pkcq)
    child_table <- child_table %>% select(!!fkcq)
  }

  target(parent_table, child_table, as_label(ptq), as_label(ctq))
}
