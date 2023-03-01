# `new_fks_in()` generates expected tibble

    Code
      new_fks_in(child_uuid = "flights-uuid", child_fk_cols = new_keys(list(list(
        "origin", "dest"))), parent_key_cols = new_keys(list(list("faa"))))
    Output
      # A tibble: 1 x 3
        child_uuid   child_fk_cols parent_key_cols
        <chr>        <keys>        <keys>         
      1 flights-uuid origin, dest  faa            

# `new_fks_out()` generates expected tibble

    Code
      new_fks_out(child_fk_cols = new_keys(list(list("origin", "dest"))),
      parent_uuid = "airports-uuid", parent_key_cols = new_keys(list(list("faa"))))
    Output
      # A tibble: 1 x 3
        child_fk_cols parent_uuid   parent_key_cols
        <keys>        <chr>         <keys>         
      1 origin, dest  airports-uuid faa            

# `new_keyed_tbl()` generates expected output

    Code
      dm <- dm_nycflights13(cycle = TRUE)
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Code
      keyed_tbl <- new_keyed_tbl(x = dm$airports, pk = "faa", fks_in = new_fks_in(
        child_uuid = "flights-uuid", child_fk_cols = new_keys(list("origin", "dest")),
        parent_key_cols = new_keys(list("faa"))), fks_out = new_fks_out(
        child_fk_cols = new_keys(list("origin", "dest")), parent_uuid = "airports-uuid",
        parent_key_cols = new_keys(list("faa"))), uuid = "0a0c060f-0d01-0b03-0402-05090800070e")
      keyed_get_info(keyed_tbl)
    Output
      $pk
      [1] "faa"
      
      $uks
      # A tibble: 0 x 1
      # ... with 1 variable: column <list>
      
      $fks_in
      # A tibble: 2 x 3
        child_uuid   child_fk_cols parent_key_cols
        <chr>        <keys>        <keys>         
      1 flights-uuid origin        faa            
      2 flights-uuid dest          faa            
      
      $fks_out
      # A tibble: 2 x 3
        child_fk_cols parent_uuid   parent_key_cols
        <keys>        <chr>         <keys>         
      1 origin        airports-uuid faa            
      2 dest          airports-uuid faa            
      
      $uuid
      [1] "0a0c060f-0d01-0b03-0402-05090800070e"
      

# dm_get_keyed_tables_impl()

    Code
      dm_nycflights13(cycle = TRUE) %>% dm_get_keyed_tables_impl() %>% map(
        keyed_get_info)
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Output
      $airlines
      $airlines$pk
      [1] "carrier"
      
      $airlines$uks
      # A tibble: 0 x 1
      # ... with 1 variable: column <list>
      
      $airlines$fks_in
      # A tibble: 1 x 3
        child_uuid                           child_fk_cols parent_key_cols
        <chr>                                <keys>        <keys>         
      1 0800020b-0c07-030f-0a0e-0105060d0904 carrier       carrier        
      
      $airlines$fks_out
      # A tibble: 0 x 3
      # ... with 3 variables: child_fk_cols <keys>, parent_uuid <chr>,
      #   parent_key_cols <keys>
      
      $airlines$uuid
      [1] "0109020c-0b0a-030e-0d04-05060f070008"
      
      
      $airports
      $airports$pk
      [1] "faa"
      
      $airports$uks
      # A tibble: 0 x 1
      # ... with 1 variable: column <list>
      
      $airports$fks_in
      # A tibble: 2 x 3
        child_uuid                           child_fk_cols parent_key_cols
        <chr>                                <keys>        <keys>         
      1 0800020b-0c07-030f-0a0e-0105060d0904 origin        faa            
      2 0800020b-0c07-030f-0a0e-0105060d0904 dest          faa            
      
      $airports$fks_out
      # A tibble: 0 x 3
      # ... with 3 variables: child_fk_cols <keys>, parent_uuid <chr>,
      #   parent_key_cols <keys>
      
      $airports$uuid
      [1] "04080601-0b0a-0c02-0503-0e070f0d0009"
      
      
      $flights
      $flights$pk
      NULL
      
      $flights$uks
      # A tibble: 0 x 1
      # ... with 1 variable: column <list>
      
      $flights$fks_in
      # A tibble: 0 x 3
      # ... with 3 variables: child_uuid <chr>, child_fk_cols <keys>,
      #   parent_key_cols <keys>
      
      $flights$fks_out
      # A tibble: 5 x 3
        child_fk_cols     parent_uuid                          parent_key_cols  
        <keys>            <chr>                                <keys>           
      1 carrier           0109020c-0b0a-030e-0d04-05060f070008 carrier          
      2 origin            04080601-0b0a-0c02-0503-0e070f0d0009 faa              
      3 dest              04080601-0b0a-0c02-0503-0e070f0d0009 faa              
      4 tailnum           0c0e080a-0307-0904-0b06-0205010f000d tailnum          
      5 origin, time_hour 0a090204-0108-0b00-0c0d-0705060e0f03 origin, time_hour
      
      $flights$uuid
      [1] "0800020b-0c07-030f-0a0e-0105060d0904"
      
      
      $planes
      $planes$pk
      [1] "tailnum"
      
      $planes$uks
      # A tibble: 0 x 1
      # ... with 1 variable: column <list>
      
      $planes$fks_in
      # A tibble: 1 x 3
        child_uuid                           child_fk_cols parent_key_cols
        <chr>                                <keys>        <keys>         
      1 0800020b-0c07-030f-0a0e-0105060d0904 tailnum       tailnum        
      
      $planes$fks_out
      # A tibble: 0 x 3
      # ... with 3 variables: child_fk_cols <keys>, parent_uuid <chr>,
      #   parent_key_cols <keys>
      
      $planes$uuid
      [1] "0c0e080a-0307-0904-0b06-0205010f000d"
      
      
      $weather
      $weather$pk
      [1] "origin"    "time_hour"
      
      $weather$uks
      # A tibble: 0 x 1
      # ... with 1 variable: column <list>
      
      $weather$fks_in
      # A tibble: 1 x 3
        child_uuid                           child_fk_cols     parent_key_cols  
        <chr>                                <keys>            <keys>           
      1 0800020b-0c07-030f-0a0e-0105060d0904 origin, time_hour origin, time_hour
      
      $weather$fks_out
      # A tibble: 0 x 3
      # ... with 3 variables: child_fk_cols <keys>, parent_uuid <chr>,
      #   parent_key_cols <keys>
      
      $weather$uuid
      [1] "0a090204-0108-0b00-0c0d-0705060e0f03"
      
      

