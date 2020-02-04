quo_select_table <- function(quo, table_names) {
  indexes <- tryCatch(
    eval_tidy(quo(tidyselect::vars_select(table_names, !!quo))),
    vctrs_error_subscript = function(cnd) {
      # https://github.com/r-lib/vctrs/issues/786
      cnd$subscript_elt <- "element"
      cnd_signal(cnd)
    }
  )

  indexes
}
