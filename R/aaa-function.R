nse_function <- function(args, body, env = caller_env()) {
  args_quo <- enquo(args)
  args_expr <- quo_get_expr(args_quo)

  stopifnot(identical(args_expr[[1]], quote(c)))

  args <- as.list(args_expr)[-1]

  unnamed <- (names2(args) == "")
  names(args)[unnamed] <- vapply(args[unnamed], as.character, character(1))
  args[unnamed] <- list(missing_arg())

  body <- f_rhs(body)

  new_function(args, body, env)
}
