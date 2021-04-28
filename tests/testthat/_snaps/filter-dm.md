# dm_filter() output for compound keys

    Code
      nyc_comp() %>% dm_filter(flights, sched_dep_time <= 1200) %>% dm_apply_filters() %>%
        dm_nrow()
    Output
      airlines airports  flights   planes  weather 
            15       77     4426     1745      861 
    Code
      nyc_comp() %>% dm_filter(weather, pressure < 1020) %>% dm_apply_filters() %>%
        dm_nrow()
    Output
      airlines airports  flights   planes  weather 
            16     1458    11227     3322      450 

