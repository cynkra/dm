scoped_options(lifecycle_verbosity = "quiet")

if (rlang::is_installed("nycflights13")) verify_output("out/rows-dm.txt", {
  # Entire dataset with all dimension tables populated
  # with flights and weather data truncated:
  flights_init <-
    dm_nycflights13() %>%
    dm_zoom_to(flights) %>%
    filter(FALSE) %>%
    dm_update_zoomed() %>%
    dm_zoom_to(weather) %>%
    filter(FALSE) %>%
    dm_update_zoomed()

  sqlite <- dbConnect(RSQLite::SQLite())

  # Target database:
  flights_sqlite <- copy_dm_to(sqlite, flights_init, temporary = FALSE)
  print(dm_nrow(flights_sqlite))

  # First update:
  flights_jan <-
    dm_nycflights13() %>%
    dm_select_tbl(flights, weather) %>%
    dm_zoom_to(flights) %>%
    filter(month == 1) %>%
    dm_update_zoomed() %>%
    dm_zoom_to(weather) %>%
    filter(month == 1) %>%
    dm_update_zoomed()
  print(dm_nrow(flights_jan))

  # Copy to temporary tables on the target database:
  flights_jan_sqlite <- copy_dm_to(sqlite, flights_jan)

  # Dry run by default:
  out <- dm_rows_insert(flights_sqlite, flights_jan_sqlite)
  print(dm_nrow(flights_sqlite))

  # Explicitly request persistence:
  dm_rows_insert(flights_sqlite, flights_jan_sqlite, in_place = TRUE)
  print(dm_nrow(flights_sqlite))

  # Second update:
  flights_feb <-
    dm_nycflights13() %>%
    dm_select_tbl(flights, weather) %>%
    dm_zoom_to(flights) %>%
    filter(month == 2) %>%
    dm_update_zoomed() %>%
    dm_zoom_to(weather) %>%
    filter(month == 2) %>%
    dm_update_zoomed()

  # Copy to temporary tables on the target database:
  flights_feb_sqlite <- copy_dm_to(sqlite, flights_feb)

  # Explicit dry run:
  flights_new <- dm_rows_insert(
    flights_sqlite,
    flights_feb_sqlite,
    in_place = FALSE
  )
  print(dm_nrow(flights_new))
  print(dm_nrow(flights_sqlite))

  # Check for consistency before applying:
  flights_new %>%
    dm_examine_constraints()

  # Apply:
  dm_rows_insert(flights_sqlite, flights_feb_sqlite, in_place = TRUE)
  print(dm_nrow(flights_sqlite))
})
