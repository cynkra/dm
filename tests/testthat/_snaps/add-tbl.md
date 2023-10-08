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
      Error in `map()`:
      i In index: 1.
      i With name: tf_1.
      Caused by error in `types[pk_col]`:
      ! invalid subscript type 'list'

