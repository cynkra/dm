# `dm_to_tibble()`/`tibble_to_dm()` round trip works

    Code
      tbl <- dm_to_tibble(dm_for_filter(), tf_4)
    Message <message>
      Rebuild a dm from this object using : %>%
        dm(tf_4 = .) %>%
        dm_add_pk(tf_4, "h") %>%
        dm_unnest_tbl(tf_4, tf_5, parent_fk = h, child_fk_names = "l", child_pk_names = "k") %>%
        dm_unpack_tbl(tf_5, tf_6, child_fk = m, parent_fk_names = "n", parent_pk_names = "o") %>%
        dm_unpack_tbl(tf_4, tf_3, child_fk = c(j, j1), parent_fk_names = c("f", "f1"), parent_pk_names = c("f", "f1")) %>%
        dm_unnest_tbl(tf_3, tf_2, parent_fk = c(f, f1), child_fk_names = c("e", "e1"), child_pk_names = "c") %>%
        dm_unpack_tbl(tf_2, tf_1, child_fk = d, parent_fk_names = "a", parent_pk_names = "a")
    Code
      tbl
    Output
      # A tibble: 5 x 6
        h     i     j        j1 tf_3$g $tf_2            tf_5            
        <chr> <chr> <chr> <int> <chr>  <nested>         <nested>        
      1 a     three C         3 two    <tibble [0 x 3]> <tibble [0 x 3]>
      2 b     four  D         4 three  <tibble [1 x 3]> <tibble [1 x 3]>
      3 c     five  E         5 four   <tibble [2 x 3]> <tibble [1 x 3]>
      4 d     six   F         6 five   <tibble [2 x 3]> <tibble [1 x 3]>
      5 e     seven F         6 five   <tibble [2 x 3]> <tibble [1 x 3]>
    Code
      tbl$tf_3$tf_2[[3]]
    Output
      # A tibble: 2 x 3
        c         d tf_1$b
        <chr> <int> <chr> 
      1 lion      3 C     
      2 dog       6 F     
    Code
      tbl$tf_5[[2]]
    Output
      # A tibble: 1 x 3
            k m     tf_6$o
        <int> <chr> <chr> 
      1     1 house e     

---

    Code
      dm2 <- tibble_to_dm(tbl, dm_for_filter())
      dm2
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `tf_4`, `tf_5`, `tf_3`, `tf_6`, `tf_2`, `tf_1`
      Columns: 18
      Primary keys: 6
      Foreign keys: 5
    Code
      dm2$tf_4
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
      dm2$tf_1
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
      dm2$tf_6
    Output
      # A tibble: 3 x 2
        n          o    
        <chr>      <chr>
      1 house      e    
      2 tree       f    
      3 streetlamp h    

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

