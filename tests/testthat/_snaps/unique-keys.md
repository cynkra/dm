# unique keys

    Code
      nyc_1_uk <- dm_add_uk(dm_nycflights_small(), flights, everything())
      nyc_1_uk %>% dm_get_all_uks()
    Output
      # A tibble: 1 x 2
        table   uk_col                     
        <chr>   <keys>                     
      1 flights year, month, ... (19 total)
    Code
      nyc_1_uk %>% dm_add_uk(flights, c(origin, dest, time_hour)) %>% dm_add_uk(
        planes, c(year, manufacturer, model)) %>% dm_get_all_uks()
    Output
      # A tibble: 3 x 2
        table   uk_col                     
        <chr>   <keys>                     
      1 flights year, month, ... (19 total)
      2 flights origin, dest, time_hour    
      3 planes  year, manufacturer, model  
    Code
      dm_has_uk(nyc_1_uk, planes)
    Output
      [1] FALSE
    Code
      dm_has_uk(nyc_1_uk, flights)
    Output
      [1] TRUE
    Code
      nyc_1_uk %>% dm_rm_uk() %>% dm_get_all_uks()
    Message
      Removing unique keys: %>%
        dm_rm_uk(flights)
    Output
      # A tibble: 0 x 2
      # ... with 2 variables: table <chr>, uk_col <keys>
    Code
      nyc_1_uk %>% dm_rm_uk(flights) %>% dm_get_all_uks()
    Output
      # A tibble: 0 x 2
      # ... with 2 variables: table <chr>, uk_col <keys>
    Code
      nyc_1_uk %>% dm_rm_uk(flights, everything()) %>% dm_get_all_uks()
    Output
      # A tibble: 0 x 2
      # ... with 2 variables: table <chr>, uk_col <keys>
    Code
      dm_get_uk_impl(nyc_1_uk, "planes")
    Output
      list()
    Code
      dm_get_uk_impl(nyc_1_uk, "flights")
    Output
      [[1]]
       [1] "year"           "month"          "day"            "dep_time"      
       [5] "sched_dep_time" "dep_delay"      "arr_time"       "sched_arr_time"
       [9] "arr_delay"      "carrier"        "flight"         "tailnum"       
      [13] "origin"         "dest"           "air_time"       "distance"      
      [17] "hour"           "minute"         "time_hour"     
      
    Code
      dm_examine_constraints(dm_nycflights_small() %>% dm_add_uk(planes, c(year,
        manufacturer, model)))
    Message
      ! Unsatisfied constraints:
    Output
      * Table `planes`: unique key `year`, `manufacturer`, `model`: has duplicate values: 2002, EMBRAER, EMB-145LR (19), 2001, EMBRAER, EMB-145LR (18), 2008, BOMBARDIER INC, CL-600-2D24 (18), 2007, BOMBARDIER INC, CL-600-2D24 (17), 1999, EMBRAER, EMB-145LR (16), ...
      * Table `flights`: foreign key `dest` into table `airports`: values of `flights$dest` not in `airports$faa`: SJU (30), BQN (6), STT (4), PSE (2)
      * Table `flights`: foreign key `tailnum` into table `planes`: values of `flights$tailnum` not in `planes$tailnum`: N725MQ (6), N537MQ (5), N722MQ (5), N730MQ (5), N736MQ (5), ...

---

    Code
      dm_add_uk(dm_nycflights_small(), planes, c(year, manufacturer, model), check = TRUE)
    Condition
      Error in `abort_not_unique_key()`:
      ! (`year`, `manufacturer`, `model`) not a unique key of `planes`.

