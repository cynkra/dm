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
    Code
      new_cg_block()
      new_cg_block(quo(dm_nycflights13()), list(function(.) dm_add_pk(., flights,
        flight_id)))
    Output
      dm_nycflights13() %>%
        dm_add_pk(flights, flight_id)
    Code
      table <- "flights"
      columns <- "carrier"
      cg_block <- new_cg_block(quo(dm_nycflights13())) %>% cg_add_call(dm_rm_fk(.,
        table = !!ensym(table), columns = !!ensym(columns), ref_table = airlines)) %>%
        cg_add_call(dm_rm_fk(., table = flights, columns = c(origin, time_hour),
        ref_table = weather)) %>% cg_add_call(dm_add_fk(., table = !!ensym(table),
      columns = !!ensym(columns), ref_table = airlines))
      cg_block
    Output
      dm_nycflights13() %>%
        dm_rm_fk(table = flights, columns = carrier, ref_table = airlines) %>%
        dm_rm_fk(table = flights, columns = c(origin, time_hour), ref_table = weather) %>%
        dm_add_fk(table = flights, columns = carrier, ref_table = airlines)
    Code
      cg_eval_block(cg_block)
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 53
      Primary keys: 4
      Foreign keys: 3
    Code
      cg_block_2 <- new_cg_block(cg_block$cg_input_object, list(function(.)
        dm_add_tbl(., mtcars), function(.) dm_select_tbl(., -planes)))
      cg_block_2
    Output
      dm_nycflights13() %>%
        dm_add_tbl(mtcars) %>%
        dm_select_tbl(-planes)
    Code
      cg_eval_block(cg_block_2)
    Condition
      Warning:
      `dm_add_tbl()` was deprecated in dm 1.0.0.
      i Please use `dm()` instead.
      i Use `.name_repair = "unique"` if necessary.
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `weather`, `mtcars`
      Columns: 55
      Primary keys: 3
      Foreign keys: 3

---

    Code
      format(new_cg_block(quo(dm_nycflights13()), list(function(.) dm_add_pk(.,
        flights, flight_id))))
    Output
      [1] "dm_nycflights13() %>%"           "  dm_add_pk(flights, flight_id)"

