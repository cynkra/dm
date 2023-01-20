# dumma

    Code
      # dummy

# dm_rows_insert()

    Code
      flights_init <- dm_nycflights13() %>% dm_zoom_to(flights) %>% filter(FALSE) %>%
        dm_update_zoomed() %>% dm_zoom_to(weather) %>% filter(FALSE) %>%
        dm_update_zoomed()
      sqlite <- dbConnect(RSQLite::SQLite())
      flights_sqlite <- copy_dm_to(sqlite, flights_init, temporary = FALSE)
      print(dm_nrow(flights_sqlite))
    Output
      airlines airports  flights   planes  weather 
            15       86        0      945        0 
    Code
      flights_hour10 <- dm_nycflights13() %>% dm_select_tbl(flights, weather) %>%
        dm_zoom_to(flights) %>% filter(month == 1, day == 10, hour == 10) %>%
        dm_update_zoomed() %>% dm_zoom_to(weather) %>% filter(month == 1, day == 10,
      hour == 10) %>% dm_update_zoomed()
      print(dm_nrow(flights_hour10))
    Output
      flights weather 
           43       3 
    Code
      flights_hour10_sqlite <- copy_dm_to(sqlite, flights_hour10)
      out <- dm_rows_append(flights_sqlite, flights_hour10_sqlite)
    Message
      Result is returned as a dm object with lazy tables. Use `in_place = FALSE` to mute this message, or `in_place = TRUE` to write to the underlying tables.
    Code
      print(dm_nrow(flights_sqlite))
    Output
      airlines airports  flights   planes  weather 
            15       86        0      945        0 
    Code
      dm_rows_append(flights_sqlite, flights_hour10_sqlite, in_place = TRUE)
      print(dm_nrow(flights_sqlite))
    Output
      airlines airports  flights   planes  weather 
            15       86       43      945        3 
    Code
      flights_hour11 <- dm_nycflights13() %>% dm_select_tbl(flights, weather) %>%
        dm_zoom_to(flights) %>% filter(month == 1, day == 10, hour == 11) %>%
        dm_update_zoomed() %>% dm_zoom_to(weather) %>% filter(month == 1, day == 10,
      hour == 11) %>% dm_update_zoomed()
      flights_hour11_sqlite <- copy_dm_to(sqlite, flights_hour11)
      flights_new <- dm_rows_append(flights_sqlite, flights_hour11_sqlite, in_place = FALSE)
      print(dm_nrow(flights_new))
    Output
      airlines airports  flights   planes  weather 
            15       86       88      945        6 
    Code
      print(dm_nrow(flights_sqlite))
    Output
      airlines airports  flights   planes  weather 
            15       86       43      945        3 
    Code
      flights_new %>% dm_examine_constraints()
    Message
      ! Unsatisfied constraints:
    Output
      * Table `flights`: foreign key `tailnum` into table `planes`: values of `flights$tailnum` not in `planes$tailnum`: N0EGMQ (1), N3BCAA (1), N3CCAA (1), N3CFAA (1), N3EHAA (1), ...
    Code
      dm_rows_append(flights_sqlite, flights_hour11_sqlite, in_place = TRUE)
      print(dm_nrow(flights_sqlite))
    Output
      airlines airports  flights   planes  weather 
            15       86       88      945        6 
    Code
      dbDisconnect(sqlite)

