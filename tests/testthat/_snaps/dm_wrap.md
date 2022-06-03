# `dm_wrap_tbl()` and `dm_unwrap_tbl()` work

    Code
      wrapped <- dm_wrap_tbl(dm_for_filter(), tf_4)
      wrapped
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `tf_4`
      Columns: 6
      Primary keys: 1
      Foreign keys: 0
    Code
      wrapped$tf_4
    Output
      # A tibble: 5 x 6
        h     i     j        j1 tf_3$g $tf_2            tf_5            
        <chr> <chr> <chr> <int> <chr>  <nested>         <nested>        
      1 a     three C         3 two    <tibble [0 x 3]> <tibble [0 x 4]>
      2 b     four  D         4 three  <tibble [1 x 3]> <tibble [1 x 4]>
      3 c     five  E         5 four   <tibble [2 x 3]> <tibble [1 x 4]>
      4 d     six   F         6 five   <tibble [2 x 3]> <tibble [1 x 4]>
      5 e     seven F         6 five   <tibble [2 x 3]> <tibble [1 x 4]>
    Code
      wrapped$tf_4$tf_3$tf_2[[3]]
    Output
      # A tibble: 2 x 3
        c         d tf_1$b
        <chr> <int> <chr> 
      1 lion      3 C     
      2 dog       6 F     
    Code
      wrapped$tf_4$tf_5[[2]]
    Output
      # A tibble: 1 x 4
           ww     k m     tf_6$zz $o   
        <int> <int> <chr>   <int> <chr>
      1     2     1 house       1 e    

---

    Code
      unwrapped <- dm_unwrap_tbl(dm_wrap_tbl(dm_for_filter(), tf_4), dm_for_filter())
      unwrapped
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `tf_4`, `tf_5`, `tf_3`, `tf_6`, `tf_2`, `tf_1`
      Columns: 20
      Primary keys: 6
      Foreign keys: 5
    Code
      unwrapped$tf_4
    Output
      # A tibble: 5 x 4
        h     i     j        j1
        <chr> <chr> <chr> <int>
      1 a     three C         3
      2 b     four  D         4
      3 c     five  E         5
      4 d     six   F         6
      5 e     seven F         6
    Code
      unwrapped$tf_1
    Output
      # A tibble: 5 x 2
            a b    
        <int> <chr>
      1     2 B    
      2     3 C    
      3     6 F    
      4     4 D    
      5     7 G    
    Code
      unwrapped$tf_6
    Output
      # A tibble: 3 x 3
        n             zz o    
        <chr>      <int> <chr>
      1 house          1 e    
      2 tree           1 f    
      3 streetlamp     1 h    

# `node_type_from_graph()` works

    Code
      node_type_from_graph(graph)
    Output
                   tf_1              tf_2              tf_3              tf_4 
      "terminal parent"    "intermediate"    "intermediate"    "intermediate" 
                   tf_5              tf_6 
         "intermediate" "terminal parent" 

---

    Code
      node_type_from_graph(graph, drop = "tf_4")
    Output
                   tf_1              tf_2              tf_3              tf_5 
      "terminal parent"    "intermediate"    "intermediate"    "intermediate" 
                   tf_6 
      "terminal parent" 

