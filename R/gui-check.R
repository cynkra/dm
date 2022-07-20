check_is_character_vec <- function(x, arg = caller_arg(x), call = caller_env()) {
  if (!is_character(x)) {
    cli::cli_abort("{.arg {arg}} must be a character vector.", call = call)
  }
}

check_tbl_in_dm <- function(x,
                            y,
                            arg_x = caller_arg(x),
                            arg_y = caller_arg(y),
                            call = caller_env()) {
  not_in_dm <- setdiff(y, names(x))
  if (length(not_in_dm) != 0) {
    cli::cli_abort("Table {.arg_y {not_in_dm}} is not in {.arg_x {names(x)}}.", call = call)
  }
}

check_at_least_one_col <- function(cols, call = current_call()) {
  if (length(cols) < 1) {
    abort("Hey, you should select at least one column!", call = call)
  }
}