# dm_rows_update()

    Code
      dm_filter_rearranged <- dm_for_filter() %>% dm_select(tf_2, d, everything()) %>%
        dm_select(tf_4, i, everything()) %>% dm_select(tf_5, l, m, everything())
      suppressMessages(dm_copy <- copy_dm_to(my_db_test_src(), dm_filter_rearranged))
      dm_update_local <- dm(tf_1 = tibble(a = 2L, b = "q"), tf_4 = tibble(h = "e", i = "sieben",
        ), tf_5 = tibble(k = 3L, ww = 3, ), )
      dm_update_copy <- suppressMessages(copy_dm_to(my_db_test_src(), dm_update_local))
      dm_copy %>% pull_tbl(tf_2) %>% arrange_all()
    Output
            d c        e        e1
        <int> <chr>    <chr> <int>
      1     2 elephant D         4
      2     3 lion     E         5
      3     4 seal     F         6
      4     5 worm     G         7
      5     6 dog      E         5
      6     7 cat      F         6
    Code
      dm_copy %>% dm_rows_update(dm_update_copy) %>% pull_tbl(tf_2) %>% arrange_all()
    Message
      Result is returned as a dm object with lazy tables. Use `in_place = FALSE` to mute this message, or `in_place = TRUE` to write to the underlying tables.
    Output
            d c        e        e1
        <int> <chr>    <chr> <int>
      1     2 elephant D         4
      2     3 lion     E         5
      3     4 seal     F         6
      4     5 worm     G         7
      5     6 dog      E         5
      6     7 cat      F         6
    Code
      dm_copy %>% pull_tbl(tf_2) %>% arrange_all()
    Output
            d c        e        e1
        <int> <chr>    <chr> <int>
      1     2 elephant D         4
      2     3 lion     E         5
      3     4 seal     F         6
      4     5 worm     G         7
      5     6 dog      E         5
      6     7 cat      F         6
    Code
      dm_copy %>% dm_rows_update(dm_update_copy, in_place = FALSE) %>% pull_tbl(tf_2) %>%
        arrange_all()
    Output
            d c        e        e1
        <int> <chr>    <chr> <int>
      1     2 elephant D         4
      2     3 lion     E         5
      3     4 seal     F         6
      4     5 worm     G         7
      5     6 dog      E         5
      6     7 cat      F         6
    Code
      dm_copy %>% dm_get_tables() %>% map(arrange_all)
    Output
      $tf_1
             a b    
         <int> <chr>
       1     1 A    
       2     2 B    
       3     3 C    
       4     4 D    
       5     5 E    
       6     6 F    
       7     7 G    
       8     8 H    
       9     9 I    
      10    10 J    
      
      $tf_2
            d c        e        e1
        <int> <chr>    <chr> <int>
      1     2 elephant D         4
      2     3 lion     E         5
      3     4 seal     F         6
      4     5 worm     G         7
      5     6 dog      E         5
      6     7 cat      F         6
      
      $tf_3
         f        f1 g    
         <chr> <int> <chr>
       1 C         2 one  
       2 C         3 two  
       3 D         4 three
       4 E         5 four 
       5 F         6 five 
       6 G         7 six  
       7 H         7 seven
       8 I         7 eight
       9 J        10 nine 
      10 K        11 ten  
      
      $tf_4
        i     h     j        j1
        <chr> <chr> <chr> <int>
      1 five  c     E         5
      2 four  b     D         4
      3 seven e     F         6
      4 six   d     F         6
      5 three a     C         3
      
      $tf_5
        l     m             ww     k
        <chr> <chr>      <int> <int>
      1 b     house          2     1
      2 c     tree           2     2
      3 d     streetlamp     2     3
      4 e     streetlamp     2     4
      
      $tf_6
           zz n          o    
        <int> <chr>      <chr>
      1     1 garden     i    
      2     1 hill       g    
      3     1 house      e    
      4     1 streetlamp h    
      5     1 tree       f    
      
    Code
      dm_copy %>% dm_rows_update(dm_update_copy, in_place = TRUE)
      dm_copy %>% dm_get_tables() %>% map(arrange_all)
    Output
      $tf_1
             a b    
         <int> <chr>
       1     1 A    
       2     2 q    
       3     3 C    
       4     4 D    
       5     5 E    
       6     6 F    
       7     7 G    
       8     8 H    
       9     9 I    
      10    10 J    
      
      $tf_2
            d c        e        e1
        <int> <chr>    <chr> <int>
      1     2 elephant D         4
      2     3 lion     E         5
      3     4 seal     F         6
      4     5 worm     G         7
      5     6 dog      E         5
      6     7 cat      F         6
      
      $tf_3
         f        f1 g    
         <chr> <int> <chr>
       1 C         2 one  
       2 C         3 two  
       3 D         4 three
       4 E         5 four 
       5 F         6 five 
       6 G         7 six  
       7 H         7 seven
       8 I         7 eight
       9 J        10 nine 
      10 K        11 ten  
      
      $tf_4
        i      h     j        j1
        <chr>  <chr> <chr> <int>
      1 five   c     E         5
      2 four   b     D         4
      3 sieben e     F         6
      4 six    d     F         6
      5 three  a     C         3
      
      $tf_5
        l     m             ww     k
        <chr> <chr>      <int> <int>
      1 b     house          2     1
      2 c     tree           2     2
      3 d     streetlamp     3     3
      4 e     streetlamp     2     4
      
      $tf_6
           zz n          o    
        <int> <chr>      <chr>
      1     1 garden     i    
      2     1 hill       g    
      3     1 house      e    
      4     1 streetlamp h    
      5     1 tree       f    
      

