# output

    Code
      print(dm())
    Output
      dm()
    Code
      nyc_flights_dm <- dm_nycflights_small()
      collect(nyc_flights_dm)
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 53
      Primary keys: 3
      Foreign keys: 3
    Code
      nyc_flights_dm %>% format()
    Output
      dm: 5 tables, 53 columns, 3 primary keys, 3 foreign keys
    Code
      nyc_flights_dm %>% dm_filter(flights, origin == "EWR") %>% collect()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 53
      Primary keys: 3
      Foreign keys: 3

# output for compound keys

    Code
      copy_to(nyc_comp(), mtcars, "car_table")
    Condition
      Warning:
      `copy_to.dm()` was deprecated in dm 0.2.0.
      Use `copy_to(dm_get_con(dm), ...)` and `dm_add_tbl()`.
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
        table    data     segment display           pks     fks filters zoom   col_t~1
        <chr>    <list>   <chr>   <chr>   <list<tibble> <list<> <list<> <list> <list> 
      1 airlines <tibble> <NA>    <NA>          [1 x 1] [1 x 4] [0 x 2] <NULL> <NULL> 
      2 airports <tibble> <NA>    <NA>          [1 x 1] [1 x 4] [0 x 2] <NULL> <NULL> 
      3 flights  <tibble> <NA>    <NA>          [0 x 1] [0 x 4] [0 x 2] <NULL> <NULL> 
      4 planes   <tibble> <NA>    <NA>          [1 x 1] [1 x 4] [0 x 2] <NULL> <NULL> 
      5 weather  <tibble> <NA>    <NA>          [1 x 1] [1 x 4] [0 x 2] <NULL> <NULL> 
      # ... with abbreviated variable name 1: col_tracker_zoom
    Code
      nyc_comp() %>% dm_zoom_to(weather) %>% mutate(origin_new = paste0(origin,
        " airport")) %>% compute() %>% dm_update_zoomed() %>% collect() %>%
        dm_get_def()
    Output
      # A tibble: 5 x 9
        table    data     segment display           pks     fks filters zoom   col_t~1
        <chr>    <list>   <chr>   <chr>   <list<tibble> <list<> <list<> <list> <list> 
      1 airlines <tibble> <NA>    <NA>          [1 x 1] [1 x 4] [0 x 2] <NULL> <NULL> 
      2 airports <tibble> <NA>    <NA>          [1 x 1] [1 x 4] [0 x 2] <NULL> <NULL> 
      3 flights  <tibble> <NA>    <NA>          [0 x 1] [0 x 4] [0 x 2] <NULL> <NULL> 
      4 planes   <tibble> <NA>    <NA>          [1 x 1] [1 x 4] [0 x 2] <NULL> <NULL> 
      5 weather  <tibble> <NA>    <NA>          [1 x 1] [1 x 4] [0 x 2] <NULL> <NULL> 
      # ... with abbreviated variable name 1: col_tracker_zoom
    Code
      nyc_comp() %>% dm_zoom_to(weather) %>% collect()
    Message
      Detaching table from dm, use `collect(pull_tbl())` instead to silence this message.
    Output
      # A tibble: 144 x 15
         origin  year month   day  hour  temp  dewp humid wind_dir wind_speed wind_g~1
         <chr>  <int> <int> <int> <int> <dbl> <dbl> <dbl>    <dbl>      <dbl>    <dbl>
       1 EWR     2013     1    10     0  41    32    70.1      230       8.06     NA  
       2 EWR     2013     1    10     1  39.0  30.0  69.9      210       9.21     NA  
       3 EWR     2013     1    10     2  39.0  28.9  66.8      230       6.90     NA  
       4 EWR     2013     1    10     3  39.9  27.0  59.5      270       5.75     NA  
       5 EWR     2013     1    10     4  41    26.1  55.0      320       6.90     NA  
       6 EWR     2013     1    10     5  41    26.1  55.0      300      12.7      20.7
       7 EWR     2013     1    10     6  39.9  25.0  54.8      280       6.90     17.3
       8 EWR     2013     1    10     7  41    25.0  52.6      330       6.90     NA  
       9 EWR     2013     1    10     8  43.0  25.0  48.7      330       8.06     NA  
      10 EWR     2013     1    10     9  45.0  23    41.6      320      17.3      26.5
      # ... with 134 more rows, 4 more variables: precip <dbl>, pressure <dbl>,
      #   visib <dbl>, time_hour <dttm>, and abbreviated variable name 1: wind_gust
    Code
      pull_tbl(nyc_comp(), weather)
    Output
      # A tibble: 144 x 15
         origin  year month   day  hour  temp  dewp humid wind_dir wind_speed wind_g~1
         <chr>  <int> <int> <int> <int> <dbl> <dbl> <dbl>    <dbl>      <dbl>    <dbl>
       1 EWR     2013     1    10     0  41    32    70.1      230       8.06     NA  
       2 EWR     2013     1    10     1  39.0  30.0  69.9      210       9.21     NA  
       3 EWR     2013     1    10     2  39.0  28.9  66.8      230       6.90     NA  
       4 EWR     2013     1    10     3  39.9  27.0  59.5      270       5.75     NA  
       5 EWR     2013     1    10     4  41    26.1  55.0      320       6.90     NA  
       6 EWR     2013     1    10     5  41    26.1  55.0      300      12.7      20.7
       7 EWR     2013     1    10     6  39.9  25.0  54.8      280       6.90     17.3
       8 EWR     2013     1    10     7  41    25.0  52.6      330       6.90     NA  
       9 EWR     2013     1    10     8  43.0  25.0  48.7      330       8.06     NA  
      10 EWR     2013     1    10     9  45.0  23    41.6      320      17.3      26.5
      # ... with 134 more rows, 4 more variables: precip <dbl>, pressure <dbl>,
      #   visib <dbl>, time_hour <dttm>, and abbreviated variable name 1: wind_gust
    Code
      nyc_comp() %>% dm_zoom_to(weather) %>% pull_tbl()
    Output
      # A tibble: 144 x 15
         origin  year month   day  hour  temp  dewp humid wind_dir wind_speed wind_g~1
         <chr>  <int> <int> <int> <int> <dbl> <dbl> <dbl>    <dbl>      <dbl>    <dbl>
       1 EWR     2013     1    10     0  41    32    70.1      230       8.06     NA  
       2 EWR     2013     1    10     1  39.0  30.0  69.9      210       9.21     NA  
       3 EWR     2013     1    10     2  39.0  28.9  66.8      230       6.90     NA  
       4 EWR     2013     1    10     3  39.9  27.0  59.5      270       5.75     NA  
       5 EWR     2013     1    10     4  41    26.1  55.0      320       6.90     NA  
       6 EWR     2013     1    10     5  41    26.1  55.0      300      12.7      20.7
       7 EWR     2013     1    10     6  39.9  25.0  54.8      280       6.90     17.3
       8 EWR     2013     1    10     7  41    25.0  52.6      330       6.90     NA  
       9 EWR     2013     1    10     8  43.0  25.0  48.7      330       8.06     NA  
      10 EWR     2013     1    10     9  45.0  23    41.6      320      17.3      26.5
      # ... with 134 more rows, 4 more variables: precip <dbl>, pressure <dbl>,
      #   visib <dbl>, time_hour <dttm>, and abbreviated variable name 1: wind_gust

