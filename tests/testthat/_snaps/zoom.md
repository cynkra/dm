# print() and format() methods for subclass `zoomed_dm` work

    Code
      dm_for_filter() %>% dm_zoom_to(tf_5) %>% as_zoomed_df() %>% tbl_sum()
    Output
      Zoomed table 
            "tf_5" 

---

    Code
      dm_for_filter() %>% dm_zoom_to(tf_2) %>% as_zoomed_df() %>% tbl_sum()
    Output
      Zoomed table 
            "tf_2" 

# zoom output for compound keys

    Code
      nyc_comp() %>% dm_zoom_to(weather)
    Output
      # Zoomed table: weather
      # A tibble:     144 x 15
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
      # ... with 134 more rows, and 5 more variables: wind_gust <dbl>, precip <dbl>,
      #   pressure <dbl>, visib <dbl>, time_hour <dttm>
    Code
      nyc_comp() %>% dm_zoom_to(weather) %>% dm_update_zoomed()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 53
      Primary keys: 4
      Foreign keys: 4
    Code
      nyc_comp_2 <- nyc_comp() %>% dm_zoom_to(weather) %>% dm_insert_zoomed(
        "weather_2")
      nyc_comp_2 %>% get_all_keys()
    Output
      $pks
      # A tibble: 5 x 2
        table     pk_cols          
        <chr>     <keys>           
      1 airlines  carrier          
      2 airports  faa              
      3 planes    tailnum          
      4 weather   origin, time_hour
      5 weather_2 origin, time_hour
      
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
      attr(igraph::E(create_graph_from_dm(nyc_comp_2)), "vnames")
    Output
      [1] "airlines|flights"  "airports|flights"  "flights|planes"   
      [4] "flights|weather"   "flights|weather_2"
    Code
      nyc_comp_3 <- nyc_comp() %>% dm_zoom_to(flights) %>% dm_insert_zoomed(
        "flights_2")
      nyc_comp_3 %>% get_all_keys()
    Output
      $pks
      # A tibble: 4 x 2
        table    pk_cols          
        <chr>    <keys>           
      1 airlines carrier          
      2 airports faa              
      3 planes   tailnum          
      4 weather  origin, time_hour
      
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
      
    Code
      attr(igraph::E(create_graph_from_dm(nyc_comp_3)), "vnames")
    Output
      [1] "airlines|flights"   "airlines|flights_2" "airports|flights"  
      [4] "airports|flights_2" "flights|planes"     "planes|flights_2"  
      [7] "flights|weather"    "weather|flights_2" 

