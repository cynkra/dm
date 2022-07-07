# output as tibble

    Code
      dm_nycflights_small_cycle() %>% dm_examine_constraints() %>% as_tibble()
    Output
      # A tibble: 7 x 6
        table    kind  columns ref_table is_key problem                               
        <chr>    <chr> <keys>  <chr>     <lgl>  <chr>                                 
      1 flights  FK    dest    airports  FALSE  "values of `flights$dest` not in `air~
      2 flights  FK    tailnum planes    FALSE  "values of `flights$tailnum` not in `~
      3 airlines PK    carrier <NA>      TRUE   ""                                    
      4 airports PK    faa     <NA>      TRUE   ""                                    
      5 planes   PK    tailnum <NA>      TRUE   ""                                    
      6 flights  FK    carrier airlines  TRUE   ""                                    
      7 flights  FK    origin  airports  TRUE   ""                                    

