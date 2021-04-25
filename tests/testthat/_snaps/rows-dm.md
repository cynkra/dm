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
            16     1458        0     3322        0 
    Code
      flights_jan <- dm_nycflights13() %>% dm_select_tbl(flights, weather) %>%
        dm_zoom_to(flights) %>% filter(month == 1) %>% dm_update_zoomed() %>%
        dm_zoom_to(weather) %>% filter(month == 1) %>% dm_update_zoomed()
      print(dm_nrow(flights_jan))
    Output
      flights weather 
          932      72 
    Code
      flights_jan_sqlite <- copy_dm_to(sqlite, flights_jan)
      out <- dm_rows_insert(flights_sqlite, flights_jan_sqlite)
    Message <simpleMessage>
      Not persisting, use `in_place = FALSE` to turn off this message.
    Code
      print(dm_nrow(flights_sqlite))
    Output
      airlines airports  flights   planes  weather 
            16     1458        0     3322        0 
    Code
      dm_rows_insert(flights_sqlite, flights_jan_sqlite, in_place = TRUE)
      print(dm_nrow(flights_sqlite))
    Output
      airlines airports  flights   planes  weather 
            16     1458      932     3322       72 
    Code
      flights_feb <- dm_nycflights13() %>% dm_select_tbl(flights, weather) %>%
        dm_zoom_to(flights) %>% filter(month == 2) %>% dm_update_zoomed() %>%
        dm_zoom_to(weather) %>% filter(month == 2) %>% dm_update_zoomed()
      flights_feb_sqlite <- copy_dm_to(sqlite, flights_feb)
      flights_new <- dm_rows_insert(flights_sqlite, flights_feb_sqlite, in_place = FALSE)
      print(dm_nrow(flights_new))
    Output
      airlines airports  flights   planes  weather 
            16     1458     1761     3322      144 
    Code
      print(dm_nrow(flights_sqlite))
    Output
      airlines airports  flights   planes  weather 
            16     1458      932     3322       72 
    Code
      flights_new %>% dm_examine_constraints()
    Message <cliMessage>
      ! Unsatisfied constraints:
    Output
      * Table `flights`: foreign key tailnum into table `planes`: 166 values (14.9%) of `flights$tailnum` not in `planes$tailnum`: N0EGMQ, N318AT, N395AA, N3ACAA, N3AEMQ, ...
    Code
      dm_rows_insert(flights_sqlite, flights_feb_sqlite, in_place = TRUE)
      print(dm_nrow(flights_sqlite))
    Output
      airlines airports  flights   planes  weather 
            16     1458     1761     3322      144 

