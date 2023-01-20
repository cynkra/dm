# dm_rows_append() works with autoincrement PKs and FKS for selected DBs

    Code
      local_dm$t1
    Output
      # A tibble: 3 x 2
            a o    
        <int> <chr>
      1     5 a    
      2     6 b    
      3     7 c    
    Code
      local_dm$t2
    Output
      # A tibble: 3 x 3
            c     d o    
        <int> <int> <chr>
      1    10     7 c    
      2     9     6 b    
      3     8     5 a    
    Code
      local_dm$t3
    Output
      # A tibble: 3 x 2
            e o    
        <int> <chr>
      1     6 b    
      2     5 a    
      3     7 c    
    Code
      local_dm$t4
    Output
      # A tibble: 3 x 3
            g     h o    
        <int> <int> <chr>
      1     1     8 a    
      2     2     9 b    
      3     3    10 c    
    Code
      filled_dm$t1
    Output
      # A tibble: 3 x 2
            a o    
        <int> <chr>
      1     5 a    
      2     6 b    
      3     7 c    
    Code
      filled_dm$t2
    Output
      # A tibble: 3 x 3
            c     d o    
        <int> <int> <chr>
      1    10     7 c    
      2     9     6 b    
      3     8     5 a    
    Code
      filled_dm$t3
    Output
      # A tibble: 0 x 2
      # ... with 2 variables: e <int>, o <chr>
    Code
      filled_dm$t4
    Output
      # A tibble: 3 x 3
            g     h o    
        <int> <int> <chr>
      1    NA     8 a    
      2    NA     9 b    
      3    NA    10 c    
    Code
      filled_dm_in_place$t1
    Output
      # A tibble: 3 x 2
            a o    
        <int> <chr>
      1     1 a    
      2     2 b    
      3     3 c    
    Code
      filled_dm_in_place$t2
    Output
      # A tibble: 3 x 3
            c     d o    
        <int> <int> <chr>
      1     1     3 c    
      2     2     2 b    
      3     3     1 a    
    Code
      filled_dm_in_place$t3
    Output
      # A tibble: 0 x 2
      # ... with 2 variables: e <int>, o <chr>
    Code
      filled_dm_in_place$t4
    Output
      # A tibble: 3 x 3
            g     h o    
        <int> <int> <chr>
      1     1     3 a    
      2     2     2 b    
      3     3     1 c    
    Code
      filled_dm_in_place_twice$t1
    Output
      # A tibble: 6 x 2
            a o    
        <int> <chr>
      1     1 a    
      2     2 b    
      3     3 c    
      4     4 a    
      5     5 b    
      6     6 c    
    Code
      filled_dm_in_place_twice$t2
    Output
      # A tibble: 6 x 3
            c     d o    
        <int> <int> <chr>
      1     1     3 c    
      2     2     2 b    
      3     3     1 a    
      4     4     6 c    
      5     5     5 b    
      6     6     4 a    
    Code
      filled_dm_in_place_twice$t3
    Output
      # A tibble: 0 x 2
      # ... with 2 variables: e <int>, o <chr>
    Code
      filled_dm_in_place_twice$t4
    Output
      # A tibble: 6 x 3
            g     h o    
        <int> <int> <chr>
      1     1     3 a    
      2     2     2 b    
      3     3     1 c    
      4     4     6 a    
      5     5     5 b    
      6     6     4 c    

