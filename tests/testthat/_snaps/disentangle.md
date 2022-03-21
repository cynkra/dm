# In case of endless cycles

    Code
      dm_disentangle(dm_for_card())
    Message
      ! Returning original `dm`, endless cycle detected in component:
      (`dc_1`, `dc_2`, `dc_3`, `dc_4`, `dc_5`, `dc_6`)
      Not supported are cycles of types:
    Output
      * `tbl_1` -> `tbl_2` -> `tbl_3` -> `tbl_1`
      * `tbl_1` -> `tbl_2` -> `tbl_1`
      -- Metadata --------------------------------------------------------------------
      Tables: `dc_1`, `dc_2`, `dc_3`, `dc_4`, `dc_5`, `dc_6`
      Columns: 11
      Primary keys: 0
      Foreign keys: 6
    Code
      dm_disentangle(dm_bind(dm_for_card(), dm_for_card() %>% dm_rename_tbl(dc_1_2 = dc_1,
        dc_2_2 = dc_2, dc_3_2 = dc_3, dc_4_2 = dc_4, dc_5_2 = dc_5, dc_6_2 = dc_6),
      dm_for_filter()))
    Message
      ! Returning original `dm`, endless cycles detected in components:
      (`dc_1`, `dc_2`, `dc_3`, `dc_4`, `dc_5`, `dc_6`)
      (`dc_1_2`, `dc_2_2`, `dc_3_2`, `dc_4_2`, `dc_5_2`, `dc_6_2`)
      Not supported are cycles of types:
    Output
      * `tbl_1` -> `tbl_2` -> `tbl_3` -> `tbl_1`
      * `tbl_1` -> `tbl_2` -> `tbl_1`
      -- Metadata --------------------------------------------------------------------
      Tables: `dc_1`, `dc_2`, `dc_3`, `dc_4`, `dc_5`, ... (18 total)
      Columns: 40
      Primary keys: 6
      Foreign keys: 17