# `new_keyed_tbl()` formatting

    Code
      keyed_tbl_impl(dm_nycflights13(cycle = TRUE), "flights")
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Output
      # A tibble: 1,761 x 19
      # Keys:     --- | 0 | 5
          year month   day dep_time sched_de~1 dep_d~2 arr_t~3 sched~4 arr_d~5 carrier
         <int> <int> <int>    <int>      <int>   <dbl>   <int>   <int>   <dbl> <chr>  
       1  2013     1    10        3       2359       4     426     437     -11 B6     
       2  2013     1    10       16       2359      17     447     444       3 B6     
       3  2013     1    10      450        500     -10     634     648     -14 US     
       4  2013     1    10      520        525      -5     813     820      -7 UA     
       5  2013     1    10      530        530       0     824     829      -5 UA     
       6  2013     1    10      531        540      -9     832     850     -18 AA     
       7  2013     1    10      535        540      -5    1015    1017      -2 B6     
       8  2013     1    10      546        600     -14     645     709     -24 B6     
       9  2013     1    10      549        600     -11     652     724     -32 EV     
      10  2013     1    10      550        600     -10     649     703     -14 US     
      # ... with 1,751 more rows, 9 more variables: flight <int>, tailnum <chr>,
      #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
      #   minute <dbl>, time_hour <dttm>, and abbreviated variable names
      #   1: sched_dep_time, 2: dep_delay, 3: arr_time, 4: sched_arr_time,
      #   5: arr_delay
    Code
      keyed_tbl_impl(dm_nycflights13(cycle = TRUE), "airports")
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Output
      # A tibble: 86 x 8
      # Keys:     `faa` | 2 | 0
         faa   name                                 lat    lon   alt    tz dst   tzone
         <chr> <chr>                              <dbl>  <dbl> <dbl> <dbl> <chr> <chr>
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
      keyed_tbl_impl(dm_nycflights13(cycle = TRUE), "airlines")
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Output
      # A tibble: 15 x 2
      # Keys:     `carrier` | 1 | 0
         carrier name                       
         <chr>   <chr>                      
       1 9E      Endeavor Air Inc.          
       2 AA      American Airlines Inc.     
       3 AS      Alaska Airlines Inc.       
       4 B6      JetBlue Airways            
       5 DL      Delta Air Lines Inc.       
       6 EV      ExpressJet Airlines Inc.   
       7 F9      Frontier Airlines Inc.     
       8 FL      AirTran Airways Corporation
       9 HA      Hawaiian Airlines Inc.     
      10 MQ      Envoy Air                  
      11 UA      United Air Lines Inc.      
      12 US      US Airways Inc.            
      13 VX      Virgin America             
      14 WN      Southwest Airlines Co.     
      15 YV      Mesa Airlines Inc.         

# `dm()` and `new_dm()` can handle a list of `dm_keyed_tbl` objects

    Code
      tbl_sum(keyed_tbl_impl(dm_output, "d1"))
    Output
                                 Keys 
      "`origin`, `time_hour` | 0 | 0" 

---

    Code
      tbl_sum(keyed_tbl_impl(dm_output, "d2"))
    Output
                 Keys 
      "`faa` | 0 | 0" 

---

    Code
      tbl_sum(keyed_tbl_impl(new_dm_output, "d1"))
    Output
                                 Keys 
      "`origin`, `time_hour` | 0 | 0" 

---

    Code
      tbl_sum(keyed_tbl_impl(new_dm_output, "d2"))
    Output
                 Keys 
      "`faa` | 0 | 0" 

# `dm()` and `new_dm()` can handle a mix of tables and `dm_keyed_tbl` objects

    Code
      tbl_sum(keyed_tbl_impl(dm_output, "d1"))
    Output
                                 Keys 
      "`origin`, `time_hour` | 0 | 0" 

---

    Code
      tbl_sum(keyed_tbl_impl(dm_output, "d2"))
    Output
               Keys 
      "--- | 0 | 0" 

---

    Code
      tbl_sum(keyed_tbl_impl(new_dm_output, "d1"))
    Output
                                 Keys 
      "`origin`, `time_hour` | 0 | 0" 

---

    Code
      tbl_sum(keyed_tbl_impl(new_dm_output, "d2"))
    Output
               Keys 
      "--- | 0 | 0" 

# `dm()` handles missing key column names gracefully

    Code
      dm(x = keyed$x["b"], y = keyed$y) %>% dm_paste()
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Message
      dm::dm(
        x,
        y,
      ) %>%
        dm::dm_add_pk(y, c(a, b))
    Code
      dm(x = keyed$x, y = keyed$y["b"]) %>% dm_paste()
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Message
      dm::dm(
        x,
        y,
      )

# keyed_by()

    Code
      keyed_by(x, y)
    Output
        a 
      "b" 
    Code
      keyed_by(y, x)
    Output
        b 
      "a" 

# joins without child PK

    Code
      keyed_build_join_spec(x, y) %>% jsonlite::toJSON(pretty = TRUE)
    Output
      {
        "x_tbl": [
          {
            "a": 1
          }
        ],
        "y_tbl": [
          {
            "b": 1
          }
        ],
        "by": [
          {
            "x": "a",
            "y": "b"
          }
        ],
        "suffix": [".x", ".y"],
        "new_pk": {},
        "new_fks_in": [
          {
            "child_uuid": "0109020c-0b0a-030e-0d04-05060f070008",
            "child_fk_cols": ["a"],
            "parent_key_cols": ["a"]
          }
        ],
        "new_fks_out": [
          {
            "child_fk_cols": ["a"],
            "parent_uuid": "04080601-0b0a-0c02-0503-0e070f0d0009",
            "parent_key_cols": ["b"]
          }
        ],
        "new_uuid": ["0800020b-0c07-030f-0a0e-0105060d0904"]
      } 
    Code
      dm(x, y, r = left_join(x, y)) %>% dm_paste(options = c("select", "keys"))
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Message
      dm::dm(
        x,
        y,
        r,
      ) %>%
        dm::dm_select(x, a) %>%
        dm::dm_select(y, b) %>%
        dm::dm_select(r, a) %>%
        dm::dm_add_pk(y, b) %>%
        dm::dm_add_fk(x, a, y) %>%
        dm::dm_add_fk(r, a, y) %>%
        dm::dm_add_fk(x, a, r, a)
    Code
      keyed_build_join_spec(y, x) %>% jsonlite::toJSON(pretty = TRUE)
    Output
      {
        "x_tbl": [
          {
            "b": 1
          }
        ],
        "y_tbl": [
          {
            "a": 1
          }
        ],
        "by": [
          {
            "x": "b",
            "y": "a"
          }
        ],
        "suffix": [".x", ".y"],
        "new_pk": {},
        "new_fks_in": [
          {
            "child_uuid": "0109020c-0b0a-030e-0d04-05060f070008",
            "child_fk_cols": ["a"],
            "parent_key_cols": ["b"]
          }
        ],
        "new_fks_out": [
          {
            "child_fk_cols": ["b"],
            "parent_uuid": "04080601-0b0a-0c02-0503-0e070f0d0009",
            "parent_key_cols": ["b"]
          }
        ],
        "new_uuid": ["03000c09-0a07-050d-020e-01040b08060f"]
      } 
    Code
      dm(x, y, r = left_join(y, x)) %>% dm_paste(options = c("select", "keys"))
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Message
      dm::dm(
        x,
        y,
        r,
      ) %>%
        dm::dm_select(x, a) %>%
        dm::dm_select(y, b) %>%
        dm::dm_select(r, b) %>%
        dm::dm_add_pk(y, b) %>%
        dm::dm_add_fk(x, a, y) %>%
        dm::dm_add_fk(r, b, y) %>%
        dm::dm_add_fk(x, a, r, b)

