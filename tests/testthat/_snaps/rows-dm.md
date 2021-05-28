# dm_rows_insert()

    Code
      flights_init <- dm_nycflights13() |> dm_zoom_to(flights) |> filter(FALSE) |>
        dm_update_zoomed() |> dm_zoom_to(weather) |> filter(FALSE) |>
        dm_update_zoomed()
      sqlite <- dbConnect(RSQLite::SQLite())
      flights_sqlite <- copy_dm_to(sqlite, flights_init, temporary = FALSE)
      print(dm_nrow(flights_sqlite))
    Output
      airlines airports  flights   planes  weather 
            15       86        0      945        0 
    Code
      flights_hour10 <- dm_nycflights13() |> dm_select_tbl(flights, weather) |>
        dm_zoom_to(flights) |> filter(month == 1, day == 10, hour == 10) |>
        dm_update_zoomed() |> dm_zoom_to(weather) |> filter(month == 1, day == 10,
      hour == 10) |> dm_update_zoomed()
      print(dm_nrow(flights_hour10))
    Output
      flights weather 
           43       3 
    Code
      flights_hour10_sqlite <- copy_dm_to(sqlite, flights_hour10)
      out <- dm_rows_insert(flights_sqlite, flights_hour10_sqlite)
    Message <simpleMessage>
      Not persisting, use `in_place = FALSE` to turn off this message.
    Code
      print(dm_nrow(flights_sqlite))
    Output
      airlines airports  flights   planes  weather 
            15       86        0      945        0 
    Code
      dm_rows_insert(flights_sqlite, flights_hour10_sqlite, in_place = TRUE)
      print(dm_nrow(flights_sqlite))
    Output
      airlines airports  flights   planes  weather 
            15       86       43      945        3 
    Code
      flights_hour11 <- dm_nycflights13() |> dm_select_tbl(flights, weather) |>
        dm_zoom_to(flights) |> filter(month == 1, day == 10, hour == 11) |>
        dm_update_zoomed() |> dm_zoom_to(weather) |> filter(month == 1, day == 10,
      hour == 11) |> dm_update_zoomed()
      flights_hour11_sqlite <- copy_dm_to(sqlite, flights_hour11)
      flights_new <- dm_rows_insert(flights_sqlite, flights_hour11_sqlite, in_place = FALSE)
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
      flights_new |> dm_examine_constraints()
    Message <cliMessage>
      ! Unsatisfied constraints:
    Output
      * Table `flights`: foreign key tailnum into table `planes`: values of `flights$tailnum` not in `planes$tailnum`: N0EGMQ (1), N3BCAA (1), N3CCAA (1), N3CFAA (1), N3EHAA (1), ...
    Code
      dm_rows_insert(flights_sqlite, flights_hour11_sqlite, in_place = TRUE)
      print(dm_nrow(flights_sqlite))
    Output
      airlines airports  flights   planes  weather 
            15       86       88      945        6 
    Code
      dbDisconnect(sqlite)

