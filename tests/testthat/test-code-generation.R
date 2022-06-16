test_that("code generation works", {
  expect_identical(
    dm_f_list(),
    structure(list(), class = c("dm_f_list", "list"))
  )

  expect_snapshot({
    call_to_char(body(function(.) dm_add_tbl(., weather)))
    call_to_char(expr(dm_add_tbl(., weather, airports, flights, airlines, planes, mtcars, penguins)))
    dm_f_list()
    dm_f_list(list(function(.) dm_add_pk(., flights, flight_id)))
    dm_f_list(list(
      function(.) dm_add_pk(., flights, flight_id),
      function(.) dm_add_fk(., planes, flight_id, flights)
    ))
    table <- "flights"
    columns <- "carrier"
    dm_f_list <- add_call(dm_f_list(), dm_rm_fk(., table = !!ensym(table), columns = !!ensym(columns), ref_table = airlines)) %>%
      add_call(dm_rm_fk(., table = flights, columns = c(origin, time_hour), ref_table = weather)) %>%
      add_call(dm_add_fk(., table = !!ensym(table), columns = !!ensym(columns), ref_table = airlines))
    dm_f_list
    freduce(dm_nycflights13(), dm_f_list) %>%
      dm_get_all_fks()
  })
})
