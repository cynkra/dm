# `new_fks_in()` generates expected tibble

    Code
      new_fks_in(child_table = "flights", child_fk_cols = new_keys(list(list("origin",
        "dest"))), parent_key_cols = new_keys(list(list("faa"))))
    Output
      # A tibble: 1 x 3
        child_table child_fk_cols parent_key_cols
        <chr>       <keys>        <keys>         
      1 flights     origin, dest  faa            

# `new_fks_out()` generates expected tibble

    Code
      new_fks_out(child_fk_cols = new_keys(list(list("origin", "dest"))),
      parent_table = "airports", parent_key_cols = new_keys(list(list("faa"))))
    Output
      # A tibble: 1 x 3
        child_fk_cols parent_table parent_key_cols
        <keys>        <chr>        <keys>         
      1 origin, dest  airports     faa            

# `new_keyed_tbl()` generates expected output

    Code
      dm <- dm_nycflights13(cycle = TRUE)
      keyed_tbl <- new_keyed_tbl(x = dm$airports, pk = "faa", fks_in = new_fks_in(
        child_table = "flights", child_fk_cols = new_keys(list("origin", "dest")),
        parent_key_cols = new_keys(list("faa"))), fks_out = new_fks_out(
        child_fk_cols = new_keys(list("origin", "dest")), parent_table = "airports",
        parent_key_cols = new_keys(list("faa"))), uuid = "0a0c060f-0d01-0b03-0402-05090800070e")
      attr(keyed_tbl, "dm_key_info")
    Output
      $pk
      [1] "faa"
      
      $fks_in
      # A tibble: 2 x 3
        child_table child_fk_cols parent_key_cols
        <chr>       <keys>        <keys>         
      1 flights     origin        faa            
      2 flights     dest          faa            
      
      $fks_out
      # A tibble: 2 x 3
        child_fk_cols parent_table parent_key_cols
        <keys>        <chr>        <keys>         
      1 origin        airports     faa            
      2 dest          airports     faa            
      
      $uuid
      [1] "0a0c060f-0d01-0b03-0402-05090800070e"
      

# `new_keyed_tbl()` formatting

    Code
      dm_nycflights13()$flights
    Output
      # A tibble: 1,761 x 19
      # Keys:     --- | 0 | 4
          year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
       * <int> <int> <int>    <int>          <int>     <dbl>    <int>          <int>
       1  2013     1    10        3           2359         4      426            437
       2  2013     1    10       16           2359        17      447            444
       3  2013     1    10      450            500       -10      634            648
       4  2013     1    10      520            525        -5      813            820
       5  2013     1    10      530            530         0      824            829
       6  2013     1    10      531            540        -9      832            850
       7  2013     1    10      535            540        -5     1015           1017
       8  2013     1    10      546            600       -14      645            709
       9  2013     1    10      549            600       -11      652            724
      10  2013     1    10      550            600       -10      649            703
      # ... with 1,751 more rows, and 11 more variables: arr_delay <dbl>,
      #   carrier <chr>, flight <int>, tailnum <chr>, origin <chr>, dest <chr>,
      #   air_time <dbl>, distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>
    Code
      dm_nycflights13()$airports
    Output
      # A tibble: 86 x 8
      # Keys:     `faa` | 1 | 0
         faa   name                                 lat    lon   alt    tz dst   tzone
       * <chr> <chr>                              <dbl>  <dbl> <dbl> <dbl> <chr> <chr>
       1 ALB   Albany Intl                         42.7  -73.8   285    -5 A     Amer~
       2 ATL   Hartsfield Jackson Atlanta Intl     33.6  -84.4  1026    -5 A     Amer~
       3 AUS   Austin Bergstrom Intl               30.2  -97.7   542    -6 A     Amer~
       4 BDL   Bradley Intl                        41.9  -72.7   173    -5 A     Amer~
       5 BHM   Birmingham Intl                     33.6  -86.8   644    -6 A     Amer~
       6 BNA   Nashville Intl                      36.1  -86.7   599    -6 A     Amer~
       7 BOS   General Edward Lawrence Logan Intl  42.4  -71.0    19    -5 A     Amer~
       8 BTV   Burlington Intl                     44.5  -73.2   335    -5 A     Amer~
       9 BUF   Buffalo Niagara Intl                42.9  -78.7   724    -5 A     Amer~
      10 BUR   Bob Hope                            34.2 -118.    778    -8 A     Amer~
      # ... with 76 more rows
    Code
      dm_nycflights13(cycle = TRUE)$airports
    Output
      # A tibble: 86 x 8
      # Keys:     `faa` | 2 | 0
         faa   name                                 lat    lon   alt    tz dst   tzone
       * <chr> <chr>                              <dbl>  <dbl> <dbl> <dbl> <chr> <chr>
       1 ALB   Albany Intl                         42.7  -73.8   285    -5 A     Amer~
       2 ATL   Hartsfield Jackson Atlanta Intl     33.6  -84.4  1026    -5 A     Amer~
       3 AUS   Austin Bergstrom Intl               30.2  -97.7   542    -6 A     Amer~
       4 BDL   Bradley Intl                        41.9  -72.7   173    -5 A     Amer~
       5 BHM   Birmingham Intl                     33.6  -86.8   644    -6 A     Amer~
       6 BNA   Nashville Intl                      36.1  -86.7   599    -6 A     Amer~
       7 BOS   General Edward Lawrence Logan Intl  42.4  -71.0    19    -5 A     Amer~
       8 BTV   Burlington Intl                     44.5  -73.2   335    -5 A     Amer~
       9 BUF   Buffalo Niagara Intl                42.9  -78.7   724    -5 A     Amer~
      10 BUR   Bob Hope                            34.2 -118.    778    -8 A     Amer~
      # ... with 76 more rows

