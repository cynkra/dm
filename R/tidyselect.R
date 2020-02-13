eval_select_table <- function(quo, table_names) {
  indexes <- eval_select_table_indices(quo, table_names)
  set_names(table_names[indexes], names(indexes))
}

eval_rename_table_all <- function(quo, table_names) {
  indexes <- eval_rename_table_indices(quo, table_names)
  names <- table_names
  names[indexes] <- names(indexes)
  set_names(table_names, names)
}

eval_select_table_indices <- function(quo, table_names) {
  tryCatch(
    eval_select_indices(quo, table_names),
    vctrs_error_subscript = function(cnd) {
      # https://github.com/r-lib/vctrs/issues/786
      cnd$subscript_elt <- "element"
      cnd_signal(cnd)
    }
  )
}

eval_rename_table_indices <- function(quo, table_names) {
  tryCatch(
    eval_rename_indices(quo, table_names),
    vctrs_error_subscript = function(cnd) {
      # https://github.com/r-lib/vctrs/issues/786
      cnd$subscript_elt <- "element"
      cnd_signal(cnd)
    }
  )
}

eval_select_both <- function(quo, names) {
  indices <- eval_select_indices(quo, names)
  names <- set_names(names[indices], names(indices))
  list(indices = indices, names = names)
}

eval_select_indices <- function(quo, names) {
  tidyselect::eval_select(quo, set_names(names))
}

eval_rename_both <- function(quo, names) {
  indices <- eval_rename_indices(quo, names)
  all_names <- set_names(names)
  names(all_names)[indices] <- names(indices)
  list(indices = indices, all_names = all_names)
}

eval_rename_indices <- function(quo, names) {
  tidyselect::eval_rename(quo, set_names(names))
}
