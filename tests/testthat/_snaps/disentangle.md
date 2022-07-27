# dm_disentangle() works

    Code
      dm_disentangle(dm_for_filter_w_cycle(), tf_1) %>% dm_get_all_fks()
    Message
      Replaced table `tf_3` with `tf_3-1`, `tf_3-2`.
      Replaced table `tf_4` with `tf_4-1`, `tf_4-2`.
      Replaced table `tf_5` with `tf_5-1`, `tf_5-2`.
      Replaced table `tf_6` with `tf_6-1`, `tf_6-2`.
      Replaced table `tf_7` with `tf_7-1`, `tf_7-2`.
    Condition
      Warning:
      Each row in `x` should match at most 1 row in `y`.
      i Row 3 of `x` matches multiple rows.
      i If multiple matches are expected, specify `multiple = "all"` in the join call to silence this warning.
    Output
      # A tibble: 11 x 5
         child_table child_fk_cols parent_table parent_key_cols on_delete
         <chr>       <keys>        <chr>        <keys>          <chr>    
       1 tf_2        d             tf_1         a               no_action
       2 tf_7-1      q             tf_2         c               no_action
       3 tf_4-1      j, j1         tf_3-1       f, f1           no_action
       4 tf_2        e, e1         tf_3-2       f, f1           no_action
       5 tf_4-2      j, j1         tf_3-2       f, f1           no_action
       6 tf_5-1      l             tf_4-1       h               cascade  
       7 tf_5-2      l             tf_4-2       h               cascade  
       8 tf_5-1      m             tf_6-1       n               no_action
       9 tf_5-2      m             tf_6-2       n               no_action
      10 tf_6-1      o             tf_7-1       p               no_action
      11 tf_6-2      o             tf_7-2       p               no_action
    Code
      dm_disentangle(dm_for_filter_w_cycle(), tf_5) %>% dm_get_all_fks()
    Message
      Replaced table `tf_1` with `tf_1-1`, `tf_1-2`.
      Replaced table `tf_2` with `tf_2-1`, `tf_2-2`.
      Replaced table `tf_3` with `tf_3-1`, `tf_3-2`.
      Replaced table `tf_4` with `tf_4-1`, `tf_4-2`.
      Replaced table `tf_6` with `tf_6-1`, `tf_6-2`.
      Replaced table `tf_7` with `tf_7-1`, `tf_7-2`.
    Condition
      Warning:
      Each row in `x` should match at most 1 row in `y`.
      i Row 1 of `x` matches multiple rows.
      i If multiple matches are expected, specify `multiple = "all"` in the join call to silence this warning.
    Output
      # A tibble: 12 x 5
         child_table child_fk_cols parent_table parent_key_cols on_delete
         <chr>       <keys>        <chr>        <keys>          <chr>    
       1 tf_2-1      d             tf_1-1       a               no_action
       2 tf_2-2      d             tf_1-2       a               no_action
       3 tf_7-1      q             tf_2-1       c               no_action
       4 tf_7-2      q             tf_2-2       c               no_action
       5 tf_4-1      j, j1         tf_3-1       f, f1           no_action
       6 tf_2-1      e, e1         tf_3-1       f, f1           no_action
       7 tf_2-2      e, e1         tf_3-2       f, f1           no_action
       8 tf_4-2      j, j1         tf_3-2       f, f1           no_action
       9 tf_5        l             tf_4-1       h               cascade  
      10 tf_5        m             tf_6-2       n               no_action
      11 tf_6-1      o             tf_7-1       p               no_action
      12 tf_6-2      o             tf_7-2       p               no_action
    Code
      dm_disentangle(entangled_dm(), a, quiet = TRUE) %>% dm_get_all_fks()
    Condition
      Warning:
      Each row in `x` should match at most 1 row in `y`.
      i Row 2 of `x` matches multiple rows.
      i If multiple matches are expected, specify `multiple = "all"` in the join call to silence this warning.
    Output
      # A tibble: 22 x 5
         child_table child_fk_cols parent_table parent_key_cols on_delete
         <chr>       <keys>        <chr>        <keys>          <chr>    
       1 a           a             b-1          b               no_action
       2 a           a             c-2          c               no_action
       3 b-1         b             d-1          d               no_action
       4 c-1         c             d-1          d               no_action
       5 c-2         c             d-2          d               no_action
       6 b-2         b             d-2          d               no_action
       7 d-1         d             e-1          e               no_action
       8 d-2         d             e-3          e               no_action
       9 d-1         d             f-2          f               no_action
      10 d-2         d             f-4          f               no_action
      # ... with 12 more rows
      # i Use `print(n = ...)` to see more rows
    Code
      dm_disentangle(entangled_dm(), c) %>% dm_get_all_fks()
    Message
      Replaced table `a` with `a-1`, `a-2`.
      Replaced table `b` with `b-1`, `b-2`.
      Replaced table `d` with `d-1`, `d-2`.
      Replaced table `e` with `e-1`, `e-2`, `e-3`, `e-4`.
      Replaced table `f` with `f-1`, `f-2`, `f-3`, `f-4`.
      Replaced table `g` with `g-1`, `g-2`, `g-3`, `g-4`.
      Replaced table `h` with `h-1`, `h-2`, `h-3`, `h-4`.
    Condition
      Warning:
      Each row in `x` should match at most 1 row in `y`.
      i Row 1 of `x` matches multiple rows.
      i If multiple matches are expected, specify `multiple = "all"` in the join call to silence this warning.
    Output
      # A tibble: 22 x 5
         child_table child_fk_cols parent_table parent_key_cols on_delete
         <chr>       <keys>        <chr>        <keys>          <chr>    
       1 a-1         a             b-1          b               no_action
       2 a-2         a             b-2          b               no_action
       3 a-1         a             c            c               no_action
       4 b-1         b             d-1          d               no_action
       5 c           c             d-2          d               no_action
       6 b-2         b             d-2          d               no_action
       7 d-1         d             e-1          e               no_action
       8 d-2         d             e-3          e               no_action
       9 d-1         d             f-2          f               no_action
      10 d-2         d             f-4          f               no_action
      # ... with 12 more rows
      # i Use `print(n = ...)` to see more rows
    Code
      dm_disentangle(entangled_dm_2(), a) %>% dm_get_all_fks()
    Message
      Replaced table `b` with `b-1`, `b-2`.
      Replaced table `c` with `c-1`, `c-2`.
      Replaced table `d` with `d-1`, `d-2`.
      Replaced table `e` with `e-1`, `e-2`.
    Condition
      Warning:
      Each row in `x` should match at most 1 row in `y`.
      i Row 2 of `x` matches multiple rows.
      i If multiple matches are expected, specify `multiple = "all"` in the join call to silence this warning.
    Output
      # A tibble: 9 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 a           a             d-1          d               no_action
      2 b-1         b             d-1          d               no_action
      3 c-1         c             d-1          d               no_action
      4 b-2         b             d-2          d               no_action
      5 c-2         c             d-2          d               no_action
      6 d-1         d             e-1          e               no_action
      7 a           a             e-2          e               no_action
      8 d-2         d             e-2          e               no_action
      9 f           f             g            g               no_action
    Code
      dm_disentangle(entangled_dm_2(), d, quiet = TRUE) %>% dm_get_all_fks()
    Condition
      Warning:
      Each row in `x` should match at most 1 row in `y`.
      i Row 1 of `x` matches multiple rows.
      i If multiple matches are expected, specify `multiple = "all"` in the join call to silence this warning.
    Output
      # A tibble: 7 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 a-1         a             d            d               no_action
      2 b           b             d            d               no_action
      3 c           c             d            d               no_action
      4 a-1         a             e-1          e               no_action
      5 d           d             e-2          e               no_action
      6 a-2         a             e-2          e               no_action
      7 f           f             g            g               no_action

---

    You can't call `dm_disentangle()` on a `dm_zoomed`. Consider using one of `dm_update_zoomed()`, `dm_insert_zoomed()` or `dm_discard_zoomed()` first.

---

    Must pass `start` argument.