# joins with other child PK

    Code
      keyed_build_join_spec(x, y) %>% jsonlite::toJSON(pretty = TRUE)
    Output
      {
        "x_tbl": [
          {
            "a": 1,
            "c": 1
          }
        ],
        "y_tbl": [
          {
            "b": 1
          }
        ],
        "by": [
          {
            "x": "a",
            "y": "b"
          }
        ],
        "suffix": [".x", ".y"],
        "new_pk": ["c"],
        "new_fks_in": [
          {
            "child_uuid": "0109020c-0b0a-030e-0d04-05060f070008",
            "child_fk_cols": ["a"],
            "parent_key_cols": ["a"]
          }
        ],
        "new_fks_out": [
          {
            "child_fk_cols": ["a"],
            "parent_uuid": "04080601-0b0a-0c02-0503-0e070f0d0009",
            "parent_key_cols": ["b"]
          }
        ],
        "new_uuid": ["0800020b-0c07-030f-0a0e-0105060d0904"]
      } 
    Code
      dm(x, y, r = left_join(x, y)) %>% dm_paste(options = c("select", "keys"))
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Message
      dm::dm(
        x,
        y,
        r,
      ) %>%
        dm::dm_select(x, a, c) %>%
        dm::dm_select(y, b) %>%
        dm::dm_select(r, a, c) %>%
        dm::dm_add_pk(x, c) %>%
        dm::dm_add_pk(y, b) %>%
        dm::dm_add_pk(r, c) %>%
        dm::dm_add_fk(x, a, y) %>%
        dm::dm_add_fk(r, a, y) %>%
        dm::dm_add_fk(x, a, r, a)
    Code
      keyed_build_join_spec(y, x) %>% jsonlite::toJSON(pretty = TRUE)
    Output
      {
        "x_tbl": [
          {
            "b": 1
          }
        ],
        "y_tbl": [
          {
            "a": 1,
            "c": 1
          }
        ],
        "by": [
          {
            "x": "b",
            "y": "a"
          }
        ],
        "suffix": [".x", ".y"],
        "new_pk": ["c"],
        "new_fks_in": [
          {
            "child_uuid": "0109020c-0b0a-030e-0d04-05060f070008",
            "child_fk_cols": ["a"],
            "parent_key_cols": ["b"]
          }
        ],
        "new_fks_out": [
          {
            "child_fk_cols": ["b"],
            "parent_uuid": "04080601-0b0a-0c02-0503-0e070f0d0009",
            "parent_key_cols": ["b"]
          }
        ],
        "new_uuid": ["03000c09-0a07-050d-020e-01040b08060f"]
      } 
    Code
      dm(x, y, r = left_join(y, x)) %>% dm_paste(options = c("select", "keys"))
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Message
      dm::dm(
        x,
        y,
        r,
      ) %>%
        dm::dm_select(x, a, c) %>%
        dm::dm_select(y, b) %>%
        dm::dm_select(r, b, c) %>%
        dm::dm_add_pk(x, c) %>%
        dm::dm_add_pk(y, b) %>%
        dm::dm_add_pk(r, c) %>%
        dm::dm_add_fk(x, a, y) %>%
        dm::dm_add_fk(r, b, y) %>%
        dm::dm_add_fk(x, a, r, b)

# joins with other child PK and name conflict

    Code
      keyed_build_join_spec(x, y) %>% jsonlite::toJSON(pretty = TRUE)
    Output
      {
        "x_tbl": [
          {
            "a": 1,
            "b": 1
          }
        ],
        "y_tbl": [
          {
            "b": 1
          }
        ],
        "by": [
          {
            "x": "a",
            "y": "b"
          }
        ],
        "suffix": [".x", ".y"],
        "new_pk": ["b"],
        "new_fks_in": [
          {
            "child_uuid": "0109020c-0b0a-030e-0d04-05060f070008",
            "child_fk_cols": ["a"],
            "parent_key_cols": ["a"]
          }
        ],
        "new_fks_out": [
          {
            "child_fk_cols": ["a"],
            "parent_uuid": "04080601-0b0a-0c02-0503-0e070f0d0009",
            "parent_key_cols": ["b"]
          }
        ],
        "new_uuid": ["0800020b-0c07-030f-0a0e-0105060d0904"]
      } 
    Code
      dm(x, y, r = left_join(x, y)) %>% dm_paste(options = c("select", "keys"))
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Message
      dm::dm(
        x,
        y,
        r,
      ) %>%
        dm::dm_select(x, a, b) %>%
        dm::dm_select(y, b) %>%
        dm::dm_select(r, a, b) %>%
        dm::dm_add_pk(x, b) %>%
        dm::dm_add_pk(y, b) %>%
        dm::dm_add_pk(r, b) %>%
        dm::dm_add_fk(x, a, y) %>%
        dm::dm_add_fk(r, a, y) %>%
        dm::dm_add_fk(x, a, r, a)
    Code
      keyed_build_join_spec(y, x) %>% jsonlite::toJSON(pretty = TRUE)
    Output
      {
        "x_tbl": [
          {
            "b": 1
          }
        ],
        "y_tbl": [
          {
            "a": 1,
            "b": 1
          }
        ],
        "by": [
          {
            "x": "b",
            "y": "a"
          }
        ],
        "suffix": [".x", ".y"],
        "new_pk": ["b"],
        "new_fks_in": [
          {
            "child_uuid": "0109020c-0b0a-030e-0d04-05060f070008",
            "child_fk_cols": ["a"],
            "parent_key_cols": ["b"]
          }
        ],
        "new_fks_out": [
          {
            "child_fk_cols": ["b"],
            "parent_uuid": "04080601-0b0a-0c02-0503-0e070f0d0009",
            "parent_key_cols": ["b"]
          }
        ],
        "new_uuid": ["03000c09-0a07-050d-020e-01040b08060f"]
      } 
    Code
      dm(x, y, r = left_join(y, x)) %>% dm_paste(options = c("select", "keys"))
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Message
      dm::dm(
        x,
        y,
        r,
      ) %>%
        dm::dm_select(x, a, b) %>%
        dm::dm_select(y, b) %>%
        dm::dm_select(r, b, b.y) %>%
        dm::dm_add_pk(x, b) %>%
        dm::dm_add_pk(y, b) %>%
        dm::dm_add_pk(r, b) %>%
        dm::dm_add_fk(x, a, y) %>%
        dm::dm_add_fk(r, b, y) %>%
        dm::dm_add_fk(x, a, r)

