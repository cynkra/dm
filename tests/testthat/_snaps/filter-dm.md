# dm_filter() deprecations

    Code
      dm_filter(dm_for_filter(), tf_1, a > 4)
    Output
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
      Please use the `.dm` argument instead.
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `tf_1`, `tf_2`, `tf_3`, `tf_4`, `tf_5`, `tf_6`
      Columns: 20
      Primary keys: 6
      Foreign keys: 5
      -- Filters ---------------------------------------------------------------------
      tf_1: a > 4
    Code
      dm_filter(dm_for_filter(), tf_1, a > 4) %>% dm_apply_filters()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `tf_1`, `tf_2`, `tf_3`, `tf_4`, `tf_5`, `tf_6`
      Columns: 20
      Primary keys: 6
      Foreign keys: 5
    Code
      dm_filter(dm_for_filter(), tf_1 = a > 4) %>% dm_apply_filters()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `tf_1`, `tf_2`, `tf_3`, `tf_4`, `tf_5`, `tf_6`
      Columns: 20
      Primary keys: 6
      Foreign keys: 5
    Code
      dm_filter(dm_for_filter(), tf_1, a > 4) %>% dm_apply_filters_to_tbl(tf_2)
    Output
      # A tibble: 3 x 4
        c         d e        e1
        <chr> <int> <chr> <int>
      1 worm      5 G         7
      2 dog       6 E         5
      3 cat       7 F         6
    Code
      dm_filter(dm_for_filter(), tf_1 = a > 4) %>% dm_apply_filters_to_tbl(tf_2)
    Output
      # A tibble: 3 x 4
        c         d e        e1
        <chr> <int> <chr> <int>
      1 worm      5 G         7
      2 dog       6 E         5
      3 cat       7 F         6
    Code
      dm_filter(dm_for_filter(), tf_1, a > 4) %>% dm_get_filters()
    Output
      # A tibble: 1 x 3
        table filter     zoomed
        <chr> <list>     <lgl> 
      1 tf_1  <language> FALSE 
    Code
      dm_filter(dm_for_filter(), tf_1 = a > 4) %>% dm_get_filters()
    Output
      # A tibble: 0 x 3
      # ... with 3 variables: table <chr>, filter <list>, zoomed <lgl>

# data structure

    Code
      dm_more_complex() %>% dm_paste(options = c("select", "keys"))
    Message
      dm::dm(
        tf_1,
        tf_2,
        tf_3,
        tf_4,
        tf_5,
        tf_6,
        tf_7,
        tf_6_2,
        tf_4_2,
        a,
        b,
        c,
        d,
        e,
      ) %>%
        dm::dm_select(tf_1, a, b) %>%
        dm::dm_select(tf_2, c, d, e, e1) %>%
        dm::dm_select(tf_3, f, f1, g) %>%
        dm::dm_select(tf_4, h, i, j, j1) %>%
        dm::dm_select(tf_5, ww, k, l, m) %>%
        dm::dm_select(tf_6, zz, n, o) %>%
        dm::dm_select(tf_7, p, q) %>%
        dm::dm_select(tf_6_2, p, f, f1) %>%
        dm::dm_select(tf_4_2, r, s, t) %>%
        dm::dm_select(a, a_1, a_2) %>%
        dm::dm_select(b, b_1, b_2, b_3) %>%
        dm::dm_select(c, c_1) %>%
        dm::dm_select(d, d_1, b_1) %>%
        dm::dm_select(e, e_1, b_1) %>%
        dm::dm_add_pk(tf_1, a) %>%
        dm::dm_add_pk(tf_2, c) %>%
        dm::dm_add_pk(tf_3, c(f, f1)) %>%
        dm::dm_add_pk(tf_4, h) %>%
        dm::dm_add_pk(tf_5, k) %>%
        dm::dm_add_pk(tf_6, n) %>%
        dm::dm_add_pk(tf_6_2, p) %>%
        dm::dm_add_pk(tf_4_2, r) %>%
        dm::dm_add_pk(a, a_1) %>%
        dm::dm_add_pk(b, b_1) %>%
        dm::dm_add_pk(c, c_1) %>%
        dm::dm_add_pk(d, d_1) %>%
        dm::dm_add_pk(e, e_1) %>%
        dm::dm_add_fk(tf_2, d, tf_1) %>%
        dm::dm_add_fk(tf_2, c(e, e1), tf_3) %>%
        dm::dm_add_fk(tf_4, c(j, j1), tf_3) %>%
        dm::dm_add_fk(tf_6_2, c(f, f1), tf_3) %>%
        dm::dm_add_fk(tf_5, l, tf_4) %>%
        dm::dm_add_fk(tf_5, m, tf_6) %>%
        dm::dm_add_fk(tf_5, l, tf_4_2) %>%
        dm::dm_add_fk(b, b_2, a) %>%
        dm::dm_add_fk(d, b_1, b) %>%
        dm::dm_add_fk(e, b_1, b) %>%
        dm::dm_add_fk(b, b_3, c)

# we get filtered/unfiltered tables with respective funs

    Code
      dm_for_filter() %>% dm_filter(tf_1 = a > 3 & a < 8) %>% dm_get_tables() %>% map(
        harmonize_tbl)
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
      1     1 streetlamp h    
      2     1 tree       f    
      

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
      

# dm_filter() works as intended for inbetween table

    Code
      dm_for_filter() %>% dm_filter(tf_3 = g == "five") %>% dm_get_tables() %>% map(
        harmonize_tbl)
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
      # A tibble: 2 x 4
           ww     k l     m         
        <int> <int> <chr> <chr>     
      1     2     3 d     streetlamp
      2     2     4 e     streetlamp
      
      $tf_6
      # A tibble: 1 x 3
           zz n          o    
        <int> <chr>      <chr>
      1     1 streetlamp h    
      

# dm_filter() output for compound keys

    Code
      nyc_comp() %>% dm_filter(flights = sched_dep_time <= 1200) %>% dm_nrow()
    Output
      airlines airports  flights   planes  weather 
            14       63      672      502       47 
    Code
      nyc_comp() %>% dm_filter(weather = pressure < 1020) %>% dm_nrow()
    Output
      airlines airports  flights   planes  weather 
             0        0        0        0        0 

