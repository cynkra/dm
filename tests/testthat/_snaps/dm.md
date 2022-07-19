# dm() API

    Code
      dm(a = tibble(), a = tibble(), .name_repair = "unique")
    Message
      New names:
      * `a` -> `a...1`
      * `a` -> `a...2`
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `a...1`, `a...2`
      Columns: 0
      Primary keys: 0
      Foreign keys: 0
    Code
      dm(a = tibble(), a = tibble(), .name_repair = "unique", .quiet = TRUE)
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `a...1`, `a...2`
      Columns: 0
      Primary keys: 0
      Foreign keys: 0

---

    Code
      dm(a = tibble(), a = tibble())
    Condition
      Error in `dm()`:
      ! Names must be unique.
      x These names are duplicated:
        * "a" at locations 1 and 2.

---

    Code
      dm(a = dm())
    Condition
      Error in `dm()`:
      ! All dm objects passed to `dm()` must be unnamed.
      i Argument 1 has name `a`.

---

    Code
      dm(a = tibble(), dm_zoom_to(dm_for_filter(), tf_1))
    Condition
      Error in `dm()`:
      ! All dm objects passed to `dm()` must be unzoomed.
      i Argument 2 is a zoomed dm.

# dm() works for adding tables

    Code
      dm(dm_for_filter(), tf_1 = data_card_1(), .name_repair = "check_unique")
    Condition
      Error in `dm()`:
      ! Names must be unique.
      x These names are duplicated:
        * "tf_1" at locations 1 and 7.

# dm() for adding tables with compound keys

    Code
      dm(dm_for_flatten(), res_flat = result_from_flatten()) %>% dm_paste(options = c(
        "select", "keys"))
    Message
      dm::dm(
        fact,
        dim_1,
        dim_2,
        dim_3,
        dim_4,
        res_flat,
      ) %>%
        dm::dm_select(fact, fact, dim_1_key_1, dim_1_key_2, dim_2_key, dim_3_key, dim_4_key, something) %>%
        dm::dm_select(dim_1, dim_1_pk_1, dim_1_pk_2, something) %>%
        dm::dm_select(dim_2, dim_2_pk, something) %>%
        dm::dm_select(dim_3, dim_3_pk, something) %>%
        dm::dm_select(dim_4, dim_4_pk, something) %>%
        dm::dm_select(res_flat, fact, dim_1_key_1, dim_1_key_2, dim_2_key, dim_3_key, dim_4_key, fact.something, dim_1.something, dim_2.something, dim_3.something, dim_4.something) %>%
        dm::dm_add_pk(dim_1, c(dim_1_pk_1, dim_1_pk_2)) %>%
        dm::dm_add_pk(dim_2, dim_2_pk) %>%
        dm::dm_add_pk(dim_3, dim_3_pk) %>%
        dm::dm_add_pk(dim_4, dim_4_pk) %>%
        dm::dm_add_fk(fact, c(dim_1_key_1, dim_1_key_2), dim_1) %>%
        dm::dm_add_fk(fact, dim_2_key, dim_2) %>%
        dm::dm_add_fk(fact, dim_3_key, dim_3) %>%
        dm::dm_add_fk(fact, dim_4_key, dim_4)

# errors: duplicate table names, src mismatches

    Code
      dm(dm_for_filter(), dm_for_flatten(), dm_for_filter())
    Condition
      Error in `dm()`:
      ! Names must be unique.
      x These names are duplicated:
        * "tf_1" at locations 1 and 12.
        * "tf_2" at locations 2 and 13.
        * "tf_3" at locations 3 and 14.
        * "tf_4" at locations 4 and 15.
        * "tf_5" at locations 5 and 16.
        * ...

# test error output for src mismatches

    Code
      writeLines(conditionMessage(expect_error(dm(dm_for_flatten(),
      dm_for_filter_duckdb()))))
    Output
      All `dm` objects need to share the same `src`.

# output for dm() with dm

    Code
      dm()
    Output
      dm()
    Code
      dm(empty_dm())
    Output
      dm()
    Code
      dm(dm_for_filter()) %>% collect()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `tf_1`, `tf_2`, `tf_3`, `tf_4`, `tf_5`, `tf_6`
      Columns: 20
      Primary keys: 6
      Foreign keys: 5
    Code
      dm(dm_for_filter(), dm_for_flatten(), dm_for_filter(), .name_repair = "unique",
      .quiet = TRUE) %>% collect()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `tf_1...1`, `tf_2...2`, `tf_3...3`, `tf_4...4`, `tf_5...5`, ... (17 total)
      Columns: 56
      Primary keys: 16
      Foreign keys: 14

---

    Code
      dm(dm_for_filter(), dm_for_flatten(), dm_for_filter())
    Condition
      Error in `dm()`:
      ! Names must be unique.
      x These names are duplicated:
        * "tf_1" at locations 1 and 12.
        * "tf_2" at locations 2 and 13.
        * "tf_3" at locations 3 and 14.
        * "tf_4" at locations 4 and 15.
        * "tf_5" at locations 5 and 16.
        * ...

---

    Code
      dm(dm_for_filter(), dm_for_flatten(), dm_for_filter(), .name_repair = "unique") %>%
        collect()
    Message
      New names:
      * `tf_1` -> `tf_1...1`
      * `tf_2` -> `tf_2...2`
      * `tf_3` -> `tf_3...3`
      * `tf_4` -> `tf_4...4`
      * `tf_5` -> `tf_5...5`
      * `tf_6` -> `tf_6...6`
      * `tf_1` -> `tf_1...12`
      * `tf_2` -> `tf_2...13`
      * `tf_3` -> `tf_3...14`
      * `tf_4` -> `tf_4...15`
      * `tf_5` -> `tf_5...16`
      * `tf_6` -> `tf_6...17`
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `tf_1...1`, `tf_2...2`, `tf_3...3`, `tf_4...4`, `tf_5...5`, ... (17 total)
      Columns: 56
      Primary keys: 16
      Foreign keys: 14

