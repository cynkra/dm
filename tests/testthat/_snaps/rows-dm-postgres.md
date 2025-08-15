# dumma

    Code
      # dummy

# dm_rows_insert()

    Code
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
      DBI::dbDisconnect(sqlite)

