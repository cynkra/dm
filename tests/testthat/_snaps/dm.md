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

# output for compound tables

    Code
      copy_to(nyc_comp(), mtcars, "car_table")
    Error <Rcpp::exception>
      no such column: (origin, time_hour)
    Code
      dm_add_tbl(nyc_comp(), car_table)
    Warning <simpleWarning>
      restarting interrupted promise evaluation
    Error <Rcpp::exception>
      no such column: (origin, time_hour)
    Code
      nyc_comp() %>% collect()
    Warning <simpleWarning>
      restarting interrupted promise evaluation
    Error <Rcpp::exception>
      no such column: (origin, time_hour)
    Code
      nyc_comp() %>% dm_filter(flights, day == 10) %>% compute() %>% collect() %>%
        dm_get_def()
    Warning <simpleWarning>
      restarting interrupted promise evaluation
    Error <Rcpp::exception>
      no such column: (origin, time_hour)
    Code
      nyc_comp() %>% dm_zoom_to(weather) %>% mutate(origin_new = paste0(origin,
        " airport")) %>% compute() %>% dm_update_zoomed() %>% collect() %>%
        dm_get_def()
    Warning <simpleWarning>
      restarting interrupted promise evaluation
    Error <Rcpp::exception>
      no such column: (origin, time_hour)
    Code
      nyc_comp() %>% dm_zoom_to(weather) %>% collect()
    Warning <simpleWarning>
      restarting interrupted promise evaluation
    Error <Rcpp::exception>
      no such column: (origin, time_hour)
    Code
      pull_tbl(nyc_comp(), weather)
    Warning <simpleWarning>
      restarting interrupted promise evaluation
    Error <Rcpp::exception>
      no such column: (origin, time_hour)
    Code
      dm_zoom_to(nyc_comp(), weather) %>% pull_tbl()
    Warning <simpleWarning>
      restarting interrupted promise evaluation
    Error <Rcpp::exception>
      no such column: (origin, time_hour)

