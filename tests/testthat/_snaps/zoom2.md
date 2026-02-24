# zoom2 output for compound keys

    Code
      nyc_comp() %>% dm_zoom2_to(weather)
    Output
      # A tibble: 144 x 15
      # Keys:     `origin`, `time_hour` | 1 | 0
         origin  year month   day  hour  temp  dewp humid wind_dir wind_speed
         <chr>  <int> <int> <int> <int> <dbl> <dbl> <dbl>    <dbl>      <dbl>
       1 EWR     2013     1    10     0  41    32    70.1      230       8.06
       2 EWR     2013     1    10     1  39.0  30.0  69.9      210       9.21
       3 EWR     2013     1    10     2  39.0  28.9  66.8      230       6.90
       4 EWR     2013     1    10     3  39.9  27.0  59.5      270       5.75
       5 EWR     2013     1    10     4  41    26.1  55.0      320       6.90
       6 EWR     2013     1    10     5  41    26.1  55.0      300      12.7 
       7 EWR     2013     1    10     6  39.9  25.0  54.8      280       6.90
       8 EWR     2013     1    10     7  41    25.0  52.6      330       6.90
       9 EWR     2013     1    10     8  43.0  25.0  48.7      330       8.06
      10 EWR     2013     1    10     9  45.0  23    41.6      320      17.3 
      # i 134 more rows
      # i 5 more variables: wind_gust <dbl>, precip <dbl>, pressure <dbl>,
      #   visib <dbl>, time_hour <chr>
    Code
      nyc_comp() %>% dm_zoom2_to(weather) %>% dm_update_zoom2ed()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 53
      Primary keys: 4
      Foreign keys: 4
    Code
      nyc_comp_2 <- nyc_comp() %>% dm_zoom2_to(weather) %>% dm_insert_zoom2ed(
        "weather_2")
      nyc_comp_2 %>% get_all_keys()
    Output
      $pks
      # A tibble: 5 x 3
        table     pk_col            autoincrement
        <chr>     <keys>            <lgl>        
      1 airlines  carrier           FALSE        
      2 airports  faa               FALSE        
      3 planes    tailnum           FALSE        
      4 weather   origin, time_hour FALSE        
      5 weather_2 origin, time_hour FALSE        
      
      $fks
      # A tibble: 5 x 5
        child_table child_fk_cols     parent_table parent_key_cols   on_delete
        <chr>       <keys>            <chr>        <keys>            <chr>    
      1 flights     carrier           airlines     carrier           no_action
      2 flights     dest              airports     faa               no_action
      3 flights     tailnum           planes       tailnum           no_action
      4 flights     origin, time_hour weather      origin, time_hour no_action
      5 flights     origin, time_hour weather_2    origin, time_hour no_action
      
    Code
      nyc_comp_3 <- nyc_comp() %>% dm_zoom2_to(flights) %>% dm_insert_zoom2ed(
        "flights_2")
      nyc_comp_3 %>% get_all_keys()
    Output
      $pks
      # A tibble: 4 x 3
        table    pk_col            autoincrement
        <chr>    <keys>            <lgl>        
      1 airlines carrier           FALSE        
      2 airports faa               FALSE        
      3 planes   tailnum           FALSE        
      4 weather  origin, time_hour FALSE        
      
      $fks
      # A tibble: 8 x 5
        child_table child_fk_cols     parent_table parent_key_cols   on_delete
        <chr>       <keys>            <chr>        <keys>            <chr>    
      1 flights     carrier           airlines     carrier           no_action
      2 flights_2   carrier           airlines     carrier           no_action
      3 flights     dest              airports     faa               no_action
      4 flights_2   dest              airports     faa               no_action
      5 flights     tailnum           planes       tailnum           no_action
      6 flights_2   tailnum           planes       tailnum           no_action
      7 flights     origin, time_hour weather      origin, time_hour no_action
      8 flights_2   origin, time_hour weather      origin, time_hour no_action
      

# zoom2 select() on parent table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(parent) %>% select(id) %>% dm_update_zoom2ed() %>% dm_paste(
        options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 select() on child table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(child) %>% select(child_id, val) %>% dm_update_zoom2ed() %>%
        dm_paste(options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        val = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id)

