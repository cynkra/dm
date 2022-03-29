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

# more iterations needed

    Code
      entangled_dm() %>% dm_disentangle() %>% dm_get_all_fks()
    Message
      Replaced table `g` with `g_1`, `g_2`.
      Replaced table `h` with `h_1`, `h_2`.
      Replaced table `d` with `d_1`, `d_2`.
      Replaced table `e` with `e_1`, `e_2`.
      Replaced table `f` with `f_1`, `f_2`.
      Replaced table `g_1` with `g_1_1`, `g_1_2`.
      Replaced table `g_2` with `g_2_1`, `g_2_2`.
      Replaced table `h_1` with `h_1_1`, `h_1_2`.
      Replaced table `h_2` with `h_2_1`, `h_2_2`.
    Output
      # A tibble: 16 x 5
         child_table child_fk_cols parent_table parent_key_cols on_delete
         <chr>       <keys>        <chr>        <keys>          <chr>    
       1 a           a             b            b               no_action
       2 a           a             c            c               no_action
       3 b           b             d_1          d               no_action
       4 c           c             d_2          d               no_action
       5 d_1         d             e_1          e               no_action
       6 d_2         d             e_2          e               no_action
       7 d_1         d             f_1          f               no_action
       8 d_2         d             f_2          f               no_action
       9 e_1         e             g_1_1        g               no_action
      10 e_2         e             g_1_2        g               no_action
      11 f_1         f             g_2_1        g               no_action
      12 f_2         f             g_2_2        g               no_action
      13 g_1_1       g             h_1_1        h               no_action
      14 g_1_2       g             h_1_2        h               no_action
      15 g_2_1       g             h_2_1        h               no_action
      16 g_2_2       g             h_2_2        h               no_action
    Code
      entangled_dm() %>% dm_disentangle(naming_template = "{.pt}_{.pkc}_{.n}") %>%
        dm_get_all_fks()
    Message
      Replaced table `g` with `g_g_1`, `g_g_2`.
      Replaced table `h` with `h_h_1`, `h_h_2`.
      Replaced table `d` with `d_d_1`, `d_d_2`.
      Replaced table `e` with `e_e_1`, `e_e_2`.
      Replaced table `f` with `f_f_1`, `f_f_2`.
      Replaced table `g_g_1` with `g_g_1_g_1`, `g_g_1_g_2`.
      Replaced table `g_g_2` with `g_g_2_g_1`, `g_g_2_g_2`.
      Replaced table `h_h_1` with `h_h_1_h_1`, `h_h_1_h_2`.
      Replaced table `h_h_2` with `h_h_2_h_1`, `h_h_2_h_2`.
    Output
      # A tibble: 16 x 5
         child_table child_fk_cols parent_table parent_key_cols on_delete
         <chr>       <keys>        <chr>        <keys>          <chr>    
       1 a           a             b            b               no_action
       2 a           a             c            c               no_action
       3 b           b             d_d_1        d               no_action
       4 c           c             d_d_2        d               no_action
       5 d_d_1       d             e_e_1        e               no_action
       6 d_d_2       d             e_e_2        e               no_action
       7 d_d_1       d             f_f_1        f               no_action
       8 d_d_2       d             f_f_2        f               no_action
       9 e_e_1       e             g_g_1_g_1    g               no_action
      10 e_e_2       e             g_g_1_g_2    g               no_action
      11 f_f_1       f             g_g_2_g_1    g               no_action
      12 f_f_2       f             g_g_2_g_2    g               no_action
      13 g_g_1_g_1   g             h_h_1_h_1    h               no_action
      14 g_g_1_g_2   g             h_h_1_h_2    h               no_action
      15 g_g_2_g_1   g             h_h_2_h_1    h               no_action
      16 g_g_2_g_2   g             h_h_2_h_2    h               no_action

