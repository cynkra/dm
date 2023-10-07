# code generation works

    Code
      call_to_char(body(function(.) dm_add_tbl(., weather)))
    Output
      [1] "dm_add_tbl(weather)"
    Code
      call_to_char(expr(dm_add_tbl(., weather, airports, flights, airlines, planes,
        mtcars, penguins)))
    Output
      [1] "dm_add_tbl(weather, airports, flights, airlines, planes, mtcars, penguins)"

---

    Code
      new_cg_block()
      new_cg_block(quo(dm_nycflights13()), list(function(.) dm_add_pk(., flights,
        flight_id)))
    Output
      dm_nycflights13() %>%
        dm_add_pk(flights, flight_id)

---

    Code
      format(new_cg_block(quo(dm_nycflights13()), list(function(.) dm_add_pk(.,
        flights, flight_id))))
    Output
      [1] "dm_nycflights13() %>%"           "  dm_add_pk(flights, flight_id)"