# output dm() for dm for compound keys

    Code
      dm(dm_for_filter(), dm_for_flatten()) %>% dm_paste(options = c("select", "keys"))
    Message
      dm::dm(
        tf_1,
        tf_2,
        tf_3,
        tf_4,
        tf_5,
        tf_6,
        fact,
        dim_1,
        dim_2,
        dim_3,
        dim_4,
      ) %>%
        dm::dm_select(tf_1, a, b) %>%
        dm::dm_select(tf_2, c, d, e, e1) %>%
        dm::dm_select(tf_3, f, f1, g) %>%
        dm::dm_select(tf_4, h, i, j, j1) %>%
        dm::dm_select(tf_5, ww, k, l, m) %>%
        dm::dm_select(tf_6, zz, n, o) %>%
        dm::dm_select(fact, fact, dim_1_key_1, dim_1_key_2, dim_2_key, dim_3_key, dim_4_key, something) %>%
        dm::dm_select(dim_1, dim_1_pk_1, dim_1_pk_2, something) %>%
        dm::dm_select(dim_2, dim_2_pk, something) %>%
        dm::dm_select(dim_3, dim_3_pk, something) %>%
        dm::dm_select(dim_4, dim_4_pk, something) %>%
        dm::dm_add_pk(tf_1, a) %>%
        dm::dm_add_pk(tf_2, c) %>%
        dm::dm_add_pk(tf_3, c(f, f1)) %>%
        dm::dm_add_pk(tf_4, h) %>%
        dm::dm_add_pk(tf_5, k) %>%
        dm::dm_add_pk(tf_6, o) %>%
        dm::dm_add_pk(dim_1, c(dim_1_pk_1, dim_1_pk_2)) %>%
        dm::dm_add_pk(dim_2, dim_2_pk) %>%
        dm::dm_add_pk(dim_3, dim_3_pk) %>%
        dm::dm_add_pk(dim_4, dim_4_pk) %>%
        dm::dm_add_fk(tf_2, d, tf_1) %>%
        dm::dm_add_fk(tf_2, c(e, e1), tf_3) %>%
        dm::dm_add_fk(tf_4, c(j, j1), tf_3) %>%
        dm::dm_add_fk(tf_5, l, tf_4, on_delete = "cascade") %>%
        dm::dm_add_fk(tf_5, m, tf_6, n) %>%
        dm::dm_add_fk(fact, c(dim_1_key_1, dim_1_key_2), dim_1) %>%
        dm::dm_add_fk(fact, dim_2_key, dim_2) %>%
        dm::dm_add_fk(fact, dim_3_key, dim_3) %>%
        dm::dm_add_fk(fact, dim_4_key, dim_4)
    Code
      dm(dm_for_flatten(), dm_for_filter()) %>% dm_paste(options = c("select", "keys"))
    Message
      dm::dm(
        fact,
        dim_1,
        dim_2,
        dim_3,
        dim_4,
        tf_1,
        tf_2,
        tf_3,
        tf_4,
        tf_5,
        tf_6,
      ) %>%
        dm::dm_select(fact, fact, dim_1_key_1, dim_1_key_2, dim_2_key, dim_3_key, dim_4_key, something) %>%
        dm::dm_select(dim_1, dim_1_pk_1, dim_1_pk_2, something) %>%
        dm::dm_select(dim_2, dim_2_pk, something) %>%
        dm::dm_select(dim_3, dim_3_pk, something) %>%
        dm::dm_select(dim_4, dim_4_pk, something) %>%
        dm::dm_select(tf_1, a, b) %>%
        dm::dm_select(tf_2, c, d, e, e1) %>%
        dm::dm_select(tf_3, f, f1, g) %>%
        dm::dm_select(tf_4, h, i, j, j1) %>%
        dm::dm_select(tf_5, ww, k, l, m) %>%
        dm::dm_select(tf_6, zz, n, o) %>%
        dm::dm_add_pk(dim_1, c(dim_1_pk_1, dim_1_pk_2)) %>%
        dm::dm_add_pk(dim_2, dim_2_pk) %>%
        dm::dm_add_pk(dim_3, dim_3_pk) %>%
        dm::dm_add_pk(dim_4, dim_4_pk) %>%
        dm::dm_add_pk(tf_1, a) %>%
        dm::dm_add_pk(tf_2, c) %>%
        dm::dm_add_pk(tf_3, c(f, f1)) %>%
        dm::dm_add_pk(tf_4, h) %>%
        dm::dm_add_pk(tf_5, k) %>%
        dm::dm_add_pk(tf_6, o) %>%
        dm::dm_add_fk(fact, c(dim_1_key_1, dim_1_key_2), dim_1) %>%
        dm::dm_add_fk(fact, dim_2_key, dim_2) %>%
        dm::dm_add_fk(fact, dim_3_key, dim_3) %>%
        dm::dm_add_fk(fact, dim_4_key, dim_4) %>%
        dm::dm_add_fk(tf_2, d, tf_1) %>%
        dm::dm_add_fk(tf_2, c(e, e1), tf_3) %>%
        dm::dm_add_fk(tf_4, c(j, j1), tf_3) %>%
        dm::dm_add_fk(tf_5, l, tf_4, on_delete = "cascade") %>%
        dm::dm_add_fk(tf_5, m, tf_6, n)

