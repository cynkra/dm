# Create a snapshot of the code and of the resulting dm object
# This requires a certain of the code.
expect_mw_cg_snapshot <- function(...) {
  testthat::expect_snapshot(...)
  quo <- enquos(...)[[1]]
  out <- eval_tidy(quo)

  expr <- quo_get_expr(quo)
  if (!identical(expr[[1]], quote(`{`)) || length(expr) != 2) {
    result <- glue::as_glue("expect_mw_cg_snapshot(): check structure of your code block")
    testthat::expect_snapshot(result)
    return()
  }

  dm_expr <- expr[[2]][[2]]

  dm <- eval_tidy(dm_expr, env = quo_get_env(quo))

  result <-
    new_cg_block(dm) %>%
    cg_add_call(!!out$call) %>%
    cg_eval_block()

  testthat::expect_snapshot(result)
}