# glimpse.dm() works

    Code
      glimpse(empty_dm())
    Output
      dm of 0 tables
    Code
      glimpse(dm_for_disambiguate())
    Output
      dm of 3 tables: `iris_1`, `iris_2`, `iris_3`
      
      Table: `iris_1`
      Primary key: (`key`)
      Rows: 150
      Columns: 6
      $ key          <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17~
      $ Sepal.Length <dbl> 5.1, 4.9, 4.7, 4.6, 5.0, 5.4, 4.6, 5.0, 4.4, 4.9, 5.4, 4.~
      $ Sepal.Width  <dbl> 3.5, 3.0, 3.2, 3.1, 3.6, 3.9, 3.4, 3.4, 2.9, 3.1, 3.7, 3.~
      $ Petal.Length <dbl> 1.4, 1.4, 1.3, 1.5, 1.4, 1.7, 1.4, 1.5, 1.4, 1.5, 1.5, 1.~
      $ Petal.Width  <dbl> 0.2, 0.2, 0.2, 0.2, 0.2, 0.4, 0.3, 0.2, 0.2, 0.1, 0.2, 0.~
      $ Species      <fct> setosa, setosa, setosa, setosa, setosa, setosa, setosa, s~
      
      Table: `iris_2`
      1 outgoing foreign key(s):
        (`key`) -> (`iris_1$key`) no_action
      Rows: 150
      Columns: 7
      $ key          <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17~
      $ Sepal.Length <dbl> 5.1, 4.9, 4.7, 4.6, 5.0, 5.4, 4.6, 5.0, 4.4, 4.9, 5.4, 4.~
      $ Sepal.Width  <dbl> 3.5, 3.0, 3.2, 3.1, 3.6, 3.9, 3.4, 3.4, 2.9, 3.1, 3.7, 3.~
      $ Petal.Length <dbl> 1.4, 1.4, 1.3, 1.5, 1.4, 1.7, 1.4, 1.5, 1.4, 1.5, 1.5, 1.~
      $ Petal.Width  <dbl> 0.2, 0.2, 0.2, 0.2, 0.2, 0.4, 0.3, 0.2, 0.2, 0.1, 0.2, 0.~
      $ Species      <fct> setosa, setosa, setosa, setosa, setosa, setosa, setosa, s~
      $ other_col    <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ~
      
      Table: `iris_3`
      Rows: 150
      Columns: 8
      $ key          <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17~
      $ Sepal.Length <dbl> 5.1, 4.9, 4.7, 4.6, 5.0, 5.4, 4.6, 5.0, 4.4, 4.9, 5.4, 4.~
      $ Sepal.Width  <dbl> 3.5, 3.0, 3.2, 3.1, 3.6, 3.9, 3.4, 3.4, 2.9, 3.1, 3.7, 3.~
      $ Petal.Length <dbl> 1.4, 1.4, 1.3, 1.5, 1.4, 1.7, 1.4, 1.5, 1.4, 1.5, 1.5, 1.~
      $ Petal.Width  <dbl> 0.2, 0.2, 0.2, 0.2, 0.2, 0.4, 0.3, 0.2, 0.2, 0.1, 0.2, 0.~
      $ Species      <fct> setosa, setosa, setosa, setosa, setosa, setosa, setosa, s~
      $ other_col    <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ~
      $ one_more_col <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ~
    Code
      glimpse(dm_for_disambiguate(), width = 40)
    Output
      dm of 3 tables: `iris_1`, `iris_2`, `iri...
      
      Table: `iris_1`
      Primary key: (`key`)
      Rows: 150
      Columns: 6
      $ key          <int> 1, 2, 3, 4, 5, 6,~
      $ Sepal.Length <dbl> 5.1, 4.9, 4.7, 4.~
      $ Sepal.Width  <dbl> 3.5, 3.0, 3.2, 3.~
      $ Petal.Length <dbl> 1.4, 1.4, 1.3, 1.~
      $ Petal.Width  <dbl> 0.2, 0.2, 0.2, 0.~
      $ Species      <fct> setosa, setosa, s~
      
      Table: `iris_2`
      1 outgoing foreign key(s):
        (`key`) -> (`iris_1$key`) no_action
      Rows: 150
      Columns: 7
      $ key          <int> 1, 2, 3, 4, 5, 6,~
      $ Sepal.Length <dbl> 5.1, 4.9, 4.7, 4.~
      $ Sepal.Width  <dbl> 3.5, 3.0, 3.2, 3.~
      $ Petal.Length <dbl> 1.4, 1.4, 1.3, 1.~
      $ Petal.Width  <dbl> 0.2, 0.2, 0.2, 0.~
      $ Species      <fct> setosa, setosa, s~
      $ other_col    <int> 1, 1, 1, 1, 1, 1,~
      
      Table: `iris_3`
      Rows: 150
      Columns: 8
      $ key          <int> 1, 2, 3, 4, 5, 6,~
      $ Sepal.Length <dbl> 5.1, 4.9, 4.7, 4.~
      $ Sepal.Width  <dbl> 3.5, 3.0, 3.2, 3.~
      $ Petal.Length <dbl> 1.4, 1.4, 1.3, 1.~
      $ Petal.Width  <dbl> 0.2, 0.2, 0.2, 0.~
      $ Species      <fct> setosa, setosa, s~
      $ other_col    <int> 1, 1, 1, 1, 1, 1,~
      $ one_more_col <dbl> 1, 1, 1, 1, 1, 1,~
    Code
      getOption("width")
    Output
      [1] 80
    Code
      glimpse(dm_for_disambiguate() %>% dm_rename(iris_1,
        gdsjgiodsjgdisogjdsiogjdsigjsdiogjisdjgiodsjgiosdjgiojsdiogjgrjihjrehoierjhiorejhrieojhreiojhieorhjioerjhierjhioerjhioerjhioerjiohjeriosdiogjsdjigjsd = key) %>%
        dm_rename_tbl(
          gdsjgiodsjgdisogjdsiogjdsigjsdiogjisdjgiodsjgiosdjgiojsdiogjgrjihjrehoierjhiorejhrieojhreiojhieorhjioerjhierjhioerjhioerjhioerjiohjeriosdiogjsdjigjsd = iris_1))
    Output
      dm of 3 tables: `gdsjgiodsjgdisogjdsiogjdsigjsdiogjisdjgiodsjgiosdjgiojsdiogjgrj...
      
      Table: `gdsjgiodsjgdisogjdsiogjdsigjsdiogjisdjgiodsjgiosdjgiojsdiogjgrjihjrehoie...
      Primary key: (`gdsjgiodsjgdisogjdsiogjdsigjsdiogjisdjgiodsjgiosdjgiojsdiogjgrjih...
      Rows: 150
      Columns: 6
      $ gdsjgiodsjgdisogjdsiogjdsigjsdiogjisdjgiodsjgiosdjgiojsdiogjgrjihjrehoierjhiorejhrieojhreiojhieorhjioerjhierjhioerjhioerjhioerjiohjeriosdiogjsdjigjsd <int> ~
      $ Sepal.Length                                                                                                                                          <dbl> ~
      $ Sepal.Width                                                                                                                                           <dbl> ~
      $ Petal.Length                                                                                                                                          <dbl> ~
      $ Petal.Width                                                                                                                                           <dbl> ~
      $ Species                                                                                                                                               <fct> ~
      
      Table: `iris_2`
      1 outgoing foreign key(s):
        (`key`) -> (`gdsjgiodsjgdisogjdsiogjdsigjsdiogjisdjgiodsjgiosdjgiojsdiogjgrjih...
      Rows: 150
      Columns: 7
      $ key          <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17~
      $ Sepal.Length <dbl> 5.1, 4.9, 4.7, 4.6, 5.0, 5.4, 4.6, 5.0, 4.4, 4.9, 5.4, 4.~
      $ Sepal.Width  <dbl> 3.5, 3.0, 3.2, 3.1, 3.6, 3.9, 3.4, 3.4, 2.9, 3.1, 3.7, 3.~
      $ Petal.Length <dbl> 1.4, 1.4, 1.3, 1.5, 1.4, 1.7, 1.4, 1.5, 1.4, 1.5, 1.5, 1.~
      $ Petal.Width  <dbl> 0.2, 0.2, 0.2, 0.2, 0.2, 0.4, 0.3, 0.2, 0.2, 0.1, 0.2, 0.~
      $ Species      <fct> setosa, setosa, setosa, setosa, setosa, setosa, setosa, s~
      $ other_col    <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ~
      
      Table: `iris_3`
      Rows: 150
      Columns: 8
      $ key          <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17~
      $ Sepal.Length <dbl> 5.1, 4.9, 4.7, 4.6, 5.0, 5.4, 4.6, 5.0, 4.4, 4.9, 5.4, 4.~
      $ Sepal.Width  <dbl> 3.5, 3.0, 3.2, 3.1, 3.6, 3.9, 3.4, 3.4, 2.9, 3.1, 3.7, 3.~
      $ Petal.Length <dbl> 1.4, 1.4, 1.3, 1.5, 1.4, 1.7, 1.4, 1.5, 1.4, 1.5, 1.5, 1.~
      $ Petal.Width  <dbl> 0.2, 0.2, 0.2, 0.2, 0.2, 0.4, 0.3, 0.2, 0.2, 0.1, 0.2, 0.~
      $ Species      <fct> setosa, setosa, setosa, setosa, setosa, setosa, setosa, s~
      $ other_col    <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ~
      $ one_more_col <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ~

