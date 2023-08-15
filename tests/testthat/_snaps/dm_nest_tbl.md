# `dm_pack_tbl()`, `dm_unpack_tbl()`, `dm_nest_tbl()`, `dm_unnest_tbl()` work

    Code
      dm_packed <- dm_pack_tbl(dm_for_filter(), tf_1)
      dm_packed
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `tf_2`, `tf_3`, `tf_4`, `tf_5`, `tf_6`
      Columns: 19
      Primary keys: 5
      Foreign keys: 4
    Code
      dm_packed_nested <- dm_nest_tbl(dm_packed, tf_2)
      dm_packed_nested
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `tf_3`, `tf_4`, `tf_5`, `tf_6`
      Columns: 15
      Primary keys: 4
      Foreign keys: 3
    Code
      dm_packed_nested_unnested <- dm_unnest_tbl(dm_packed_nested, tf_3, tf_2)
    Condition
      Warning:
      `type_of()` is deprecated as of rlang 0.4.0.
      Please use `typeof()` or your own version instead.
      This warning is displayed once every 8 hours.
      Warning:
      There were 4 warnings in `filter()`.
      The first warning was:
      i In argument: `n_distinct(c_across()) == ncol(.)`.
      i In row 1.
      Caused by warning:
      ! Using `c_across()` without supplying `cols` was deprecated in dplyr 1.1.0.
      i Please supply `cols` instead.
      i Run `dplyr::last_dplyr_warnings()` to see the 3 remaining warnings.
    Code
      dm_packed_nested_unnested
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `tf_3`, `tf_4`, `tf_5`, `tf_6`, `tf_2`
      Columns: 19
      Primary keys: 5
      Foreign keys: 4
    Code
      dm_packed_nested_unnested_unpacked <- dm_unpack_tbl(dm_packed_nested_unnested,
        tf_2, tf_1)
      dm_packed_nested_unnested_unpacked
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `tf_3`, `tf_4`, `tf_5`, `tf_6`, `tf_2`, `tf_1`
      Columns: 20
      Primary keys: 6
      Foreign keys: 5

