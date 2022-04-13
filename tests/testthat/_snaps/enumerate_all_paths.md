# enumerate_all_paths() works

    Code
      enumerate_all_paths(dm_for_filter_w_cycle(), "tf_1")
    Output
      # A tibble: 10 x 7
         child_table child_cols parent_table parent_cols new_child_table
         <chr>       <keys>     <chr>        <keys>      <chr>          
       1 tf_2        e, e1      tf_3         f, f1       tf_2           
       2 tf_4        j, j1      tf_3         f, f1       tf_4-1         
       3 tf_5        l          tf_4         h           tf_5-1         
       4 tf_5        m          tf_6         n           tf_5-1         
       5 tf_6        o          tf_7         p           tf_6-1         
       6 tf_7        q          tf_2         c           tf_7-2         
       7 tf_6        o          tf_7         p           tf_6-2         
       8 tf_5        m          tf_6         n           tf_5-2         
       9 tf_5        l          tf_4         h           tf_5-2         
      10 tf_4        j, j1      tf_3         f, f1       tf_4-2         
      # ... with 2 more variables: new_parent_table <chr>, on_delete <chr>
    Code
      enumerate_all_paths(dm_for_filter_w_cycle(), "tf_5")
    Output
      # A tibble: 12 x 7
         child_table child_cols parent_table parent_cols new_child_table
         <chr>       <keys>     <chr>        <keys>      <chr>          
       1 tf_5        l          tf_4         h           tf_5           
       2 tf_4        j, j1      tf_3         f, f1       tf_4-1         
       3 tf_2        e, e1      tf_3         f, f1       tf_2-1         
       4 tf_2        d          tf_1         a           tf_2-1         
       5 tf_7        q          tf_2         c           tf_7-1         
       6 tf_6        o          tf_7         p           tf_6-1         
       7 tf_5        m          tf_6         n           tf_5           
       8 tf_6        o          tf_7         p           tf_6-2         
       9 tf_7        q          tf_2         c           tf_7-2         
      10 tf_2        d          tf_1         a           tf_2-2         
      11 tf_2        e, e1      tf_3         f, f1       tf_2-2         
      12 tf_4        j, j1      tf_3         f, f1       tf_4-2         
      # ... with 2 more variables: new_parent_table <chr>, on_delete <chr>
    Code
      enumerate_all_paths(entangled_dm(), "a")
    Output
      # A tibble: 22 x 7
         child_table child_cols parent_table parent_cols new_child_table
         <chr>       <keys>     <chr>        <keys>      <chr>          
       1 a           a          b            b           a              
       2 b           b          d            d           b-1            
       3 d           d          e            e           d-1            
       4 e           e          g            g           e-1            
       5 g           g          h            h           g-1            
       6 f           f          g            g           f-1            
       7 d           d          f            f           d-1            
       8 f           f          g            g           f-2            
       9 g           g          h            h           g-2            
      10 e           e          g            g           e-2            
      # ... with 12 more rows, and 2 more variables: new_parent_table <chr>,
      #   on_delete <chr>
    Code
      enumerate_all_paths(entangled_dm(), "c")
    Output
      # A tibble: 22 x 7
         child_table child_cols parent_table parent_cols new_child_table
         <chr>       <keys>     <chr>        <keys>      <chr>          
       1 c           c          d            d           c              
       2 d           d          e            e           d-1            
       3 e           e          g            g           e-1            
       4 g           g          h            h           g-1            
       5 f           f          g            g           f-1            
       6 d           d          f            f           d-1            
       7 f           f          g            g           f-2            
       8 g           g          h            h           g-2            
       9 e           e          g            g           e-2            
      10 b           b          d            d           b-1            
      # ... with 12 more rows, and 2 more variables: new_parent_table <chr>,
      #   on_delete <chr>
    Code
      enumerate_all_paths(entangled_dm_2(), "a")
    Output
      # A tibble: 8 x 7
        child_table child_cols parent_table parent_cols new_child_table
        <chr>       <keys>     <chr>        <keys>      <chr>          
      1 a           a          d            d           a              
      2 d           d          e            e           d-1            
      3 b           b          d            d           b-1            
      4 c           c          d            d           c-1            
      5 a           a          e            e           a              
      6 d           d          e            e           d-2            
      7 b           b          d            d           b-2            
      8 c           c          d            d           c-2            
      # ... with 2 more variables: new_parent_table <chr>, on_delete <chr>
    Code
      enumerate_all_paths(entangled_dm_2(), "d")
    Output
      # A tibble: 4 x 7
        child_table child_cols parent_table parent_cols new_child_table
        <chr>       <keys>     <chr>        <keys>      <chr>          
      1 d           d          e            e           d              
      2 a           a          e            e           a-1            
      3 a           a          d            d           a-2            
      4 a           a          e            e           a-2            
      # ... with 2 more variables: new_parent_table <chr>, on_delete <chr>

