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
      dm_packed_nested_unnested <- dm_unnest_tbl(dm_packed_nested, tf_3, tf_2, ptype = dm_for_filter())
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
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
        tf_2, tf_1, ptype = dm_for_filter())
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Code
      dm_packed_nested_unnested_unpacked
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `tf_3`, `tf_4`, `tf_5`, `tf_6`, `tf_2`, `tf_1`
      Columns: 20
      Primary keys: 6
      Foreign keys: 5

