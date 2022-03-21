# In case of endless cycles

    Code
      dm_disentangle(dm_for_card()) %>% dm_get_all_fks()
    Message
      ! Returning original `dm`, endless cycle detected in component:
      (`dc_1`, `dc_2`, `dc_3`, `dc_4`, `dc_5`, `dc_6`)
      Not supported are cycles of types:
    Output
      * `tbl_1` -> `tbl_2` -> `tbl_3` -> `tbl_1`
      * `tbl_1` -> `tbl_2` -> `tbl_1`
      # A tibble: 6 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 dc_2        a, b          dc_1         a, b            no_action
      2 dc_3        a, b          dc_1         a, b            no_action
      3 dc_5        b, a          dc_1         b, a            no_action
      4 dc_6        c             dc_1         a               no_action
      5 dc_4        b, a          dc_3         b, a            no_action
      6 dc_3        b, a          dc_4         b, a            no_action
    Code
      dm_disentangle(dm_bind(dm_for_card(), dm_for_card() %>% dm_rename_tbl(dc_1_2 = dc_1,
        dc_2_2 = dc_2, dc_3_2 = dc_3, dc_4_2 = dc_4, dc_5_2 = dc_5, dc_6_2 = dc_6),
      dm_for_filter())) %>% dm_get_all_fks()
    Message
      ! Returning original `dm`, endless cycles detected in components:
      (`dc_1`, `dc_2`, `dc_3`, `dc_4`, `dc_5`, `dc_6`)
      (`dc_1_2`, `dc_2_2`, `dc_3_2`, `dc_4_2`, `dc_5_2`, `dc_6_2`)
      Not supported are cycles of types:
    Output
      * `tbl_1` -> `tbl_2` -> `tbl_3` -> `tbl_1`
      * `tbl_1` -> `tbl_2` -> `tbl_1`
      # A tibble: 17 x 5
         child_table child_fk_cols parent_table parent_key_cols on_delete
         <chr>       <keys>        <chr>        <keys>          <chr>    
       1 dc_2        a, b          dc_1         a, b            no_action
       2 dc_3        a, b          dc_1         a, b            no_action
       3 dc_5        b, a          dc_1         b, a            no_action
       4 dc_6        c             dc_1         a               no_action
       5 dc_4        b, a          dc_3         b, a            no_action
       6 dc_3        b, a          dc_4         b, a            no_action
       7 dc_2_2      a, b          dc_1_2       a, b            no_action
       8 dc_3_2      a, b          dc_1_2       a, b            no_action
       9 dc_5_2      b, a          dc_1_2       b, a            no_action
      10 dc_6_2      c             dc_1_2       a               no_action
      11 dc_4_2      b, a          dc_3_2       b, a            no_action
      12 dc_3_2      b, a          dc_4_2       b, a            no_action
      13 tf_2        d             tf_1         a               no_action
      14 tf_2        e, e1         tf_3         f, f1           no_action
      15 tf_4        j, j1         tf_3         f, f1           no_action
      16 tf_5        l             tf_4         h               cascade  
      17 tf_5        m             tf_6         n               no_action

