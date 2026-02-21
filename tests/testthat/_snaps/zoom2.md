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
    Condition
      Warning in `left_join()`:
      Detected an unexpected many-to-many relationship between `x` and `y`.
      i Row 1 of `x` matches multiple rows in `y`.
      i Row 3 of `y` matches multiple rows in `x`.
      i If a many-to-many relationship is expected, set `relationship = "many-to-many"` to silence this warning.
    Code
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
      zoom2_verb_paste(d, "parent", function(z) select(z, id))
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
      zoom2_verb_paste(d, "child", function(z) select(z, child_id, val))
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
      zoom2_verb_paste(d, "parent", function(z) rename(z, parent_id = id))
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
      zoom2_verb_paste(d, "child", function(z) rename(z, cid = child_id, pid = parent_id))
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
      zoom2_verb_paste(d, "parent", function(z) summarise(z, n = n()))
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

# zoom2 summarise() on child table

    Code
      zoom2_verb_paste(d, "child", function(z) {
        z %>% group_by(parent_id) %>% summarise(n = n())
      })
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

# zoom2 left_join()

    Code
      zoom2_verb_paste(d, "child", function(z) {
        left_join(z, dm_zoom2_to(d, parent))
      })
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
        name = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 inner_join()

    Code
      zoom2_verb_paste(d, "child", function(z) {
        inner_join(z, dm_zoom2_to(d, parent))
      })
    Message
      parent <- tibble::tibble(
        id = integer(0),
        name = character(0),
      )
      child <- tibble::tibble(
        child_id = integer(0),
        parent_id = integer(0),
        val = character(0),
        name = character(0),
      )
      dm::dm(
        parent,
        child,
      ) %>%
        dm::dm_add_pk(parent, id) %>%
        dm::dm_add_pk(child, child_id) %>%
        dm::dm_add_fk(child, parent_id, parent)

# zoom2 semi_join()

    Code
      zoom2_verb_paste(d, "child", function(z) {
        semi_join(z, dm_zoom2_to(d, parent))
      })
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

# zoom2 anti_join()

    Code
      zoom2_verb_paste(d, "child", function(z) {
        anti_join(z, dm_zoom2_to(d, parent))
      })
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

# zoom2 filter() on parent table

    Code
      zoom2_verb_paste(d, "parent", function(z) filter(z, id > 1))
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
      zoom2_verb_paste(d, "child", function(z) filter(z, val != "a"))
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
      zoom2_verb_paste(d, "parent", function(z) mutate(z, name2 = toupper(name)))
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
      zoom2_verb_paste(d, "child", function(z) mutate(z, val2 = toupper(val)))
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
      zoom2_verb_paste(d, "parent", function(z) arrange(z, desc(id)))
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
      zoom2_verb_paste(d, "child", function(z) arrange(z, desc(child_id)))
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
      zoom2_verb_paste(d, "parent", function(z) distinct(z))
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
      zoom2_verb_paste(d, "child", function(z) distinct(z))
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
      zoom2_verb_paste(d, "parent", function(z) slice(z, 1:2))
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
      zoom2_verb_paste(d, "child", function(z) slice(z, 1:3))
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
      zoom2_verb_paste(d, "parent", function(z) transmute(z, id, name_upper = toupper(
        name)))
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
      zoom2_verb_paste(d, "child", function(z) transmute(z, child_id, parent_id))
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

