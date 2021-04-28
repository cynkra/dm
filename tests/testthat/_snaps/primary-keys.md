# dm_enum_pk_candidates() works properly?

    Code
      dm_enum_pk_candidates(dm_test_obj(), dm_table_1)
    Output
      # A tibble: 2 x 3
        columns candidate why  
        <keys>  <lgl>     <chr>
      1 a       TRUE      ""   
      2 b       TRUE      ""   
    Code
      dm_enum_pk_candidates(dm_test_obj(), dm_table_2)
    Output
      # A tibble: 1 x 3
        columns candidate why                        
        <keys>  <lgl>     <chr>                      
      1 c       FALSE     has duplicate values: 5 (2)
    Code
      dm_enum_pk_candidates(dm_test_obj(), dm_table_5)
    Output
      # A tibble: 1 x 3
        columns candidate why                 
        <keys>  <lgl>     <chr>               
      1 c       FALSE     has 1 missing values
    Code
      dm_enum_pk_candidates(dm_test_obj(), dm_table_6)
    Output
      # A tibble: 1 x 3
        columns candidate why                                              
        <keys>  <lgl>     <chr>                                            
      1 c       FALSE     has 1 missing values, and duplicate values: 3 (2)

# output

    Code
      dm(x = tibble(a = c(1, 1))) %>% dm_add_pk(x, a, check = TRUE)
    Error <dm_error_not_unique_key>
      (`a`) not a unique key of `x`.

# dm_get_all_pks() with compound keys

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
      4 weather  origin, time_hour

