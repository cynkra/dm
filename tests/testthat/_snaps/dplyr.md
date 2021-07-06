# basic test: 'join()'-methods for `zoomed.dm` work (2)

    Code
      # keys are correctly tracked if selected columns from 'y' have same name as key columns from 'x'
      zoomed_dm() %>% left_join(tf_3, select = c(d = g, f, f1)) %>% dm_update_zoomed() %>%
        get_all_keys()
    Message <simpleMessage>
      Renamed columns:
      * d -> tf_2.d, tf_3.d
    Output
      $pks
      # A tibble: 6 x 2
        table pk_col
        <chr> <keys>
      1 tf_1  a     
      2 tf_2  c     
      3 tf_3  f, f1 
      4 tf_4  h     
      5 tf_5  k     
      6 tf_6  o     
      
      $fks
      # A tibble: 5 x 4
        child_table child_fk_cols parent_table parent_key_cols
        <chr>       <keys>        <chr>        <keys>         
      1 tf_2        tf_2.d        tf_1         a              
      2 tf_2        e, e1         tf_3         f, f1          
      3 tf_4        j, j1         tf_3         f, f1          
      4 tf_5        l             tf_4         h              
      5 tf_5        m             tf_6         n              
      
    Code
      # keys are correctly tracked if selected columns from 'y' have same name as key columns from 'x'
      zoomed_dm() %>% semi_join(tf_3, select = c(d = g, f, f1)) %>% dm_update_zoomed() %>%
        get_all_keys()
    Output
      $pks
      # A tibble: 6 x 2
        table pk_col
        <chr> <keys>
      1 tf_1  a     
      2 tf_2  c     
      3 tf_3  f, f1 
      4 tf_4  h     
      5 tf_5  k     
      6 tf_6  o     
      
      $fks
      # A tibble: 5 x 4
        child_table child_fk_cols parent_table parent_key_cols
        <chr>       <keys>        <chr>        <keys>         
      1 tf_2        d             tf_1         a              
      2 tf_2        e, e1         tf_3         f, f1          
      3 tf_4        j, j1         tf_3         f, f1          
      4 tf_5        l             tf_4         h              
      5 tf_5        m             tf_6         n              
      

