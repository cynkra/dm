#' Check table relations
#'
#' @description All `check_cardinality_?_?()` functions test the following conditions:
#' 1. Is `pk_column` is a unique key for `parent_table`?
#' 1. Is the set of values in `fk_column` of `child_table` a subset of the set of values of `pk_column`?
#' 1. Does the relation between the two tables of the data model meet the cardinality requirements?
#'
#' `examine_cardinality()` also checks the first two points and subsequently determines the type of cardinality.
#'
#' @details All cardinality-functions accept a `parent table` (data frame), a column name of this table,
#' a `child table`, and a column name of the child table.
#' The given column of the `parent table` has to be one of its
#' unique keys (no duplicates are allowed).
#' Furthermore, in all cases, the set of values of the child table's column has to be a subset of the set of values of
#' the parent table's column.
#'
#' The cardinality specifications `0_n`, `1_n`, `0_1`, `1_1` refer to the expected relation that the child table has with the parent table.
#' The numbers `0`, `1` and `n` refer to the number of values in the column of the child table that correspond to each value of the
#' column of the parent table.
#' `n` means "more than one" in this context, with no upper limit.
#'
#' `0_n` means, that each value of the `pk_column` has at least `0` and at most
#' `n` corresponding values in the column of the child table (which translates to no further restrictions).
#'
#' `1_n` means, that each value of the `pk_column` has at least `1` and at most
#' `n` corresponding values in the column of the child table.
#' This means that there is a "surjective" mapping from the child table
#' to the parent table w.r.t. the specified columns, i.e. for each parent table column value there exists at least one equal child table column value.
#'
#' `0_1` means, that each value of the `pk_column` has at least `0` and at most
#' `1` corresponding values in the column of the child table.
#' This means that there is a "injective" mapping from the child table
#' to the parent table w.r.t. the specified columns, i.e. no parent table column value is addressed multiple times.
#' But not all of the parent table
#' column values have to be referred to.
#'
#' `1_1` means, that each value of the `pk_column` has exactly
#' `1`  corresponding value in the column of the child table.
#' This means that there is a "bijective" ("injective" AND "surjective") mapping
#' between the child table and the parent table w.r.t. the specified columns, i.e. the sets of values of the two columns are equal and
#' there are no duplicates in either of them.
#'
#' Finally, `examine_cardinality()` tests for and returns the nature of the relationship (injective, surjective, bijective, or none of these)
#' between the two given columns. If either `pk_column` is not a unique key of `parent_table` or the values of `fk_column` are
#' not a subset of the values in `pk_column`, the requirements for a cardinality test is not fulfilled. No error will be thrown, but
#' the result will contain the information which prerequisite was violated.
#' @param parent_table Data frame.
#' @param pk_column Column or columns of `parent_table`, must be a unique key.
#'   Passed to [tidyselect::eval_select()].
#' @param child_table Data frame.
#' @param fk_column Column or columns of `child_table`, must be a foreign key into `parent_table`.
#'   Passed to [tidyselect::eval_select()].
#'
#' @name examine_cardinality
#'
#' @return For `check_cardinality_?_?()`: Functions return `parent_table`, invisibly, if the check is passed, to support pipes.
#' Otherwise an error is thrown and the reason for it is explained.
#'
#' For `examine_cardinality()`: Returns a character variable specifying the type of relationship between the two columns.
#'
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
check_cardinality_0_n <- function(parent_table, pk_column, child_table, fk_column) {
  pt <- enquo(parent_table)
  ct <- enquo(child_table)

  check_key(!!pt, {{ pk_column }})

  check_subset(!!ct, {{ fk_column }}, !!pt, {{ pk_column }})

  invisible(parent_table)
}

#' @rdname examine_cardinality
#' @export
check_cardinality_1_n <- function(parent_table, pk_column, child_table, fk_column) {
  pt <- enquo(parent_table)
  ct <- enquo(child_table)

  check_key(!!pt, {{ pk_column }})

  check_set_equality(!!ct, {{ fk_column }}, !!pt, {{ pk_column }})

  invisible(parent_table)
}

#' @rdname examine_cardinality
#' @export
check_cardinality_1_1 <- function(parent_table, pk_column, child_table, fk_column) {
  pt <- enquo(parent_table)
  ct <- enquo(child_table)

  check_key(!!pt, {{ pk_column }})

  check_set_equality(!!ct, {{ fk_column }}, !!pt, {{ pk_column }})

  tryCatch(
    {
      check_key(!!ct, {{ fk_column }})
      NULL
    },
    error = function(e) abort_not_bijective(as_label(ct), as_label(enexpr(fk_column)))
  )

  invisible(parent_table)
}

#' @rdname examine_cardinality
#' @export
check_cardinality_0_1 <- function(parent_table, pk_column, child_table, fk_column) {
  pt <- enquo(parent_table)
  ct <- enquo(child_table)

  check_key(!!pt, {{ pk_column }})

  check_subset(!!ct, {{ fk_column }}, !!pt, {{ pk_column }})

  tryCatch(
    {
      check_key(!!ct, {{ fk_column }})
      NULL
    },
    error = function(e) abort_not_injective(as_label(ct), as_label(enexpr(fk_column)))
  )

  invisible(parent_table)
}

#' @rdname examine_cardinality
#' @export
#' @examples
#'
#' # Returns the kind of cardinality
#' examine_cardinality(d1, a, d2, c)
examine_cardinality <- function(parent_table, pk_column, child_table, fk_column) {
  pt <- enquo(parent_table)
  ct <- enquo(child_table)

  if (!is_unique_key(eval_tidy(pt), {{ pk_column }})$unique) {
    return(
      glue(
        "Column(s) {tick(commas(as_label(enexpr(fk_column))))} not ",
        "a unique key of {tick('parent_table')}."
      )
    )
  }

  if (!is_subset(!!ct, {{ fk_column }}, !!pt, {{ pk_column }})) {
    return(
      glue(
        "Column(s) {tick(commas(as_string(fkc)))} of {tick('child_table')} not ",
        "a subset of column(s) {tick(commas(as_string(pkc)))} of {tick('parent_table')}."
      )
    )
  }

  min_1 <- is_subset(!!pt, {{ pk_column }}, !!ct, {{ fk_column }})
  max_1 <- pull(is_unique_key(eval_tidy(ct), {{ fk_column }}), unique)

  if (min_1 && max_1) {
    return("bijective mapping (child: 1 -> parent: 1)")
  } else
  if (min_1) {
    return("surjective mapping (child: 1 to n -> parent: 1)")
  } else
  if (max_1) {
    return("injective mapping (child: 0 or 1 -> parent: 1)")
  }
  "generic mapping (child: 0 to n -> parent: 1)"
}
