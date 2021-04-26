# dm_add_tbl() and dm_rm_tbl() for compound keys

    Code
      dm_add_tbl(nyc_comp(), res_flat = result_from_flatten())
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`, `res_flat`
      Columns: 63
      Primary keys: 4
      Foreign keys: 4
    Code
      dm_rm_tbl(nyc_comp(), planes)
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `weather`
      Columns: 44
      Primary keys: 3
      Foreign keys: 3
    Code
      dm_rm_tbl(nyc_comp(), weather)
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`
      Columns: 38
      Primary keys: 3
      Foreign keys: 3

