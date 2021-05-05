# we get filtered/unfiltered tables with respective funs

    Code
      dm_for_filter() %>% dm_filter(tf_1, a > 3, a < 8) %>% dm_apply_filters() %>%
        dm_get_tables() %>% map(harmonize_tbl)
    Output
      $tf_1
      # A tibble: 4 x 2
            a b    
        <int> <chr>
      1     4 D    
      2     5 E    
      3     6 F    
      4     7 G    
      
      $tf_2
      # A tibble: 4 x 4
        c         d e        e1
        <chr> <int> <chr> <int>
      1 cat       7 F         6
      2 dog       6 E         5
      3 seal      4 F         6
      4 worm      5 G         7
      
      $tf_3
      # A tibble: 3 x 3
        f        f1 g    
        <chr> <int> <chr>
      1 E         5 four 
      2 F         6 five 
      3 G         7 six  
      
      $tf_4
      # A tibble: 3 x 4
        h     i     j        j1
        <chr> <chr> <chr> <int>
      1 c     five  E         5
      2 d     six   F         6
      3 e     seven F         6
      
      $tf_5
      # A tibble: 3 x 3
            k l     m         
        <int> <chr> <chr>     
      1     2 c     tree      
      2     3 d     streetlamp
      3     4 e     streetlamp
      
      $tf_6
      # A tibble: 2 x 2
        n          o    
        <chr>      <chr>
      1 streetlamp h    
      2 tree       f    
      

# dm_filter() works as intended for reversed dm

    Code
      dm_for_filter_rev() %>% dm_filter(tf_1, a < 8, a > 3) %>% dm_apply_filters() %>%
        dm_get_tables() %>% map(harmonize_tbl)
    Output
      $tf_6
      # A tibble: 2 x 2
        n          o    
        <chr>      <chr>
      1 streetlamp h    
      2 tree       f    
      
      $tf_5
      # A tibble: 3 x 3
            k l     m         
        <int> <chr> <chr>     
      1     2 c     tree      
      2     3 d     streetlamp
      3     4 e     streetlamp
      
      $tf_4
      # A tibble: 3 x 4
        h     i     j        j1
        <chr> <chr> <chr> <int>
      1 c     five  E         5
      2 d     six   F         6
      3 e     seven F         6
      
      $tf_3
      # A tibble: 3 x 3
        f        f1 g    
        <chr> <int> <chr>
      1 E         5 four 
      2 F         6 five 
      3 G         7 six  
      
      $tf_2
      # A tibble: 4 x 4
        c         d e        e1
        <chr> <int> <chr> <int>
      1 cat       7 F         6
      2 dog       6 E         5
      3 seal      4 F         6
      4 worm      5 G         7
      
      $tf_1
      # A tibble: 4 x 2
            a b    
        <int> <chr>
      1     4 D    
      2     5 E    
      3     6 F    
      4     7 G    
      

# dm_filter() works as intended for inbetween table

    Code
      dm_for_filter() %>% dm_filter(tf_3, g == "five") %>% dm_apply_filters() %>%
        dm_get_tables() %>% map(harmonize_tbl)
    Output
      $tf_1
      # A tibble: 2 x 2
            a b    
        <int> <chr>
      1     4 D    
      2     7 G    
      
      $tf_2
      # A tibble: 2 x 4
        c         d e        e1
        <chr> <int> <chr> <int>
      1 cat       7 F         6
      2 seal      4 F         6
      
      $tf_3
      # A tibble: 1 x 3
        f        f1 g    
        <chr> <int> <chr>
      1 F         6 five 
      
      $tf_4
      # A tibble: 2 x 4
        h     i     j        j1
        <chr> <chr> <chr> <int>
      1 d     six   F         6
      2 e     seven F         6
      
      $tf_5
      # A tibble: 2 x 3
            k l     m         
        <int> <chr> <chr>     
      1     3 d     streetlamp
      2     4 e     streetlamp
      
      $tf_6
      # A tibble: 1 x 2
        n          o    
        <chr>      <chr>
      1 streetlamp h    
      

# dm_filter() output for compound keys

    Code
      nyc_comp() %>% dm_filter(flights, sched_dep_time <= 1200) %>% dm_apply_filters() %>%
        dm_nrow()
    Output
      airlines airports  flights   planes  weather 
            15       77     4426     1745      285 
    Code
      nyc_comp() %>% dm_filter(weather, pressure < 1020) %>% dm_apply_filters() %>%
        dm_nrow()
    Output
      airlines airports  flights   planes  weather 
            16       91     5869     1881      450 

