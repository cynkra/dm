# dm_get_all_fks() with compound keys

    Code
      nyc_comp() %>% dm_get_all_fks()
    Output
      # A tibble: 3 x 3
        child_table child_fk_cols parent_table
        <chr>       <keys>        <chr>       
      1 flights     carrier       airlines    
      2 flights     dest          airports    
      3 flights     tailnum       planes      

