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
      Warning in `inherits()`:
      restarting interrupted promise evaluation
      Warning in `dm_for_filter_w_cycle()`:
      restarting interrupted promise evaluation
      Error:
      ! You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'INTEGER) AS `a`, CAST(`b` AS CHAR) AS `b`
      FROM (
        (
          SELECT NULL AS `a`, NUL' at line 2 [1064]

