# key tracking works (6)

    Code
      zoomed_grouped_in_dm %>% select(g_new = g) %>% get_all_keys("tf_3")
    Output
      $pks
      # A tibble: 1 x 2
        table pk_col
        <chr> <keys>
      1 tf_3  f, f1 
      
      $fks
      # A tibble: 2 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 tf_2        e, e1         tf_3         f, f1           no_action
      2 tf_4        j, j1         tf_3         f, f1           no_action
      

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
      Foreign keys: 4
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
      Foreign keys: 4
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
      Foreign keys: 4
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
      Foreign keys: 4
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
    Message
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
    Message
      Renaming ambiguous columns: %>%
        dm_rename(weather, weather.year = year) %>%
        dm_rename(weather, weather.month = month) %>%
        dm_rename(weather, weather.day = day) %>%
        dm_rename(weather, weather.hour = hour) %>%
        dm_rename(flights, flights.year = year) %>%
        dm_rename(flights, flights.month = month) %>%
        dm_rename(flights, flights.day = day) %>%
        dm_rename(flights, flights.hour = hour)
    Output
      [1] 1800
    Code
      zoomed_comp_dm %>% right_join(flights) %>% nrow()
    Message
      Renaming ambiguous columns: %>%
        dm_rename(weather, weather.year = year) %>%
        dm_rename(weather, weather.month = month) %>%
        dm_rename(weather, weather.day = day) %>%
        dm_rename(weather, weather.hour = hour) %>%
        dm_rename(flights, flights.year = year) %>%
        dm_rename(flights, flights.month = month) %>%
        dm_rename(flights, flights.day = day) %>%
        dm_rename(flights, flights.hour = hour)
    Output
      [1] 1761
    Code
      zoomed_comp_dm %>% inner_join(flights) %>% nrow()
    Message
      Renaming ambiguous columns: %>%
        dm_rename(weather, weather.year = year) %>%
        dm_rename(weather, weather.month = month) %>%
        dm_rename(weather, weather.day = day) %>%
        dm_rename(weather, weather.hour = hour) %>%
        dm_rename(flights, flights.year = year) %>%
        dm_rename(flights, flights.month = month) %>%
        dm_rename(flights, flights.day = day) %>%
        dm_rename(flights, flights.hour = hour)
    Output
      [1] 1761
    Code
      zoomed_comp_dm %>% full_join(flights) %>% nrow()
    Message
      Renaming ambiguous columns: %>%
        dm_rename(weather, weather.year = year) %>%
        dm_rename(weather, weather.month = month) %>%
        dm_rename(weather, weather.day = day) %>%
        dm_rename(weather, weather.hour = hour) %>%
        dm_rename(flights, flights.year = year) %>%
        dm_rename(flights, flights.month = month) %>%
        dm_rename(flights, flights.day = day) %>%
        dm_rename(flights, flights.hour = hour)
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

