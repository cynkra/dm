# dm_add_tbl() snapshots

    Code
      dm_add_tbl(dm_for_filter(), tf_1 = data_card_1(), repair = "check_unique")
    Condition
      Warning:
      `dm_add_tbl()` was deprecated in dm 1.0.0.
      i Please use `dm()` instead.
      i Use `.name_repair = "unique"` if necessary.
      Warning in `dm_for_filter()`:
      restarting interrupted promise evaluation
      Warning in `my_test_src_cache()`:
      restarting interrupted promise evaluation
      Warning in `my_test_src_cache()`:
      restarting interrupted promise evaluation
      Error in `value[[3L]]()`:
      ! Data source mysql not accessible: Failed to connect: Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock' (2)

