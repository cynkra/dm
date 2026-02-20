eval_select_table <- function(quo, table_names, unique = TRUE, error_call = caller_env()) {
  indexes <- eval_select_table_indices(quo, table_names, unique = unique, error_call = error_call)
  set_names(table_names[indexes], names(indexes))
}

eval_rename_table_all <- function(quo, table_names) {
  indexes <- eval_rename_table_indices(quo, table_names)
  names <- table_names
  names[indexes] <- names(indexes)
  set_names(table_names, names)
}

eval_select_table_indices <- function(quo, table_names, unique = TRUE, error_call = caller_env()) {
  withCallingHandlers(
    eval_select_indices(quo, table_names, unique = unique, error_call = error_call),
    vctrs_error_subscript = function(cnd) {
      cnd$subscript_elt <- "table"
      cnd_signal(cnd)
    }
  )
}

eval_rename_table_indices <- function(quo, table_names) {
  withCallingHandlers(
    eval_rename_indices(quo, table_names),
    vctrs_error_subscript = function(cnd) {
      cnd$subscript_elt <- "table"
      cnd_signal(cnd)
    }
  )
}

eval_select_both <- function(quo, names, error_call = caller_env()) {
  indices <- eval_select_indices(quo, names, error_call = error_call)
  names <- set_names(names[indices], names(indices))
  list(indices = indices, names = names)
}

eval_select_indices <- function(quo, names, unique = TRUE, error_call = caller_env()) {
  pos <- tidyselect::eval_select(quo, set_names(names), error_call = error_call)

  if (unique) {
    # Called for side effects.
    # Normally done by tidyselect if the `data` argument
    # to eval_select() is a data frame.
    vec_as_names(names(pos), repair = "check_unique", call = error_call)
  }

  pos
}

eval_rename_both <- function(quo, names) {
  indices <- eval_rename_indices(quo, names)
  all_names <- set_names(names)
  names(all_names)[indices] <- names(indices)
  list(indices = indices, all_names = all_names)
}

eval_rename_indices <- function(quo, names) {
  pos <- tidyselect::eval_rename(quo, set_names(names))

  # Called for side effects.
  # Normally done by tidyselect if the `data` argument
  # to eval_rename() is a data frame.
  vec_as_names(names(pos), repair = "check_unique")

  pos
}