---

    Code
      dm(dm_for_flatten(), dm_for_flatten(), .name_repair = "unique") %>% dm_paste(
        options = c("select", "keys"))
    Message
      New names:
      * `fact` -> `fact...1`
      * `dim_1` -> `dim_1...2`
      * `dim_2` -> `dim_2...3`
      * `dim_3` -> `dim_3...4`
      * `dim_4` -> `dim_4...5`
      * `fact` -> `fact...6`
      * `dim_1` -> `dim_1...7`
      * `dim_2` -> `dim_2...8`
      * `dim_3` -> `dim_3...9`
      * `dim_4` -> `dim_4...10`
      dm::dm(
        fact...1,
        dim_1...2,
        dim_2...3,
        dim_3...4,
        dim_4...5,
        fact...6,
        dim_1...7,
        dim_2...8,
        dim_3...9,
        dim_4...10,
      ) %>%
        dm::dm_select(fact...1, fact, dim_1_key_1, dim_1_key_2, dim_2_key, dim_3_key, dim_4_key, something) %>%
        dm::dm_select(dim_1...2, dim_1_pk_1, dim_1_pk_2, something) %>%
        dm::dm_select(dim_2...3, dim_2_pk, something) %>%
        dm::dm_select(dim_3...4, dim_3_pk, something) %>%
        dm::dm_select(dim_4...5, dim_4_pk, something) %>%
        dm::dm_select(fact...6, fact, dim_1_key_1, dim_1_key_2, dim_2_key, dim_3_key, dim_4_key, something) %>%
        dm::dm_select(dim_1...7, dim_1_pk_1, dim_1_pk_2, something) %>%
        dm::dm_select(dim_2...8, dim_2_pk, something) %>%
        dm::dm_select(dim_3...9, dim_3_pk, something) %>%
        dm::dm_select(dim_4...10, dim_4_pk, something) %>%
        dm::dm_add_pk(dim_1...2, c(dim_1_pk_1, dim_1_pk_2)) %>%
        dm::dm_add_pk(dim_2...3, dim_2_pk) %>%
        dm::dm_add_pk(dim_3...4, dim_3_pk) %>%
        dm::dm_add_pk(dim_4...5, dim_4_pk) %>%
        dm::dm_add_pk(dim_1...7, c(dim_1_pk_1, dim_1_pk_2)) %>%
        dm::dm_add_pk(dim_2...8, dim_2_pk) %>%
        dm::dm_add_pk(dim_3...9, dim_3_pk) %>%
        dm::dm_add_pk(dim_4...10, dim_4_pk) %>%
        dm::dm_add_fk(fact...1, c(dim_1_key_1, dim_1_key_2), dim_1...2) %>%
        dm::dm_add_fk(fact...1, dim_2_key, dim_2...3) %>%
        dm::dm_add_fk(fact...1, dim_3_key, dim_3...4) %>%
        dm::dm_add_fk(fact...1, dim_4_key, dim_4...5) %>%
        dm::dm_add_fk(fact...6, c(dim_1_key_1, dim_1_key_2), dim_1...7) %>%
        dm::dm_add_fk(fact...6, dim_2_key, dim_2...8) %>%
        dm::dm_add_fk(fact...6, dim_3_key, dim_3...9) %>%
        dm::dm_add_fk(fact...6, dim_4_key, dim_4...10)

# output

    Code
      print(dm())
    Output
      dm()
    Code
      nyc_flights_dm <- dm_nycflights_small()
      collect(nyc_flights_dm)
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 53
      Primary keys: 3
      Foreign keys: 3
    Code
      nyc_flights_dm %>% format()
    Output
      dm: 5 tables, 53 columns, 3 primary keys, 3 foreign keys
    Code
      nyc_flights_dm %>% dm_filter(flights = (origin == "EWR")) %>% collect()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 53
      Primary keys: 3
      Foreign keys: 3

