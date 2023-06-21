# output

    Code
      dm_for_filter() %>% dm_select_tbl(tf_7)
    Condition
      Warning in `dm_for_filter()`:
      restarting interrupted promise evaluation
      Warning in `inherits()`:
      restarting interrupted promise evaluation
      Warning in `dm_for_filter_w_cycle()`:
      restarting interrupted promise evaluation
      Error in `pmap()`:
      i In index: 1.
      Caused by error:
      ! rapi_execute: Failed to run query
      Error: Constraint Error: NOT NULL constraint failed: tf_1_67_2023_06_21_19_23_17_153682_19415.a
    Code
      dm_for_filter() %>% dm_rename_tbl(tf_0 = tf_7)
    Condition
      Warning in `dm_for_filter()`:
      restarting interrupted promise evaluation
      Warning in `inherits()`:
      restarting interrupted promise evaluation
      Warning in `dm_for_filter_w_cycle()`:
      restarting interrupted promise evaluation
      Error in `pmap()`:
      i In index: 1.
      Caused by error:
      ! rapi_execute: Failed to run query
      Error: Constraint Error: NOT NULL constraint failed: tf_1_68_2023_06_21_19_23_18_213363_19415.a

