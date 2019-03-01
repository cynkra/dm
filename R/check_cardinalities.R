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

  tryCatch({
    check_key(!!ct, !!fkc)
    NULL},
    error = stop(paste0("1..1 cardinality (bijectivity) is not given: Column `",
                     as_label(fkc),
                     "` in table `",
                     as_label(ct),
                     "` contains duplicate values."),
                 call. = FALSE)
  )


  invisible(TRUE)
}


check_cardinality_0_1 <- function(parent_table, primary_key_column, child_table, foreign_key_column) {
  pt <- enquo(parent_table)
  pkc <- enexpr(primary_key_column)
  ct <- enquo(child_table)
  fkc <- enexpr(foreign_key_column)

  check_key(!!pt, !!pkc)

  check_if_subset(!!ct, !!fkc, !!pt, !!pkc)

  tryCatch({
    check_key(!!ct, !!fkc)
    NULL},
    error = stop(paste0("0..1 cardinality (injectivity from child table to parent table) is not given: Column `",
                        as_label(fkc),
                        "` in table `",
                        as_label(ct),
                        "` contains duplicate values."),
                 call. = FALSE)
  )

  invisible(TRUE)
}
