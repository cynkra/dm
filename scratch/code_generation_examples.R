library(tidyverse)
devtools::load_all()

# using expr --------------------------------------------------------------

# using an input object provided by user:
inp_obj <- expr(dm_nycflights13())
cg_block <- new_cg_block(cg_input_object = inp_obj)

# visualisation of object:
dm_draw(cg_eval_block(cg_block))

# Code Output in Shiny App:
cg_block

# user hits add table mtcars:
cg_block <- cg_block %>%
  cg_add_call(dm_add_tbl(., mtcars))

# visualisation of object:
dm_draw(cg_eval_block(cg_block))

# Code Output in Shiny App:
cg_block

# user adds a primary key for table mtcars:
cg_block <- cg_block %>%
  cg_add_call(dm_add_pk(., mtcars, c(mpg, wt)))

# visualisation of object:
dm_draw(cg_eval_block(cg_block))

# Code Output in Shiny App:
cg_block

# user hits undo last action: FIXME: probably need a function for this
cg_block$cg_f_list <- cg_block$cg_f_list[-length(cg_block$cg_f_list)]

# visualisation of object:
dm_draw(cg_eval_block(cg_block))

# Code Output in Shiny App:
cg_block


# for quosure -------------------------------------------------------------

# need to redefine evaluation function:
# Actually this implementation also works for the above scenario
cg_eval_block <- function(cg_block) {
  if (is_empty(cg_block$cg_f_list)) {
    eval_tidy(cg_block$cg_input_object)
  } else {
    freduce(eval_tidy(cg_block$cg_input_object), cg_block$cg_f_list)
  }
}

# would need to tweak `show_cg_input_object()` to avoid "`"; normally called by print.cg_code_block():

# using an input object provided by user:
inp_obj <- quo(dm_nycflights13())
cg_block <- new_cg_block(cg_input_object = inp_obj)

# visualisation of object:
dm_draw(cg_eval_block(cg_block))

# Code Output in Shiny App:
cg_block

# user hits add table mtcars:
cg_block <- cg_block %>%
  cg_add_call(dm_add_tbl(., mtcars))

# visualisation of object:
dm_draw(cg_eval_block(cg_block))

# Code Output in Shiny App:
cg_block

# user adds a primary key for table mtcars:
cg_block <- cg_block %>%
  cg_add_call(dm_add_pk(., mtcars, c(mpg, wt)))

# visualisation of object:
dm_draw(cg_eval_block(cg_block))

# Code Output in Shiny App:
cg_block

# user hits undo last action: FIXME: probably need a function for this
cg_block$cg_f_list <- cg_block$cg_f_list[-length(cg_block$cg_f_list)]

# visualisation of object:
dm_draw(cg_eval_block(cg_block))

# Code Output in Shiny App:
cg_block

