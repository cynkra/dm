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
         fact        dim_1_key_1 dim_1_key_2 dim_2_key dim_3_key dim_4_key something~1
         <chr>             <int> <chr>       <chr>     <chr>         <int>       <int>
       1 acorn                14 N           c         X                 7           1
       2 blubber              13 M           d         W                 8           2
       3 cinderella           12 L           e         V                 9           3
       4 depth                11 K           f         U                10           4
       5 elysium              10 J           g         T                11           5
       6 fantasy               9 I           h         S                12           6
       7 gorgeous              8 H           i         R                13           7
       8 halo                  7 G           j         Q                14           8
       9 ill-advised           6 F           k         P                15           9
      10 jitter                5 E           l         O                16          10
      # ... with abbreviated variable name 1: something.fact
      
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
      # ... with more rows
      
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
      # ... with more rows
      
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
      # ... with more rows
      
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
      # ... with more rows
      
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
         fact  dim_1~1 dim_1~2 dim_2~3 dim_3~4 dim_4~5 somet~6 somet~7 somet~8 somet~9
         <chr>   <int> <chr>   <chr>   <chr>     <int>   <int> <chr>   <chr>     <int>
       1 acorn      14 N       c       X             7       1 p       G            22
       2 blub~      13 M       d       W             8       2 o       H            21
       3 cind~      12 L       e       V             9       3 n       I            20
       4 depth      11 K       f       U            10       4 m       J            19
       5 elys~      10 J       g       T            11       5 l       K            18
       6 fant~       9 I       h       S            12       6 k       L            17
       7 gorg~       8 H       i       R            13       7 j       M            16
       8 halo        7 G       j       Q            14       8 i       N            15
       9 ill-~       6 F       k       P            15       9 h       O            14
      10 jitt~       5 E       l       O            16      10 g       P            13
      # ... with 1 more variable: something.dim_4 <int>, and abbreviated variable
      #   names 1: dim_1_key_1, 2: dim_1_key_2, 3: dim_2_key, 4: dim_3_key,
      #   5: dim_4_key, 6: something.fact, 7: something.dim_1, 8: something.dim_2,
      #   9: something.dim_3
    Code
      result_from_flatten_new()
    Output
         fact  dim_1~1 dim_1~2 dim_2~3 dim_3~4 dim_4~5 somet~6 somet~7 somet~8 somet~9
         <chr>   <int> <chr>   <chr>   <chr>     <int>   <int> <chr>   <chr>     <int>
       1 acorn      14 N       c       X             7       1 p       G            22
       2 blub~      13 M       d       W             8       2 o       H            21
       3 cind~      12 L       e       V             9       3 n       I            20
       4 depth      11 K       f       U            10       4 m       J            19
       5 elys~      10 J       g       T            11       5 l       K            18
       6 fant~       9 I       h       S            12       6 k       L            17
       7 gorg~       8 H       i       R            13       7 j       M            16
       8 halo        7 G       j       Q            14       8 i       N            15
       9 ill-~       6 F       k       P            15       9 h       O            14
      10 jitt~       5 E       l       O            16      10 g       P            13
      # ... with 1 more variable: something.dim_4 <int>, and abbreviated variable
      #   names 1: dim_1_key_1, 2: dim_1_key_2, 3: dim_2_key, 4: dim_3_key,
      #   5: dim_4_key, 6: something.fact, 7: something.dim_1, 8: something.dim_2,
      #   9: something.dim_3

# `dm_flatten_to_tbl()` does the right things for 'inner_join()'

    Code
      out
    Output
         fact  dim_1~1 dim_1~2 dim_2~3 dim_3~4 dim_4~5 somet~6 somet~7 somet~8 somet~9
         <chr>   <int> <chr>   <chr>   <chr>     <int>   <int> <chr>   <chr>     <int>
       1 jitt~       5 E       l       O            16      10 g       P            13
       2 ill-~       6 F       k       P            15       9 h       O            14
       3 halo        7 G       j       Q            14       8 i       N            15
       4 gorg~       8 H       i       R            13       7 j       M            16
       5 fant~       9 I       h       S            12       6 k       L            17
       6 elys~      10 J       g       T            11       5 l       K            18
       7 depth      11 K       f       U            10       4 m       J            19
       8 cind~      12 L       e       V             9       3 n       I            20
       9 blub~      13 M       d       W             8       2 o       H            21
      10 acorn      14 N       c       X             7       1 p       G            22
      # ... with 1 more variable: something.dim_4 <int>, and abbreviated variable
      #   names 1: dim_1_key_1, 2: dim_1_key_2, 3: dim_2_key, 4: dim_3_key,
      #   5: dim_4_key, 6: something.fact, 7: something.dim_1, 8: something.dim_2,
      #   9: something.dim_3

