# errors: duplicate table names, src mismatches

    Code
      dm_bind(dm_for_filter(), dm_for_flatten(), dm_for_filter())
    Condition
      Warning:
      `dm_bind()` was deprecated in dm 1.0.0.
      i Please use `dm()` instead.
      Warning in `dm_for_filter()`:
      restarting interrupted promise evaluation
      Warning in `my_test_src_cache()`:
      restarting interrupted promise evaluation
      Warning in `my_test_src_cache()`:
      restarting interrupted promise evaluation
      Error in `value[[3L]]()`:
      ! Data source mysql not accessible: Failed to connect: Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock' (2)

# test error output for src mismatches

    Code
      writeLines(conditionMessage(expect_error(dm_bind(dm_for_flatten(),
      dm_for_filter_duckdb()))))
    Condition
      Warning:
      `dm_bind()` was deprecated in dm 1.0.0.
      i Please use `dm()` instead.
      Warning in `dm_for_flatten()`:
      restarting interrupted promise evaluation
      Warning in `my_test_src_cache()`:
      restarting interrupted promise evaluation
      Warning in `my_test_src_cache()`:
      restarting interrupted promise evaluation
    Output
      Data source mysql not accessible: Failed to connect: Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock' (2)

