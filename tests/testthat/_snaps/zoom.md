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
      # A tibble:     861 x 15
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
      # ... with 851 more rows, and 5 more variables: wind_gust <dbl>, precip <dbl>,
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
      nyc_comp_2
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`, `weather_2`
      Columns: 68
      Primary keys: 5
      Foreign keys: 5
    Code
      attr(igraph::E(create_graph_from_dm(nyc_comp_2)), "vnames")
    Output
      [1] "airlines|flights"  "airports|flights"  "flights|planes"   
      [4] "flights|weather"   "flights|weather_2"
    Code
      dm_get_pk(nyc_comp_2, weather_2)
    Output
      <list_of<character>[1]>
      [[1]]
      [1] "origin"    "time_hour"
      
    Code
      # FIXME: COMPOUND:: dm_insert_zoomed() does not recreate compound FKs
      nyc_comp_3 <- nyc_comp() %>% dm_zoom_to(flights) %>% dm_insert_zoomed(
        "flights_2")
      nyc_comp_3
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`, `flights_2`
      Columns: 72
      Primary keys: 4
      Foreign keys: 7
    Code
      attr(igraph::E(create_graph_from_dm(nyc_comp_3)), "vnames")
    Output
      [1] "airlines|flights"   "airlines|flights_2" "airports|flights"  
      [4] "airports|flights_2" "flights|planes"     "planes|flights_2"  
      [7] "flights|weather"   
    Code
      dm_get_fk(nyc_comp_3, flights_2, weather)
    Output
      <list_of<character>[0]>