# key tracking works

    Code
      # rename()
      zoomed_grouped_out_dm %>% rename(c_new = c) %>% dm_update_zoomed() %>%
        get_all_keys()
    Output
      $pks
      # A tibble: 6 x 2
        table pk_col
        <chr> <keys>
      1 tf_1  a     
      2 tf_2  c_new 
      3 tf_3  f, f1 
      4 tf_4  h     
      5 tf_5  k     
      6 tf_6  o     
      
      $fks
      # A tibble: 5 x 4
        child_table child_fk_cols parent_table parent_key_cols
        <chr>       <keys>        <chr>        <keys>         
      1 tf_2        d             tf_1         a              
      2 tf_2        e, e1         tf_3         f, f1          
      3 tf_4        j, j1         tf_3         f, f1          
      4 tf_5        l             tf_4         h              
      5 tf_5        m             tf_6         n              
      
    Code
      zoomed_grouped_out_dm %>% rename(e_new = e) %>% dm_update_zoomed() %>%
        get_all_keys()
    Output
      $pks
      # A tibble: 6 x 2
        table pk_col
        <chr> <keys>
      1 tf_1  a     
      2 tf_2  c     
      3 tf_3  f, f1 
      4 tf_4  h     
      5 tf_5  k     
      6 tf_6  o     
      
      $fks
      # A tibble: 5 x 4
        child_table child_fk_cols parent_table parent_key_cols
        <chr>       <keys>        <chr>        <keys>         
      1 tf_2        d             tf_1         a              
      2 tf_2        e_new, e1     tf_3         f, f1          
      3 tf_4        j, j1         tf_3         f, f1          
      4 tf_5        l             tf_4         h              
      5 tf_5        m             tf_6         n              
      
    Code
      zoomed_grouped_in_dm %>% rename(f_new = f) %>% dm_update_zoomed() %>%
        get_all_keys()
    Output
      $pks
      # A tibble: 6 x 2
        table pk_col   
        <chr> <keys>   
      1 tf_1  a        
      2 tf_2  c        
      3 tf_3  f_new, f1
      4 tf_4  h        
      5 tf_5  k        
      6 tf_6  o        
      
      $fks
      # A tibble: 5 x 4
        child_table child_fk_cols parent_table parent_key_cols
        <chr>       <keys>        <chr>        <keys>         
      1 tf_2        d             tf_1         a              
      2 tf_2        e, e1         tf_3         f, f1          
      3 tf_4        j, j1         tf_3         f, f1          
      4 tf_5        l             tf_4         h              
      5 tf_5        m             tf_6         n              
      
    Code
      # summarize()
      zoomed_grouped_out_dm %>% summarize(d_mean = mean(d)) %>% dm_insert_zoomed(
        "new_tbl") %>% get_all_keys()
    Output
      $pks
      # A tibble: 7 x 2
        table   pk_col
        <chr>   <keys>
      1 tf_1    a     
      2 tf_2    c     
      3 tf_3    f, f1 
      4 tf_4    h     
      5 tf_5    k     
      6 tf_6    o     
      7 new_tbl c     
      
      $fks
      # A tibble: 6 x 4
        child_table child_fk_cols parent_table parent_key_cols
        <chr>       <keys>        <chr>        <keys>         
      1 tf_2        d             tf_1         a              
      2 tf_2        e, e1         tf_3         f, f1          
      3 tf_4        j, j1         tf_3         f, f1          
      4 new_tbl     e, e1         tf_3         f, f1          
      5 tf_5        l             tf_4         h              
      6 tf_5        m             tf_6         n              
      
    Code
      zoomed_grouped_in_dm %>% summarize(g_list = list(g)) %>% dm_insert_zoomed(
        "new_tbl") %>% get_all_keys()
    Output
      $pks
      # A tibble: 6 x 2
        table pk_col
        <chr> <keys>
      1 tf_1  a     
      2 tf_2  c     
      3 tf_3  f, f1 
      4 tf_4  h     
      5 tf_5  k     
      6 tf_6  o     
      
      $fks
      # A tibble: 5 x 4
        child_table child_fk_cols parent_table parent_key_cols
        <chr>       <keys>        <chr>        <keys>         
      1 tf_2        d             tf_1         a              
      2 tf_2        e, e1         tf_3         f, f1          
      3 tf_4        j, j1         tf_3         f, f1          
      4 tf_5        l             tf_4         h              
      5 tf_5        m             tf_6         n              
      

# key tracking works (2)

    Code
      # transmute()
      zoomed_grouped_out_dm %>% transmute(d_mean = mean(d)) %>% dm_insert_zoomed(
        "new_tbl") %>% get_all_keys()
    Output
      $pks
      # A tibble: 7 x 2
        table   pk_col
        <chr>   <keys>
      1 tf_1    a     
      2 tf_2    c     
      3 tf_3    f, f1 
      4 tf_4    h     
      5 tf_5    k     
      6 tf_6    o     
      7 new_tbl c     
      
      $fks
      # A tibble: 6 x 4
        child_table child_fk_cols parent_table parent_key_cols
        <chr>       <keys>        <chr>        <keys>         
      1 tf_2        d             tf_1         a              
      2 tf_2        e, e1         tf_3         f, f1          
      3 tf_4        j, j1         tf_3         f, f1          
      4 new_tbl     e, e1         tf_3         f, f1          
      5 tf_5        l             tf_4         h              
      6 tf_5        m             tf_6         n              
      

