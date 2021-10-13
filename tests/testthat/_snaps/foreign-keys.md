# dm_add_fk() works as intended?

    Code
      dm_test_obj() %>% dm_add_pk(dm_table_4, c) %>% dm_add_fk(dm_table_1, a,
        dm_table_4) %>% get_all_keys()
    Output
      $pks
      # A tibble: 1 x 2
        table      pk_col
        <chr>      <keys>
      1 dm_table_4 c     
      
      $fks
      # A tibble: 1 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 dm_table_1  a             dm_table_4   c               no_action
      

# dm_rm_fk() works with partial matching

    Code
      dm_for_filter() %>% dm_rm_fk(tf_5) %>% get_all_keys()
    Message <simpleMessage>
      Removing foreign keys: %>%
        dm_rm_fk(tf_5, l, tf_4) %>%
        dm_rm_fk(tf_5, m, tf_6, n))
    Output
      $pks
      # A tibble: 6 x 2
        table pk_col
        <chr> <keys>
      1 tf_1  a     
      2 tf_2  c     
      3 tf_3  f, f1 
      4 tf_4  h     
      5 tf_5  k     
      6 tf_6  o     
      
      $fks
      # A tibble: 3 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_2        e, e1         tf_3         f, f1           no_action
      3 tf_4        j, j1         tf_3         f, f1           no_action
      
    Code
      dm_for_filter() %>% dm_rm_fk(columns = l) %>% get_all_keys()
    Message <simpleMessage>
      Removing foreign keys: %>%
        dm_rm_fk(tf_5, l, tf_4)
    Output
      $pks
      # A tibble: 6 x 2
        table pk_col
        <chr> <keys>
      1 tf_1  a     
      2 tf_2  c     
      3 tf_3  f, f1 
      4 tf_4  h     
      5 tf_5  k     
      6 tf_6  o     
      
      $fks
      # A tibble: 4 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_2        e, e1         tf_3         f, f1           no_action
      3 tf_4        j, j1         tf_3         f, f1           no_action
      4 tf_5        m             tf_6         n               no_action
      
    Code
      dm_for_filter() %>% dm_rm_fk(columns = c(e, e1)) %>% get_all_keys()
    Message <simpleMessage>
      Removing foreign keys: %>%
        dm_rm_fk(tf_2, c(e, e1), tf_3)
    Output
      $pks
      # A tibble: 6 x 2
        table pk_col
        <chr> <keys>
      1 tf_1  a     
      2 tf_2  c     
      3 tf_3  f, f1 
      4 tf_4  h     
      5 tf_5  k     
      6 tf_6  o     
      
      $fks
      # A tibble: 4 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_4        j, j1         tf_3         f, f1           no_action
      3 tf_5        l             tf_4         h               no_action
      4 tf_5        m             tf_6         n               no_action
      
    Code
      dm_for_filter() %>% dm_rm_fk(ref_table = tf_3) %>% get_all_keys()
    Message <simpleMessage>
      Removing foreign keys: %>%
        dm_rm_fk(tf_2, c(e, e1), tf_3) %>%
        dm_rm_fk(tf_4, c(j, j1), tf_3)
    Output
      $pks
      # A tibble: 6 x 2
        table pk_col
        <chr> <keys>
      1 tf_1  a     
      2 tf_2  c     
      3 tf_3  f, f1 
      4 tf_4  h     
      5 tf_5  k     
      6 tf_6  o     
      
      $fks
      # A tibble: 3 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_5        l             tf_4         h               no_action
      3 tf_5        m             tf_6         n               no_action
      
    Code
      dm_for_filter() %>% dm_rm_fk(ref_columns = c(f, f1)) %>% get_all_keys()
    Message <simpleMessage>
      Removing foreign keys: %>%
        dm_rm_fk(tf_2, c(e, e1), tf_3) %>%
        dm_rm_fk(tf_4, c(j, j1), tf_3)
    Output
      $pks
      # A tibble: 6 x 2
        table pk_col
        <chr> <keys>
      1 tf_1  a     
      2 tf_2  c     
      3 tf_3  f, f1 
      4 tf_4  h     
      5 tf_5  k     
      6 tf_6  o     
      
      $fks
      # A tibble: 3 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_5        l             tf_4         h               no_action
      3 tf_5        m             tf_6         n               no_action
      
    Code
      dm_for_filter() %>% dm_rm_fk() %>% get_all_keys()
    Message <simpleMessage>
      Removing foreign keys: %>%
        dm_rm_fk(tf_2, d, tf_1) %>%
        dm_rm_fk(tf_2, c(e, e1), tf_3) %>%
        dm_rm_fk(tf_4, c(j, j1), tf_3) %>%
        dm_rm_fk(tf_5, l, tf_4) %>%
        dm_rm_fk(tf_5, m, tf_6, n))
    Output
      $pks
      # A tibble: 6 x 2
        table pk_col
        <chr> <keys>
      1 tf_1  a     
      2 tf_2  c     
      3 tf_3  f, f1 
      4 tf_4  h     
      5 tf_5  k     
      6 tf_6  o     
      
      $fks
      # A tibble: 0 x 5
      # ... with 5 variables: child_table <chr>, child_fk_cols <keys>,
      #   parent_table <chr>, parent_key_cols <keys>, on_delete <chr>
      

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

