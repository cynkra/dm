# dm_filter() deprecations

    Code
      dm_filter(dm_for_filter(), tf_1, a > 4)
    Condition
      Warning:
      The `table` argument of `dm_filter()` is deprecated as of dm 1.0.0.
      i `dm_filter()` now takes named filter expressions, the names correspond to the tables to be filtered. You no longer need to call `dm_apply_filters()` to materialize the filters.
    Output
      -- Table source ----------------------------------------------------------------
      src:  <src>
      -- Metadata --------------------------------------------------------------------
      Tables: `tf_1`, `tf_2`, `tf_3`, `tf_4`, `tf_5`, `tf_6`
      Columns: 20
      Primary keys: 6
      Foreign keys: 5
      -- Filters ---------------------------------------------------------------------
      tf_1: a > 4
    Code
      dm_filter(dm = dm_for_filter(), tf_1, a > 4)
    Condition
      Warning:
      The `dm` argument of `dm_filter()` is deprecated as of dm 1.0.0.
      i Please use the `.dm` argument instead.
      Warning:
      The `table` argument of `dm_filter()` is deprecated as of dm 1.0.0.
      i `dm_filter()` now takes named filter expressions, the names correspond to the tables to be filtered. You no longer need to call `dm_apply_filters()` to materialize the filters.
    Output
      -- Table source ----------------------------------------------------------------
      src:  <src>
      -- Metadata --------------------------------------------------------------------
      Tables: `tf_1`, `tf_2`, `tf_3`, `tf_4`, `tf_5`, `tf_6`
      Columns: 20
      Primary keys: 6
      Foreign keys: 5
      -- Filters ---------------------------------------------------------------------
      tf_1: a > 4
    Code
      dm_filter(dm_for_filter(), tf_1, a > 4) %>% dm_apply_filters()
    Condition
      Warning:
      The `table` argument of `dm_filter()` is deprecated as of dm 1.0.0.
      i `dm_filter()` now takes named filter expressions, the names correspond to the tables to be filtered. You no longer need to call `dm_apply_filters()` to materialize the filters.
    Output
      -- Table source ----------------------------------------------------------------
      src:  <src>
      -- Metadata --------------------------------------------------------------------
      Tables: `tf_1`, `tf_2`, `tf_3`, `tf_4`, `tf_5`, `tf_6`
      Columns: 20
      Primary keys: 6
      Foreign keys: 5
    Code
      dm_filter(dm_for_filter(), tf_1 = a > 4) %>% dm_apply_filters()
    Condition
      Warning:
      `dm_apply_filters()` was deprecated in dm 1.0.0.
      i Calling `dm_apply_filters()` after `dm_filter()` is no longer necessary.
    Output
      -- Table source ----------------------------------------------------------------
      src:  <src>
      -- Metadata --------------------------------------------------------------------
      Tables: `tf_1`, `tf_2`, `tf_3`, `tf_4`, `tf_5`, `tf_6`
      Columns: 20
      Primary keys: 6
      Foreign keys: 5
    Code
      dm_filter(dm_for_filter(), tf_1, a > 4) %>% dm_apply_filters_to_tbl(tf_2)
    Condition
      Warning:
      The `table` argument of `dm_filter()` is deprecated as of dm 1.0.0.
      i `dm_filter()` now takes named filter expressions, the names correspond to the tables to be filtered. You no longer need to call `dm_apply_filters()` to materialize the filters.
    Output
        c         d e        e1
        <chr> <int> <chr> <int>
      1 cat       7 F         6
      2 dog       6 E         5
      3 worm      5 G         7
    Code
      dm_filter(dm_for_filter(), tf_1 = a > 4) %>% dm_apply_filters_to_tbl(tf_2)
    Condition
      Warning:
      `dm_apply_filters_to_tbl()` was deprecated in dm 1.0.0.
      i Access tables directly after `dm_filter()`.
    Output
        c         d e        e1
        <chr> <int> <chr> <int>
      1 cat       7 F         6
      2 dog       6 E         5
      3 worm      5 G         7
    Code
      dm_filter(dm_for_filter(), tf_1, a > 4) %>% dm_get_filters()
    Condition
      Warning:
      The `table` argument of `dm_filter()` is deprecated as of dm 1.0.0.
      i `dm_filter()` now takes named filter expressions, the names correspond to the tables to be filtered. You no longer need to call `dm_apply_filters()` to materialize the filters.
    Output
      # A tibble: 1 x 3
        table filter     zoomed
        <chr> <list>     <lgl> 
      1 tf_1  <language> FALSE 
    Code
      dm_filter(dm_for_filter(), tf_1 = a > 4) %>% dm_get_filters()
    Condition
      Warning:
      `dm_get_filters()` was deprecated in dm 1.0.0.
      i Filter conditions are no longer stored with the dm object.
    Output
      # A tibble: 0 x 3
      # i 3 variables: table <chr>, filter <list>, zoomed <lgl>

# dm_filter() works as intended for reversed dm

    Code
      dm_for_filter_rev() %>% dm_filter(tf_1 = a < 8 & a > 3) %>% dm_get_tables() %>%
        map(harmonize_tbl)
    Output
      $tf_6
      # A tibble: 2 x 3
           zz n          o    
        <int> <chr>      <chr>
      1     1 streetlamp h    
      2     1 tree       f    
      
      $tf_5
      # A tibble: 3 x 4
           ww     k l     m         
        <int> <int> <chr> <chr>     
      1     2     2 c     tree      
      2     2     3 d     streetlamp
      3     2     4 e     streetlamp
      
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
      

