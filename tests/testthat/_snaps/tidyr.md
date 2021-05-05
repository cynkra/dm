# key tracking works

    Code
      zoomed_dm() %>% unite("new_col", c, e) %>% dm_update_zoomed() %>% get_all_keys(
        "tf_2")
    Output
      $pk
      list()
      
      $fks
      <list_of<character>[1]>
      [[1]]
      [1] "d"
      
      
    Code
      zoomed_dm() %>% unite("new_col", c, e, remove = FALSE) %>% dm_update_zoomed() %>%
        get_all_keys("tf_2")
    Output
      $pk
      $pk[[1]]
      [1] "c"
      
      
      $fks
      <list_of<character>[2]>
      [[1]]
      [1] "d"
      
      [[2]]
      [1] "e"
      
      
    Code
      zoomed_dm() %>% unite("new_col", c, e, remove = FALSE) %>% dm_update_zoomed() %>%
        dm_add_fk(tf_2, new_col, tf_6) %>% dm_zoom_to(tf_2) %>% separate(new_col, c(
        "c", "e"), remove = TRUE) %>% dm_update_zoomed() %>% get_all_keys("tf_2")
    Output
      $pk
      $pk[[1]]
      [1] "c"
      
      
      $fks
      <list_of<character>[2]>
      [[1]]
      [1] "d"
      
      [[2]]
      [1] "e"
      
      
    Code
      zoomed_dm() %>% unite("new_col", c, e, remove = FALSE) %>% dm_update_zoomed() %>%
        dm_add_fk(tf_2, new_col, tf_6) %>% dm_zoom_to(tf_2) %>% separate(new_col, c(
        "c", "e"), remove = FALSE) %>% dm_update_zoomed() %>% get_all_keys("tf_2")
    Output
      $pk
      $pk[[1]]
      [1] "c"
      
      
      $fks
      <list_of<character>[3]>
      [[1]]
      [1] "d"
      
      [[2]]
      [1] "e"
      
      [[3]]
      [1] "new_col"
      
      

# output for compound keys

    Code
      unite_weather_dm <- nyc_comp() %>% dm_zoom_to(weather) %>% mutate(chr_col = "airport") %>%
        unite("new_col", origin, chr_col) %>% dm_update_zoomed()
      unite_weather_dm %>% get_all_keys("flights")
    Output
      $pk
      list()
      
      $fks
      <list_of<character>[3]>
      [[1]]
      [1] "carrier"
      
      [[2]]
      [1] "dest"
      
      [[3]]
      [1] "tailnum"
      
      
    Code
      unite_weather_dm %>% get_all_keys("weather")
    Output
      $pk
      list()
      
      $fks
      <list_of<character>[0]>
      
    Code
      unite_flights_dm <- nyc_comp() %>% dm_zoom_to(flights) %>% mutate(chr_col = "airport") %>%
        unite("new_col", origin, chr_col) %>% dm_update_zoomed()
      unite_flights_dm %>% get_all_keys("flights")
    Output
      $pk
      list()
      
      $fks
      <list_of<character>[3]>
      [[1]]
      [1] "carrier"
      
      [[2]]
      [1] "dest"
      
      [[3]]
      [1] "tailnum"
      
      
    Code
      unite_flights_dm %>% get_all_keys("weather")
    Output
      $pk
      $pk[[1]]
      [1] "origin"    "time_hour"
      
      
      $fks
      <list_of<character>[0]>
      
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

