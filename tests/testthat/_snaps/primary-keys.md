# output

    Code
      dm(x = tibble(a = c(1, 1))) %>% dm_add_pk(x, a, check = TRUE)
    Error <dm_error_not_unique_key>
      (`a`) not a unique key of `x`.

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
      nyc_comp() %>% dm_get_all_pks()
    Output
      # A tibble: 4 x 2
        table    pk_col             
        <chr>    <keys>             
      1 airlines carrier            
      2 airports faa                
      3 planes   tailnum            
      4 weather  (origin, time_hour)