# joins with same child PK

    Code
      keyed_build_join_spec(x, y) %>% jsonlite::toJSON(pretty = TRUE)
    Output
      {
        "x_tbl": [
          {
            "a": 1
          }
        ],
        "y_tbl": [
          {
            "b": 1
          }
        ],
        "by": [
          {
            "x": "a",
            "y": "b"
          }
        ],
        "suffix": [".x", ".y"],
        "new_pk": ["a"],
        "new_fks_in": [
          {
            "child_uuid": "0109020c-0b0a-030e-0d04-05060f070008",
            "child_fk_cols": ["a"],
            "parent_key_cols": ["a"]
          }
        ],
        "new_fks_out": [
          {
            "child_fk_cols": ["a"],
            "parent_uuid": "04080601-0b0a-0c02-0503-0e070f0d0009",
            "parent_key_cols": ["b"]
          }
        ],
        "new_uuid": ["0800020b-0c07-030f-0a0e-0105060d0904"]
      } 
    Code
      dm(x, y, r = left_join(x, y)) %>% dm_paste(options = c("select", "keys"))
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Message
      dm::dm(
        x,
        y,
        r,
      ) %>%
        dm::dm_select(x, a) %>%
        dm::dm_select(y, b) %>%
        dm::dm_select(r, a) %>%
        dm::dm_add_pk(x, a) %>%
        dm::dm_add_pk(y, b) %>%
        dm::dm_add_pk(r, a) %>%
        dm::dm_add_fk(x, a, y) %>%
        dm::dm_add_fk(r, a, y) %>%
        dm::dm_add_fk(x, a, r)
    Code
      keyed_build_join_spec(y, x) %>% jsonlite::toJSON(pretty = TRUE)
    Output
      {
        "x_tbl": [
          {
            "b": 1
          }
        ],
        "y_tbl": [
          {
            "a": 1
          }
        ],
        "by": [
          {
            "x": "b",
            "y": "a"
          }
        ],
        "suffix": [".x", ".y"],
        "new_pk": ["b"],
        "new_fks_in": [
          {
            "child_uuid": "0109020c-0b0a-030e-0d04-05060f070008",
            "child_fk_cols": ["a"],
            "parent_key_cols": ["b"]
          }
        ],
        "new_fks_out": [
          {
            "child_fk_cols": ["b"],
            "parent_uuid": "04080601-0b0a-0c02-0503-0e070f0d0009",
            "parent_key_cols": ["b"]
          }
        ],
        "new_uuid": ["03000c09-0a07-050d-020e-01040b08060f"]
      } 
    Code
      dm(x, y, r = left_join(y, x)) %>% dm_paste(options = c("select", "keys"))
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Message
      dm::dm(
        x,
        y,
        r,
      ) %>%
        dm::dm_select(x, a) %>%
        dm::dm_select(y, b) %>%
        dm::dm_select(r, b) %>%
        dm::dm_add_pk(x, a) %>%
        dm::dm_add_pk(y, b) %>%
        dm::dm_add_pk(r, b) %>%
        dm::dm_add_fk(x, a, y) %>%
        dm::dm_add_fk(r, b, y) %>%
        dm::dm_add_fk(x, a, r)

# joins with same child PK and same name

    Code
      keyed_build_join_spec(x, y) %>% jsonlite::toJSON(pretty = TRUE)
    Output
      {
        "x_tbl": [
          {
            "b": 1
          }
        ],
        "y_tbl": [
          {
            "b": 1
          }
        ],
        "by": [
          {
            "x": "b",
            "y": "b"
          }
        ],
        "suffix": [".x", ".y"],
        "new_pk": ["b"],
        "new_fks_in": [
          {
            "child_uuid": "0109020c-0b0a-030e-0d04-05060f070008",
            "child_fk_cols": ["b"],
            "parent_key_cols": ["b"]
          }
        ],
        "new_fks_out": [
          {
            "child_fk_cols": ["b"],
            "parent_uuid": "04080601-0b0a-0c02-0503-0e070f0d0009",
            "parent_key_cols": ["b"]
          }
        ],
        "new_uuid": ["0800020b-0c07-030f-0a0e-0105060d0904"]
      } 
    Code
      dm(x, y, r = left_join(x, y)) %>% dm_paste(options = c("select", "keys"))
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Message
      dm::dm(
        x,
        y,
        r,
      ) %>%
        dm::dm_select(x, b) %>%
        dm::dm_select(y, b) %>%
        dm::dm_select(r, b) %>%
        dm::dm_add_pk(x, b) %>%
        dm::dm_add_pk(y, b) %>%
        dm::dm_add_pk(r, b) %>%
        dm::dm_add_fk(x, b, y) %>%
        dm::dm_add_fk(r, b, y) %>%
        dm::dm_add_fk(x, b, r)
    Code
      keyed_build_join_spec(y, x) %>% jsonlite::toJSON(pretty = TRUE)
    Output
      {
        "x_tbl": [
          {
            "b": 1
          }
        ],
        "y_tbl": [
          {
            "b": 1
          }
        ],
        "by": [
          {
            "x": "b",
            "y": "b"
          }
        ],
        "suffix": [".x", ".y"],
        "new_pk": ["b"],
        "new_fks_in": [
          {
            "child_uuid": "0109020c-0b0a-030e-0d04-05060f070008",
            "child_fk_cols": ["b"],
            "parent_key_cols": ["b"]
          }
        ],
        "new_fks_out": [
          {
            "child_fk_cols": ["b"],
            "parent_uuid": "04080601-0b0a-0c02-0503-0e070f0d0009",
            "parent_key_cols": ["b"]
          }
        ],
        "new_uuid": ["03000c09-0a07-050d-020e-01040b08060f"]
      } 
    Code
      dm(x, y, r = left_join(y, x)) %>% dm_paste(options = c("select", "keys"))
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Message
      dm::dm(
        x,
        y,
        r,
      ) %>%
        dm::dm_select(x, b) %>%
        dm::dm_select(y, b) %>%
        dm::dm_select(r, b) %>%
        dm::dm_add_pk(x, b) %>%
        dm::dm_add_pk(y, b) %>%
        dm::dm_add_pk(r, b) %>%
        dm::dm_add_fk(x, b, y) %>%
        dm::dm_add_fk(r, b, y) %>%
        dm::dm_add_fk(x, b, r)

