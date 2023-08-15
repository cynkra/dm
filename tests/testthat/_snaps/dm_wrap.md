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
        h     i     j        j1 tf_3$g $tf_2            $`f=j*` $`f1=j1*` tf_5    
        <chr> <chr> <chr> <int> <chr>  <list>           <chr>       <int> <list>  
      1 a     three C         3 two    <tibble [0 x 5]> C               3 <tibble>
      2 b     four  D         4 three  <tibble [1 x 5]> D               4 <tibble>
      3 c     five  E         5 four   <tibble [2 x 5]> E               5 <tibble>
      4 d     six   F         6 five   <tibble [2 x 5]> F               6 <tibble>
      5 e     seven F         6 five   <tibble [2 x 5]> F               6 <tibble>
    Code
      wrapped$tf_4$tf_3$tf_2[[3]]
    Output
      # A tibble: 2 x 5
        `c*`      d `e=f` `e1=f1` tf_1$b $`a=d*`
        <chr> <int> <chr>   <int> <chr>    <int>
      1 lion      3 E           5 C            3
      2 dog       6 E           5 F            6
    Code
      wrapped$tf_4$tf_5[[2]]
    Output
      # A tibble: 1 x 5
           ww  `k*` `l=h` m     tf_6$zz $`o*` $`n=m`
        <int> <int> <chr> <chr>   <int> <chr> <chr> 
      1     2     1 b     house       1 e     house 

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
        b         a
        <chr> <int>
      1 B         2
      2 C         3
      3 F         6
      4 D         4
      5 G         7
    Code
      unwrapped$tf_6
    Output
      # A tibble: 3 x 3
           zz o     n         
        <int> <chr> <chr>     
      1     1 e     house     
      2     1 f     tree      
      3     1 h     streetlamp

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

