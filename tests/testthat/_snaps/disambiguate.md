# dm_disambiguate_cols() output for compound keys

    Code
      dm_disambiguate_cols(nyc_comp())
    Message <simpleMessage>
      Renamed columns:
      * name -> airlines.name, airports.name
      * year -> flights.year, planes.year, weather.year
      * month -> flights.month, weather.month
      * day -> flights.day, weather.day
      * hour -> flights.hour, weather.hour
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
      Columns: 53
      Primary keys: 4
      Foreign keys: 4

