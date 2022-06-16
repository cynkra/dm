# code generation works

    Code
      call_to_char(body(function(.) dm_add_tbl(., weather)))
    Output
      [1] "dm_add_tbl(., weather)"
    Code
      call_to_char(expr(dm_add_tbl(., weather, airports, flights, airlines, planes,
        mtcars, penguins)))
    Output
      [1] "dm_add_tbl(., weather, airports, flights, airlines, planes, mtcars, penguins)"
    Code
      dm_f_list()
      dm_f_list(list(function(.) dm_add_pk(., flights, flight_id)))
    Output
      Called from: show_dm_f_list(x)
      debug at /Users/tobias/git/cynkra/dm/R/code-generation.R#21: purrr::map_chr(x, ~body(.) %>% call_to_char()) %>% paste0("  ", 
          ., collapse = " %>%\n") %>% cat()
        dm_add_pk(., flights, flight_id)debug at /Users/tobias/git/cynkra/dm/R/code-generation.R#24: invisible(x)
    Code
      dm_f_list(list(function(.) dm_add_pk(., flights, flight_id), function(.)
        dm_add_fk(., planes, flight_id, flights)))
    Output
      Called from: show_dm_f_list(x)
      debug at /Users/tobias/git/cynkra/dm/R/code-generation.R#21: purrr::map_chr(x, ~body(.) %>% call_to_char()) %>% paste0("  ", 
          ., collapse = " %>%\n") %>% cat()
        dm_add_pk(., flights, flight_id) %>%
        dm_add_fk(., planes, flight_id, flights)debug at /Users/tobias/git/cynkra/dm/R/code-generation.R#24: invisible(x)
    Code
      table <- "flights"
      columns <- "carrier"
      dm_f_list <- add_call(dm_f_list(), dm_rm_fk(., table = !!ensym(table), columns = !
      !ensym(columns), ref_table = airlines)) %>% add_call(dm_rm_fk(., table = flights,
        columns = c(origin, time_hour), ref_table = weather)) %>% add_call(dm_add_fk(
        ., table = !!ensym(table), columns = !!ensym(columns), ref_table = airlines))
      dm_f_list
    Output
      Called from: show_dm_f_list(x)
      debug at /Users/tobias/git/cynkra/dm/R/code-generation.R#21: purrr::map_chr(x, ~body(.) %>% call_to_char()) %>% paste0("  ", 
          ., collapse = " %>%\n") %>% cat()
        dm_rm_fk(., table = flights, columns = carrier, ref_table = airlines) %>%
        dm_rm_fk(., table = flights, columns = c(origin, time_hour), ref_table = weather) %>%
        dm_add_fk(., table = flights, columns = carrier, ref_table = airlines)debug at /Users/tobias/git/cynkra/dm/R/code-generation.R#24: invisible(x)
    Code
      freduce(dm_nycflights13(), dm_f_list) %>% dm_get_all_fks()
    Output
      # A tibble: 3 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 flights     carrier       airlines     carrier         no_action
      2 flights     origin        airports     faa             no_action
      3 flights     tailnum       planes       tailnum         no_action

