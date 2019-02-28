check_cardinality_0_n <- function(parent_table, primary_key_column, child_table, foreign_key_column) {
  pt <- enquo(parent_table)
  pkc <- enexpr(primary_key_column)
  ct <- enquo(child_table)
  fkc <- enexpr(foreign_key_column)

  check_key(!!pt, !!pkc)

  check_if_subset(!!ct, !!fkc, !!pt, !!pkc)

  invisible(TRUE)
}

check_cardinality_1_n <- function(parent_table, primary_key_column, child_table, foreign_key_column) {
  pt <- enquo(parent_table)
  pkc <- enexpr(primary_key_column)
  ct <- enquo(child_table)
  fkc <- enexpr(foreign_key_column)

  check_key(!!pt, !!pkc)

  check_set_equality(!!ct, !!fkc, !!pt, !!pkc)

  invisible(TRUE)
}

check_cardinality_1_1 <- function(parent_table, primary_key_column, child_table, foreign_key_column) {
  pt <- enquo(parent_table)
  pkc <- enexpr(primary_key_column)
  ct <- enquo(child_table)
  fkc <- enexpr(foreign_key_column)

  check_key(!!pt, !!pkc)

  check_set_equality(!!ct, !!fkc, !!pt, !!pkc)

  n_pt <- pull(count(rlang::eval_tidy(pt)))
  n_ct <- pull(count(rlang::eval_tidy(ct)))

  if (n_ct > n_pt) {
    stop(paste0("1..1 cardinality (bijectivity) is not given: Column `",
                      rlang::as_label(fkc),
                      "` in table `",
                      rlang::as_label(ct),
                      "` contains duplicate values."),
               call. = FALSE)
  }

  invisible(TRUE)
}