# dm_rows_update()

    Code
      dm_filter_rearranged <- dm_for_filter() %>% dm_select(tf_2, d, everything()) %>%
        dm_select(tf_4, i, everything()) %>% dm_select(tf_5, l, m, everything())
      suppressMessages(dm_copy <- copy_dm_to(my_test_src(), dm_filter_rearranged))
      dm_update_local <- dm(tf_1 = tibble(a = 2L, b = "q"), tf_2 = tibble(c = c(
        "worm"), d = 10L, ), tf_4 = tibble(h = "e", i = "sieben", ), tf_5 = tibble(k = 3L,
        m = "tree", ), )
      dm_update_copy <- suppressMessages(copy_dm_to(my_test_src(), dm_update_local))
      dm_copy %>% pull_tbl(tf_2) %>% arrange_all()
    Output
            d c        e    
        <int> <chr>    <chr>
      1     2 elephant D    
      2     3 lion     E    
      3     4 seal     F    
      4     5 worm     G    
      5     6 dog      E    
      6     7 cat      F    
    Code
      dm_copy %>% dm_rows_update(dm_update_copy) %>% pull_tbl(tf_2) %>% arrange_all()
    Message <simpleMessage>
      Not persisting, use `in_place = FALSE` to turn off this message.
    Output
            d c        e    
        <int> <chr>    <chr>
      1     2 elephant D    
      2     3 lion     E    
      3     4 seal     F    
      4     6 dog      E    
      5     7 cat      F    
      6    10 worm     G    
    Code
      dm_copy %>% pull_tbl(tf_2) %>% arrange_all()
    Output
            d c        e    
        <int> <chr>    <chr>
      1     2 elephant D    
      2     3 lion     E    
      3     4 seal     F    
      4     5 worm     G    
      5     6 dog      E    
      6     7 cat      F    
    Code
      dm_copy %>% dm_rows_update(dm_update_copy, in_place = FALSE) %>% pull_tbl(tf_2) %>%
        arrange_all()
    Output
            d c        e    
        <int> <chr>    <chr>
      1     2 elephant D    
      2     3 lion     E    
      3     4 seal     F    
      4     6 dog      E    
      5     7 cat      F    
      6    10 worm     G    
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
            d c        e    
        <int> <chr>    <chr>
      1     2 elephant D    
      2     3 lion     E    
      3     4 seal     F    
      4     5 worm     G    
      5     6 dog      E    
      6     7 cat      F    
      
      $tf_3
         f     g    
         <chr> <chr>
       1 B     one  
       2 C     two  
       3 D     three
       4 E     four 
       5 F     five 
       6 G     six  
       7 H     seven
       8 I     eight
       9 J     nine 
      10 K     ten  
      
      $tf_4
        i     h     j    
        <chr> <chr> <chr>
      1 five  c     E    
      2 four  b     D    
      3 seven e     F    
      4 six   d     F    
      5 three a     C    
      
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
            d c        e    
        <int> <chr>    <chr>
      1     2 elephant D    
      2     3 lion     E    
      3     4 seal     F    
      4     6 dog      E    
      5     7 cat      F    
      6    10 worm     G    
      
      $tf_3
         f     g    
         <chr> <chr>
       1 B     one  
       2 C     two  
       3 D     three
       4 E     four 
       5 F     five 
       6 G     six  
       7 H     seven
       8 I     eight
       9 J     nine 
      10 K     ten  
      
      $tf_4
        i      h     j    
        <chr>  <chr> <chr>
      1 five   c     E    
      2 four   b     D    
      3 sieben e     F    
      4 six    d     F    
      5 three  a     C    
      
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
      dm_copy %>% pull_tbl(tf_2) %>% arrange_all()
    Output
        c            d e    
        <chr>    <int> <chr>
      1 cat          7 F    
      2 dog          6 E    
      3 elephant     2 D    
      4 lion         3 E    
      5 seal         4 F    
      6 worm         5 G    
    Code
      dm_copy %>% dm_rows_truncate(dm_truncate_copy) %>% pull_tbl(tf_2) %>%
        arrange_all()
    Message <simpleMessage>
      Not persisting, use `in_place = FALSE` to turn off this message.
    Output
      # ... with 3 variables: c <chr>, d <int>, e <chr>
    Code
      dm_copy %>% pull_tbl(tf_2) %>% arrange_all()
    Output
        c            d e    
        <chr>    <int> <chr>
      1 cat          7 F    
      2 dog          6 E    
      3 elephant     2 D    
      4 lion         3 E    
      5 seal         4 F    
      6 worm         5 G    
    Code
      dm_copy %>% dm_rows_truncate(dm_truncate_copy, in_place = FALSE) %>% pull_tbl(
        tf_2) %>% arrange_all()
    Output
      # ... with 3 variables: c <chr>, d <int>, e <chr>
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
        c            d e    
        <chr>    <int> <chr>
      1 cat          7 F    
      2 dog          6 E    
      3 elephant     2 D    
      4 lion         3 E    
      5 seal         4 F    
      6 worm         5 G    
      
      $tf_3
         f     g    
         <chr> <chr>
       1 B     one  
       2 C     two  
       3 D     three
       4 E     four 
       5 F     five 
       6 G     six  
       7 H     seven
       8 I     eight
       9 J     nine 
      10 K     ten  
      
      $tf_4
        h     i     j    
        <chr> <chr> <chr>
      1 a     three C    
      2 b     four  D    
      3 c     five  E    
      4 d     six   F    
      5 e     seven F    
      
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
      dm_copy %>% dm_rows_truncate(dm_truncate_copy, in_place = TRUE)
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
      # ... with 3 variables: c <chr>, d <int>, e <chr>
      
      $tf_3
         f     g    
         <chr> <chr>
       1 B     one  
       2 C     two  
       3 D     three
       4 E     four 
       5 F     five 
       6 G     six  
       7 H     seven
       8 I     eight
       9 J     nine 
      10 K     ten  
      
      $tf_4
        h     i     j    
        <chr> <chr> <chr>
      1 a     three C    
      2 b     four  D    
      3 c     five  E    
      4 d     six   F    
      5 e     seven F    
      
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
      

