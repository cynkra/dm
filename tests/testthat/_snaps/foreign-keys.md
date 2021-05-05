# dm_enum_fk_candidates() works as intended?

    Code
      dm_nycflights13() %>% dm_enum_fk_candidates(flights, airports) %>% mutate(why = if_else(
        why != "", "<reason>", ""))
    Output
      # A tibble: 19 x 3
         columns        candidate why       
         <keys>         <lgl>     <chr>     
       1 origin         TRUE      ""        
       2 year           FALSE     "<reason>"
       3 month          FALSE     "<reason>"
       4 day            FALSE     "<reason>"
       5 dep_time       FALSE     "<reason>"
       6 sched_dep_time FALSE     "<reason>"
       7 dep_delay      FALSE     "<reason>"
       8 arr_time       FALSE     "<reason>"
       9 sched_arr_time FALSE     "<reason>"
      10 arr_delay      FALSE     "<reason>"
      11 carrier        FALSE     "<reason>"
      12 flight         FALSE     "<reason>"
      13 tailnum        FALSE     "<reason>"
      14 dest           FALSE     "<reason>"
      15 air_time       FALSE     "<reason>"
      16 distance       FALSE     "<reason>"
      17 hour           FALSE     "<reason>"
      18 minute         FALSE     "<reason>"
      19 time_hour      FALSE     "<reason>"