# joins with other FK from parent

    Code
      keyed_build_join_spec(x, y) %>% jsonlite::toJSON(pretty = TRUE)
    Output
      {
        "x_tbl": [
          {
            "a": 1
          }
        ],
        "y_tbl": [
          {
            "b": 1,
            "c": 1
          }
        ],
        "by": [
          {
            "x": "a",
            "y": "b"
          }
        ],
        "suffix": [".x", ".y"],
        "new_pk": ["a"],
        "new_fks_in": [
          {
            "child_uuid": "0109020c-0b0a-030e-0d04-05060f070008",
            "child_fk_cols": ["a"],
            "parent_key_cols": ["a"]
          }
        ],
        "new_fks_out": [
          {
            "child_fk_cols": ["a"],
            "parent_uuid": "04080601-0b0a-0c02-0503-0e070f0d0009",
            "parent_key_cols": ["b"]
          },
          {
            "child_fk_cols": ["c"],
            "parent_uuid": "0800020b-0c07-030f-0a0e-0105060d0904",
            "parent_key_cols": ["c"]
          }
        ],
        "new_uuid": ["0c0e080a-0307-0904-0b06-0205010f000d"]
      } 
    Code
      dm(x, y, z, r = left_join(x, y)) %>% dm_paste(options = c("select", "keys"))
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Message
      dm::dm(
        x,
        y,
        z,
        r,
      ) %>%
        dm::dm_select(x, a) %>%
        dm::dm_select(y, b, c) %>%
        dm::dm_select(z, c) %>%
        dm::dm_select(r, a, c) %>%
        dm::dm_add_pk(x, a) %>%
        dm::dm_add_pk(y, b) %>%
        dm::dm_add_pk(r, a) %>%
        dm::dm_add_fk(x, a, y) %>%
        dm::dm_add_fk(r, a, y) %>%
        dm::dm_add_fk(y, c, z, c) %>%
        dm::dm_add_fk(r, c, z, c) %>%
        dm::dm_add_fk(x, a, r)
    Code
      keyed_build_join_spec(y, x) %>% jsonlite::toJSON(pretty = TRUE)
    Output
      {
        "x_tbl": [
          {
            "b": 1,
            "c": 1
          }
        ],
        "y_tbl": [
          {
            "a": 1
          }
        ],
        "by": [
          {
            "x": "b",
            "y": "a"
          }
        ],
        "suffix": [".x", ".y"],
        "new_pk": ["b"],
        "new_fks_in": [
          {
            "child_uuid": "0109020c-0b0a-030e-0d04-05060f070008",
            "child_fk_cols": ["a"],
            "parent_key_cols": ["b"]
          }
        ],
        "new_fks_out": [
          {
            "child_fk_cols": ["c"],
            "parent_uuid": "0800020b-0c07-030f-0a0e-0105060d0904",
            "parent_key_cols": ["c"]
          },
          {
            "child_fk_cols": ["b"],
            "parent_uuid": "04080601-0b0a-0c02-0503-0e070f0d0009",
            "parent_key_cols": ["b"]
          }
        ],
        "new_uuid": ["0108090a-0403-0f05-0d0c-0b0006020e07"]
      } 
    Code
      dm(x, y, z, r = left_join(y, x)) %>% dm_paste(options = c("select", "keys"))
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Message
      dm::dm(
        x,
        y,
        z,
        r,
      ) %>%
        dm::dm_select(x, a) %>%
        dm::dm_select(y, b, c) %>%
        dm::dm_select(z, c) %>%
        dm::dm_select(r, b, c) %>%
        dm::dm_add_pk(x, a) %>%
        dm::dm_add_pk(y, b) %>%
        dm::dm_add_pk(r, b) %>%
        dm::dm_add_fk(x, a, y) %>%
        dm::dm_add_fk(r, b, y) %>%
        dm::dm_add_fk(y, c, z, c) %>%
        dm::dm_add_fk(r, c, z, c) %>%
        dm::dm_add_fk(x, a, r)

