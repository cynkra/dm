# enumerate_all_paths() works

    Code
      enumerate_all_paths(dm_for_filter_w_cycle(), "tf_1")
    Output
      $table_mapping
      # A tibble: 10 x 2
         new_table table
         <chr>     <chr>
       1 tf_7-1    tf_7 
       2 tf_6-1    tf_6 
       3 tf_5-1    tf_5 
       4 tf_4-1    tf_4 
       5 tf_4-2    tf_4 
       6 tf_5-2    tf_5 
       7 tf_6-2    tf_6 
       8 tf_3-1    tf_3 
       9 tf_3-2    tf_3 
      10 tf_7-2    tf_7 
      
      $new_fks
      # A tibble: 11 x 5
         new_child_table child_cols new_parent_table parent_cols on_delete
         <chr>           <keys>     <chr>            <keys>      <chr>    
       1 tf_2            d          tf_1             a           no_action
       2 tf_7-1          q          tf_2             c           no_action
       3 tf_6-1          o          tf_7-1           p           no_action
       4 tf_5-1          m          tf_6-1           n           no_action
       5 tf_5-1          l          tf_4-1           h           cascade  
       6 tf_4-1          j, j1      tf_3-1           f, f1       no_action
       7 tf_2            e, e1      tf_3-2           f, f1       no_action
       8 tf_4-2          j, j1      tf_3-2           f, f1       no_action
       9 tf_5-2          l          tf_4-2           h           cascade  
      10 tf_5-2          m          tf_6-2           n           no_action
      11 tf_6-2          o          tf_7-2           p           no_action
      
    Code
      enumerate_all_paths(dm_for_filter_w_cycle(), "tf_5")
    Output
      $table_mapping
      # A tibble: 12 x 2
         new_table table
         <chr>     <chr>
       1 tf_4-1    tf_4 
       2 tf_2-1    tf_2 
       3 tf_7-1    tf_7 
       4 tf_6-1    tf_6 
       5 tf_6-2    tf_6 
       6 tf_7-2    tf_7 
       7 tf_2-2    tf_2 
       8 tf_4-2    tf_4 
       9 tf_3-1    tf_3 
      10 tf_1-1    tf_1 
      11 tf_1-2    tf_1 
      12 tf_3-2    tf_3 
      
      $new_fks
      # A tibble: 12 x 5
         new_child_table child_cols new_parent_table parent_cols on_delete
         <chr>           <keys>     <chr>            <keys>      <chr>    
       1 tf_5            l          tf_4-1           h           cascade  
       2 tf_4-1          j, j1      tf_3-1           f, f1       no_action
       3 tf_2-1          e, e1      tf_3-1           f, f1       no_action
       4 tf_7-1          q          tf_2-1           c           no_action
       5 tf_6-1          o          tf_7-1           p           no_action
       6 tf_2-1          d          tf_1-1           a           no_action
       7 tf_5            m          tf_6-2           n           no_action
       8 tf_6-2          o          tf_7-2           p           no_action
       9 tf_7-2          q          tf_2-2           c           no_action
      10 tf_2-2          d          tf_1-2           a           no_action
      11 tf_2-2          e, e1      tf_3-2           f, f1       no_action
      12 tf_4-2          j, j1      tf_3-2           f, f1       no_action
      
    Code
      enumerate_all_paths(entangled_dm(), "a")
    Output
      $table_mapping
      # A tibble: 22 x 2
         new_table table
         <chr>     <chr>
       1 b-1       b    
       2 c-1       c    
       3 d-1       d    
       4 e-1       e    
       5 f-1       f    
       6 g-1       g    
       7 f-2       f    
       8 e-2       e    
       9 g-2       g    
      10 c-2       c    
      # * 12 more rows
      
      $new_fks
      # A tibble: 22 x 5
         new_child_table child_cols new_parent_table parent_cols on_delete
         <chr>           <keys>     <chr>            <keys>      <chr>    
       1 a               a          b-1              b           no_action
       2 b-1             b          d-1              d           no_action
       3 c-1             c          d-1              d           no_action
       4 d-1             d          e-1              e           no_action
       5 e-1             e          g-1              g           no_action
       6 f-1             f          g-1              g           no_action
       7 g-1             g          h-1              h           no_action
       8 d-1             d          f-2              f           no_action
       9 f-2             f          g-2              g           no_action
      10 e-2             e          g-2              g           no_action
      # * 12 more rows
      
    Code
      enumerate_all_paths(entangled_dm(), "c")
    Output
      $table_mapping
      # A tibble: 22 x 2
         new_table table
         <chr>     <chr>
       1 a-1       a    
       2 b-1       b    
       3 d-1       d    
       4 e-1       e    
       5 f-1       f    
       6 g-1       g    
       7 f-2       f    
       8 e-2       e    
       9 g-2       g    
      10 b-2       b    
      # * 12 more rows
      
      $new_fks
      # A tibble: 22 x 5
         new_child_table child_cols new_parent_table parent_cols on_delete
         <chr>           <keys>     <chr>            <keys>      <chr>    
       1 a-1             a          c                c           no_action
       2 a-1             a          b-1              b           no_action
       3 b-1             b          d-1              d           no_action
       4 d-1             d          e-1              e           no_action
       5 e-1             e          g-1              g           no_action
       6 f-1             f          g-1              g           no_action
       7 g-1             g          h-1              h           no_action
       8 d-1             d          f-2              f           no_action
       9 f-2             f          g-2              g           no_action
      10 e-2             e          g-2              g           no_action
      # * 12 more rows
      
    Code
      enumerate_all_paths(entangled_dm_2(), "a")
    Output
      $table_mapping
      # A tibble: 8 x 2
        new_table table
        <chr>     <chr>
      1 b-1       b    
      2 c-1       c    
      3 d-1       d    
      4 d-2       d    
      5 b-2       b    
      6 c-2       c    
      7 e-1       e    
      8 e-2       e    
      
      $new_fks
      # A tibble: 9 x 5
        new_child_table child_cols new_parent_table parent_cols on_delete
        <chr>           <keys>     <chr>            <keys>      <chr>    
      1 a               a          d-1              d           no_action
      2 b-1             b          d-1              d           no_action
      3 c-1             c          d-1              d           no_action
      4 d-1             d          e-1              e           no_action
      5 a               a          e-2              e           no_action
      6 d-2             d          e-2              e           no_action
      7 b-2             b          d-2              d           no_action
      8 c-2             c          d-2              d           no_action
      9 f               f          g                g           no_action
      
    Code
      enumerate_all_paths(entangled_dm_2(), "d")
    Output
      $table_mapping
      # A tibble: 4 x 2
        new_table table
        <chr>     <chr>
      1 a-1       a    
      2 a-2       a    
      3 e-1       e    
      4 e-2       e    
      
      $new_fks
      # A tibble: 7 x 5
        new_child_table child_cols new_parent_table parent_cols on_delete
        <chr>           <keys>     <chr>            <keys>      <chr>    
      1 a-1             a          d                d           no_action
      2 a-1             a          e-1              e           no_action
      3 b               b          d                d           no_action
      4 c               c          d                d           no_action
      5 d               d          e-2              e           no_action
      6 a-2             a          e-2              e           no_action
      7 f               f          g                g           no_action
      

