# Add info about a dm's tables

When creating a diagram from a `dm` using
[`dm_draw()`](https://dm.cynkra.com/dev/reference/dm_draw.md) the table
descriptions set with `dm_set_table_description()` will be displayed.

## Usage

``` r
dm_set_table_description(dm, ...)

dm_get_table_description(dm, table = NULL, ...)

dm_reset_table_description(dm, table = NULL, ...)
```

## Arguments

- dm:

  A [`dm`](https://dm.cynkra.com/dev/reference/dm.md) object.

- ...:

  For `dm_set_table_description()`: Descriptions for tables to set in
  the form `description = table`. `tidyselect` is supported, see
  [`dplyr::select()`](https://dplyr.tidyverse.org/reference/select.html)
  for details on the semantics.

  For `dm_get_table_description()` and `dm_reset_table_description()`:
  These dots are for future extensions and must be empty.

- table:

  One or more table names, unquoted, for which to

  1.  get information about the current description(s) with
      `dm_get_table_description()`.

  2.  remove descriptions with `dm_reset_table_description()`.

  In both cases the default applies to all tables in the `dm`.

## Value

For `dm_set_table_description()`: A `dm` object containing descriptions
for specified tables.

For `dm_get_table_description`: A named vector of tables, with the
descriptions in the names.

For `dm_reset_table_description()`: A `dm` object without descriptions
for specified tables.

## Details

Multi-line descriptions can be achieved using the newline symbol `\n`.
Descriptions are set with `dm_set_table_description()`. The currently
set descriptions can be checked using `dm_get_table_description()`.
Descriptions can be removed using `dm_reset_table_description()`.

## Examples

``` r
desc_flights <- rlang::set_names(
  "flights",
  paste(
    "On-time data for all flights",
    "that departed NYC (i.e. JFK, LGA or EWR) in 2013.",
    sep = "\n"
  )
)
nyc_desc <- dm_nycflights13() %>%
  dm_set_table_description(
    !!desc_flights,
    "Weather at the airport of\norigin at time of departure" = weather
  )
nyc_desc %>%
  dm_draw()
%0


airlines
airlinescarrierairports
airportsfaaflights
flightsOn-time data for all flightsthat departed NYC (i.e. JFK, LGA or EWR) in 2013.carriertailnumoriginorigin, time_hourflights:carrier->airlines:carrier
flights:origin->airports:faa
planes
planestailnumflights:tailnum->planes:tailnum
weather
weatherWeather at the airport oforigin at time of departureorigin, time_hourflights:origin, time_hour->weather:origin, time_hour

dm_get_table_description(nyc_desc)
#> On-time data for all flights\nthat departed NYC (i.e. JFK, LGA or EWR) in 2013. 
#>                                                                       "flights" 
#>                          Weather at the airport of\norigin at time of departure 
#>                                                                       "weather" 
dm_reset_table_description(nyc_desc, flights) %>%
  dm_draw(font_size = c(header = 18L, table_description = 9L, column = 15L))
#> Warning: The `font_size` argument of `dm_draw()` is deprecated as of dm 1.1.0.
#> ℹ Use `backend_opts = list(font_size = ...)` instead.
%0


airlines
airlinescarrierairports
airportsfaaflights
flightscarriertailnumoriginorigin, time_hourflights:carrier->airlines:carrier
flights:origin->airports:faa
planes
planestailnumflights:tailnum->planes:tailnum
weather
weatherWeather at the airport oforigin at time of departureorigin, time_hourflights:origin, time_hour->weather:origin, time_hour

pull_tbl(nyc_desc, flights) %>%
  labelled::label_attribute()
#> [1] "On-time data for all flights\nthat departed NYC (i.e. JFK, LGA or EWR) in 2013."
```