# key tracking works (3)

    Code
      zoomed_grouped_in_dm %>% transmute(g_list = list(g)) %>% dm_insert_zoomed(
        "new_tbl") %>% get_all_keys()
    Output
      $pks
      # A tibble: 6 x 2
        table pk_col
        <chr> <keys>
      1 tf_1  a     
      2 tf_2  c     
      3 tf_3  f, f1 
      4 tf_4  h     
      5 tf_5  k     
      6 tf_6  o     
      
      $fks
      # A tibble: 5 x 4
        child_table child_fk_cols parent_table parent_key_cols
        <chr>       <keys>        <chr>        <keys>         
      1 tf_2        d             tf_1         a              
      2 tf_2        e, e1         tf_3         f, f1          
      3 tf_4        j, j1         tf_3         f, f1          
      4 tf_5        l             tf_4         h              
      5 tf_5        m             tf_6         n              
      

# key tracking works (4)

    Code
      # mutate()
      zoomed_grouped_out_dm %>% mutate(d_mean = mean(d), d = d * 2) %>%
        dm_insert_zoomed("new_tbl") %>% get_all_keys()
    Output
      $pks
      # A tibble: 7 x 2
        table   pk_col
        <chr>   <keys>
      1 tf_1    a     
      2 tf_2    c     
      3 tf_3    f, f1 
      4 tf_4    h     
      5 tf_5    k     
      6 tf_6    o     
      7 new_tbl c     
      
      $fks
      # A tibble: 6 x 4
        child_table child_fk_cols parent_table parent_key_cols
        <chr>       <keys>        <chr>        <keys>         
      1 tf_2        d             tf_1         a              
      2 tf_2        e, e1         tf_3         f, f1          
      3 tf_4        j, j1         tf_3         f, f1          
      4 new_tbl     e, e1         tf_3         f, f1          
      5 tf_5        l             tf_4         h              
      6 tf_5        m             tf_6         n              
      
    Code
      zoomed_grouped_in_dm %>% mutate(f = list(g)) %>% dm_insert_zoomed("new_tbl") %>%
        get_all_keys()
    Output
      $pks
      # A tibble: 6 x 2
        table pk_col
        <chr> <keys>
      1 tf_1  a     
      2 tf_2  c     
      3 tf_3  f, f1 
      4 tf_4  h     
      5 tf_5  k     
      6 tf_6  o     
      
      $fks
      # A tibble: 5 x 4
        child_table child_fk_cols parent_table parent_key_cols
        <chr>       <keys>        <chr>        <keys>         
      1 tf_2        d             tf_1         a              
      2 tf_2        e, e1         tf_3         f, f1          
      3 tf_4        j, j1         tf_3         f, f1          
      4 tf_5        l             tf_4         h              
      5 tf_5        m             tf_6         n              
      
    Code
      zoomed_grouped_in_dm %>% mutate(g_new = list(g)) %>% dm_insert_zoomed("new_tbl") %>%
        get_all_keys()
    Output
      $pks
      # A tibble: 7 x 2
        table   pk_col
        <chr>   <keys>
      1 tf_1    a     
      2 tf_2    c     
      3 tf_3    f, f1 
      4 tf_4    h     
      5 tf_5    k     
      6 tf_6    o     
      7 new_tbl f, f1 
      
      $fks
      # A tibble: 7 x 4
        child_table child_fk_cols parent_table parent_key_cols
        <chr>       <keys>        <chr>        <keys>         
      1 tf_2        d             tf_1         a              
      2 tf_2        e, e1         tf_3         f, f1          
      3 tf_4        j, j1         tf_3         f, f1          
      4 tf_5        l             tf_4         h              
      5 tf_5        m             tf_6         n              
      6 tf_2        e, e1         new_tbl      f, f1          
      7 tf_4        j, j1         new_tbl      f, f1          
      
    Code
      # chain of renames & other transformations
      zoomed_grouped_out_dm %>% summarize(d_mean = mean(d)) %>% ungroup() %>% rename(
        e_new = e) %>% group_by(e_new, e1) %>% transmute(c = paste0(c, "_animal")) %>%
        dm_insert_zoomed("new_tbl") %>% get_all_keys()
    Output
      $pks
      # A tibble: 6 x 2
        table pk_col
        <chr> <keys>
      1 tf_1  a     
      2 tf_2  c     
      3 tf_3  f, f1 
      4 tf_4  h     
      5 tf_5  k     
      6 tf_6  o     
      
      $fks
      # A tibble: 6 x 4
        child_table child_fk_cols parent_table parent_key_cols
        <chr>       <keys>        <chr>        <keys>         
      1 tf_2        d             tf_1         a              
      2 tf_2        e, e1         tf_3         f, f1          
      3 tf_4        j, j1         tf_3         f, f1          
      4 new_tbl     e_new, e1     tf_3         f, f1          
      5 tf_5        l             tf_4         h              
      6 tf_5        m             tf_6         n              
      

