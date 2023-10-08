# errors: duplicate table names, src mismatches

    Code
      dm_bind(dm_for_filter(), dm_for_flatten(), dm_for_filter())
    Condition
      Warning:
      `dm_bind()` was deprecated in dm 1.0.0.
      i Please use `dm()` instead.
      Warning in `dm_for_filter()`:
      restarting interrupted promise evaluation
      Warning in `inherits()`:
      restarting interrupted promise evaluation
      Warning in `dm_for_filter_w_cycle()`:
      restarting interrupted promise evaluation
      Error in `map()`:
      i In index: 1.
      i With name: tf_1.
      Caused by error in `types[pk_col]`:
      ! invalid subscript type 'list'

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
    Output
      You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near 'ROW('acorn', 14, 'N', 'c', 'X', 7, 1),
          ROW('blubber', 13, 'M', 'd', 'W', ...' at line 25 [1064]

