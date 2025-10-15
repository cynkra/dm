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
      # A tibble: 3 x 4
           ww     k l     m         
        <int> <int> <chr> <chr>     
      1     2     2 c     tree      
      2     2     3 d     streetlamp
      3     2     4 e     streetlamp
      
      $tf_6
      # A tibble: 2 x 3
           zz n          o    
        <int> <chr>      <chr>
      1     1 tree       f    
      2     1 streetlamp h    
      

# dm_squash_to_tbl() deprecation warning is correct

    Code
      dm_squash_to_tbl(dm_for_flatten(), fact)
    Condition
      Warning:
      `dm_squash_to_tbl()` was deprecated in dm 1.0.0.
      i Please use `.recursive = TRUE` in `dm_flatten_to_tbl()` instead.
      Warning:
      The `father` argument of `dfs()` is deprecated as of igraph 2.2.0.
      i Please use the `parent` argument instead.
    Message
      Renaming ambiguous columns: %>%
        dm_rename(fact, fact.something = something) %>%
        dm_rename(dim_1, dim_1.something = something) %>%
        dm_rename(dim_2, dim_2.something = something) %>%
        dm_rename(dim_3, dim_3.something = something) %>%
        dm_rename(dim_4, dim_4.something = something)
    Output
      # A tibble: 10 x 11
         fact     dim_1_key_1 dim_1_key_2 dim_2_key dim_3_key dim_4_key fact.something
         <chr>          <int> <chr>       <chr>     <chr>         <int>          <int>
       1 acorn             14 N           c         X                 7              1
       2 blubber           13 M           d         W                 8              2
       3 cindere~          12 L           e         V                 9              3
       4 depth             11 K           f         U                10              4
       5 elysium           10 J           g         T                11              5
       6 fantasy            9 I           h         S                12              6
       7 gorgeous           8 H           i         R                13              7
       8 halo               7 G           j         Q                14              8
       9 ill-adv~           6 F           k         P                15              9
      10 jitter             5 E           l         O                16             10
      # i 4 more variables: dim_1.something <chr>, dim_2.something <chr>,
      #   dim_3.something <int>, dim_4.something <int>

