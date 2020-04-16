verify_output("out/persist-tbl.txt", {
  # Truncated table:
  flights_init <- nycflights13::flights[0, ]

  sqlite <- src_sqlite(":memory:", create = TRUE)

  # Target database:
  flights_sqlite <- copy_to(sqlite, flights_init, temporary = FALSE)
  print(count(flights_sqlite))

  # First update:
  flights_jan_1 <-
    nycflights13::flights %>%
    filter(month == 1, day == 1)
  print(count(flights_jan_1))

  # Copy to temporary tables on the target database:
  flights_jan_1_sqlite <- copy_to(sqlite, flights_jan_1)
  tbl_insert(flights_sqlite, flights_jan_1_sqlite)
  print(count(flights_sqlite))

  # Second update:
  flights_jan_2 <-
    nycflights13::flights %>%
    filter(month == 1, day == 2)

  # Copy to temporary tables on the target database:
  flights_jan_2_sqlite <- copy_to(sqlite, flights_jan_2)

  # Dry run:
  flights_new <- tbl_insert(
    flights_sqlite,
    flights_jan_2_sqlite,
    persist = NULL
  )
  print(count(flights_new))
  print(count(flights_sqlite))

  # Check for consistency before applying:
  flights_new %>%
    dplyr::count(year, month, day)

  # Apply:
  tbl_insert(flights_sqlite, flights_jan_2_sqlite)
  print(count(flights_sqlite))
})
