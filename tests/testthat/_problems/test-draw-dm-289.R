# Extracted from test-draw-dm.R:289

# setup ------------------------------------------------------------------------
library(testthat)
test_env <- simulate_test_env(package = "dm", path = "..")
attach(test_env, warn.conflicts = FALSE)

# test -------------------------------------------------------------------------
skip_if_not_installed("DiagrammeR")
expect_snapshot({
    dm_nycflights13() |>
      dm_draw(graph_attrs = "rankdir=LR") |>
      invisible()
  })