# zoom2 rename() on parent table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(parent) %>% rename(parent_id = id) %>% dm_update_zoom2ed() %>%
        dm_paste(options = "all")
    Message
      parent <- tibble::tibble(
        parent_id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(child, child_id)

# zoom2 rename() on child table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(child) %>% rename(cid = child_id, pid = parent_id) %>%
        dm_update_zoom2ed() %>% dm_paste(options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        cid = integer(0),
        pid = integer(0),
        val = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id)

# zoom2 summarise() on parent table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(parent) %>% summarise(n = n()) %>% dm_update_zoom2ed() %>%
        dm_paste(options = "all")
    Message
      parent <- tibble::tibble(
        n = integer(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(child, child_id)

# zoom2 summarise() on child table with group_by

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(child) %>% group_by(parent_id) %>% summarise(n = n()) %>%
        dm_update_zoom2ed() %>% dm_paste(options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        parent_id = integer(0),
        n = integer(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, parent_id) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 summarise() insert

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(child) %>% group_by(parent_id) %>% summarise(n = n()) %>%
        dm_insert_zoom2ed("child_summary") %>% dm_paste(options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
      )
      child_summary <- tibble::tibble(
        parent_id = integer(0),
        n = integer(0),
      )
      dm::dm(
        parent,
        child,
        child_summary,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_pk(child_summary, parent_id) %>%
        dm::dm_add_fk(child, parent_id, parent) %>%
        dm::dm_add_fk(child_summary, parent_id, parent)

# zoom2 summarise() on child table with .by

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(child) %>% summarise(n = n(), .by = parent_id) %>%
        dm_update_zoom2ed() %>% dm_paste(options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        parent_id = integer(0),
        n = integer(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, parent_id) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 summarise() insert with .by

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(child) %>% summarise(n = n(), .by = parent_id) %>%
        dm_insert_zoom2ed("child_summary") %>% dm_paste(options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
      )
      child_summary <- tibble::tibble(
        parent_id = integer(0),
        n = integer(0),
      )
      dm::dm(
        parent,
        child,
        child_summary,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_pk(child_summary, parent_id) %>%
        dm::dm_add_fk(child, parent_id, parent) %>%
        dm::dm_add_fk(child_summary, parent_id, parent)

# zoom2 reframe() on parent table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(parent) %>% reframe(n = n()) %>% dm_update_zoom2ed() %>% dm_paste(
        options = "all")
    Message
      parent <- tibble::tibble(
        n = integer(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(child, child_id)

# zoom2 reframe() on child table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(child) %>% reframe(n = n(), .by = parent_id) %>%
        dm_update_zoom2ed() %>% dm_paste(options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        parent_id = integer(0),
        n = integer(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 tally() on parent table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(parent) %>% tally() %>% dm_update_zoom2ed() %>% dm_paste(options = "all")
    Message
      parent <- tibble::tibble(
        n = integer(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(child, child_id)

# zoom2 tally() on child table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(child) %>% tally() %>% dm_update_zoom2ed() %>% dm_paste(options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        n = integer(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id)

# zoom2 left_join()

    Code
      d <- dm(grandparent = tibble(gp_id = 1:2, gp_name = c("x", "y")), parent = tibble(
        id = 1:3, gp_id = c(1L, 1L, 2L), name = c("a", "b", "c")), child = tibble(
        child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>%
        dm_add_pk(grandparent, gp_id) %>% dm_add_pk(parent, id) %>% dm_add_pk(child,
        child_id) %>% dm_add_fk(parent, gp_id, grandparent) %>% dm_add_fk(child,
        parent_id, parent)
      d %>% dm_zoom2_to(child) %>% left_join(dm_zoom2_to(d, parent)) %>%
        dm_update_zoom2ed() %>% dm_paste(options = "all")
    Message
      grandparent <- tibble::tibble(
        gp_id = integer(0),
        gp_name = character(0),
      )
      parent <- tibble::tibble(
        id = integer(0),
        gp_id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
        gp_id = integer(0),
        name = character(0),
      )
      dm::dm(
        grandparent,
        parent,
        child,
      ) %>%
        dm::dm_add_pk(grandparent, gp_id) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(parent, gp_id, grandparent) %>%
        dm::dm_add_fk(child, gp_id, grandparent) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 inner_join()

    Code
      d <- dm(grandparent = tibble(gp_id = 1:2, gp_name = c("x", "y")), parent = tibble(
        id = 1:3, gp_id = c(1L, 1L, 2L), name = c("a", "b", "c")), child = tibble(
        child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>%
        dm_add_pk(grandparent, gp_id) %>% dm_add_pk(parent, id) %>% dm_add_pk(child,
        child_id) %>% dm_add_fk(parent, gp_id, grandparent) %>% dm_add_fk(child,
        parent_id, parent)
      d %>% dm_zoom2_to(child) %>% inner_join(dm_zoom2_to(d, parent)) %>%
        dm_update_zoom2ed() %>% dm_paste(options = "all")
    Message
      grandparent <- tibble::tibble(
        gp_id = integer(0),
        gp_name = character(0),
      )
      parent <- tibble::tibble(
        id = integer(0),
        gp_id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
        gp_id = integer(0),
        name = character(0),
      )
      dm::dm(
        grandparent,
        parent,
        child,
      ) %>%
        dm::dm_add_pk(grandparent, gp_id) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(parent, gp_id, grandparent) %>%
        dm::dm_add_fk(child, gp_id, grandparent) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 semi_join()

    Code
      d <- dm(grandparent = tibble(gp_id = 1:2, gp_name = c("x", "y")), parent = tibble(
        id = 1:3, gp_id = c(1L, 1L, 2L), name = c("a", "b", "c")), child = tibble(
        child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>%
        dm_add_pk(grandparent, gp_id) %>% dm_add_pk(parent, id) %>% dm_add_pk(child,
        child_id) %>% dm_add_fk(parent, gp_id, grandparent) %>% dm_add_fk(child,
        parent_id, parent)
      d %>% dm_zoom2_to(child) %>% semi_join(dm_zoom2_to(d, parent)) %>%
        dm_update_zoom2ed() %>% dm_paste(options = "all")
    Message
      grandparent <- tibble::tibble(
        gp_id = integer(0),
        gp_name = character(0),
      )
      parent <- tibble::tibble(
        id = integer(0),
        gp_id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
      )
      dm::dm(
        grandparent,
        parent,
        child,
      ) %>%
        dm::dm_add_pk(grandparent, gp_id) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(parent, gp_id, grandparent) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 anti_join()

    Code
      d <- dm(grandparent = tibble(gp_id = 1:2, gp_name = c("x", "y")), parent = tibble(
        id = 1:3, gp_id = c(1L, 1L, 2L), name = c("a", "b", "c")), child = tibble(
        child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>%
        dm_add_pk(grandparent, gp_id) %>% dm_add_pk(parent, id) %>% dm_add_pk(child,
        child_id) %>% dm_add_fk(parent, gp_id, grandparent) %>% dm_add_fk(child,
        parent_id, parent)
      d %>% dm_zoom2_to(child) %>% anti_join(dm_zoom2_to(d, parent)) %>%
        dm_update_zoom2ed() %>% dm_paste(options = "all")
    Message
      grandparent <- tibble::tibble(
        gp_id = integer(0),
        gp_name = character(0),
      )
      parent <- tibble::tibble(
        id = integer(0),
        gp_id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
      )
      dm::dm(
        grandparent,
        parent,
        child,
      ) %>%
        dm::dm_add_pk(grandparent, gp_id) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(parent, gp_id, grandparent) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 right_join()

    Code
      d <- dm(grandparent = tibble(gp_id = 1:2, gp_name = c("x", "y")), parent = tibble(
        id = 1:3, gp_id = c(1L, 1L, 2L), name = c("a", "b", "c")), child = tibble(
        child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>%
        dm_add_pk(grandparent, gp_id) %>% dm_add_pk(parent, id) %>% dm_add_pk(child,
        child_id) %>% dm_add_fk(parent, gp_id, grandparent) %>% dm_add_fk(child,
        parent_id, parent)
      d %>% dm_zoom2_to(child) %>% right_join(dm_zoom2_to(d, parent)) %>%
        dm_update_zoom2ed() %>% dm_paste(options = "all")
    Message
      grandparent <- tibble::tibble(
        gp_id = integer(0),
        gp_name = character(0),
      )
      parent <- tibble::tibble(
        id = integer(0),
        gp_id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
        gp_id = integer(0),
        name = character(0),
      )
      dm::dm(
        grandparent,
        parent,
        child,
      ) %>%
        dm::dm_add_pk(grandparent, gp_id) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(parent, gp_id, grandparent) %>%
        dm::dm_add_fk(child, gp_id, grandparent) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 full_join()

    Code
      d <- dm(grandparent = tibble(gp_id = 1:2, gp_name = c("x", "y")), parent = tibble(
        id = 1:3, gp_id = c(1L, 1L, 2L), name = c("a", "b", "c")), child = tibble(
        child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>%
        dm_add_pk(grandparent, gp_id) %>% dm_add_pk(parent, id) %>% dm_add_pk(child,
        child_id) %>% dm_add_fk(parent, gp_id, grandparent) %>% dm_add_fk(child,
        parent_id, parent)
      d %>% dm_zoom2_to(child) %>% full_join(dm_zoom2_to(d, parent)) %>%
        dm_update_zoom2ed() %>% dm_paste(options = "all")
    Message
      grandparent <- tibble::tibble(
        gp_id = integer(0),
        gp_name = character(0),
      )
      parent <- tibble::tibble(
        id = integer(0),
        gp_id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
        gp_id = integer(0),
        name = character(0),
      )
      dm::dm(
        grandparent,
        parent,
        child,
      ) %>%
        dm::dm_add_pk(grandparent, gp_id) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(parent, gp_id, grandparent) %>%
        dm::dm_add_fk(child, gp_id, grandparent) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 cross_join()

    Code
      d <- dm(grandparent = tibble(gp_id = 1:2, gp_name = c("x", "y")), parent = tibble(
        id = 1:3, gp_id = c(1L, 1L, 2L), name = c("a", "b", "c")), child = tibble(
        child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>%
        dm_add_pk(grandparent, gp_id) %>% dm_add_pk(parent, id) %>% dm_add_pk(child,
        child_id) %>% dm_add_fk(parent, gp_id, grandparent) %>% dm_add_fk(child,
        parent_id, parent)
      d %>% dm_zoom2_to(child) %>% cross_join(dm_zoom2_to(d, parent)) %>%
        dm_update_zoom2ed() %>% dm_paste(options = "all")
    Message
      grandparent <- tibble::tibble(
        gp_id = integer(0),
        gp_name = character(0),
      )
      parent <- tibble::tibble(
        id = integer(0),
        gp_id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
        id = integer(0),
        gp_id = integer(0),
        name = character(0),
      )
      dm::dm(
        grandparent,
        parent,
        child,
      ) %>%
        dm::dm_add_pk(grandparent, gp_id) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_fk(parent, gp_id, grandparent) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 left_join() insert

    Code
      d <- dm(grandparent = tibble(gp_id = 1:2, gp_name = c("x", "y")), parent = tibble(
        id = 1:3, gp_id = c(1L, 1L, 2L), name = c("a", "b", "c")), child = tibble(
        child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>%
        dm_add_pk(grandparent, gp_id) %>% dm_add_pk(parent, id) %>% dm_add_pk(child,
        child_id) %>% dm_add_fk(parent, gp_id, grandparent) %>% dm_add_fk(child,
        parent_id, parent)
      d %>% dm_zoom2_to(child) %>% left_join(dm_zoom2_to(d, parent)) %>%
        dm_insert_zoom2ed("child_parent") %>% dm_paste(options = "all")
    Message
      grandparent <- tibble::tibble(
        gp_id = integer(0),
        gp_name = character(0),
      )
      parent <- tibble::tibble(
        id = integer(0),
        gp_id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
      )
      child_parent <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
        gp_id = integer(0),
        name = character(0),
      )
      dm::dm(
        grandparent,
        parent,
        child,
        child_parent,
      ) %>%
        dm::dm_add_pk(grandparent, gp_id) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_pk(child_parent, child_id) %>%
        dm::dm_add_fk(parent, gp_id, grandparent) %>%
        dm::dm_add_fk(child_parent, gp_id, grandparent) %>%
        dm::dm_add_fk(child, parent_id, parent) %>%
        dm::dm_add_fk(child_parent, parent_id, parent) %>%
        dm::dm_add_fk(child, parent_id, child_parent, parent_id)

# zoom2 filter() on parent table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(parent) %>% filter(id > 1) %>% dm_update_zoom2ed() %>% dm_paste(
        options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 filter() on child table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(child) %>% filter(val != "a") %>% dm_update_zoom2ed() %>%
        dm_paste(options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 mutate() on parent table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(parent) %>% mutate(name2 = toupper(name)) %>% dm_update_zoom2ed() %>%
        dm_paste(options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name = character(0),
        name2 = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 mutate() on child table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(child) %>% mutate(val2 = toupper(val)) %>% dm_update_zoom2ed() %>%
        dm_paste(options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
        val2 = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 arrange() on parent table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(parent) %>% arrange(desc(id)) %>% dm_update_zoom2ed() %>%
        dm_paste(options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 arrange() on child table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(child) %>% arrange(desc(child_id)) %>% dm_update_zoom2ed() %>%
        dm_paste(options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 distinct() on parent table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(parent) %>% distinct() %>% dm_update_zoom2ed() %>% dm_paste(
        options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 distinct() on child table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(child) %>% distinct() %>% dm_update_zoom2ed() %>% dm_paste(
        options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 slice() on parent table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(parent) %>% slice(1:2) %>% dm_update_zoom2ed() %>% dm_paste(
        options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 slice() on child table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(child) %>% slice(1:3) %>% dm_update_zoom2ed() %>% dm_paste(
        options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 transmute() on parent table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(parent) %>% transmute(id, name_upper = toupper(name)) %>%
        dm_update_zoom2ed() %>% dm_paste(options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name_upper = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 transmute() on child table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(child) %>% transmute(child_id, parent_id) %>% dm_update_zoom2ed() %>%
        dm_paste(options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 relocate() on parent table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(parent) %>% relocate(name, .before = id) %>% dm_update_zoom2ed() %>%
        dm_paste(options = "all")
    Message
      parent <- tibble::tibble(
        name = character(0),
        id = integer(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 relocate() on child table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(child) %>% relocate(val, .before = child_id) %>%
        dm_update_zoom2ed() %>% dm_paste(options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        val = character(0),
        child_id = integer(0),
        parent_id = integer(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 group_by() on parent table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(parent) %>% group_by(name) %>% dm_update_zoom2ed() %>% dm_paste(
        options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 group_by() on child table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(child) %>% group_by(parent_id) %>% dm_update_zoom2ed() %>%
        dm_paste(options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 ungroup() on parent table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(parent) %>% group_by(name) %>% ungroup() %>% dm_update_zoom2ed() %>%
        dm_paste(options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 ungroup() on child table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(child) %>% group_by(parent_id) %>% ungroup() %>%
        dm_update_zoom2ed() %>% dm_paste(options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 count() on parent table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(parent) %>% count(name) %>% dm_update_zoom2ed() %>% dm_paste(
        options = "all")
    Message
      parent <- tibble::tibble(
        name = character(0),
        n = integer(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(child, child_id)

# zoom2 count() on child table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>% dm_add_pk(parent,
        id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child, parent_id, parent) %>%
        dm_zoom2_to(child) %>% count(parent_id) %>% dm_update_zoom2ed() %>% dm_paste(
        options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        parent_id = integer(0),
        n = integer(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 unite() on parent table

    Code
      dm(parent = tibble(id = 1:3, first = c("a", "b", "c"), last = c("x", "y", "z")),
      child = tibble(child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>%
        dm_add_pk(parent, id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child,
        parent_id, parent) %>% dm_zoom2_to(parent) %>% tidyr::unite(full_name, first,
        last) %>% dm_update_zoom2ed() %>% dm_paste(options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        full_name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 unite() on child table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), first = c("a", "b", "c", "d"), last = c("w",
        "x", "y", "z"))) %>% dm_add_pk(parent, id) %>% dm_add_pk(child, child_id) %>%
        dm_add_fk(child, parent_id, parent) %>% dm_zoom2_to(child) %>% tidyr::unite(
        full_name, first, last) %>% dm_update_zoom2ed() %>% dm_paste(options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        full_name = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 separate() on parent table

    Code
      dm(parent = tibble(id = 1:3, full_name = c("a_x", "b_y", "c_z")), child = tibble(
        child_id = 1:4, parent_id = c(1L, 1L, 2L, 3L), val = letters[1:4])) %>%
        dm_add_pk(parent, id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child,
        parent_id, parent) %>% dm_zoom2_to(parent) %>% tidyr::separate(full_name,
        into = c("first", "last")) %>% dm_update_zoom2ed() %>% dm_paste(options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        first = character(0),
        last = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 separate() on child table

    Code
      dm(parent = tibble(id = 1:3, name = c("a", "b", "c")), child = tibble(child_id = 1:
        4, parent_id = c(1L, 1L, 2L, 3L), full_val = c("a_1", "b_2", "c_3", "d_4"))) %>%
        dm_add_pk(parent, id) %>% dm_add_pk(child, child_id) %>% dm_add_fk(child,
        parent_id, parent) %>% dm_zoom2_to(child) %>% tidyr::separate(full_val, into = c(
        "letter", "number")) %>% dm_update_zoom2ed() %>% dm_paste(options = "all")
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        letter = character(0),
        number = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(child, parent_id, parent)

