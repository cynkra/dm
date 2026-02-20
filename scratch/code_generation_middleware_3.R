library(tidyverse)
library(rlang)
devtools::load_all()

parent <- tibble(a = c(1L, 1:3), b = -1)
child <- tibble(a = 1:4, c = 3)

dm <- dm(parent, child)

# This is done by the Shiny app
ops <- enum_ops(quo(dm))
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

cg_block <- new_cg_block(ops_4$input$dm)

cg_block %>%
  cg_add_call(!!ops_4$call)

cg_block %>%
  cg_add_call(!!ops_4$call) %>%
  cg_eval_block()