# dm_rows_truncate()

    Code
      suppressMessages(dm_copy <- copy_dm_to(my_db_test_src(), dm_for_filter()))
      dm_truncate_local <- dm(tf_2 = tibble(c = c("worm"), d = 10L, ), tf_5 = tibble(
        k = 3L, m = "tree", ), )
      dm_truncate_copy <- suppressMessages(copy_dm_to(my_db_test_src(),
      dm_truncate_local))
      dm_copy %>% pull_tbl(tf_2) %>% arrange_all()
    Output
        c            d e        e1
        <chr>    <int> <chr> <int>
      1 cat          7 F         6
      2 dog          6 E         5
      3 elephant     2 D         4
      4 lion         3 E         5
      5 seal         4 F         6
      6 worm         5 G         7
    Code
      dm_copy %>% dm_rows_truncate(dm_truncate_copy) %>% pull_tbl(tf_2) %>%
        arrange_all()
    Condition
      Warning:
      `dm_rows_truncate()` was deprecated in dm 1.0.0.
    Message
      Result is returned as a dm object with lazy tables. Use `in_place = FALSE` to mute this message, or `in_place = TRUE` to write to the underlying tables.
    Output
      # ... with 4 variables: c <chr>, d <int>, e <chr>, e1 <int>
    Code
      dm_copy %>% pull_tbl(tf_2) %>% arrange_all()
    Output
        c            d e        e1
        <chr>    <int> <chr> <int>
      1 cat          7 F         6
      2 dog          6 E         5
      3 elephant     2 D         4
      4 lion         3 E         5
      5 seal         4 F         6
      6 worm         5 G         7
    Code
      dm_copy %>% dm_rows_truncate(dm_truncate_copy, in_place = FALSE) %>% pull_tbl(
        tf_2) %>% arrange_all()
    Condition
      Warning:
      `dm_rows_truncate()` was deprecated in dm 1.0.0.
    Output
      # ... with 4 variables: c <chr>, d <int>, e <chr>, e1 <int>
    Code
      dm_copy %>% dm_get_tables() %>% map(arrange_all)
    Output
      $tf_1
             a b    
         <int> <chr>
       1     1 A    
       2     2 B    
       3     3 C    
       4     4 D    
       5     5 E    
       6     6 F    
       7     7 G    
       8     8 H    
       9     9 I    
      10    10 J    
      
      $tf_2
        c            d e        e1
        <chr>    <int> <chr> <int>
      1 cat          7 F         6
      2 dog          6 E         5
      3 elephant     2 D         4
      4 lion         3 E         5
      5 seal         4 F         6
      6 worm         5 G         7
      
      $tf_3
         f        f1 g    
         <chr> <int> <chr>
       1 C         2 one  
       2 C         3 two  
       3 D         4 three
       4 E         5 four 
       5 F         6 five 
       6 G         7 six  
       7 H         7 seven
       8 I         7 eight
       9 J        10 nine 
      10 K        11 ten  
      
      $tf_4
        h     i     j        j1
        <chr> <chr> <chr> <int>
      1 a     three C         3
      2 b     four  D         4
      3 c     five  E         5
      4 d     six   F         6
      5 e     seven F         6
      
      $tf_5
           ww     k l     m         
        <int> <int> <chr> <chr>     
      1     2     1 b     house     
      2     2     2 c     tree      
      3     2     3 d     streetlamp
      4     2     4 e     streetlamp
      
      $tf_6
           zz n          o    
        <int> <chr>      <chr>
      1     1 garden     i    
      2     1 hill       g    
      3     1 house      e    
      4     1 streetlamp h    
      5     1 tree       f    
      
    Code
      dm_copy %>% dm_rows_truncate(dm_truncate_copy, in_place = TRUE)
    Condition
      Warning:
      `dm_rows_truncate()` was deprecated in dm 1.0.0.
      Warning:
      `sql_rows_truncate()` was deprecated in dm 1.0.0.
      Warning:
      `sql_rows_truncate()` was deprecated in dm 1.0.0.
    Code
      dm_copy %>% dm_get_tables() %>% map(arrange_all)
    Output
      $tf_1
             a b    
         <int> <chr>
       1     1 A    
       2     2 B    
       3     3 C    
       4     4 D    
       5     5 E    
       6     6 F    
       7     7 G    
       8     8 H    
       9     9 I    
      10    10 J    
      
      $tf_2
      # ... with 4 variables: c <chr>, d <int>, e <chr>, e1 <int>
      
      $tf_3
         f        f1 g    
         <chr> <int> <chr>
       1 C         2 one  
       2 C         3 two  
       3 D         4 three
       4 E         5 four 
       5 F         6 five 
       6 G         7 six  
       7 H         7 seven
       8 I         7 eight
       9 J        10 nine 
      10 K        11 ten  
      
      $tf_4
        h     i     j        j1
        <chr> <chr> <chr> <int>
      1 a     three C         3
      2 b     four  D         4
      3 c     five  E         5
      4 d     six   F         6
      5 e     seven F         6
      
      $tf_5
      # ... with 4 variables: ww <int>, k <int>, l <chr>, m <chr>
      
      $tf_6
           zz n          o    
        <int> <chr>      <chr>
      1     1 garden     i    
      2     1 hill       g    
      3     1 house      e    
      4     1 streetlamp h    
      5     1 tree       f    
      

