# dm_rm_fk() works with partial matching

    Code
      dm_for_filter() %>% dm_rm_fk(tf_5) %>% dm_paste()
    Message <simpleMessage>
      Removing foreign keys: %>%
        dm_rm_fk(tf_5, l, tf_4) %>%
        dm_rm_fk(tf_5, m, tf_6, n))
    Message <cliMessage>
      dm::dm(tf_1, tf_2, tf_3, tf_4, tf_5, tf_6) %>%
        dm::dm_add_pk(tf_1, a) %>%
        dm::dm_add_pk(tf_2, c) %>%
        dm::dm_add_pk(tf_3, c(f, f1)) %>%
        dm::dm_add_pk(tf_4, h) %>%
        dm::dm_add_pk(tf_5, k) %>%
        dm::dm_add_pk(tf_6, o) %>%
        dm::dm_add_fk(tf_2, d, tf_1) %>%
        dm::dm_add_fk(tf_2, c(e, e1), tf_3) %>%
        dm::dm_add_fk(tf_4, c(j, j1), tf_3)
    Code
      dm_for_filter() %>% dm_rm_fk(columns = l) %>% dm_paste()
    Message <simpleMessage>
      Removing foreign keys: %>%
        dm_rm_fk(tf_5, l, tf_4)
    Message <cliMessage>
      dm::dm(tf_1, tf_2, tf_3, tf_4, tf_5, tf_6) %>%
        dm::dm_add_pk(tf_1, a) %>%
        dm::dm_add_pk(tf_2, c) %>%
        dm::dm_add_pk(tf_3, c(f, f1)) %>%
        dm::dm_add_pk(tf_4, h) %>%
        dm::dm_add_pk(tf_5, k) %>%
        dm::dm_add_pk(tf_6, o) %>%
        dm::dm_add_fk(tf_2, d, tf_1) %>%
        dm::dm_add_fk(tf_2, c(e, e1), tf_3) %>%
        dm::dm_add_fk(tf_4, c(j, j1), tf_3) %>%
        dm::dm_add_fk(tf_5, m, tf_6, n)
    Code
      dm_for_filter() %>% dm_rm_fk(columns = c(e, e1)) %>% dm_paste()
    Message <simpleMessage>
      Removing foreign keys: %>%
        dm_rm_fk(tf_2, c(e, e1), tf_3)
    Message <cliMessage>
      dm::dm(tf_1, tf_2, tf_3, tf_4, tf_5, tf_6) %>%
        dm::dm_add_pk(tf_1, a) %>%
        dm::dm_add_pk(tf_2, c) %>%
        dm::dm_add_pk(tf_3, c(f, f1)) %>%
        dm::dm_add_pk(tf_4, h) %>%
        dm::dm_add_pk(tf_5, k) %>%
        dm::dm_add_pk(tf_6, o) %>%
        dm::dm_add_fk(tf_2, d, tf_1) %>%
        dm::dm_add_fk(tf_4, c(j, j1), tf_3) %>%
        dm::dm_add_fk(tf_5, l, tf_4) %>%
        dm::dm_add_fk(tf_5, m, tf_6, n)
    Code
      dm_for_filter() %>% dm_rm_fk(ref_table = tf_3) %>% dm_paste()
    Message <simpleMessage>
      Removing foreign keys: %>%
        dm_rm_fk(tf_2, c(e, e1), tf_3) %>%
        dm_rm_fk(tf_4, c(j, j1), tf_3)
    Message <cliMessage>
      dm::dm(tf_1, tf_2, tf_3, tf_4, tf_5, tf_6) %>%
        dm::dm_add_pk(tf_1, a) %>%
        dm::dm_add_pk(tf_2, c) %>%
        dm::dm_add_pk(tf_3, c(f, f1)) %>%
        dm::dm_add_pk(tf_4, h) %>%
        dm::dm_add_pk(tf_5, k) %>%
        dm::dm_add_pk(tf_6, o) %>%
        dm::dm_add_fk(tf_2, d, tf_1) %>%
        dm::dm_add_fk(tf_5, l, tf_4) %>%
        dm::dm_add_fk(tf_5, m, tf_6, n)
    Code
      dm_for_filter() %>% dm_rm_fk(ref_columns = c(f, f1)) %>% dm_paste()
    Message <simpleMessage>
      Removing foreign keys: %>%
        dm_rm_fk(tf_2, c(e, e1), tf_3) %>%
        dm_rm_fk(tf_4, c(j, j1), tf_3)
    Message <cliMessage>
      dm::dm(tf_1, tf_2, tf_3, tf_4, tf_5, tf_6) %>%
        dm::dm_add_pk(tf_1, a) %>%
        dm::dm_add_pk(tf_2, c) %>%
        dm::dm_add_pk(tf_3, c(f, f1)) %>%
        dm::dm_add_pk(tf_4, h) %>%
        dm::dm_add_pk(tf_5, k) %>%
        dm::dm_add_pk(tf_6, o) %>%
        dm::dm_add_fk(tf_2, d, tf_1) %>%
        dm::dm_add_fk(tf_5, l, tf_4) %>%
        dm::dm_add_fk(tf_5, m, tf_6, n)
    Code
      dm_for_filter() %>% dm_rm_fk() %>% dm_paste()
    Message <simpleMessage>
      Removing foreign keys: %>%
        dm_rm_fk(tf_2, d, tf_1) %>%
        dm_rm_fk(tf_2, c(e, e1), tf_3) %>%
        dm_rm_fk(tf_4, c(j, j1), tf_3) %>%
        dm_rm_fk(tf_5, l, tf_4) %>%
        dm_rm_fk(tf_5, m, tf_6, n))
    Message <cliMessage>
      dm::dm(tf_1, tf_2, tf_3, tf_4, tf_5, tf_6) %>%
        dm::dm_add_pk(tf_1, a) %>%
        dm::dm_add_pk(tf_2, c) %>%
        dm::dm_add_pk(tf_3, c(f, f1)) %>%
        dm::dm_add_pk(tf_4, h) %>%
        dm::dm_add_pk(tf_5, k) %>%
        dm::dm_add_pk(tf_6, o)

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