# key tracking works (5)

    Code
      zoomed_grouped_in_dm %>% select(g_new = g) %>% get_all_keys("tf_3")
    Output
      $pks
      # A tibble: 1 x 2
        table pk_col
        <chr> <keys>
      1 tf_3  f, f1 
      
      $fks
      # A tibble: 2 x 4
        child_table child_fk_cols parent_table parent_key_cols
        <chr>       <keys>        <chr>        <keys>         
      1 tf_2        e, e1         tf_3         f, f1          
      2 tf_4        j, j1         tf_3         f, f1          
      

# output for compound keys

    Code
      grouped_zoomed_comp_dm_1 %>% mutate(count = n()) %>% col_tracker_zoomed()
    Output
            origin         year        month          day         hour         temp 
          "origin"       "year"      "month"        "day"       "hour"       "temp" 
              dewp        humid     wind_dir   wind_speed    wind_gust       precip 
            "dewp"      "humid"   "wind_dir" "wind_speed"  "wind_gust"     "precip" 
          pressure        visib    time_hour 
        "pressure"      "visib"  "time_hour" 
    Code
      grouped_zoomed_comp_dm_2 %>% mutate(count = n()) %>% col_tracker_zoomed()
    Output
            origin         year        month          day         hour         temp 
          "origin"       "year"      "month"        "day"       "hour"       "temp" 
              dewp        humid     wind_dir   wind_speed    wind_gust       precip 
            "dewp"      "humid"   "wind_dir" "wind_speed"  "wind_gust"     "precip" 
          pressure        visib    time_hour 
        "pressure"      "visib"  "time_hour" 
    Code
      grouped_zoomed_comp_dm_1 %>% transmute(count = n()) %>% dm_update_zoomed()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 41
      Primary keys: 3
      Foreign keys: 3
    Code
      grouped_zoomed_comp_dm_2 %>% transmute(count = n()) %>% dm_update_zoomed()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 41
      Primary keys: 4
      Foreign keys: 4
    Code
      grouped_zoomed_comp_dm_1 %>% summarize(count = n()) %>% dm_update_zoomed()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 41
      Primary keys: 3
      Foreign keys: 3
    Code
      grouped_zoomed_comp_dm_2 %>% summarize(count = n()) %>% dm_update_zoomed()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 41
      Primary keys: 4
      Foreign keys: 4
    Code
      zoomed_comp_dm %>% select(time_hour, wind_dir) %>% dm_update_zoomed()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 40
      Primary keys: 3
      Foreign keys: 3
    Code
      zoomed_comp_dm %>% select(time_hour, origin, wind_dir) %>% dm_update_zoomed()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 41
      Primary keys: 4
      Foreign keys: 4
    Code
      zoomed_comp_dm %>% rename(th = time_hour, wd = wind_dir) %>% dm_update_zoomed()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 53
      Primary keys: 4
      Foreign keys: 4
    Code
      zoomed_comp_dm %>% distinct(origin, wind_dir) %>% dm_update_zoomed()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 40
      Primary keys: 3
      Foreign keys: 3
    Code
      zoomed_comp_dm %>% distinct(origin, wind_dir, time_hour) %>% dm_update_zoomed()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 41
      Primary keys: 4
      Foreign keys: 4
    Code
      zoomed_comp_dm %>% filter(pressure < 1020) %>% dm_update_zoomed()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 53
      Primary keys: 4
      Foreign keys: 4
    Code
      zoomed_comp_dm %>% pull(origin) %>% unique()
    Output
      [1] "EWR" "JFK" "LGA"
    Code
      zoomed_comp_dm %>% slice(c(1:3, 5:3))
    Message <simpleMessage>
      Keeping PK column, but `slice.zoomed_dm()` can potentially damage the uniqueness of PK columns (duplicated indices). Set argument `.keep_pk` to `TRUE` or `FALSE` to ensure the behavior you intended.
    Output
      # Zoomed table: weather
      # A tibble:     6 x 15
        origin  year month   day  hour  temp  dewp humid wind_dir wind_speed wind_gust
        <chr>  <int> <int> <int> <int> <dbl> <dbl> <dbl>    <dbl>      <dbl>     <dbl>
      1 EWR     2013     1    10     0  41    32    70.1      230       8.06        NA
      2 EWR     2013     1    10     1  39.0  30.0  69.9      210       9.21        NA
      3 EWR     2013     1    10     2  39.0  28.9  66.8      230       6.90        NA
      4 EWR     2013     1    10     4  41    26.1  55.0      320       6.90        NA
      5 EWR     2013     1    10     3  39.9  27.0  59.5      270       5.75        NA
      6 EWR     2013     1    10     2  39.0  28.9  66.8      230       6.90        NA
      # ... with 4 more variables: precip <dbl>, pressure <dbl>, visib <dbl>,
      #   time_hour <dttm>
    Code
      zoomed_comp_dm %>% slice(c(1:3, 5:3), .keep_pk = TRUE) %>% col_tracker_zoomed()
    Output
            origin         year        month          day         hour         temp 
          "origin"       "year"      "month"        "day"       "hour"       "temp" 
              dewp        humid     wind_dir   wind_speed    wind_gust       precip 
            "dewp"      "humid"   "wind_dir" "wind_speed"  "wind_gust"     "precip" 
          pressure        visib    time_hour 
        "pressure"      "visib"  "time_hour" 
    Code
      zoomed_comp_dm %>% left_join(flights) %>% nrow()
    Message <simpleMessage>
      Renamed columns:
      * year -> weather.year, flights.year
      * month -> weather.month, flights.month
      * day -> weather.day, flights.day
      * hour -> weather.hour, flights.hour
    Output
      [1] 1800
    Code
      zoomed_comp_dm %>% right_join(flights) %>% nrow()
    Message <simpleMessage>
      Renamed columns:
      * year -> weather.year, flights.year
      * month -> weather.month, flights.month
      * day -> weather.day, flights.day
      * hour -> weather.hour, flights.hour
    Output
      [1] 1761
    Code
      zoomed_comp_dm %>% inner_join(flights) %>% nrow()
    Message <simpleMessage>
      Renamed columns:
      * year -> weather.year, flights.year
      * month -> weather.month, flights.month
      * day -> weather.day, flights.day
      * hour -> weather.hour, flights.hour
    Output
      [1] 1761
    Code
      zoomed_comp_dm %>% full_join(flights) %>% nrow()
    Message <simpleMessage>
      Renamed columns:
      * year -> weather.year, flights.year
      * month -> weather.month, flights.month
      * day -> weather.day, flights.day
      * hour -> weather.hour, flights.hour
    Output
      [1] 1800
    Code
      zoomed_comp_dm %>% semi_join(flights) %>% nrow()
    Output
      [1] 105
    Code
      zoomed_comp_dm %>% anti_join(flights) %>% nrow()
    Output
      [1] 39

