#' Check table relations
#'
#' @description All `check_cardinality_*()` functions test the following conditions:
#' 1. Is `pk_column` a unique key for `parent_table`?
#' 1. Is the set of values in `fk_column` of `child_table` a subset of the set of values of `pk_column`?
#' 1. Does the relation between the two tables of the data model meet the cardinality requirements?
#'
#' `examine_cardinality()` also checks the first two points and subsequently determines the type of cardinality.
#'
#' @details All cardinality-functions accept a `parent_table` (data frame), column names of this table,
#' a `child_table`, and column names of the child table.
#' The given columns of the `parent_table` have to be one of its
#' unique keys (no duplicates are allowed).
#' Furthermore, in all cases, the set of combinations of the child table's columns have
#' to be a subset of the combinations of values of the parent table's columns.
#'
#' The cardinality specifications "0_n", "1_n", "0_1", "1_1" refer to the expected relation that the child table has with the parent table.
#' "0", "1" and "n" refer to the occurrences of value combinations
#' in the columns of the child table that correspond to each combination in the
#' columns of the parent table.
#' "n" means "more than one" in this context, with no upper limit.
#'
#' **"0_n"**: each combination of `pk_column` values has at least 0 and at most
#' n corresponding occurrences in the columns of the child table
#' (which translates to no further restrictions).
#'
#' **"1_n"**: each combination of `pk_column` values has at least 1 and at most
#' n corresponding occurrences in the columns of the child table.
#' This means that there is a "surjective" mapping from the child table
#' to the parent table w.r.t. the specified columns, i.e. each combination in the
#' parent table columns exists at least once in the child table columns.
#'
#' **"0_1"**: each combination of `pk_column` values has at least 0 and at most
#' 1 corresponding occurrence in the column of the child table.
#' This means that there is a "injective" mapping from the child table
#' to the parent table w.r.t. the specified columns, i.e. no combination of values in the
#' parent table columns is addressed multiple times.
#' But not all of the parent table column values have to be referred to.
#'
#' **"1_1"**: each combination of `pk_column` values occurs exactly once
#' in the corresponding columns of the child table.
#' This means that there is a "bijective" ("injective" AND "surjective") mapping
#' between the child table and the parent table w.r.t. the specified columns, i.e. the
#' respective sets of combinations within the two sets of columns are equal and there
#' are no duplicates in either of them.
#'
#' Finally, `examine_cardinality()` tests for and returns the nature of the relationship (injective, surjective, bijective, or none of these)
#' between the two given sets of columns. If either `pk_column` is not a unique key of `parent_table` or the values of `fk_column` are
#' not a subset of the values in `pk_column`, the requirements for a cardinality test is not fulfilled. No error will be thrown, but
#' the result will contain the information which prerequisite was violated.
#' @param parent_table Data frame.
#' @param pk_column Columns of `parent_table` that have to be one of its unique keys, for multiple columns use `c(col1, col2)`.
#' @param child_table Data frame.
#' @param fk_column Columns of `child_table` that have to be a foreign key candidate to `pk_column` in `parent_table`, for multiple columns use `c(col1, col2)`.
#'
#' @family cardinality functions
#'
#' @name examine_cardinality
#'
#' @return For `check_cardinality_*()`: Functions return `parent_table`, invisibly, if the check is passed, to support pipes.
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

  examine_cardinality_impl(eval_tidy(ptq), pkc, eval_tidy(ctq), fkc, as_label(ptq), as_label(ctq))
}

examine_cardinality_impl <- function(parent_table, parent_key_cols, child_table, child_fk_cols, pt_name, ct_name) {
  if (!is_unique_key(parent_table, !!parent_key_cols)$unique) {
    plural <- s_if_plural(parent_key_cols)
    return(
      glue(
        "Column{plural['n']} ({commas(tick(parent_key_cols))}) not ",
        "a unique key of {tick(pt_name)}."
      )
    )
  }
  if (!is_subset(child_table, !!child_fk_cols, parent_table, !!parent_key_cols)) {
    plural <- s_if_plural(parent_key_cols)
    return(
      glue(
        "Column{plural['n']} ({commas(tick(child_fk_cols))}) of table {tick(ct_name)} not ",
        "a subset of column{plural['n']} ({commas(tick(parent_key_cols))}) of table {tick(pt_name)}."
      )
    )
  }
  min_1 <- is_subset(parent_table, !!parent_key_cols, child_table, !!child_fk_cols)
  max_1 <- pull(is_unique_key(child_table, !!child_fk_cols), unique)

  if (min_1 && max_1) {
    return("bijective mapping (child: 1 -> parent: 1)")
  } else if (min_1) {
    return("surjective mapping (child: 1 to n -> parent: 1)")
  } else if (max_1) {
    return("injective mapping (child: 0 or 1 -> parent: 1)")
  }
  "generic mapping (child: 0 to n -> parent: 1)"
}
