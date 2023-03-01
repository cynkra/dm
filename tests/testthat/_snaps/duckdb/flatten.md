# `dm_flatten_to_tbl()` does the right things for 'left_join()'

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
         <chr>   <int> <chr>   <chr>   <chr>     <int>   <int> <chr>   <chr>   <chr>  
       1 jitt~       5 E       l       O            16      10 g       P       P      
       2 ill-~       6 F       k       P            15       9 h       O       O      
       3 halo        7 G       j       Q            14       8 i       N       N      
       4 gorg~       8 H       i       R            13       7 j       M       M      
       5 fant~       9 I       h       S            12       6 k       L       L      
       6 elys~      10 J       g       T            11       5 l       K       K      
       7 depth      11 K       f       U            10       4 m       J       J      
       8 cind~      12 L       e       V             9       3 n       I       I      
       9 blub~      13 M       d       W             8       2 o       H       H      
      10 acorn      14 N       c       X             7       1 p       G       G      
      # ... with 1 more variable: something.dim_4 <chr>, and abbreviated variable
      #   names 1: dim_1_key_1, 2: dim_1_key_2, 3: dim_2_key, 4: dim_3_key,
      #   5: dim_4_key, 6: something.fact, 7: something.dim_1, 8: something.dim_2,
      #   9: something.dim_3
    Code
      result_from_flatten_new()
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

# `dm_flatten_to_tbl()` does the right things for 'inner_join()'

    Code
      out
    Output
         fact  dim_1~1 dim_1~2 dim_2~3 dim_3~4 dim_4~5 somet~6 somet~7 somet~8 somet~9
         <chr>   <int> <chr>   <chr>   <chr>     <int>   <int> <chr>   <chr>   <chr>  
       1 jitt~       5 E       l       O            16      10 g       P       P      
       2 ill-~       6 F       k       P            15       9 h       O       O      
       3 halo        7 G       j       Q            14       8 i       N       N      
       4 gorg~       8 H       i       R            13       7 j       M       M      
       5 fant~       9 I       h       S            12       6 k       L       L      
       6 elys~      10 J       g       T            11       5 l       K       K      
       7 depth      11 K       f       U            10       4 m       J       J      
       8 cind~      12 L       e       V             9       3 n       I       I      
       9 blub~      13 M       d       W             8       2 o       H       H      
      10 acorn      14 N       c       X             7       1 p       G       G      
      # ... with 1 more variable: something.dim_4 <chr>, and abbreviated variable
      #   names 1: dim_1_key_1, 2: dim_1_key_2, 3: dim_2_key, 4: dim_3_key,
      #   5: dim_4_key, 6: something.fact, 7: something.dim_1, 8: something.dim_2,
      #   9: something.dim_3

