# output

    Code
      print(dm())
    Output
      dm()
    Code
      nyc_flights_dm <- dm_nycflights13(cycle = TRUE)
      nyc_flights_dm
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 53
      Primary keys: 4
      Foreign keys: 5
    Code
      nyc_flights_dm %>% format()
    Output
      dm: 5 tables, 53 columns, 4 primary keys, 5 foreign keys
    Code
      nyc_flights_dm %>% dm_filter(flights, origin == "EWR")
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 53
      Primary keys: 4
      Foreign keys: 5
      -- Filters ---------------------------------------------------------------------
      flights: origin == "EWR"

# output for compound tables

    Code
      copy_to(nyc_comp(), mtcars, "car_table")
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`, `car_table`
      Columns: 64
      Primary keys: 4
      Foreign keys: 4
    Code
      dm_add_tbl(nyc_comp(), car_table)
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`, `car_table`
      Columns: 64
      Primary keys: 4
      Foreign keys: 4
    Code
      nyc_comp() %>% collect()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 53
      Primary keys: 4
      Foreign keys: 4
    Code
      nyc_comp() %>% dm_filter(flights, day == 10) %>% compute() %>% collect() %>%
        dm_get_def()
    Output
      # A tibble: 5 x 9
        table  data    segment display      pks     fks filters zoom  col_tracker_zoom
        <chr>  <list>  <chr>   <chr>    <list<> <list<> <list<> <lis> <list>          
      1 airli~ <tibbl~ <NA>    #ED7D31~ [1 x 1] [1 x 2] [0 x 2] <NUL~ <NULL>          
      2 airpo~ <tibbl~ <NA>    #ED7D31~ [1 x 1] [1 x 2] [0 x 2] <NUL~ <NULL>          
      3 fligh~ <tibbl~ <NA>    #5B9BD5~ [0 x 1] [0 x 2] [0 x 2] <NUL~ <NULL>          
      4 planes <tibbl~ <NA>    #ED7D31~ [1 x 1] [1 x 2] [0 x 2] <NUL~ <NULL>          
      5 weath~ <tibbl~ <NA>    #70AD47~ [1 x 1] [1 x 2] [0 x 2] <NUL~ <NULL>          
    Code
      nyc_comp() %>% dm_zoom_to(weather) %>% mutate(origin_new = paste0(origin,
        " airport")) %>% compute() %>% dm_update_zoomed() %>% collect() %>%
        dm_get_def()
    Output
      # A tibble: 5 x 9
        table  data    segment display      pks     fks filters zoom  col_tracker_zoom
        <chr>  <list>  <chr>   <chr>    <list<> <list<> <list<> <lis> <list>          
      1 airli~ <tibbl~ <NA>    #ED7D31~ [1 x 1] [1 x 2] [0 x 2] <NUL~ <NULL>          
      2 airpo~ <tibbl~ <NA>    #ED7D31~ [1 x 1] [1 x 2] [0 x 2] <NUL~ <NULL>          
      3 fligh~ <tibbl~ <NA>    #5B9BD5~ [0 x 1] [0 x 2] [0 x 2] <NUL~ <NULL>          
      4 planes <tibbl~ <NA>    #ED7D31~ [1 x 1] [1 x 2] [0 x 2] <NUL~ <NULL>          
      5 weath~ <tibbl~ <NA>    #70AD47~ [1 x 1] [1 x 2] [0 x 2] <NUL~ <NULL>          
    Code
      nyc_comp() %>% dm_zoom_to(weather) %>% collect()
    Message <simpleMessage>
      Detaching table from dm, use `collect(pull_tbl())` instead to silence this message.
    Output
      # A tibble: 861 x 15
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
      pull_tbl(nyc_comp(), weather)
    Output
      # A tibble: 861 x 15
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
      dm_zoom_to(nyc_comp(), weather) %>% pull_tbl()
    Output
      # A tibble: 861 x 15
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

