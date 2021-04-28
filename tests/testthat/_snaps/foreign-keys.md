# dm_get_all_fks() with compound keys

    Code
      nyc_comp()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 53
      Primary keys: 4
      Foreign keys: 4
    Code
      nyc_comp() %>% dm_get_all_fks()
    Output
      # A tibble: 4 x 4
        child_table child_fk_cols     parent_table parent_pk_cols   
        <chr>       <keys>            <chr>        <keys>           
      1 flights     carrier           airlines     carrier          
      2 flights     dest              airports     faa              
      3 flights     tailnum           planes       tailnum          
      4 flights     origin, time_hour weather      origin, time_hour

