# dm_rows_append() works with autoincrement PKs and FKS for selected DBs

    Code
      local_dm$t1
    Output
      # A tibble: 3 x 2
            a b    
        <int> <chr>
      1     5 a    
      2     6 b    
      3     7 c    
    Code
      local_dm$t2
    Output
      # A tibble: 3 x 2
            c     d
        <int> <int>
      1    10     7
      2     9     6
      3     8     5
    Code
      local_dm$t3
    Output
      # A tibble: 3 x 2
            e f    
        <int> <chr>
      1     6 a    
      2     5 b    
      3     7 c    
    Code
      local_dm$t4
    Output
      # A tibble: 3 x 2
            g     h
        <int> <int>
      1     1     8
      2     2     9
      3     3    10
    Code
      filled_dm$t1
    Output
      # A tibble: 3 x 2
            a b    
        <int> <chr>
      1    NA a    
      2    NA b    
      3    NA c    
    Code
      filled_dm$t2
    Output
      # A tibble: 3 x 2
            c     d
        <int> <int>
      1    NA    NA
      2    NA    NA
      3    NA    NA
    Code
      filled_dm$t3
    Output
      # A tibble: 3 x 2
            e f    
        <int> <chr>
      1    NA a    
      2    NA b    
      3    NA c    
    Code
      filled_dm$t4
    Output
      # A tibble: 3 x 2
            g     h
        <int> <int>
      1     1    NA
      2     2    NA
      3     3    NA
    Code
      filled_dm_in_place$t1
    Output
      # A tibble: 3 x 2
            a b    
        <int> <chr>
      1     1 a    
      2     2 b    
      3     3 c    
    Code
      filled_dm_in_place$t2
    Output
      # A tibble: 3 x 2
            c     d
        <int> <int>
      1     1     3
      2     2     2
      3     3     1
    Code
      filled_dm_in_place$t3
    Output
      # A tibble: 3 x 2
            e f    
        <int> <chr>
      1     2 a    
      2     1 b    
      3     3 c    
    Code
      filled_dm_in_place$t4
    Output
      # A tibble: 3 x 2
            g     h
        <int> <int>
      1     1     3
      2     2     2
      3     3     1

