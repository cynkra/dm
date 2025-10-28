# Create R code for a dm object

`dm_paste()` takes an existing `dm` and emits the code necessary for its
creation.

## Usage

``` r
dm_paste(dm, select = NULL, ..., tab_width = 2, options = NULL, path = NULL)
```

## Arguments

- dm:

  A `dm` object.

- select:

  Deprecated, see `"select"` in the `options` argument.

- ...:

  Must be empty.

- tab_width:

  Indentation width for code from the second line onwards

- options:

  Formatting options. A character vector containing some of:

  - `"tables"`:
    [`tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
    calls for empty table definitions derived from
    [`dm_ptype()`](https://dm.cynkra.com/dev/reference/dm_ptype.md),
    overrides `"select"`.

  - `"select"`:
    [`dm_select()`](https://dm.cynkra.com/dev/reference/dm_select.md)
    statements for columns that are part of the dm.

  - `"keys"`:
    [`dm_add_pk()`](https://dm.cynkra.com/dev/reference/dm_add_pk.md),
    [`dm_add_fk()`](https://dm.cynkra.com/dev/reference/dm_add_fk.md)
    and
    [`dm_add_uk()`](https://dm.cynkra.com/dev/reference/dm_add_uk.md)
    statements for adding keys.

  - `"color"`:
    [`dm_set_colors()`](https://dm.cynkra.com/dev/reference/dm_set_colors.md)
    statements to set color.

  - `"all"`: All options above except `"select"`

  Default `NULL` is equivalent to `c("keys", "color")`

- path:

  Output file, if `NULL` the code is printed to the console.

## Value

Code for producing the prototype of the given `dm`.

## Details

The code emitted by the function reproduces the structure of the `dm`
object. The `options` argument controls the level of detail: keys,
colors, table definitions. Data in the tables is never included, see
[`dm_ptype()`](https://dm.cynkra.com/dev/reference/dm_ptype.md) for the
underlying logic.

## Examples

``` r
dm() %>%
  dm_paste()
#> dm::dm(
#> )

dm_nycflights13() %>%
  dm_paste()
#> dm::dm(
#>   airlines,
#>   airports,
#>   flights,
#>   planes,
#>   weather,
#> ) %>%
#>   dm::dm_add_pk(airlines, carrier) %>%
#>   dm::dm_add_pk(airports, faa) %>%
#>   dm::dm_add_pk(planes, tailnum) %>%
#>   dm::dm_add_pk(weather, c(origin, time_hour)) %>%
#>   dm::dm_add_fk(flights, carrier, airlines) %>%
#>   dm::dm_add_fk(flights, origin, airports) %>%
#>   dm::dm_add_fk(flights, tailnum, planes) %>%
#>   dm::dm_add_fk(flights, c(origin, time_hour), weather) %>%
#>   dm::dm_set_colors(`#ED7D31FF` = airlines) %>%
#>   dm::dm_set_colors(`#ED7D31FF` = airports) %>%
#>   dm::dm_set_colors(`#5B9BD5FF` = flights) %>%
#>   dm::dm_set_colors(`#ED7D31FF` = planes) %>%
#>   dm::dm_set_colors(`#70AD47FF` = weather)

dm_nycflights13() %>%
  dm_paste(options = "select")
#> dm::dm(
#>   airlines,
#>   airports,
#>   flights,
#>   planes,
#>   weather,
#> ) %>%
#>   dm::dm_select(airlines, carrier, name) %>%
#>   dm::dm_select(airports, faa, name, lat, lon, alt, tz, dst, tzone) %>%
#>   dm::dm_select(flights, year, month, day, dep_time, sched_dep_time, dep_delay, arr_time, sched_arr_time, arr_delay, carrier, flight, tailnum, origin, dest, air_time, distance, hour, minute, time_hour) %>%
#>   dm::dm_select(planes, tailnum, year, type, manufacturer, model, engines, seats, speed, engine) %>%
#>   dm::dm_select(weather, origin, year, month, day, hour, temp, dewp, humid, wind_dir, wind_speed, wind_gust, precip, pressure, visib, time_hour)
```