# dm_rows_update()

    Code
      dm_filter_rearranged <- dm_for_filter() |> dm_select(tf_2, d, everything()) |>
        dm_select(tf_4, i, everything()) |> dm_select(tf_5, l, m, everything())
      suppressMessages(dm_copy <- copy_dm_to(my_test_src(), dm_filter_rearranged))
      dm_update_local <- dm(tf_1 = tibble(a = 2L, b = "q"), tf_2 = tibble(c = c(
        "worm"), d = 10L, ), tf_4 = tibble(h = "e", i = "sieben", ), tf_5 = tibble(k = 3L,
        m = "tree", ), )
      dm_update_copy <- suppressMessages(copy_dm_to(my_test_src(), dm_update_local))
      dm_copy |> pull_tbl(tf_2) |> arrange_all()
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
      dm_copy |> dm_rows_update(dm_update_copy) |> pull_tbl(tf_2) |> arrange_all()
    Message <simpleMessage>
      Not persisting, use `in_place = FALSE` to turn off this message.
    Output
            d c        e        e1
        <int> <chr>    <chr> <int>
      1     2 elephant D         4
      2     3 lion     E         5
      3     4 seal     F         6
      4     6 dog      E         5
      5     7 cat      F         6
      6    10 worm     G         7
    Code
      dm_copy |> pull_tbl(tf_2) |> arrange_all()
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
      dm_copy |> dm_rows_update(dm_update_copy, in_place = FALSE) |> pull_tbl(tf_2) |>
        arrange_all()
    Output
            d c        e        e1
        <int> <chr>    <chr> <int>
      1     2 elephant D         4
      2     3 lion     E         5
      3     4 seal     F         6
      4     6 dog      E         5
      5     7 cat      F         6
      6    10 worm     G         7
    Code
      dm_copy |> dm_get_tables() |> map(arrange_all)
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
        l     m              k
        <chr> <chr>      <int>
      1 b     house          1
      2 c     tree           2
      3 d     streetlamp     3
      4 e     streetlamp     4
      
      $tf_6
        n          o    
        <chr>      <chr>
      1 garden     i    
      2 hill       g    
      3 house      e    
      4 streetlamp h    
      5 tree       f    
      
    Code
      dm_copy |> dm_rows_update(dm_update_copy, in_place = TRUE)
      dm_copy |> dm_get_tables() |> map(arrange_all)
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
      4     6 dog      E         5
      5     7 cat      F         6
      6    10 worm     G         7
      
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
        l     m              k
        <chr> <chr>      <int>
      1 b     house          1
      2 c     tree           2
      3 d     tree           3
      4 e     streetlamp     4
      
      $tf_6
        n          o    
        <chr>      <chr>
      1 garden     i    
      2 hill       g    
      3 house      e    
      4 streetlamp h    
      5 tree       f    
      

# dm_rows_truncate()

    Code
      suppressMessages(dm_copy <- copy_dm_to(my_test_src(), dm_for_filter()))
      dm_truncate_local <- dm(tf_2 = tibble(c = c("worm"), d = 10L, ), tf_5 = tibble(
        k = 3L, m = "tree", ), )
      dm_truncate_copy <- suppressMessages(copy_dm_to(my_test_src(),
      dm_truncate_local))
      dm_copy |> pull_tbl(tf_2) |> arrange_all()
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
      dm_copy |> dm_rows_truncate(dm_truncate_copy) |> pull_tbl(tf_2) |>
        arrange_all()
    Message <simpleMessage>
      Not persisting, use `in_place = FALSE` to turn off this message.
    Output
      # ... with 4 variables: c <chr>, d <int>, e <chr>, e1 <int>
    Code
      dm_copy |> pull_tbl(tf_2) |> arrange_all()
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
      dm_copy |> dm_rows_truncate(dm_truncate_copy, in_place = FALSE) |> pull_tbl(
        tf_2) |> arrange_all()
    Output
      # ... with 4 variables: c <chr>, d <int>, e <chr>, e1 <int>
    Code
      dm_copy |> dm_get_tables() |> map(arrange_all)
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
            k l     m         
        <int> <chr> <chr>     
      1     1 b     house     
      2     2 c     tree      
      3     3 d     streetlamp
      4     4 e     streetlamp
      
      $tf_6
        n          o    
        <chr>      <chr>
      1 garden     i    
      2 hill       g    
      3 house      e    
      4 streetlamp h    
      5 tree       f    
      
    Code
      dm_copy |> dm_rows_truncate(dm_truncate_copy, in_place = TRUE)
      dm_copy |> dm_get_tables() |> map(arrange_all)
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
      # ... with 3 variables: k <int>, l <chr>, m <chr>
      
      $tf_6
        n          o    
        <chr>      <chr>
      1 garden     i    
      2 hill       g    
      3 house      e    
      4 streetlamp h    
      5 tree       f    
      

