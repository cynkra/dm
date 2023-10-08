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
      Error:
      ! You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'INTEGER) AS `a`, CAST(`b` AS CHAR) AS `b`
      FROM (
        (
          SELECT NULL AS `a`, NUL' at line 2 [1064]

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
      You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'INTEGER) AS `dim_1_key_1`,
        CAST(`dim_1_key_2` AS CHAR) AS `dim_1_key_2`,
        CAS' at line 4 [1064]

