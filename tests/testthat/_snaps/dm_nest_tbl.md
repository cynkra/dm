# `dm_pack_tbl()`, `dm_unpack_tbl()`, `dm_nest_tbl()`, `dm_unnest_tbl()` work

    Code
      dm_packed <- dm_pack_tbl(dm1, tf_1)
    Message <message>
      Rebuild a dm from this object using : %>%
        dm_unpack_tbl(tf_2, tf_1, child_fk = d, parent_fk_names = "a", parent_pk_names = "a")
    Code
      dm_packed
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `tf_2`, `tf_3`, `tf_4`, `tf_5`, `tf_6`
      Columns: 17
      Primary keys: 5
      Foreign keys: 4
    Code
      dm_packed_nested <- dm_nest_tbl(dm_packed, tf_2)
    Message <message>
      Rebuild a dm from this object using : %>%
        dm_unnest_tbl(tf_3, tf_2, parent_fk = c(f, f1), child_fk_names = c("e", "e1"), child_pk_names = "c")
    Code
      dm_packed_nested
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `tf_3`, `tf_4`, `tf_5`, `tf_6`
      Columns: 13
      Primary keys: 4
      Foreign keys: 3
    Code
      dm_packed_nested_unnested <- dm_unnest_tbl(dm_packed_nested, tf_3, tf_2,
        prototype = dm1)
      dm_packed_nested_unnested
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `tf_3`, `tf_4`, `tf_5`, `tf_6`, `tf_2`
      Columns: 17
      Primary keys: 5
      Foreign keys: 4
    Code
      dm_packed_nested_unnested_unpacked <- dm_unpack_tbl(dm_packed_nested_unnested,
        tf_2, tf_1, prototype = dm1)
      dm_packed_nested_unnested_unpacked
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `tf_3`, `tf_4`, `tf_5`, `tf_6`, `tf_2`, `tf_1`
      Columns: 18
      Primary keys: 6
      Foreign keys: 5

