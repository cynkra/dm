# In case of endless cycles

    Code
      dm_disentangle(dm_for_card()) %>% dm_get_all_fks()
    Message
      ! Returning original `dm`, cannot disentangle cycles of types:
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

