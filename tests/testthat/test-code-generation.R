test_that("code generation works", {
  expect_identical(
    new_cg_block(),
    structure(list(cg_input_object = list(), cg_f_list = list()), class = "cg_code_block")
  )

  expect_snapshot({
    call_to_char(body(function(.) dm_add_tbl(., weather)))
    call_to_char(expr(dm_add_tbl(., weather, airports, flights, airlines, planes, mtcars, penguins)))
    new_cg_block()
    new_cg_block(quo(dm_nycflights13()), list(function(.) dm_add_pk(., flights, flight_id)))
    table <- "flights"
    columns <- "carrier"
    cg_block <- new_cg_block(quo(dm_nycflights13())) %>%
      cg_add_call(dm_rm_fk(., table = !!ensym(table), columns = !!ensym(columns), ref_table = airlines)) %>%
      cg_add_call(dm_rm_fk(., table = flights, columns = c(origin, time_hour), ref_table = weather)) %>%
      cg_add_call(dm_add_fk(., table = !!ensym(table), columns = !!ensym(columns), ref_table = airlines))
    cg_block
    cg_eval_block(cg_block)
    cg_block_2 <- new_cg_block(
      cg_block$cg_input_object,
      list(
        function(.) dm_add_tbl(., mtcars),
        function(.) dm_select_tbl(., -planes)
      )
    )
    cg_block_2
    cg_eval_block(cg_block_2)
  })

  expect_snapshot({
    format(new_cg_block(quo(dm_nycflights13()), list(function(.) dm_add_pk(., flights, flight_id))))
  })
})
