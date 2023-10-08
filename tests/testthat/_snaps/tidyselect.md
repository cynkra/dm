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
      Error:
      ! You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near 'ROW(1, 'A'),
          ROW(2, 'B'),
          ROW(3, 'C'),
          ROW(4, 'D'),
          ROW(5, 'E...' at line 11 [1064]
    Code
      dm_for_filter() %>% dm_rename_tbl(tf_0 = tf_7)
    Condition
      Warning in `dm_for_filter()`:
      restarting interrupted promise evaluation
      Warning in `inherits()`:
      restarting interrupted promise evaluation
      Warning in `dm_for_filter_w_cycle()`:
      restarting interrupted promise evaluation
      Error:
      ! You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near 'ROW(1, 'A'),
          ROW(2, 'B'),
          ROW(3, 'C'),
          ROW(4, 'D'),
          ROW(5, 'E...' at line 11 [1064]

