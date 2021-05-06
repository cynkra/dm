# cdm_filter() behaves correctly

    Code
      dm_for_filter_simple() %>% dm_filter(tf_1, a > 3, a < 8) %>% cdm_apply_filters() %>%
        dm_get_tables()
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
      # A tibble: 4 x 3
        c         d e    
        <chr> <int> <chr>
      1 seal      4 F    
      2 worm      5 G    
      3 dog       6 E    
      4 cat       7 F    
      
      $tf_3
      # A tibble: 3 x 2
        f     g    
        <chr> <chr>
      1 E     four 
      2 F     five 
      3 G     six  
      
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
      1 tree       f    
      2 streetlamp h    
      

