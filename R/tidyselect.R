quo_select_table <- function(quo, table_names) {
  names(table_names) <- table_names

  indexes <- tryCatch(
    tidyselect::eval_select(quo, table_names),
    vctrs_error_subscript = function(cnd) {
      # https://github.com/r-lib/vctrs/issues/786
      cnd$subscript_elt <- "element"
      cnd_signal(cnd)
    }
  )

  set_names(table_names[indexes], names(indexes))
}

quo_rename_table <- function(quo, table_names) {
  names(table_names) <- table_names
  indexes <- tryCatch(
    tidyselect::eval_rename(quo, table_names),
    vctrs_error_subscript = function(cnd) {
      # https://github.com/r-lib/vctrs/issues/786
      cnd$subscript_elt <- "element"
      cnd_signal(cnd)
    }
  )

  names <- names(table_names)
  names[indexes] <- names(indexes)

  set_names(table_names, names)
}