# joins with other FK from parent and name conflict

    Code
      keyed_build_join_spec(x, y) %>% jsonlite::toJSON(pretty = TRUE)
    Output
      {
        "x_tbl": [
          {
            "a": 1
          }
        ],
        "y_tbl": [
          {
            "b": 1,
            "a": 1
          }
        ],
        "by": [
          {
            "x": "a",
            "y": "b"
          }
        ],
        "suffix": [".x", ".y"],
        "new_pk": ["a"],
        "new_fks_in": [
          {
            "child_uuid": "0109020c-0b0a-030e-0d04-05060f070008",
            "child_fk_cols": ["a"],
            "parent_key_cols": ["a"]
          }
        ],
        "new_fks_out": [
          {
            "child_fk_cols": ["a"],
            "parent_uuid": "04080601-0b0a-0c02-0503-0e070f0d0009",
            "parent_key_cols": ["b"]
          },
          {
            "child_fk_cols": ["a"],
            "parent_uuid": "0800020b-0c07-030f-0a0e-0105060d0904",
            "parent_key_cols": ["a"]
          }
        ],
        "new_uuid": ["0c0e080a-0307-0904-0b06-0205010f000d"]
      } 
    Code
      dm(x, y, z, r = left_join(x, y)) %>% dm_paste(options = c("select", "keys"))
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Message
      dm::dm(
        x,
        y,
        z,
        r,
      ) %>%
        dm::dm_select(x, a) %>%
        dm::dm_select(y, b, a) %>%
        dm::dm_select(z, a) %>%
        dm::dm_select(r, a, a.y) %>%
        dm::dm_add_pk(x, a) %>%
        dm::dm_add_pk(y, b) %>%
        dm::dm_add_pk(r, a) %>%
        dm::dm_add_fk(x, a, y) %>%
        dm::dm_add_fk(r, a, y) %>%
        dm::dm_add_fk(y, a, z, a) %>%
        dm::dm_add_fk(r, a, z, a) %>%
        dm::dm_add_fk(x, a, r)
    Code
      keyed_build_join_spec(y, x) %>% jsonlite::toJSON(pretty = TRUE)
    Output
      {
        "x_tbl": [
          {
            "b": 1,
            "a": 1
          }
        ],
        "y_tbl": [
          {
            "a": 1
          }
        ],
        "by": [
          {
            "x": "b",
            "y": "a"
          }
        ],
        "suffix": [".x", ".y"],
        "new_pk": ["b"],
        "new_fks_in": [
          {
            "child_uuid": "0109020c-0b0a-030e-0d04-05060f070008",
            "child_fk_cols": ["a"],
            "parent_key_cols": ["b"]
          }
        ],
        "new_fks_out": [
          {
            "child_fk_cols": ["a"],
            "parent_uuid": "0800020b-0c07-030f-0a0e-0105060d0904",
            "parent_key_cols": ["a"]
          },
          {
            "child_fk_cols": ["b"],
            "parent_uuid": "04080601-0b0a-0c02-0503-0e070f0d0009",
            "parent_key_cols": ["b"]
          }
        ],
        "new_uuid": ["0108090a-0403-0f05-0d0c-0b0006020e07"]
      } 
    Code
      dm(x, y, z, r = left_join(y, x)) %>% dm_paste(options = c("select", "keys"))
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Message
      dm::dm(
        x,
        y,
        z,
        r,
      ) %>%
        dm::dm_select(x, a) %>%
        dm::dm_select(y, b, a) %>%
        dm::dm_select(z, a) %>%
        dm::dm_select(r, b, a) %>%
        dm::dm_add_pk(x, a) %>%
        dm::dm_add_pk(y, b) %>%
        dm::dm_add_pk(r, b) %>%
        dm::dm_add_fk(x, a, y) %>%
        dm::dm_add_fk(r, b, y) %>%
        dm::dm_add_fk(y, a, z, a) %>%
        dm::dm_add_fk(r, a, z, a) %>%
        dm::dm_add_fk(x, a, r)

# joins with other FK from child

    Code
      keyed_build_join_spec(x, y) %>% jsonlite::toJSON(pretty = TRUE)
    Output
      {
        "x_tbl": [
          {
            "a": 1,
            "c": 1
          }
        ],
        "y_tbl": [
          {
            "b": 1
          }
        ],
        "by": [
          {
            "x": "a",
            "y": "b"
          }
        ],
        "suffix": [".x", ".y"],
        "new_pk": ["a"],
        "new_fks_in": [
          {
            "child_uuid": "0109020c-0b0a-030e-0d04-05060f070008",
            "child_fk_cols": ["a"],
            "parent_key_cols": ["a"]
          }
        ],
        "new_fks_out": [
          {
            "child_fk_cols": ["a"],
            "parent_uuid": "04080601-0b0a-0c02-0503-0e070f0d0009",
            "parent_key_cols": ["b"]
          },
          {
            "child_fk_cols": ["c"],
            "parent_uuid": "0800020b-0c07-030f-0a0e-0105060d0904",
            "parent_key_cols": ["c"]
          }
        ],
        "new_uuid": ["0c0e080a-0307-0904-0b06-0205010f000d"]
      } 
    Code
      dm(x, y, z, r = left_join(x, y)) %>% dm_paste(options = c("select", "keys"))
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Message
      dm::dm(
        x,
        y,
        z,
        r,
      ) %>%
        dm::dm_select(x, a, c) %>%
        dm::dm_select(y, b) %>%
        dm::dm_select(z, c) %>%
        dm::dm_select(r, a, c) %>%
        dm::dm_add_pk(x, a) %>%
        dm::dm_add_pk(y, b) %>%
        dm::dm_add_pk(r, a) %>%
        dm::dm_add_fk(x, a, y) %>%
        dm::dm_add_fk(r, a, y) %>%
        dm::dm_add_fk(x, c, z, c) %>%
        dm::dm_add_fk(r, c, z, c) %>%
        dm::dm_add_fk(x, a, r)
    Code
      keyed_build_join_spec(y, x) %>% jsonlite::toJSON(pretty = TRUE)
    Output
      {
        "x_tbl": [
          {
            "b": 1
          }
        ],
        "y_tbl": [
          {
            "a": 1,
            "c": 1
          }
        ],
        "by": [
          {
            "x": "b",
            "y": "a"
          }
        ],
        "suffix": [".x", ".y"],
        "new_pk": ["b"],
        "new_fks_in": [
          {
            "child_uuid": "0109020c-0b0a-030e-0d04-05060f070008",
            "child_fk_cols": ["a"],
            "parent_key_cols": ["b"]
          }
        ],
        "new_fks_out": [
          {
            "child_fk_cols": ["b"],
            "parent_uuid": "04080601-0b0a-0c02-0503-0e070f0d0009",
            "parent_key_cols": ["b"]
          },
          {
            "child_fk_cols": ["c"],
            "parent_uuid": "0800020b-0c07-030f-0a0e-0105060d0904",
            "parent_key_cols": ["c"]
          }
        ],
        "new_uuid": ["0108090a-0403-0f05-0d0c-0b0006020e07"]
      } 
    Code
      dm(x, y, z, r = left_join(y, x)) %>% dm_paste(options = c("select", "keys"))
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Message
      dm::dm(
        x,
        y,
        z,
        r,
      ) %>%
        dm::dm_select(x, a, c) %>%
        dm::dm_select(y, b) %>%
        dm::dm_select(z, c) %>%
        dm::dm_select(r, b, c) %>%
        dm::dm_add_pk(x, a) %>%
        dm::dm_add_pk(y, b) %>%
        dm::dm_add_pk(r, b) %>%
        dm::dm_add_fk(x, a, y) %>%
        dm::dm_add_fk(r, b, y) %>%
        dm::dm_add_fk(x, c, z, c) %>%
        dm::dm_add_fk(r, c, z, c) %>%
        dm::dm_add_fk(x, a, r)