# output for compound keys

    Code
      copy_to(nyc_comp(), mtcars, "car_table")
    Condition
      Warning:
      `copy_to.dm()` was deprecated in dm 0.2.0.
      Use `copy_to(dm_get_con(dm), ...)` and `dm()`.
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`, `car_table`
      Columns: 64
      Primary keys: 4
      Foreign keys: 4
    Code
      dm(nyc_comp(), car_table)
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`, `car_table`
      Columns: 64
      Primary keys: 4
      Foreign keys: 4
    Code
      nyc_comp() %>% collect()
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 53
      Primary keys: 4
      Foreign keys: 4
    Code
      nyc_comp() %>% dm_filter(flights = (day == 10)) %>% collect() %>% dm_get_def()
    Output
      # A tibble: 5 x 10
        table    data     segment display     pks     fks filters zoom   col_t~1 uuid 
        <chr>    <list>   <chr>   <chr>   <list<> <list<> <list<> <list> <list>  <chr>
      1 airlines <tibble> <NA>    <NA>    [1 x 1] [1 x 4] [0 x 2] <NULL> <NULL>  0d04~
      2 airports <tibble> <NA>    <NA>    [1 x 1] [1 x 4] [0 x 2] <NULL> <NULL>  0f0e~
      3 flights  <tibble> <NA>    <NA>    [0 x 1] [0 x 4] [0 x 2] <NULL> <NULL>  0405~
      4 planes   <tibble> <NA>    <NA>    [1 x 1] [1 x 4] [0 x 2] <NULL> <NULL>  0d0c~
      5 weather  <tibble> <NA>    <NA>    [1 x 1] [1 x 4] [0 x 2] <NULL> <NULL>  0702~
      # ... with abbreviated variable name 1: col_tracker_zoom
    Code
      nyc_comp() %>% dm_zoom_to(weather) %>% mutate(origin_new = paste0(origin,
        " airport")) %>% compute() %>% dm_update_zoomed() %>% collect() %>%
        dm_get_def()
    Output
      # A tibble: 5 x 10
        table    data     segment display     pks     fks filters zoom   col_t~1 uuid 
        <chr>    <list>   <chr>   <chr>   <list<> <list<> <list<> <list> <list>  <chr>
      1 airlines <tibble> <NA>    <NA>    [1 x 1] [1 x 4] [0 x 2] <NULL> <NULL>  0d04~
      2 airports <tibble> <NA>    <NA>    [1 x 1] [1 x 4] [0 x 2] <NULL> <NULL>  0f0e~
      3 flights  <tibble> <NA>    <NA>    [0 x 1] [0 x 4] [0 x 2] <NULL> <NULL>  0405~
      4 planes   <tibble> <NA>    <NA>    [1 x 1] [1 x 4] [0 x 2] <NULL> <NULL>  0d0c~
      5 weather  <tibble> <NA>    <NA>    [1 x 1] [1 x 4] [0 x 2] <NULL> <NULL>  0702~
      # ... with abbreviated variable name 1: col_tracker_zoom
    Code
      nyc_comp() %>% dm_zoom_to(weather) %>% collect()
    Message
      Detaching table from dm, use `collect(pull_tbl())` instead to silence this message.
    Output
      # A tibble: 144 x 15
         origin  year month   day  hour  temp  dewp humid wind_dir wind_speed wind_g~1
         <chr>  <int> <int> <int> <int> <dbl> <dbl> <dbl>    <dbl>      <dbl>    <dbl>
       1 EWR     2013     1    10     0  41    32    70.1      230       8.06     NA  
       2 EWR     2013     1    10     1  39.0  30.0  69.9      210       9.21     NA  
       3 EWR     2013     1    10     2  39.0  28.9  66.8      230       6.90     NA  
       4 EWR     2013     1    10     3  39.9  27.0  59.5      270       5.75     NA  
       5 EWR     2013     1    10     4  41    26.1  55.0      320       6.90     NA  
       6 EWR     2013     1    10     5  41    26.1  55.0      300      12.7      20.7
       7 EWR     2013     1    10     6  39.9  25.0  54.8      280       6.90     17.3
       8 EWR     2013     1    10     7  41    25.0  52.6      330       6.90     NA  
       9 EWR     2013     1    10     8  43.0  25.0  48.7      330       8.06     NA  
      10 EWR     2013     1    10     9  45.0  23    41.6      320      17.3      26.5
      # ... with 134 more rows, 4 more variables: precip <dbl>, pressure <dbl>,
      #   visib <dbl>, time_hour <dttm>, and abbreviated variable name 1: wind_gust
      # i Use `print(n = ...)` to see more rows, and `colnames()` to see all variable names
    Code
      pull_tbl(nyc_comp(), weather)
    Output
      # A tibble: 144 x 15
         origin  year month   day  hour  temp  dewp humid wind_dir wind_speed wind_g~1
         <chr>  <int> <int> <int> <int> <dbl> <dbl> <dbl>    <dbl>      <dbl>    <dbl>
       1 EWR     2013     1    10     0  41    32    70.1      230       8.06     NA  
       2 EWR     2013     1    10     1  39.0  30.0  69.9      210       9.21     NA  
       3 EWR     2013     1    10     2  39.0  28.9  66.8      230       6.90     NA  
       4 EWR     2013     1    10     3  39.9  27.0  59.5      270       5.75     NA  
       5 EWR     2013     1    10     4  41    26.1  55.0      320       6.90     NA  
       6 EWR     2013     1    10     5  41    26.1  55.0      300      12.7      20.7
       7 EWR     2013     1    10     6  39.9  25.0  54.8      280       6.90     17.3
       8 EWR     2013     1    10     7  41    25.0  52.6      330       6.90     NA  
       9 EWR     2013     1    10     8  43.0  25.0  48.7      330       8.06     NA  
      10 EWR     2013     1    10     9  45.0  23    41.6      320      17.3      26.5
      # ... with 134 more rows, 4 more variables: precip <dbl>, pressure <dbl>,
      #   visib <dbl>, time_hour <dttm>, and abbreviated variable name 1: wind_gust
      # i Use `print(n = ...)` to see more rows, and `colnames()` to see all variable names
    Code
      nyc_comp() %>% dm_zoom_to(weather) %>% pull_tbl()
    Output
      # A tibble: 144 x 15
         origin  year month   day  hour  temp  dewp humid wind_dir wind_speed wind_g~1
         <chr>  <int> <int> <int> <int> <dbl> <dbl> <dbl>    <dbl>      <dbl>    <dbl>
       1 EWR     2013     1    10     0  41    32    70.1      230       8.06     NA  
       2 EWR     2013     1    10     1  39.0  30.0  69.9      210       9.21     NA  
       3 EWR     2013     1    10     2  39.0  28.9  66.8      230       6.90     NA  
       4 EWR     2013     1    10     3  39.9  27.0  59.5      270       5.75     NA  
       5 EWR     2013     1    10     4  41    26.1  55.0      320       6.90     NA  
       6 EWR     2013     1    10     5  41    26.1  55.0      300      12.7      20.7
       7 EWR     2013     1    10     6  39.9  25.0  54.8      280       6.90     17.3
       8 EWR     2013     1    10     7  41    25.0  52.6      330       6.90     NA  
       9 EWR     2013     1    10     8  43.0  25.0  48.7      330       8.06     NA  
      10 EWR     2013     1    10     9  45.0  23    41.6      320      17.3      26.5
      # ... with 134 more rows, 4 more variables: precip <dbl>, pressure <dbl>,
      #   visib <dbl>, time_hour <dttm>, and abbreviated variable name 1: wind_gust
      # i Use `print(n = ...)` to see more rows, and `colnames()` to see all variable names

