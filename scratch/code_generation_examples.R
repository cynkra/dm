library(tidyverse)
devtools::load_all()

# using an input object provided by user:
inp_obj <- quo(dm_nycflights13())
cg_block <- new_cg_block(cg_input_object = inp_obj)

# evaluation of object:
cg_block %>%
  cg_eval_block()

# visualisation of object:
cg_block %>%
  cg_eval_block() %>%
  dm_draw()

# Code Output in Shiny App:
cg_block

# user hits add table mtcars:
cg_block_2 <-
  cg_block %>%
  cg_add_call(dm_add_tbl(., mtcars))

# evaluation of object:
cg_block_2 %>%
  cg_eval_block()

# visualisation of object:
cg_block_2 %>%
  cg_eval_block() %>%
  dm_draw()

# Code Output in Shiny App:
cg_block_2

# user adds a primary key for table mtcars:
cg_block_3 <-
  cg_block_2 %>%
  cg_add_call(dm_add_pk(., mtcars, c(mpg, wt)))

# evaluation of object:
cg_block_3 %>%
  cg_eval_block()

# visualisation of object:
cg_block_3 %>%
  cg_eval_block() %>%
  dm_draw()

# Code Output in Shiny App:
cg_block_3

# user hits undo last action: FIXME: probably need a function for this
cg_block_4 <- cg_block_3
cg_block_4$cg_f_list <- cg_block_4$cg_f_list[-length(cg_block_4$cg_f_list)]

# visualisation of object:
cg_block_4 %>%
  cg_eval_block() %>%
  dm_draw()

# Code Output in Shiny App:
cg_block_4
