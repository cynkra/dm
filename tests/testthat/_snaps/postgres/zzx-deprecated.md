# dm_squash_to_tbl() deprecation warning is correct

    Code
      dm_squash_to_tbl(dm_for_flatten(), fact)
    Condition
      Warning:
      `dm_squash_to_tbl()` was deprecated in dm 1.0.0.
      i Please use `.recursive = TRUE` in `dm_flatten_to_tbl()` instead.
    Message
      Renaming ambiguous columns: %>%
        dm_rename(fact, fact.something = something) %>%
        dm_rename(dim_1, dim_1.something = something) %>%
        dm_rename(dim_2, dim_2.something = something) %>%
        dm_rename(dim_3, dim_3.something = something) %>%
        dm_rename(dim_4, dim_4.something = something)
    Output
         fact     dim_1_key_1 dim_1_key_2 dim_2_key dim_3_key dim_4_key fact.something
         <chr>          <int> <chr>       <chr>     <chr>         <int>          <int>
       1 jitter             5 E           l         O                16             10
       2 ill-adv~           6 F           k         P                15              9
       3 halo               7 G           j         Q                14              8
       4 gorgeous           8 H           i         R                13              7
       5 fantasy            9 I           h         S                12              6
       6 elysium           10 J           g         T                11              5
       7 depth             11 K           f         U                10              4
       8 cindere~          12 L           e         V                 9              3
       9 blubber           13 M           d         W                 8              2
      10 acorn             14 N           c         X                 7              1
      # i 4 more variables: dim_1.something <chr>, dim_2.something <chr>,
      #   dim_3.something <int>, dim_4.something <int>

