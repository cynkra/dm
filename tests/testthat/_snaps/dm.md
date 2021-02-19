# output

    Code
      print(dm())
    Output
      dm()
    Code
      nyc_flights_dm <- dm_nycflights13(cycle = TRUE)
      nyc_flights_dm
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 53
      Primary keys: 3
      Foreign keys: 4
    Code
      nyc_flights_dm %>% format()
    Output
      dm: 5 tables, 53 columns, 3 primary keys, 4 foreign keys
    Code
      nyc_flights_dm %>% dm_filter(flights, origin == "EWR")
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 53
      Primary keys: 3
      Foreign keys: 4
      -- Filters ---------------------------------------------------------------------
      flights: origin == "EWR"

