# `dm_flatten_to_tbl()` does the right things for 'inner_join()'

    Code
      out
    Output
         fact     dim_1_key_1 dim_1_key_2 dim_2_key dim_3_key dim_4_key something.fact
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
      # i 4 more variables: something.dim_1 <chr>, something.dim_2 <chr>,
      #   something.dim_3 <int>, something.dim_4 <int>