# glimpse.dm() works

    Code
      glimpse(empty_dm())
    Output
      dm of 0 tables
    Code
      glimpse(dm_for_disambiguate())
    Output
      dm of 3 tables: `iris_1`, `iris_2`, `iris_3`
      
      --------------------------------------------------------------------------------
      
      Table: `iris_1`
      Primary key: `key`
      
      Rows: 150
      Columns: 6
      $ key          <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17~
      $ Sepal.Length <dbl> 5.1, 4.9, 4.7, 4.6, 5.0, 5.4, 4.6, 5.0, 4.4, 4.9, 5.4, 4.~
      $ Sepal.Width  <dbl> 3.5, 3.0, 3.2, 3.1, 3.6, 3.9, 3.4, 3.4, 2.9, 3.1, 3.7, 3.~
      $ Petal.Length <dbl> 1.4, 1.4, 1.3, 1.5, 1.4, 1.7, 1.4, 1.5, 1.4, 1.5, 1.5, 1.~
      $ Petal.Width  <dbl> 0.2, 0.2, 0.2, 0.2, 0.2, 0.4, 0.3, 0.2, 0.2, 0.1, 0.2, 0.~
      $ Species      <chr> "setosa", "setosa", "setosa", "setosa", "setosa", "setosa~
      
      --------------------------------------------------------------------------------
      
      Table: `iris_2`
      1 outgoing foreign key(s):
        `key` -> `iris_1$key` no_action
      
      Rows: 150
      Columns: 7
      $ key          <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17~
      $ Sepal.Length <dbl> 5.1, 4.9, 4.7, 4.6, 5.0, 5.4, 4.6, 5.0, 4.4, 4.9, 5.4, 4.~
      $ Sepal.Width  <dbl> 3.5, 3.0, 3.2, 3.1, 3.6, 3.9, 3.4, 3.4, 2.9, 3.1, 3.7, 3.~
      $ Petal.Length <dbl> 1.4, 1.4, 1.3, 1.5, 1.4, 1.7, 1.4, 1.5, 1.4, 1.5, 1.5, 1.~
      $ Petal.Width  <dbl> 0.2, 0.2, 0.2, 0.2, 0.2, 0.4, 0.3, 0.2, 0.2, 0.1, 0.2, 0.~
      $ Species      <chr> "setosa", "setosa", "setosa", "setosa", "setosa", "setosa~
      $ other_col    <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ~
      
      --------------------------------------------------------------------------------
      
      Table: `iris_3`
      
      Rows: 150
      Columns: 8
      $ key          <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17~
      $ Sepal.Length <dbl> 5.1, 4.9, 4.7, 4.6, 5.0, 5.4, 4.6, 5.0, 4.4, 4.9, 5.4, 4.~
      $ Sepal.Width  <dbl> 3.5, 3.0, 3.2, 3.1, 3.6, 3.9, 3.4, 3.4, 2.9, 3.1, 3.7, 3.~
      $ Petal.Length <dbl> 1.4, 1.4, 1.3, 1.5, 1.4, 1.7, 1.4, 1.5, 1.4, 1.5, 1.5, 1.~
      $ Petal.Width  <dbl> 0.2, 0.2, 0.2, 0.2, 0.2, 0.4, 0.3, 0.2, 0.2, 0.1, 0.2, 0.~
      $ Species      <chr> "setosa", "setosa", "setosa", "setosa", "setosa", "setosa~
      $ other_col    <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ~
      $ one_more_col <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ~
      
      --------------------------------------------------------------------------------
    Code
      glimpse(dm_for_disambiguate(), width = 40)
    Output
      dm of 3 tables: `iris_1`, `iris_2`, `iri...
      
      --------------------------------------------------------------------------------
      
      Table: `iris_1`
      Primary key: `key`
      
      Rows: 150
      Columns: 6
      $ key          <int> 1, 2, 3, 4, 5, 6,~
      $ Sepal.Length <dbl> 5.1, 4.9, 4.7, 4.~
      $ Sepal.Width  <dbl> 3.5, 3.0, 3.2, 3.~
      $ Petal.Length <dbl> 1.4, 1.4, 1.3, 1.~
      $ Petal.Width  <dbl> 0.2, 0.2, 0.2, 0.~
      $ Species      <chr> "setosa", "setosa~
      
      --------------------------------------------------------------------------------
      
      Table: `iris_2`
      1 outgoing foreign key(s):
        `key` -> `iris_1$key` no_action
      
      Rows: 150
      Columns: 7
      $ key          <int> 1, 2, 3, 4, 5, 6,~
      $ Sepal.Length <dbl> 5.1, 4.9, 4.7, 4.~
      $ Sepal.Width  <dbl> 3.5, 3.0, 3.2, 3.~
      $ Petal.Length <dbl> 1.4, 1.4, 1.3, 1.~
      $ Petal.Width  <dbl> 0.2, 0.2, 0.2, 0.~
      $ Species      <chr> "setosa", "setosa~
      $ other_col    <int> 1, 1, 1, 1, 1, 1,~
      
      --------------------------------------------------------------------------------
      
      Table: `iris_3`
      
      Rows: 150
      Columns: 8
      $ key          <int> 1, 2, 3, 4, 5, 6,~
      $ Sepal.Length <dbl> 5.1, 4.9, 4.7, 4.~
      $ Sepal.Width  <dbl> 3.5, 3.0, 3.2, 3.~
      $ Petal.Length <dbl> 1.4, 1.4, 1.3, 1.~
      $ Petal.Width  <dbl> 0.2, 0.2, 0.2, 0.~
      $ Species      <chr> "setosa", "setosa~
      $ other_col    <int> 1, 1, 1, 1, 1, 1,~
      $ one_more_col <dbl> 1, 1, 1, 1, 1, 1,~
      
      --------------------------------------------------------------------------------
    Code
      getOption("width")
    Output
      [1] 80
    Code
      glimpse(dm_for_disambiguate() %>% dm_rename(iris_1,
        gdsjgiodsjgdisogjdsiogjdsigjsdiogjisdjgiodsjgiosdjgiojsdiogjgrjihjrehoierjhiorejhrieojhreiojhieorhjioerjhierjhioerjhioerjhioerjiohjeriosdiogjsdjigjsd = key) %>%
        dm_rename_tbl(
          gdsjgiodsjgdisogjdsiogjdsigjsdiogjisdjgiodsjgiosdjgiojsdiogjgrjihjrehoierjhiorejhrieojhreiojhieorhjioerjhierjhioerjhioerjhioerjiohjeriosdiogjsdjigjsd = iris_1))
    Output
      dm of 3 tables: `gdsjgiodsjgdisogjdsiogjdsigjsdiogjisdjgiodsjgiosdjgiojsdiogjgrj...
      
      --------------------------------------------------------------------------------
      
      Table: `gdsjgiodsjgdisogjdsiogjdsigjsdiogjisdjgiodsjgiosdjgiojsdiogjgrjihjrehoie...
      Primary key: `gdsjgiodsjgdisogjdsiogjdsigjsdiogjisdjgiodsjgiosdjgiojsdiogjgrjihj...
      
      Rows: 150
      Columns: 6
      $ gdsjgiodsjgdisogjdsiogjdsigjsdiogjisdjgiodsjgiosdjgiojsdiogjgrjihjrehoierjhiorejhrieojhreiojhieorhjioerjhierjhioerjhioerjhioerjiohjeriosdiogjsdjigjsd <int> ~
      $ Sepal.Length                                                                                                                                          <dbl> ~
      $ Sepal.Width                                                                                                                                           <dbl> ~
      $ Petal.Length                                                                                                                                          <dbl> ~
      $ Petal.Width                                                                                                                                           <dbl> ~
      $ Species                                                                                                                                               <chr> ~
      
      --------------------------------------------------------------------------------
      
      Table: `iris_2`
      1 outgoing foreign key(s):
        `key` -> `gdsjgiodsjgdisogjdsiogjdsigjsdiogjisdjgiodsjgiosdjgiojsdiogjgrjihjre...
      
      Rows: 150
      Columns: 7
      $ key          <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17~
      $ Sepal.Length <dbl> 5.1, 4.9, 4.7, 4.6, 5.0, 5.4, 4.6, 5.0, 4.4, 4.9, 5.4, 4.~
      $ Sepal.Width  <dbl> 3.5, 3.0, 3.2, 3.1, 3.6, 3.9, 3.4, 3.4, 2.9, 3.1, 3.7, 3.~
      $ Petal.Length <dbl> 1.4, 1.4, 1.3, 1.5, 1.4, 1.7, 1.4, 1.5, 1.4, 1.5, 1.5, 1.~
      $ Petal.Width  <dbl> 0.2, 0.2, 0.2, 0.2, 0.2, 0.4, 0.3, 0.2, 0.2, 0.1, 0.2, 0.~
      $ Species      <chr> "setosa", "setosa", "setosa", "setosa", "setosa", "setosa~
      $ other_col    <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ~
      
      --------------------------------------------------------------------------------
      
      Table: `iris_3`
      
      Rows: 150
      Columns: 8
      $ key          <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17~
      $ Sepal.Length <dbl> 5.1, 4.9, 4.7, 4.6, 5.0, 5.4, 4.6, 5.0, 4.4, 4.9, 5.4, 4.~
      $ Sepal.Width  <dbl> 3.5, 3.0, 3.2, 3.1, 3.6, 3.9, 3.4, 3.4, 2.9, 3.1, 3.7, 3.~
      $ Petal.Length <dbl> 1.4, 1.4, 1.3, 1.5, 1.4, 1.7, 1.4, 1.5, 1.4, 1.5, 1.5, 1.~
      $ Petal.Width  <dbl> 0.2, 0.2, 0.2, 0.2, 0.2, 0.4, 0.3, 0.2, 0.2, 0.1, 0.2, 0.~
      $ Species      <chr> "setosa", "setosa", "setosa", "setosa", "setosa", "setosa~
      $ other_col    <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ~
      $ one_more_col <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ~
      
      --------------------------------------------------------------------------------
    Code
      dm_nycflights13() %>% dm_select_tbl(weather) %>% dm_select(weather, -origin) %>%
        glimpse()
    Output
      dm of 1 tables: `weather`
      
      --------------------------------------------------------------------------------
      
      Table: `weather`
      
      Rows: 144
      Columns: 14
      $ year       <int> 2013, 2013, 2013, 2013, 2013, 2013, 2013, 2013, 2013, 2013,~
      $ month      <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,~
      $ day        <int> 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10,~
      $ hour       <int> 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 1~
      $ temp       <dbl> 41.00, 39.02, 39.02, 39.92, 41.00, 41.00, 39.92, 41.00, 42.~
      $ dewp       <dbl> 32.00, 30.02, 28.94, 26.96, 26.06, 26.06, 24.98, 24.98, 24.~
      $ humid      <dbl> 70.08, 69.86, 66.85, 59.50, 54.97, 54.97, 54.81, 52.56, 48.~
      $ wind_dir   <dbl> 230, 210, 230, 270, 320, 300, 280, 330, 330, 320, 320, 330,~
      $ wind_speed <dbl> 8.05546, 9.20624, 6.90468, 5.75390, 6.90468, 12.65858, 6.90~
      $ wind_gust  <dbl> NA, NA, NA, NA, NA, 20.71404, 17.26170, NA, NA, 26.46794, N~
      $ precip     <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,~
      $ pressure   <dbl> 1024.6, 1025.9, 1026.9, 1027.5, 1028.2, 1029.0, 1030.0, 103~
      $ visib      <dbl> 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10,~
      $ time_hour  <dttm> 2013-01-10 00:00:00, 2013-01-10 01:00:00, 2013-01-10 02:00~
      
      --------------------------------------------------------------------------------

# glimpse.zoomed_dm() works

    Code
      dm_nycflights13() %>% dm_zoom_to(airports) %>% glimpse()
    Output
      dm of 5 tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      
      Zoomed table: `airports`
      Primary key: `faa`
      
      Rows: 86
      Columns: 8
      $ faa   <chr> "ALB", "ATL", "AUS", "BDL", "BHM", "BNA", "BOS", "BTV", "BUF", "~
      $ name  <chr> "Albany Intl", "Hartsfield Jackson Atlanta Intl", "Austin Bergst~
      $ lat   <dbl> 42.74827, 33.63672, 30.19453, 41.93889, 33.56294, 36.12447, 42.3~
      $ lon   <dbl> -73.80169, -84.42807, -97.66989, -72.68322, -86.75355, -86.67819~
      $ alt   <dbl> 285, 1026, 542, 173, 644, 599, 19, 335, 724, 778, 146, 236, 1228~
      $ tz    <dbl> -5, -5, -6, -5, -6, -6, -5, -5, -5, -8, -5, -5, -5, -5, -5, -5, ~
      $ dst   <chr> "A", "A", "A", "A", "A", "A", "A", "A", "A", "A", "A", "A", "A",~
      $ tzone <chr> "America/New_York", "America/New_York", "America/Chicago", "Amer~
    Code
      dm_nycflights13() %>% dm_zoom_to(flights) %>% glimpse(width = 100)
    Output
      dm of 5 tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      
      Zoomed table: `flights`
      4 outgoing foreign key(s):
        `carrier` -> `airlines$carrier` no_action
        `origin` -> `airports$faa` no_action
        `tailnum` -> `planes$tailnum` no_action
        (`origin`, `time_hour`) -> (`weather$origin`, `weather$time_hour`) no_action
      
      Rows: 1,761
      Columns: 19
      $ year           <int> 2013, 2013, 2013, 2013, 2013, 2013, 2013, 2013, 2013, 2013, 2013, 2013, 201~
      $ month          <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ~
      $ day            <int> 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10,~
      $ dep_time       <int> 3, 16, 450, 520, 530, 531, 535, 546, 549, 550, 553, 553, 553, 553, 555, 555~
      $ sched_dep_time <int> 2359, 2359, 500, 525, 530, 540, 540, 600, 600, 600, 600, 600, 600, 600, 600~
      $ dep_delay      <dbl> 4, 17, -10, -5, 0, -9, -5, -14, -11, -10, -7, -7, -7, -7, -5, -10, -5, -4, ~
      $ arr_time       <int> 426, 447, 634, 813, 824, 832, 1015, 645, 652, 649, 711, 837, 834, 733, 733,~
      $ sched_arr_time <int> 437, 444, 648, 820, 829, 850, 1017, 709, 724, 703, 715, 910, 859, 759, 745,~
      $ arr_delay      <dbl> -11, 3, -14, -7, -5, -18, -2, -24, -32, -14, -4, -33, -25, -26, -12, -19, 2~
      $ carrier        <chr> "B6", "B6", "US", "UA", "UA", "AA", "B6", "B6", "EV", "US", "EV", "AA", "B6~
      $ flight         <int> 727, 739, 1117, 1018, 404, 1141, 725, 380, 6055, 2114, 5716, 707, 507, 731,~
      $ tailnum        <chr> "N571JB", "N564JB", "N171US", "N35204", "N815UA", "N5EAAA", "N784JB", "N337~
      $ origin         <chr> "JFK", "JFK", "EWR", "EWR", "LGA", "JFK", "JFK", "EWR", "LGA", "LGA", "JFK"~
      $ dest           <chr> "BQN", "PSE", "CLT", "IAH", "IAH", "MIA", "BQN", "BOS", "IAD", "BOS", "IAD"~
      $ air_time       <dbl> 183, 191, 78, 215, 210, 149, 191, 39, 48, 36, 51, 201, 144, 85, 126, 94, 42~
      $ distance       <dbl> 1576, 1617, 529, 1400, 1416, 1089, 1576, 200, 229, 184, 228, 1389, 1065, 50~
      $ hour           <dbl> 23, 23, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6~
      $ minute         <dbl> 59, 59, 0, 25, 30, 40, 40, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, ~
      $ time_hour      <dttm> 2013-01-10 23:00:00, 2013-01-10 23:00:00, 2013-01-10 05:00:00, 2013-01-10 ~
    Code
      dm_nycflights13() %>% dm_zoom_to(weather) %>% select(-origin) %>% glimpse()
    Output
      dm of 5 tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      
      Zoomed table: `weather`
      
      Rows: 144
      Columns: 14
      $ year       <int> 2013, 2013, 2013, 2013, 2013, 2013, 2013, 2013, 2013, 2013,~
      $ month      <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,~
      $ day        <int> 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10,~
      $ hour       <int> 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 1~
      $ temp       <dbl> 41.00, 39.02, 39.02, 39.92, 41.00, 41.00, 39.92, 41.00, 42.~
      $ dewp       <dbl> 32.00, 30.02, 28.94, 26.96, 26.06, 26.06, 24.98, 24.98, 24.~
      $ humid      <dbl> 70.08, 69.86, 66.85, 59.50, 54.97, 54.97, 54.81, 52.56, 48.~
      $ wind_dir   <dbl> 230, 210, 230, 270, 320, 300, 280, 330, 330, 320, 320, 330,~
      $ wind_speed <dbl> 8.05546, 9.20624, 6.90468, 5.75390, 6.90468, 12.65858, 6.90~
      $ wind_gust  <dbl> NA, NA, NA, NA, NA, 20.71404, 17.26170, NA, NA, 26.46794, N~
      $ precip     <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,~
      $ pressure   <dbl> 1024.6, 1025.9, 1026.9, 1027.5, 1028.2, 1029.0, 1030.0, 103~
      $ visib      <dbl> 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10,~
      $ time_hour  <dttm> 2013-01-10 00:00:00, 2013-01-10 01:00:00, 2013-01-10 02:00~
    Code
      dm_nycflights13() %>% dm_zoom_to(weather) %>% rename(origin_location = origin) %>%
        glimpse()
    Output
      dm of 5 tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      
      Zoomed table: `weather`
      Primary key: (`origin_location`, `time_hour`)
      
      Rows: 144
      Columns: 15
      $ origin_location <chr> "EWR", "EWR", "EWR", "EWR", "EWR", "EWR", "EWR", "EWR"~
      $ year            <int> 2013, 2013, 2013, 2013, 2013, 2013, 2013, 2013, 2013, ~
      $ month           <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ~
      $ day             <int> 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10~
      $ hour            <int> 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, ~
      $ temp            <dbl> 41.00, 39.02, 39.02, 39.92, 41.00, 41.00, 39.92, 41.00~
      $ dewp            <dbl> 32.00, 30.02, 28.94, 26.96, 26.06, 26.06, 24.98, 24.98~
      $ humid           <dbl> 70.08, 69.86, 66.85, 59.50, 54.97, 54.97, 54.81, 52.56~
      $ wind_dir        <dbl> 230, 210, 230, 270, 320, 300, 280, 330, 330, 320, 320,~
      $ wind_speed      <dbl> 8.05546, 9.20624, 6.90468, 5.75390, 6.90468, 12.65858,~
      $ wind_gust       <dbl> NA, NA, NA, NA, NA, 20.71404, 17.26170, NA, NA, 26.467~
      $ precip          <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ~
      $ pressure        <dbl> 1024.6, 1025.9, 1026.9, 1027.5, 1028.2, 1029.0, 1030.0~
      $ visib           <dbl> 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10~
      $ time_hour       <dttm> 2013-01-10 00:00:00, 2013-01-10 01:00:00, 2013-01-10 ~
    Code
      dm_nycflights13() %>% dm_zoom_to(flights) %>% select(-carrier) %>% glimpse()
    Output
      dm of 5 tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      
      Zoomed table: `flights`
      3 outgoing foreign key(s):
        `origin` -> `airports$faa` no_action
        `tailnum` -> `planes$tailnum` no_action
        (`origin`, `time_hour`) -> (`weather$origin`, `weather$time_hour`) no_action
      
      Rows: 1,761
      Columns: 18
      $ year           <int> 2013, 2013, 2013, 2013, 2013, 2013, 2013, 2013, 2013, 2~
      $ month          <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1~
      $ day            <int> 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10,~
      $ dep_time       <int> 3, 16, 450, 520, 530, 531, 535, 546, 549, 550, 553, 553~
      $ sched_dep_time <int> 2359, 2359, 500, 525, 530, 540, 540, 600, 600, 600, 600~
      $ dep_delay      <dbl> 4, 17, -10, -5, 0, -9, -5, -14, -11, -10, -7, -7, -7, -~
      $ arr_time       <int> 426, 447, 634, 813, 824, 832, 1015, 645, 652, 649, 711,~
      $ sched_arr_time <int> 437, 444, 648, 820, 829, 850, 1017, 709, 724, 703, 715,~
      $ arr_delay      <dbl> -11, 3, -14, -7, -5, -18, -2, -24, -32, -14, -4, -33, -~
      $ flight         <int> 727, 739, 1117, 1018, 404, 1141, 725, 380, 6055, 2114, ~
      $ tailnum        <chr> "N571JB", "N564JB", "N171US", "N35204", "N815UA", "N5EA~
      $ origin         <chr> "JFK", "JFK", "EWR", "EWR", "LGA", "JFK", "JFK", "EWR",~
      $ dest           <chr> "BQN", "PSE", "CLT", "IAH", "IAH", "MIA", "BQN", "BOS",~
      $ air_time       <dbl> 183, 191, 78, 215, 210, 149, 191, 39, 48, 36, 51, 201, ~
      $ distance       <dbl> 1576, 1617, 529, 1400, 1416, 1089, 1576, 200, 229, 184,~
      $ hour           <dbl> 23, 23, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,~
      $ minute         <dbl> 59, 59, 0, 25, 30, 40, 40, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0~
      $ time_hour      <dttm> 2013-01-10 23:00:00, 2013-01-10 23:00:00, 2013-01-10 0~
    Code
      dm_nycflights13() %>% dm_zoom_to(flights) %>% select(-origin) %>% glimpse()
    Output
      dm of 5 tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      
      Zoomed table: `flights`
      2 outgoing foreign key(s):
        `carrier` -> `airlines$carrier` no_action
        `tailnum` -> `planes$tailnum` no_action
      
      Rows: 1,761
      Columns: 18
      $ year           <int> 2013, 2013, 2013, 2013, 2013, 2013, 2013, 2013, 2013, 2~
      $ month          <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1~
      $ day            <int> 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10,~
      $ dep_time       <int> 3, 16, 450, 520, 530, 531, 535, 546, 549, 550, 553, 553~
      $ sched_dep_time <int> 2359, 2359, 500, 525, 530, 540, 540, 600, 600, 600, 600~
      $ dep_delay      <dbl> 4, 17, -10, -5, 0, -9, -5, -14, -11, -10, -7, -7, -7, -~
      $ arr_time       <int> 426, 447, 634, 813, 824, 832, 1015, 645, 652, 649, 711,~
      $ sched_arr_time <int> 437, 444, 648, 820, 829, 850, 1017, 709, 724, 703, 715,~
      $ arr_delay      <dbl> -11, 3, -14, -7, -5, -18, -2, -24, -32, -14, -4, -33, -~
      $ carrier        <chr> "B6", "B6", "US", "UA", "UA", "AA", "B6", "B6", "EV", "~
      $ flight         <int> 727, 739, 1117, 1018, 404, 1141, 725, 380, 6055, 2114, ~
      $ tailnum        <chr> "N571JB", "N564JB", "N171US", "N35204", "N815UA", "N5EA~
      $ dest           <chr> "BQN", "PSE", "CLT", "IAH", "IAH", "MIA", "BQN", "BOS",~
      $ air_time       <dbl> 183, 191, 78, 215, 210, 149, 191, 39, 48, 36, 51, 201, ~
      $ distance       <dbl> 1576, 1617, 529, 1400, 1416, 1089, 1576, 200, 229, 184,~
      $ hour           <dbl> 23, 23, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,~
      $ minute         <dbl> 59, 59, 0, 25, 30, 40, 40, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0~
      $ time_hour      <dttm> 2013-01-10 23:00:00, 2013-01-10 23:00:00, 2013-01-10 0~
    Code
      dm_nycflights13() %>% dm_zoom_to(flights) %>% rename(origin_location = origin) %>%
        glimpse()
    Output
      dm of 5 tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      
      Zoomed table: `flights`
      4 outgoing foreign key(s):
        `carrier` -> `airlines$carrier` no_action
        `origin_location` -> `airports$faa` no_action
        `tailnum` -> `planes$tailnum` no_action
        (`origin_location`, `time_hour`) -> (`weather$origin`, `weather$time_hour`) no...
      
      Rows: 1,761
      Columns: 19
      $ year            <int> 2013, 2013, 2013, 2013, 2013, 2013, 2013, 2013, 2013, ~
      $ month           <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ~
      $ day             <int> 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10~
      $ dep_time        <int> 3, 16, 450, 520, 530, 531, 535, 546, 549, 550, 553, 55~
      $ sched_dep_time  <int> 2359, 2359, 500, 525, 530, 540, 540, 600, 600, 600, 60~
      $ dep_delay       <dbl> 4, 17, -10, -5, 0, -9, -5, -14, -11, -10, -7, -7, -7, ~
      $ arr_time        <int> 426, 447, 634, 813, 824, 832, 1015, 645, 652, 649, 711~
      $ sched_arr_time  <int> 437, 444, 648, 820, 829, 850, 1017, 709, 724, 703, 715~
      $ arr_delay       <dbl> -11, 3, -14, -7, -5, -18, -2, -24, -32, -14, -4, -33, ~
      $ carrier         <chr> "B6", "B6", "US", "UA", "UA", "AA", "B6", "B6", "EV", ~
      $ flight          <int> 727, 739, 1117, 1018, 404, 1141, 725, 380, 6055, 2114,~
      $ tailnum         <chr> "N571JB", "N564JB", "N171US", "N35204", "N815UA", "N5E~
      $ origin_location <chr> "JFK", "JFK", "EWR", "EWR", "LGA", "JFK", "JFK", "EWR"~
      $ dest            <chr> "BQN", "PSE", "CLT", "IAH", "IAH", "MIA", "BQN", "BOS"~
      $ air_time        <dbl> 183, 191, 78, 215, 210, 149, 191, 39, 48, 36, 51, 201,~
      $ distance        <dbl> 1576, 1617, 529, 1400, 1416, 1089, 1576, 200, 229, 184~
      $ hour            <dbl> 23, 23, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6~
      $ minute          <dbl> 59, 59, 0, 25, 30, 40, 40, 0, 0, 0, 0, 0, 0, 0, 0, 5, ~
      $ time_hour       <dttm> 2013-01-10 23:00:00, 2013-01-10 23:00:00, 2013-01-10 ~

