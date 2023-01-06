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
      nyc_1_uk %>% dm_add_uk(flights, c(origin, dest, time_hour)) %>% dm_add_uk(
        planes, c(year, manufacturer, model)) %>% dm_rm_uk(flights, c(origin, dest,
        time_hour)) %>% dm_get_all_uks()
    Output
      # A tibble: 2 x 2
        table   uk_col                     
        <chr>   <keys>                     
      1 flights year, month, ... (19 total)
      2 planes  year, manufacturer, model  
    Code
      nyc_1_uk %>% dm_add_uk(flights, c(origin, dest, time_hour)) %>% dm_add_uk(
        planes, c(year, manufacturer, model)) %>% dm_rm_uk(flights, everything()) %>%
        dm_get_all_uks()
    Output
      # A tibble: 2 x 2
        table   uk_col                   
        <chr>   <keys>                   
      1 flights origin, dest, time_hour  
      2 planes  year, manufacturer, model
    Code
      nyc_1_uk %>% dm_rm_uk() %>% dm_get_all_uks()
    Message
      Removing unique keys: %>%
        dm_rm_uk(flights, c(year, month, day, dep_time, sched_dep_time, dep_delay, arr_time, sched_arr_time, arr_delay, carrier, flight, tailnum, origin, dest, air_time, distance, hour, minute, time_hour))
    Output
      # A tibble: 0 x 2
      # ... with 2 variables: table <chr>, uk_col <keys>
    Code
      nyc_1_uk %>% dm_rm_uk(flights) %>% dm_get_all_uks()
    Message
      Removing unique keys: %>%
        dm_rm_uk(flights, c(year, month, day, dep_time, sched_dep_time, dep_delay, arr_time, sched_arr_time, arr_delay, carrier, flight, tailnum, origin, dest, air_time, distance, hour, minute, time_hour))
    Output
      # A tibble: 0 x 2
      # ... with 2 variables: table <chr>, uk_col <keys>
    Code
      nyc_1_uk %>% dm_rm_uk(flights, everything()) %>% dm_get_all_uks()
    Output
      # A tibble: 0 x 2
      # ... with 2 variables: table <chr>, uk_col <keys>
    Code
      nyc_1_uk %>% dm_add_uk(flights, c(origin, dest, time_hour)) %>% dm_add_uk(
        planes, c(year, manufacturer, model)) %>% dm_rm_uk() %>% dm_get_all_uks()
    Message
      Removing unique keys: %>%
        dm_rm_uk(flights, c(year, month, day, dep_time, sched_dep_time, dep_delay, arr_time, sched_arr_time, arr_delay, carrier, flight, tailnum, origin, dest, air_time, distance, hour, minute, time_hour)) %>%
        dm_rm_uk(flights, c(origin, dest, time_hour)) %>%
        dm_rm_uk(planes, c(year, manufacturer, model))
    Output
      # A tibble: 0 x 2
      # ... with 2 variables: table <chr>, uk_col <keys>
    Code
      nyc_1_uk %>% dm_add_uk(flights, c(origin, dest, time_hour)) %>% dm_add_uk(
        planes, manufacturer) %>% dm_rm_uk() %>% dm_get_all_uks()
    Message
      Removing unique keys: %>%
        dm_rm_uk(flights, c(year, month, day, dep_time, sched_dep_time, dep_delay, arr_time, sched_arr_time, arr_delay, carrier, flight, tailnum, origin, dest, air_time, distance, hour, minute, time_hour)) %>%
        dm_rm_uk(flights, c(origin, dest, time_hour)) %>%
        dm_rm_uk(planes, manufacturer)
    Output
      # A tibble: 0 x 2
      # ... with 2 variables: table <chr>, uk_col <keys>
    Code
      dm_examine_constraints(dm_nycflights_small() %>% dm_add_uk(planes, c(year,
        manufacturer, model)))
    Message
      ! Unsatisfied constraints:
    Output
      * Table `planes`: unique key `year`, `manufacturer`, `model`: has duplicate values: 2002, EMBRAER, EMB-145LR (19), 2001, EMBRAER, EMB-145LR (18), 2008, BOMBARDIER INC, CL-600-2D24 (18), 2007, BOMBARDIER INC, CL-600-2D24 (17), 1999, EMBRAER, EMB-145LR (16), ...
      * Table `flights`: foreign key `dest` into table `airports`: values of `flights$dest` not in `airports$faa`: SJU (30), BQN (6), STT (4), PSE (2)
      * Table `flights`: foreign key `tailnum` into table `planes`: values of `flights$tailnum` not in `planes$tailnum`: N725MQ (6), N537MQ (5), N722MQ (5), N730MQ (5), N736MQ (5), ...
    Code
      dm_rename(dm_for_filter(), tf_6, p = n) %>% dm_get_all_uks()
    Output
      # A tibble: 1 x 2
        table uk_col
        <chr> <keys>
      1 tf_6  p     
    Code
      dm_rename(dm_for_filter(), tf_6, p = n) %>% dm_get_all_fks()
    Output
      # A tibble: 5 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_2        e, e1         tf_3         f, f1           no_action
      3 tf_4        j, j1         tf_3         f, f1           no_action
      4 tf_5        l             tf_4         h               cascade  
      5 tf_5        m             tf_6         p               no_action
    Code
      dm_select(dm_for_filter(), tf_6, -n) %>% dm_get_all_uks()
    Output
      # A tibble: 0 x 2
      # ... with 2 variables: table <chr>, uk_col <keys>
    Code
      dm_select(dm_for_filter(), tf_6, -n) %>% dm_get_all_fks()
    Output
      # A tibble: 4 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_2        e, e1         tf_3         f, f1           no_action
      3 tf_4        j, j1         tf_3         f, f1           no_action
      4 tf_5        l             tf_4         h               cascade  

---

    (`year`, `manufacturer`, `model`) not a unique key of `planes`.

---

    There are foreign keys pointing from table(s) `flights` to table `weather`. First remove those, or set `fail_fk = FALSE`.

---

    A PK (`carrier`) for table `airlines` already exists, not adding UK.

