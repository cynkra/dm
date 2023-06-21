# output

    Code
      dm_for_filter() %>% dm_select_tbl(tf_7)
    Condition
      Error in `eval_select_indices()`:
      ! Can't select tables that don't exist.
      x Table `tf_7` doesn't exist.
    Code
      dm_for_filter() %>% dm_rename_tbl(tf_0 = tf_7)
    Condition
      Error in `eval_rename_indices()`:
      ! Can't rename tables that don't exist.
      x Table `tf_7` doesn't exist.