# joins with other FK from child and name conflict

    Code
      keyed_build_join_spec(x, y) %>% jsonlite::toJSON(pretty = TRUE)
    Output
      {
        "x_tbl": [
          {
            "a": 1,
            "b": 1
          }
        ],
        "y_tbl": [
          {
            "b": 1
          }
        ],
        "by": [
          {
            "x": "a",
            "y": "b"
          }
        ],
        "suffix": [".x", ".y"],
        "new_pk": ["a"],
        "new_fks_in": [
          {
            "child_uuid": "0109020c-0b0a-030e-0d04-05060f070008",
            "child_fk_cols": ["a"],
            "parent_key_cols": ["a"]
          }
        ],
        "new_fks_out": [
          {
            "child_fk_cols": ["a"],
            "parent_uuid": "04080601-0b0a-0c02-0503-0e070f0d0009",
            "parent_key_cols": ["b"]
          },
          {
            "child_fk_cols": ["b"],
            "parent_uuid": "0800020b-0c07-030f-0a0e-0105060d0904",
            "parent_key_cols": ["b"]
          }
        ],
        "new_uuid": ["0c0e080a-0307-0904-0b06-0205010f000d"]
      } 
    Code
      dm(x, y, z, r = left_join(x, y)) %>% dm_paste(options = c("select", "keys"))
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Message
      dm::dm(
        x,
        y,
        z,
        r,
      ) %>%
        dm::dm_select(x, a, b) %>%
        dm::dm_select(y, b) %>%
        dm::dm_select(z, b) %>%
        dm::dm_select(r, a, b) %>%
        dm::dm_add_pk(x, a) %>%
        dm::dm_add_pk(y, b) %>%
        dm::dm_add_pk(r, a) %>%
        dm::dm_add_fk(x, a, y) %>%
        dm::dm_add_fk(r, a, y) %>%
        dm::dm_add_fk(x, b, z, b) %>%
        dm::dm_add_fk(r, b, z, b) %>%
        dm::dm_add_fk(x, a, r)
    Code
      keyed_build_join_spec(y, x) %>% jsonlite::toJSON(pretty = TRUE)
    Output
      {
        "x_tbl": [
          {
            "b": 1
          }
        ],
        "y_tbl": [
          {
            "a": 1,
            "b": 1
          }
        ],
        "by": [
          {
            "x": "b",
            "y": "a"
          }
        ],
        "suffix": [".x", ".y"],
        "new_pk": ["b"],
        "new_fks_in": [
          {
            "child_uuid": "0109020c-0b0a-030e-0d04-05060f070008",
            "child_fk_cols": ["a"],
            "parent_key_cols": ["b"]
          }
        ],
        "new_fks_out": [
          {
            "child_fk_cols": ["b"],
            "parent_uuid": "04080601-0b0a-0c02-0503-0e070f0d0009",
            "parent_key_cols": ["b"]
          },
          {
            "child_fk_cols": ["b"],
            "parent_uuid": "0800020b-0c07-030f-0a0e-0105060d0904",
            "parent_key_cols": ["b"]
          }
        ],
        "new_uuid": ["0108090a-0403-0f05-0d0c-0b0006020e07"]
      } 
    Code
      dm(x, y, z, r = left_join(y, x)) %>% dm_paste(options = c("select", "keys"))
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Message
      dm::dm(
        x,
        y,
        z,
        r,
      ) %>%
        dm::dm_select(x, a, b) %>%
        dm::dm_select(y, b) %>%
        dm::dm_select(z, b) %>%
        dm::dm_select(r, b, b.y) %>%
        dm::dm_add_pk(x, a) %>%
        dm::dm_add_pk(y, b) %>%
        dm::dm_add_pk(r, b) %>%
        dm::dm_add_fk(x, a, y) %>%
        dm::dm_add_fk(r, b, y) %>%
        dm::dm_add_fk(x, b, z, b) %>%
        dm::dm_add_fk(r, b, z, b) %>%
        dm::dm_add_fk(x, a, r)

# left join works as expected with keyed tables

    Code
      dm <- dm_nycflights13()
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Code
      keyed_tbl_impl(dm, "weather") %>% left_join(keyed_tbl_impl(dm, "flights"),
      multiple = "all")
    Output
      # A tibble: 1,800 x 32
      # Keys:     --- | 1 | 4
         origin year.x month.x day.x hour.x  temp  dewp humid wind_dir wind_~1 wind_~2
         <chr>   <int>   <int> <int>  <int> <dbl> <dbl> <dbl>    <dbl>   <dbl>   <dbl>
       1 EWR      2013       1    10      0  41    32    70.1      230    8.06    NA  
       2 EWR      2013       1    10      1  39.0  30.0  69.9      210    9.21    NA  
       3 EWR      2013       1    10      2  39.0  28.9  66.8      230    6.90    NA  
       4 EWR      2013       1    10      3  39.9  27.0  59.5      270    5.75    NA  
       5 EWR      2013       1    10      4  41    26.1  55.0      320    6.90    NA  
       6 EWR      2013       1    10      5  41    26.1  55.0      300   12.7     20.7
       7 EWR      2013       1    10      5  41    26.1  55.0      300   12.7     20.7
       8 EWR      2013       1    10      6  39.9  25.0  54.8      280    6.90    17.3
       9 EWR      2013       1    10      6  39.9  25.0  54.8      280    6.90    17.3
      10 EWR      2013       1    10      6  39.9  25.0  54.8      280    6.90    17.3
      # ... with 1,790 more rows, 21 more variables: precip <dbl>, pressure <dbl>,
      #   visib <dbl>, time_hour <dttm>, year.y <int>, month.y <int>, day.y <int>,
      #   dep_time <int>, sched_dep_time <int>, dep_delay <dbl>, arr_time <int>,
      #   sched_arr_time <int>, arr_delay <dbl>, carrier <chr>, flight <int>,
      #   tailnum <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour.y <dbl>,
      #   minute <dbl>, and abbreviated variable names 1: wind_speed, 2: wind_gust

# semi_join()

    Code
      dm(x, y, r = semi_join(x, y)) %>% dm_paste(options = c("select", "keys"))
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Message
      dm::dm(
        x,
        y,
        r,
      ) %>%
        dm::dm_select(x, a) %>%
        dm::dm_select(y, b) %>%
        dm::dm_select(r, a) %>%
        dm::dm_add_pk(y, b) %>%
        dm::dm_add_fk(x, a, y) %>%
        dm::dm_add_fk(r, a, y)
    Code
      dm(x, y, r = semi_join(y, x)) %>% dm_paste(options = c("select", "keys"))
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Message
      dm::dm(
        x,
        y,
        r,
      ) %>%
        dm::dm_select(x, a) %>%
        dm::dm_select(y, b) %>%
        dm::dm_select(r, b) %>%
        dm::dm_add_pk(y, b) %>%
        dm::dm_add_pk(r, b) %>%
        dm::dm_add_fk(x, a, y) %>%
        dm::dm_add_fk(x, a, r)

