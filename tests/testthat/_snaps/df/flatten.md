# `dm_flatten_to_tbl()` does the right things for 'inner_join()'

    Code
      out
    Output
      # A tibble: 10 x 11
         fact     dim_1_key_1 dim_1_key_2 dim_2_key dim_3_key dim_4_key something.fact
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
      # * 4 more variables: something.dim_1 <chr>, something.dim_2 <chr>,
      #   something.dim_3 <int>, something.dim_4 <int>

