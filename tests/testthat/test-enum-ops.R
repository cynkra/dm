# NB. The following changes were made to the snapshotted files:
#
# 1. Calls to `rlang::quo()` have been suppressed, since these calls capture
#    an ephemeral environment that cannot be reproduced across separate test
#    runs.
#
# 2. `cg_block` invocations are excluded, since they belong to a separate and
#    independent testing unit.

test_that("snapshot of code_generation_middleware.R is unchanged", {
  expect_snapshot({
    parent <- tibble(a = c(1L, 1:3), b = -1)
    child <- tibble(a = 1:4, c = 3)

    dm <- dm(parent, child)

    # This is done by the Shiny app
    ops <- enum_ops(dm)
    ops

    enum_ops(dm, op_name = "dm_add_pk")
    enum_ops(dm, op_name = "dm_add_pk", table_names = "parent")

    enum_ops(dm, op_name = "dm_add_pk", table_names = "parent", column_names = "a")$call
  })
})

test_that("snapshot of code_generation_middleware_2.R is unchanged", {
  expect_snapshot({
    parent <- tibble(a = c(1L, 1:3), b = -1)
    child <- tibble(a = 1:4, c = 3)

    dm <- dm(parent, child)

    # This is done by the Shiny app
    ops <- enum_ops(dm)
    ops

    ops$multiple

    # Choice options (the user can choose arbitrarily many):
    user_choice <- list(
      table_names = "parent"
    )

    # Called by the Shiny app, always with the same pattern:
    ops_2 <- exec(
      # Always enum_ops
      enum_ops,
      # Returned by the previous call to enum_ops()
      !!!ops$input,
      # Input selected by the user
      !!!user_choice
    )
    # Same as:
    # ops_2 <- enum_ops(dm = ops$input$dm, table_names = table_names)

    ops_2

    # Choice options (the user can choose only one of those):
    ops_2$single

    # User's choice:
    user_choice_2 <- list(op_name = "dm_add_pk")

    # Called by the Shiny app, always with the same pattern:
    ops_3 <- exec(
      # Always enum_ops
      enum_ops,
      # Returned by the previous call to enum_ops()
      !!!ops_2$input,
      # Input selected by the user
      !!!user_choice_2
    )

    ops_3

    # Choice options (the user can choose arbitrarily many):
    ops_3$multiple

    # User's choice:
    user_choice_3 <- list(column_names = c("a"))

    # Called by the Shiny app, always with the same pattern:
    ops_4 <- exec(
      # Always enum_ops
      enum_ops,
      # Returned by the previous call to enum_ops()
      !!!ops_3$input,
      # Input selected by the user
      !!!user_choice_3
    )

    ops_4

    # Final result:
    ops_4$call
  })
})

test_that("snapshot of code_generation_middleware_3.R is unchanged", {
  expect_snapshot({
    parent <- tibble(a = c(1L, 1:3), b = -1)
    child <- tibble(a = 1:4, c = 3)

    dm <- dm(parent, child)

    # This is done by the Shiny app
    ops <- enum_ops(dm)
    ops

    ops$multiple

    # Choice options (the user can choose arbitrarily many):
    user_choice <- list(
      table_names = "parent"
    )

    # Called by the Shiny app, always with the same pattern:
    ops_2 <- exec(
      # Always enum_ops
      enum_ops,
      # Returned by the previous call to enum_ops()
      !!!ops$input,
      # Input selected by the user
      !!!user_choice
    )
    # Same as:
    # ops_2 <- enum_ops(dm = ops$input$dm, table_names = table_names)

    ops_2

    # Choice options (the user can choose arbitrarily many):
    ops_2$multiple

    # User's choice:
    user_choice_2 <- list(column_names = c("a"))

    # Called by the Shiny app, always with the same pattern:
    ops_3 <- exec(
      # Always enum_ops
      enum_ops,
      # Returned by the previous call to enum_ops()
      !!!ops_2$input,
      # Input selected by the user
      !!!user_choice_2
    )

    ops_3

    # Choice options (the user can choose only one of those):
    ops_3$single

    # User's choice:
    user_choice_3 <- list(op_name = "dm_add_pk")

    # Called by the Shiny app, always with the same pattern:
    ops_4 <- exec(
      # Always enum_ops
      enum_ops,
      # Returned by the previous call to enum_ops()
      !!!ops_3$input,
      # Input selected by the user
      !!!user_choice_3
    )

    ops_4

    # Final result:
    ops_4$call
  })
})

test_that("snapshot of code_generation_middleware_4.R is unchanged", {
  expect_snapshot({
    parent <- tibble(a = c(1L, 1:3), b = -1)
    child <- tibble(a = 1:4, c = 3)

    dm <-
      dm(parent, child) %>%
      dm_add_pk(parent, b)

    # This is done by the Shiny app
    ops <- enum_ops(dm)
    ops

    ops$multiple

    # Choice options (the user can choose arbitrarily many):
    user_choice <- list(
      table_names = "parent"
    )

    # Called by the Shiny app, always with the same pattern:
    ops_2 <- exec(
      # Always enum_ops
      enum_ops,
      # Returned by the previous call to enum_ops()
      !!!ops$input,
      # Input selected by the user
      !!!user_choice
    )
    # Same as:
    # ops_2 <- enum_ops(dm = ops$input$dm, table_names = table_names)

    ops_2

    # Choice options (the user can choose arbitrarily many):
    ops_2$multiple

    # User's choice:
    user_choice_2 <- list(column_names = c("a"))

    # Called by the Shiny app, always with the same pattern:
    ops_3 <- exec(
      # Always enum_ops
      enum_ops,
      # Returned by the previous call to enum_ops()
      !!!ops_2$input,
      # Input selected by the user
      !!!user_choice_2
    )

    ops_3

    # Choice options (the user can choose only one of those):
    ops_3$single

    # User's choice:
    user_choice_3 <- list(op_name = "dm_add_pk")

    # Called by the Shiny app, always with the same pattern:
    ops_4 <- exec(
      # Always enum_ops
      enum_ops,
      # Returned by the previous call to enum_ops()
      !!!ops_3$input,
      # Input selected by the user
      !!!user_choice_3
    )

    ops_4

    # Final result:
    ops_4$call
  })
})
