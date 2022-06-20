library(tidyverse)
devtools::load_all()

# using expr --------------------------------------------------------------

# using an input object provided by user:
inp_obj <- expr(dm_nycflights13())
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


# for quosure -------------------------------------------------------------

# need to redefine evaluation function:
# Actually this implementation also works for the above scenario
cg_eval_block_quo <- function(cg_block) {
  if (is_empty(cg_block$cg_f_list)) {
    # freduce(1, list()) gives an error, bug in purrr?
    eval_tidy(cg_block$cg_input_object)
  } else {
    freduce(eval_tidy(cg_block$cg_input_object), cg_block$cg_f_list)
  }
}

# would need to tweak `show_cg_input_object()` to avoid "`"; normally called by print.cg_code_block():

# using an input object provided by user:
inp_obj <- quo(dm_nycflights13())
cg_block_5 <- new_cg_block(cg_input_object = inp_obj)

# visualisation of object:
cg_block_5 %>%
  cg_eval_block_quo() %>%
  dm_draw()

# Code Output in Shiny App:
cg_block_5

# user hits add table mtcars:
cg_block_6 <-
  cg_block_5 %>%
  cg_add_call(dm_add_tbl(., mtcars))

# visualisation of object:
cg_block_6 %>%
  cg_eval_block_quo() %>%
  dm_draw()

# Code Output in Shiny App:
cg_block_6

# user adds a primary key for table mtcars:
cg_block_7 <-
  cg_block_6 %>%
  cg_add_call(dm_add_pk(., mtcars, c(mpg, wt)))

# visualisation of object:
cg_block_7 %>%
  cg_eval_block_quo() %>%
  dm_draw()

# Code Output in Shiny App:
cg_block

# user hits undo last action: FIXME: probably need a function for this
cg_block_8 <- cg_block_7
cg_block_8$cg_f_list <- cg_block_8$cg_f_list[-length(cg_block_8$cg_f_list)]

# visualisation of object:
cg_block_8 %>%
  cg_eval_block_quo() %>%
  dm_draw()

# Code Output in Shiny App:
cg_block_8
