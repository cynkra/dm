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
#' @param pk_column Column of `parent_table` that has to be one of its unique keys.
#' @param child_table Data frame.
#' @param fk_column Column of `child_table` that has to be a foreign key to `pk_column` in `parent_table`.
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
  pkcq <- enexpr(pk_column)
  pkc <- names(eval_select_indices(pkcq, colnames(eval_tidy(pt))))

  ct <- enquo(child_table)
  fkcq <- enexpr(fk_column)
  fkc <- names(eval_select_indices(fkcq, colnames(eval_tidy(ct))))

  check_key(!!pt, !!pkc)

  check_subset(!!ct, !!fkc, !!pt, !!pkc)

  invisible(parent_table)
}

#' @rdname examine_cardinality
#' @export
check_cardinality_1_n <- function(parent_table, pk_column, child_table, fk_column) {
  pt <- enquo(parent_table)
  pkcq <- enexpr(pk_column)
  pkc <- names(eval_select_indices(pkcq, colnames(eval_tidy(pt))))

  ct <- enquo(child_table)
  fkcq <- enexpr(fk_column)
  fkc <- names(eval_select_indices(fkcq, colnames(eval_tidy(ct))))

  check_key(!!pt, !!pkc)

  check_set_equality(!!ct, !!fkc, !!pt, !!pkc)

  invisible(parent_table)
}

#' @rdname examine_cardinality
#' @export
check_cardinality_1_1 <- function(parent_table, pk_column, child_table, fk_column) {
  pt <- enquo(parent_table)
  pkcq <- enexpr(pk_column)
  pkc <- names(eval_select_indices(pkcq, colnames(eval_tidy(pt))))

  ct <- enquo(child_table)
  fkcq <- enexpr(fk_column)
  fkc <- names(eval_select_indices(fkcq, colnames(eval_tidy(ct))))

  check_key(!!pt, !!pkc)

  check_set_equality(!!ct, !!fkc, !!pt, !!pkc)

  tryCatch(
    {
      check_key(!!ct, !!fkc)
      NULL
    },
    error = function(e) abort_not_bijective(as_label(ct), fkc)
  )

  invisible(parent_table)
}

#' @rdname examine_cardinality
#' @export
check_cardinality_0_1 <- function(parent_table, pk_column, child_table, fk_column) {
  pt <- enquo(parent_table)
  pkcq <- enexpr(pk_column)
  pkc <- names(eval_select_indices(pkcq, colnames(eval_tidy(pt))))

  ct <- enquo(child_table)
  fkcq <- enexpr(fk_column)
  fkc <- names(eval_select_indices(fkcq, colnames(eval_tidy(ct))))

  check_key(!!pt, !!pkc)

  check_subset(!!ct, !!fkc, !!pt, !!pkc)

  tryCatch(
    {
      check_key(!!ct, !!fkc)
      NULL
    },
    error = function(e) abort_not_injective(as_label(ct), fkc)
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
  ptq <- enquo(parent_table)
  pkcq <- enexpr(pk_column)
  pkc <- names(eval_select_indices(pkcq, colnames(eval_tidy(ptq))))

  ctq <- enquo(child_table)
  fkcq <- enexpr(fk_column)
  fkc <- names(eval_select_indices(fkcq, colnames(eval_tidy(ctq))))
  if (!is_unique_key(eval_tidy(ptq), !!pkc)$unique) {
    plural <- if (length(pkc) > 1) {"s"} else {""}
    return(
      glue(
        "Column{plural} ({commas(tick(pkc))}) not ",
        "a unique key of {tick(as_label(ptq))}."
      )
    )
  }

  if (!is_subset(eval_tidy(ctq), !!fkc, eval_tidy(ptq), !!pkc)) {
    plural <- if (length(pkc) > 1) {"s"} else {""}
    return(
      glue(
        "Column{plural} ({commas(tick(fkc))}) of table {tick(as_label(ctq))} not ",
        "a subset of column{plural} ({commas(tick(pkc))}) of table {tick(as_label(ptq))}."
      )
    )
  }

  min_1 <- is_subset(eval_tidy(ptq), !!pkc, eval_tidy(ctq), !!fkc)
  max_1 <- pull(is_unique_key(eval_tidy(ctq), !!fkc), unique)

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