# dm_rows_append() works with autoincrement PKs and FKS for selected DBs

    Code
      local_dm$t1
    Output
      # A tibble: 3 x 2
            a o    
        <int> <chr>
      1     5 a    
      2     6 b    
      3     7 c    
    Code
      local_dm$t2
    Output
      # A tibble: 3 x 3
            c     d o    
        <int> <int> <chr>
      1    10     7 c    
      2     9     6 b    
      3     8     5 a    
    Code
      local_dm$t3
    Output
      # A tibble: 3 x 2
            e o    
        <int> <chr>
      1     6 b    
      2     5 a    
      3     7 c    
    Code
      local_dm$t4
    Output
      # A tibble: 3 x 3
            g     h o    
        <int> <int> <chr>
      1     1     8 a    
      2     2     9 b    
      3     3    10 c    
    Code
      filled_dm$t1
    Output
      # A tibble: 3 x 2
            a o    
        <int> <chr>
      1     5 a    
      2     6 b    
      3     7 c    
    Code
      filled_dm$t2
    Output
      # A tibble: 3 x 3
            c     d o    
        <int> <int> <chr>
      1    10     7 c    
      2     9     6 b    
      3     8     5 a    
    Code
      filled_dm$t3
    Output
      # A tibble: 0 x 2
      # ... with 2 variables: e <int>, o <chr>
    Code
      filled_dm$t4
    Output
      # A tibble: 3 x 3
            g     h o    
        <int> <int> <chr>
      1    NA     8 a    
      2    NA     9 b    
      3    NA    10 c    
    Code
      filled_dm_in_place$t1
    Output
      # A tibble: 3 x 2
            a o    
        <int> <chr>
      1     1 a    
      2     2 b    
      3     3 c    
    Code
      filled_dm_in_place$t2
    Output
      # A tibble: 3 x 3
            c     d o    
        <int> <int> <chr>
      1     1     3 c    
      2     2     2 b    
      3     3     1 a    
    Code
      filled_dm_in_place$t3
    Output
      # A tibble: 0 x 2
      # ... with 2 variables: e <int>, o <chr>
    Code
      filled_dm_in_place$t4
    Output
      # A tibble: 3 x 3
            g     h o    
        <int> <int> <chr>
      1     1     3 a    
      2     2     2 b    
      3     3     1 c    
    Code
      filled_dm_in_place_twice$t1
    Output
      # A tibble: 6 x 2
            a o    
        <int> <chr>
      1     1 a    
      2     2 b    
      3     3 c    
      4     4 a    
      5     5 b    
      6     6 c    
    Code
      filled_dm_in_place_twice$t2
    Output
      # A tibble: 6 x 3
            c     d o    
        <int> <int> <chr>
      1     1     3 c    
      2     2     2 b    
      3     3     1 a    
      4     4     6 c    
      5     5     5 b    
      6     6     4 a    
    Code
      filled_dm_in_place_twice$t3
    Output
      # A tibble: 0 x 2
      # ... with 2 variables: e <int>, o <chr>
    Code
      filled_dm_in_place_twice$t4
    Output
      # A tibble: 6 x 3
            g     h o    
        <int> <int> <chr>
      1     1     3 a    
      2     2     2 b    
      3     3     1 c    
      4     4     6 a    
      5     5     5 b    
      6     6     4 c    
      

