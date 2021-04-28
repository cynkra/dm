# output for compound keys

    Code
      unite_weather_dm <- nyc_comp() %>% dm_zoom_to(weather) %>% mutate(chr_col = "airport") %>%
        unite("new_col", origin, chr_col) %>% dm_update_zoomed()
      unite_weather_dm %>% get_all_keys("flights")
    Output
      <list_of<character>[3]>
      [[1]]
      [1] "carrier"
      
      [[2]]
      [1] "origin"
      
      [[3]]
      [1] "tailnum"
      
    Code
      unite_weather_dm %>% get_all_keys("weather")
    Output
      <list_of<character>[0]>
    Code
      unite_flights_dm <- nyc_comp() %>% dm_zoom_to(flights) %>% mutate(chr_col = "airport") %>%
        unite("new_col", origin, chr_col) %>% dm_update_zoomed()
      unite_flights_dm %>% get_all_keys("flights")
    Output
      <list_of<character>[2]>
      [[1]]
      [1] "carrier"
      
      [[2]]
      [1] "tailnum"
      
    Code
      unite_flights_dm %>% get_all_keys("weather")
    Output
      <list_of<character>[2]>
      [[1]]
      [1] "origin"
      
      [[2]]
      [1] "time_hour"
      
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

