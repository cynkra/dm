# code generation works

    Code
      format(new_cg_block(quo(dm_nycflights13()), list(function(.) dm_add_pk(.,
        flights, flight_id))))
    Output
      [1] "dm_nycflights13() %>%"           "  dm_add_pk(flights, flight_id)"

