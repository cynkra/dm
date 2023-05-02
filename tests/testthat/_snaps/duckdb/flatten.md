# `dm_flatten_to_tbl()` does the right things for 'left_join()'

    Code
      prepare_dm_for_flatten(dm_for_flatten(), tables = c("fact", "dim_1", "dim_2",
        "dim_3", "dim_4"), gotta_rename = TRUE) %>% dm_get_tables()
    Message
      Renaming ambiguous columns: %>%
        dm_rename(fact, something.fact = something) %>%
        dm_rename(dim_1, something.dim_1 = something) %>%
        dm_rename(dim_2, something.dim_2 = something) %>%
        dm_rename(dim_3, something.dim_3 = something) %>%
        dm_rename(dim_4, something.dim_4 = something)
    Output
      $fact
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
      
      $dim_1
         dim_1_pk_1 dim_1_pk_2 something.dim_1
              <int> <chr>      <chr>          
       1          1 A          c              
       2          2 B          d              
       3          3 C          e              
       4          4 D          f              
       5          5 E          g              
       6          6 F          h              
       7          7 G          i              
       8          8 H          j              
       9          9 I          k              
      10         10 J          l              
      # i more rows
      
      $dim_2
         dim_2_pk something.dim_2
         <chr>    <chr>          
       1 a        E              
       2 b        F              
       3 c        G              
       4 d        H              
       5 e        I              
       6 f        J              
       7 g        K              
       8 h        L              
       9 i        M              
      10 j        N              
      # i more rows
      
      $dim_3
         dim_3_pk something.dim_3
         <chr>              <int>
       1 E                      3
       2 F                      4
       3 G                      5
       4 H                      6
       5 I                      7
       6 J                      8
       7 K                      9
       8 L                     10
       9 M                     11
      10 N                     12
      # i more rows
      
      $dim_4
         dim_4_pk something.dim_4
            <int>           <int>
       1       19              19
       2       18              20
       3       17              21
       4       16              22
       5       15              23
       6       14              24
       7       13              25
       8       12              26
       9       11              27
      10       10              28
      # i more rows
      
    Code
      dm_flatten_to_tbl(dm_for_flatten(), fact)
    Message
      Renaming ambiguous columns: %>%
        dm_rename(fact, something.fact = something) %>%
        dm_rename(dim_1, something.dim_1 = something) %>%
        dm_rename(dim_2, something.dim_2 = something) %>%
        dm_rename(dim_3, something.dim_3 = something) %>%
        dm_rename(dim_4, something.dim_4 = something)
    Output
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
      # i 4 more variables: something.dim_1 <chr>, something.dim_2 <chr>,
      #   something.dim_3 <int>, something.dim_4 <int>
    Code
      result_from_flatten_new()
    Output
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
      # i 4 more variables: something.dim_1 <chr>, something.dim_2 <chr>,
      #   something.dim_3 <int>, something.dim_4 <int>

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