# arrange for keyed tables produces expected output

    Code
      keyed_tbl_impl(dm, "airlines") %>% arrange(desc(name))
    Output
      # A tibble: 15 x 2
      # Keys:     `carrier` | 1 | 0
         carrier name                       
         <chr>   <chr>                      
       1 VX      Virgin America             
       2 UA      United Air Lines Inc.      
       3 US      US Airways Inc.            
       4 WN      Southwest Airlines Co.     
       5 YV      Mesa Airlines Inc.         
       6 B6      JetBlue Airways            
       7 HA      Hawaiian Airlines Inc.     
       8 F9      Frontier Airlines Inc.     
       9 EV      ExpressJet Airlines Inc.   
      10 MQ      Envoy Air                  
      11 9E      Endeavor Air Inc.          
      12 DL      Delta Air Lines Inc.       
      13 AA      American Airlines Inc.     
      14 AS      Alaska Airlines Inc.       
      15 FL      AirTran Airways Corporation

# group_by for keyed tables produces expected output

    Code
      dm <- dm_nycflights13(cycle = TRUE)
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Code
      keyed_tbl_impl(dm, "flights") %>% group_by(month)
    Output
      # A tibble: 1,761 x 19
      # Groups:   month [2]
      # Keys:     --- | 0 | 5
          year month   day dep_time sched_de~1 dep_d~2 arr_t~3 sched~4 arr_d~5 carrier
         <int> <int> <int>    <int>      <int>   <dbl>   <int>   <int>   <dbl> <chr>  
       1  2013     1    10        3       2359       4     426     437     -11 B6     
       2  2013     1    10       16       2359      17     447     444       3 B6     
       3  2013     1    10      450        500     -10     634     648     -14 US     
       4  2013     1    10      520        525      -5     813     820      -7 UA     
       5  2013     1    10      530        530       0     824     829      -5 UA     
       6  2013     1    10      531        540      -9     832     850     -18 AA     
       7  2013     1    10      535        540      -5    1015    1017      -2 B6     
       8  2013     1    10      546        600     -14     645     709     -24 B6     
       9  2013     1    10      549        600     -11     652     724     -32 EV     
      10  2013     1    10      550        600     -10     649     703     -14 US     
      # ... with 1,751 more rows, 9 more variables: flight <int>, tailnum <chr>,
      #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
      #   minute <dbl>, time_hour <dttm>, and abbreviated variable names
      #   1: sched_dep_time, 2: dep_delay, 3: arr_time, 4: sched_arr_time,
      #   5: arr_delay
    Code
      keyed_tbl_impl(dm, "airports") %>% group_by(tzone)
    Output
      # A tibble: 86 x 8
      # Groups:   tzone [6]
      # Keys:     `faa` | 2 | 0
         faa   name                                 lat    lon   alt    tz dst   tzone
         <chr> <chr>                              <dbl>  <dbl> <dbl> <dbl> <chr> <chr>
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
      keyed_tbl_impl(dm, "airports") %>% group_by(faa)
    Output
      # A tibble: 86 x 8
      # Groups:   faa [86]
      # Keys:     `faa` | 2 | 0
         faa   name                                 lat    lon   alt    tz dst   tzone
         <chr> <chr>                              <dbl>  <dbl> <dbl> <dbl> <chr> <chr>
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

# summarize for keyed tables produces expected output

    Code
      dm <- dm_nycflights13(cycle = TRUE)
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Code
      keyed_tbl_impl(dm, "airports") %>% summarise(mean_alt = mean(alt))
    Output
      # A tibble: 1 x 1
      # Keys:     --- | 0 | 0
        mean_alt
           <dbl>
      1     632.
    Code
      keyed_tbl_impl(dm, "airports") %>% group_by(tzone, dst) %>% summarise(mean_alt = mean(
        alt))
    Output
      # A tibble: 6 x 3
      # Groups:   tzone [6]
      # Keys:     `tzone`, `dst` | 0 | 0
        tzone               dst   mean_alt
        <chr>               <chr>    <dbl>
      1 America/Chicago     A         680.
      2 America/Denver      A        5399.
      3 America/Los_Angeles A         313.
      4 America/New_York    A         396.
      5 America/Phoenix     N        1135 
      6 Pacific/Honolulu    N          13 

# pks_df_from_keys_info()

    Code
      dm %>% dm_get_keyed_tables_impl() %>% pks_df_from_keys_info() %>% jsonlite::toJSON(
        pretty = TRUE)
    Output
      [
        {
          "table": "airlines",
          "pks": [
            {
              "column": ["carrier"],
              "autoincrement": false
            }
          ]
        },
        {
          "table": "airports",
          "pks": [
            {
              "column": ["faa"],
              "autoincrement": false
            }
          ]
        },
        {
          "table": "flights",
          "pks": {}
        },
        {
          "table": "planes",
          "pks": [
            {
              "column": ["tailnum"],
              "autoincrement": false
            }
          ]
        },
        {
          "table": "weather",
          "pks": [
            {
              "column": ["origin", "time_hour"],
              "autoincrement": false
            }
          ]
        }
      ] 

# uks_df_from_keys_info()

    Code
      dm %>% dm_get_keyed_tables_impl() %>% uks_df_from_keys_info() %>% jsonlite::toJSON(
        pretty = TRUE)
    Output
      [
        {
          "table": "tf_1",
          "uks": []
        },
        {
          "table": "tf_2",
          "uks": []
        },
        {
          "table": "tf_3",
          "uks": []
        },
        {
          "table": "tf_4",
          "uks": []
        },
        {
          "table": "tf_5",
          "uks": [
            {
              "column": ["l"]
            }
          ]
        },
        {
          "table": "tf_6",
          "uks": []
        }
      ] 

# fks_df_from_keys_info()

    Code
      dm %>% dm_get_keyed_tables_impl() %>% fks_df_from_keys_info() %>% jsonlite::toJSON(
        pretty = TRUE)
    Output
      [
        {
          "table": "airlines",
          "fks": [
            {
              "ref_column": ["carrier"],
              "table": "flights",
              "column": ["carrier"],
              "on_delete": "no_action"
            }
          ]
        },
        {
          "table": "airports",
          "fks": [
            {
              "ref_column": ["faa"],
              "table": "flights",
              "column": ["origin"],
              "on_delete": "no_action"
            },
            {
              "ref_column": ["faa"],
              "table": "flights",
              "column": ["dest"],
              "on_delete": "no_action"
            }
          ]
        },
        {
          "table": "planes",
          "fks": [
            {
              "ref_column": ["tailnum"],
              "table": "flights",
              "column": ["tailnum"],
              "on_delete": "no_action"
            }
          ]
        },
        {
          "table": "weather",
          "fks": [
            {
              "ref_column": ["origin", "time_hour"],
              "table": "flights",
              "column": ["origin", "time_hour"],
              "on_delete": "no_action"
            }
          ]
        }
      ] 

