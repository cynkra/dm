# key tracking works

    Code
      zoomed_dm() %>% unite("new_col", c, e) %>% dm_update_zoomed() %>% get_all_keys(
        "tf_2")
    Output
      $pks
      # A tibble: 0 x 2
      # ... with 2 variables: table <chr>, pk_col <keys>
      
      $fks
      # A tibble: 1 x 3
        child_fk_cols parent_table parent_pk_cols
        <keys>        <chr>        <keys>        
      1 d             tf_1         a             
      
    Code
      zoomed_dm() %>% unite("new_col", c, e, remove = FALSE) %>% dm_update_zoomed() %>%
        get_all_keys("tf_2")
    Output
      $pks
      # A tibble: 1 x 2
        table pk_col
        <chr> <keys>
      1 tf_2  c     
      
      $fks
      # A tibble: 2 x 3
        child_fk_cols parent_table parent_pk_cols
        <keys>        <chr>        <keys>        
      1 d             tf_1         a             
      2 e, e1         tf_3         f, f1         
      
    Code
      zoomed_dm() %>% unite("new_col", c, e, remove = FALSE) %>% dm_update_zoomed() %>%
        dm_add_fk(tf_2, new_col, tf_6) %>% dm_zoom_to(tf_2) %>% separate(new_col, c(
        "c", "e"), remove = TRUE) %>% dm_update_zoomed() %>% get_all_keys("tf_2")
    Output
      $pks
      # A tibble: 1 x 2
        table pk_col
        <chr> <keys>
      1 tf_2  c     
      
      $fks
      # A tibble: 2 x 3
        child_fk_cols parent_table parent_pk_cols
        <keys>        <chr>        <keys>        
      1 d             tf_1         a             
      2 e, e1         tf_3         f, f1         
      
    Code
      zoomed_dm() %>% unite("new_col", c, e, remove = FALSE) %>% dm_update_zoomed() %>%
        dm_add_fk(tf_2, new_col, tf_6) %>% dm_zoom_to(tf_2) %>% separate(new_col, c(
        "c", "e"), remove = FALSE) %>% dm_update_zoomed() %>% get_all_keys("tf_2")
    Output
      $pks
      # A tibble: 1 x 2
        table pk_col
        <chr> <keys>
      1 tf_2  c     
      
      $fks
      # A tibble: 3 x 3
        child_fk_cols parent_table parent_pk_cols
        <keys>        <chr>        <keys>        
      1 d             tf_1         a             
      2 e, e1         tf_3         f, f1         
      3 new_col       tf_6         o             
      

# output for compound keys

    Code
      unite_weather_dm <- nyc_comp() %>% dm_zoom_to(weather) %>% mutate(chr_col = "airport") %>%
        unite("new_col", origin, chr_col) %>% dm_update_zoomed()
      unite_weather_dm %>% get_all_keys("flights")
    Output
      $pks
      # A tibble: 0 x 2
      # ... with 2 variables: table <chr>, pk_col <keys>
      
      $fks
      # A tibble: 3 x 3
        child_fk_cols parent_table parent_pk_cols
        <keys>        <chr>        <keys>        
      1 carrier       airlines     carrier       
      2 dest          airports     faa           
      3 tailnum       planes       tailnum       
      
    Code
      unite_weather_dm %>% get_all_keys("weather")
    Output
      $pks
      # A tibble: 0 x 2
      # ... with 2 variables: table <chr>, pk_col <keys>
      
      $fks
      # A tibble: 0 x 3
      # ... with 3 variables: child_fk_cols <keys>, parent_table <chr>,
      #   parent_pk_cols <keys>
      
    Code
      unite_flights_dm <- nyc_comp() %>% dm_zoom_to(flights) %>% mutate(chr_col = "airport") %>%
        unite("new_col", origin, chr_col) %>% dm_update_zoomed()
      unite_flights_dm %>% get_all_keys("flights")
    Output
      $pks
      # A tibble: 0 x 2
      # ... with 2 variables: table <chr>, pk_col <keys>
      
      $fks
      # A tibble: 3 x 3
        child_fk_cols parent_table parent_pk_cols
        <keys>        <chr>        <keys>        
      1 carrier       airlines     carrier       
      2 dest          airports     faa           
      3 tailnum       planes       tailnum       
      
    Code
      unite_flights_dm %>% get_all_keys("weather")
    Output
      $pks
      # A tibble: 1 x 2
        table   pk_col           
        <chr>   <keys>           
      1 weather origin, time_hour
      
      $fks
      # A tibble: 0 x 3
      # ... with 3 variables: child_fk_cols <keys>, parent_table <chr>,
      #   parent_pk_cols <keys>
      
    Code
      nyc_comp() %>% dm_zoom_to(weather) %>% separate(origin, c("o1", "o2"), sep = "^..",
      remove = TRUE) %>% dm_update_zoomed()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 54
      Primary keys: 3
      Foreign keys: 3
    Code
      nyc_comp() %>% dm_zoom_to(weather) %>% separate(origin, c("o1", "o2"), sep = "^..",
      remove = FALSE) %>% dm_update_zoomed()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 55
      Primary keys: 4
      Foreign keys: 4

