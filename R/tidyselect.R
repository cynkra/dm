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

  table_names[indexes]
}
