library(tidyverse)
library(rlang)
devtools::load_all()

parent <- tibble(a = c(1L, 1:3), b = -1)
child <- tibble(a = 1:4, c = 3)

dm <- dm(parent, child)

# This is done by the Shiny app
ops <- enum_ops(dm)
ops

enum_ops(dm, op_name = "dm_add_pk")
enum_ops(dm, op_name = "dm_add_pk", table_name = "parent")

final_ops <- enum_ops(dm, op_name = "dm_add_pk", table_name = "parent", column_names = "a")
final_ops

cg_block <- new_cg_block(quo(dm))

cg_block %>%
  cg_add_call(!!final_ops$call)

cg_block %>%
  cg_add_call(!!final_ops$call) %>%
  cg_eval_block()