# dm_rows_append() works with autoincrement PKs and FKS locally

    Code
      local_dm$t1
    Output
      # A tibble: 3 x 2
            a o    
        <int> <chr>
      1     5 a    
      2     6 b    
      3     7 c    
    Code
      local_dm$t2
    Output
      # A tibble: 3 x 3
            c     d o    
        <int> <int> <chr>
      1    10     7 c    
      2     9     6 b    
      3     8     5 a    
    Code
      local_dm$t3
    Output
      # A tibble: 3 x 2
            e o    
        <int> <chr>
      1     6 b    
      2     5 a    
      3     7 c    
    Code
      local_dm$t4
    Output
      # A tibble: 3 x 3
            g     h o    
        <int> <int> <chr>
      1     1     8 a    
      2     2     9 b    
      3     3    10 c    
    Code
      filled_dm$t1
    Output
      # A tibble: 3 x 2
            a o    
        <int> <chr>
      1     1 a    
      2     2 b    
      3     3 c    
    Code
      filled_dm$t2
    Output
      # A tibble: 3 x 3
            c     d o    
        <int> <int> <chr>
      1     1     3 c    
      2     2     2 b    
      3     3     1 a    
    Code
      filled_dm$t3
    Output
      # A tibble: 0 x 2
      # ... with 2 variables: e <int>, o <chr>
    Code
      filled_dm$t4
    Output
      # A tibble: 3 x 3
            g     h o    
        <int> <int> <chr>
      1     1     3 a    
      2     2     2 b    
      3     3     1 c    
    Code
      filled_twice_dm$t1
    Output
      # A tibble: 6 x 2
            a o    
        <int> <chr>
      1     1 a    
      2     2 b    
      3     3 c    
      4     4 a    
      5     5 b    
      6     6 c    
    Code
      filled_twice_dm$t2
    Output
      # A tibble: 6 x 3
            c     d o    
        <int> <int> <chr>
      1     1     3 c    
      2     2     2 b    
      3     3     1 a    
      4     4     6 c    
      5     5     5 b    
      6     6     4 a    
    Code
      filled_twice_dm$t3
    Output
      # A tibble: 0 x 2
      # ... with 2 variables: e <int>, o <chr>
    Code
      filled_twice_dm$t4
    Output
      # A tibble: 6 x 3
            g     h o    
        <int> <int> <chr>
      1     1     3 a    
      2     2     2 b    
      3     3     1 c    
      4     4     6 a    
      5     5     5 b    
      6     6     4 c    

