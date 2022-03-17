# dm_disentangle() works

    Code
      dm_disentangle(dm_for_filter()) %>% collect()
    Message
      No cycle detected, returning original `dm`.
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `tf_1`, `tf_2`, `tf_3`, `tf_4`, `tf_5`, `tf_6`
      Columns: 18
      Primary keys: 6
      Foreign keys: 5
    Code
      dm_disentangle(dm_for_filter_w_cycle()) %>% collect()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `tf_1`, `tf_2`, `tf_4`, `tf_5`, `tf_6`, ... (8 total)
      Columns: 23
      Primary keys: 8
      Foreign keys: 7
    Code
      dm_disentangle(dm_bind(dm_for_disambiguate(), dm_for_filter_w_cycle(),
      dm_nycflights_small_cycle())) %>% dm_get_all_fks()
    Output
      # A tibble: 12 x 5
         child_table child_fk_cols parent_table parent_key_cols on_delete
         <chr>       <keys>        <chr>        <keys>          <chr>    
       1 iris_2      key           iris_1       key             no_action
       2 tf_2        d             tf_1         a               no_action
       3 tf_7        q             tf_2         c               no_action
       4 tf_5        l             tf_4         h               cascade  
       5 tf_5        m             tf_6         n               no_action
       6 tf_6        o             tf_7         p               no_action
       7 flights     carrier       airlines     carrier         no_action
       8 flights     tailnum       planes       tailnum         no_action
       9 tf_2        e, e1         tf_3_1       f, f1           no_action
      10 tf_4        j, j1         tf_3_2       f, f1           no_action
      11 flights     dest          airports_1   faa             no_action
      12 flights     origin        airports_2   faa             no_action

