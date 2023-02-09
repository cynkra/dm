# unique keys

    Code
      nyc_1_uk <- dm_add_uk(dm_nycflights_small(), flights, everything())
      nyc_1_uk %>% dm_get_all_uks()
    Output
      # A tibble: 4 x 3
        table    uk_col                      kind       
        <chr>    <keys>                      <chr>      
      1 airlines carrier                     PK         
      2 airports faa                         PK         
      3 planes   tailnum                     PK         
      4 flights  year, month, ... (19 total) explicit UK
    Code
      nyc_1_uk %>% dm_add_uk(flights, c(origin, dest, time_hour)) %>% dm_add_uk(
        planes, c(year, manufacturer, model)) %>% dm_get_all_uks()
    Output
      # A tibble: 6 x 3
        table    uk_col                      kind       
        <chr>    <keys>                      <chr>      
      1 airlines carrier                     PK         
      2 airports faa                         PK         
      3 planes   tailnum                     PK         
      4 flights  year, month, ... (19 total) explicit UK
      5 flights  origin, dest, time_hour     explicit UK
      6 planes   year, manufacturer, model   explicit UK
    Code
      nyc_1_uk %>% dm_add_uk(flights, c(origin, dest, time_hour)) %>% dm_add_uk(
        planes, c(year, manufacturer, model)) %>% dm_rm_uk(flights, c(origin, dest,
        time_hour)) %>% dm_get_all_uks()
    Output
      # A tibble: 5 x 3
        table    uk_col                      kind       
        <chr>    <keys>                      <chr>      
      1 airlines carrier                     PK         
      2 airports faa                         PK         
      3 planes   tailnum                     PK         
      4 flights  year, month, ... (19 total) explicit UK
      5 planes   year, manufacturer, model   explicit UK
    Code
      nyc_1_uk %>% dm_add_uk(flights, c(origin, dest, time_hour)) %>% dm_add_uk(
        planes, c(year, manufacturer, model)) %>% dm_rm_uk(flights, everything()) %>%
        dm_get_all_uks()
    Output
      # A tibble: 5 x 3
        table    uk_col                    kind       
        <chr>    <keys>                    <chr>      
      1 airlines carrier                   PK         
      2 airports faa                       PK         
      3 planes   tailnum                   PK         
      4 flights  origin, dest, time_hour   explicit UK
      5 planes   year, manufacturer, model explicit UK
    Code
      nyc_1_uk %>% dm_rm_uk() %>% dm_get_all_uks()
    Message
      Removing unique keys: %>%
        dm_rm_uk(flights, c(year, month, day, dep_time, sched_dep_time, dep_delay, arr_time, sched_arr_time, arr_delay, carrier, flight, tailnum, origin, dest, air_time, distance, hour, minute, time_hour))
    Output
      # A tibble: 3 x 3
        table    uk_col  kind 
        <chr>    <keys>  <chr>
      1 airlines carrier PK   
      2 airports faa     PK   
      3 planes   tailnum PK   
    Code
      nyc_1_uk %>% dm_rm_uk(flights) %>% dm_get_all_uks()
    Message
      Removing unique keys: %>%
        dm_rm_uk(flights, c(year, month, day, dep_time, sched_dep_time, dep_delay, arr_time, sched_arr_time, arr_delay, carrier, flight, tailnum, origin, dest, air_time, distance, hour, minute, time_hour))
    Output
      # A tibble: 3 x 3
        table    uk_col  kind 
        <chr>    <keys>  <chr>
      1 airlines carrier PK   
      2 airports faa     PK   
      3 planes   tailnum PK   
    Code
      nyc_1_uk %>% dm_rm_uk(flights, everything()) %>% dm_get_all_uks()
    Output
      # A tibble: 3 x 3
        table    uk_col  kind 
        <chr>    <keys>  <chr>
      1 airlines carrier PK   
      2 airports faa     PK   
      3 planes   tailnum PK   
    Code
      nyc_1_uk %>% dm_add_uk(flights, c(origin, dest, time_hour)) %>% dm_add_uk(
        planes, c(year, manufacturer, model)) %>% dm_rm_uk() %>% dm_get_all_uks()
    Message
      Removing unique keys: %>%
        dm_rm_uk(flights, c(year, month, day, dep_time, sched_dep_time, dep_delay, arr_time, sched_arr_time, arr_delay, carrier, flight, tailnum, origin, dest, air_time, distance, hour, minute, time_hour)) %>%
        dm_rm_uk(flights, c(origin, dest, time_hour)) %>%
        dm_rm_uk(planes, c(year, manufacturer, model))
    Output
      # A tibble: 3 x 3
        table    uk_col  kind 
        <chr>    <keys>  <chr>
      1 airlines carrier PK   
      2 airports faa     PK   
      3 planes   tailnum PK   
    Code
      nyc_1_uk %>% dm_add_uk(flights, c(origin, dest, time_hour)) %>% dm_add_uk(
        planes, manufacturer) %>% dm_rm_uk() %>% dm_get_all_uks()
    Message
      Removing unique keys: %>%
        dm_rm_uk(flights, c(year, month, day, dep_time, sched_dep_time, dep_delay, arr_time, sched_arr_time, arr_delay, carrier, flight, tailnum, origin, dest, air_time, distance, hour, minute, time_hour)) %>%
        dm_rm_uk(flights, c(origin, dest, time_hour)) %>%
        dm_rm_uk(planes, manufacturer)
    Output
      # A tibble: 3 x 3
        table    uk_col  kind 
        <chr>    <keys>  <chr>
      1 airlines carrier PK   
      2 airports faa     PK   
      3 planes   tailnum PK   
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
      dm_add_fk(dm_nycflights_small(), flights, time_hour, weather, time_hour) %>%
        dm_get_all_uks()
    Output
      # A tibble: 4 x 3
        table    uk_col    kind       
        <chr>    <keys>    <chr>      
      1 airlines carrier   PK         
      2 airports faa       PK         
      3 planes   tailnum   PK         
      4 weather  time_hour implicit UK
    Code
      dm_add_fk(dm_nycflights_small(), flights, time_hour, weather, time_hour) %>%
        dm_add_uk(weather, time_hour) %>% dm_get_all_uks()
    Output
      # A tibble: 4 x 3
        table    uk_col    kind       
        <chr>    <keys>    <chr>      
      1 airlines carrier   PK         
      2 airports faa       PK         
      3 planes   tailnum   PK         
      4 weather  time_hour explicit UK
    Code
      dm_rename(dm_for_filter(), tf_6, p = n) %>% dm_get_all_uks()
    Output
      # A tibble: 7 x 3
        table uk_col kind       
        <chr> <keys> <chr>      
      1 tf_1  a      PK         
      2 tf_2  c      PK         
      3 tf_3  f, f1  PK         
      4 tf_4  h      PK         
      5 tf_5  k      PK         
      6 tf_6  o      PK         
      7 tf_6  p      implicit UK
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
      # A tibble: 6 x 3
        table uk_col kind 
        <chr> <keys> <chr>
      1 tf_1  a      PK   
      2 tf_2  c      PK   
      3 tf_3  f, f1  PK   
      4 tf_4  h      PK   
      5 tf_5  k      PK   
      6 tf_6  o      PK   
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
    Code
      nyc_1_uk %>% dm_get_all_uks(flights)
    Output
      # A tibble: 1 x 3
        table   uk_col                      kind       
        <chr>   <keys>                      <chr>      
      1 flights year, month, ... (19 total) explicit UK
    Code
      nyc_1_uk %>% dm_get_all_uks("airports")
    Output
      # A tibble: 1 x 3
        table    uk_col kind 
        <chr>    <keys> <chr>
      1 airports faa    PK   
    Code
      nyc_1_uk %>% dm_get_all_uks(c(airports, weather, flights, airlines))
    Output
      # A tibble: 3 x 3
        table    uk_col                      kind       
        <chr>    <keys>                      <chr>      
      1 airports faa                         PK         
      2 airlines carrier                     PK         
      3 flights  year, month, ... (19 total) explicit UK
    Code
      nyc_1_uk %>% dm_get_all_uks(starts_with("a"))
    Output
      # A tibble: 2 x 3
        table    uk_col  kind 
        <chr>    <keys>  <chr>
      1 airlines carrier PK   
      2 airports faa     PK   
    Code
      nyc_1_uk %>% dm_get_all_uks(everything())
    Output
      # A tibble: 4 x 3
        table    uk_col                      kind       
        <chr>    <keys>                      <chr>      
      1 airlines carrier                     PK         
      2 airports faa                         PK         
      3 planes   tailnum                     PK         
      4 flights  year, month, ... (19 total) explicit UK

---

    (`year`, `manufacturer`, `model`) not a unique key of `planes`.

---

    A PK (`carrier`) for table `airlines` already exists, not adding UK.

---

    Can't subset tables that don't exist.
    x Table `timetable` doesn't exist.

---

    Can't subset tables that don't exist.
    x Table `timetable` doesn't exist.

---

    A UK (`year`, `month`, `day`, `dep_time`, `sched_dep_time`, ... (19 total)) for table `flights` already exists, not adding UK.

