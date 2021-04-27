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
      * Table `flights`: foreign key tailnum into table `planes`: values of `flights$tailnum` not in `planes$tailnum`: N725MQ (6), N537MQ (5), N722MQ (5), N730MQ (5), N736MQ (5), ...
    Code
      dm_rows_insert(flights_sqlite, flights_feb_sqlite, in_place = TRUE)
      print(dm_nrow(flights_sqlite))
    Output
      airlines airports  flights   planes  weather 
            16     1458     1761     3322      144 

