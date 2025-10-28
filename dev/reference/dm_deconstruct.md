# Create code to deconstruct a dm object

**\[experimental\]**

Emits code that assigns each table in the dm to a variable, using
[`pull_tbl()`](https://dm.cynkra.com/dev/reference/pull_tbl.md) with
`keyed = TRUE`. These tables retain information about primary and
foreign keys, even after data transformations, and can be converted back
to a dm object with [`dm()`](https://dm.cynkra.com/dev/reference/dm.md).

## Usage

``` r
dm_deconstruct(dm, dm_name = NULL)
```

## Arguments

- dm:

  A `dm` object.

- dm_name:

  The code to use to access the dm object, by default the expression
  passed to this function.

## Value

This function is called for its side effect of printing generated code.

## Examples

``` r
dm <- dm_nycflights13()
dm_deconstruct(dm)
#> airlines <- pull_tbl(dm, "airlines", keyed = TRUE)
#> airports <- pull_tbl(dm, "airports", keyed = TRUE)
#> flights <- pull_tbl(dm, "flights", keyed = TRUE)
#> planes <- pull_tbl(dm, "planes", keyed = TRUE)
#> weather <- pull_tbl(dm, "weather", keyed = TRUE)
airlines <- pull_tbl(dm, "airlines", keyed = TRUE)
airports <- pull_tbl(dm, "airports", keyed = TRUE)
flights <- pull_tbl(dm, "flights", keyed = TRUE)
planes <- pull_tbl(dm, "planes", keyed = TRUE)
weather <- pull_tbl(dm, "weather", keyed = TRUE)
by_origin <-
  flights %>%
  group_by(origin) %>%
  summarize(mean_arr_delay = mean(arr_delay, na.rm = TRUE)) %>%
  ungroup()

by_origin
#> # A tibble: 3 × 2
#> # Keys:     `origin` | 0 | 0
#>   origin mean_arr_delay
#>   <chr>           <dbl>
#> 1 EWR             3.43 
#> 2 JFK            -4.36 
#> 3 LGA             0.523
dm(airlines, airports, flights, planes, weather, by_origin) %>%
  dm_draw()
%0


airlines
airlinescarrierairports
airportsfaaby_origin
by_originoriginby_origin:origin->airports:faa
flights
flightscarriertailnumoriginorigin, time_hourflights:carrier->airlines:carrier
flights:origin->airports:faa
planes
planestailnumflights:tailnum->planes:tailnum
weather
weatherorigin, time_hourflights:origin, time_hour->weather:origin, time_hour
```
