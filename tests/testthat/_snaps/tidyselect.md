# output

    Code
      dm_for_filter() %>% dm_select_tbl(tf_7)
    Condition
      Error in `stop_subscript()`:
      ! Can't subset tables that don't exist.
      x Table `tf_7` doesn't exist.
    Code
      dm_for_filter() %>% dm_rename_tbl(tf_0 = tf_7)
    Condition
      Error in `stop_subscript()`:
      ! Can't rename tables that don't exist.
      x Table `tf_7` doesn't exist.

