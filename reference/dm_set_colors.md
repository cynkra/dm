# Color in database diagrams

`dm_set_colors()` allows to define the colors that will be used to
display the tables of the data model with
[`dm_draw()`](https://dm.cynkra.com/reference/dm_draw.md). The colors
can either be specified with hex color codes or using the names of the
built-in R colors. An overview of the colors corresponding to the
standard color names can be found at the bottom of
<https://rpubs.com/krlmlr/colors>.

`dm_get_colors()` returns the colors defined for a data model.

`dm_get_available_colors()` returns an overview of the names of the
available colors These are the standard colors also returned by
[`grDevices::colors()`](https://rdrr.io/r/grDevices/colors.html) plus a
default table color with the name "default".

## Usage

``` r
dm_set_colors(dm, ...)

dm_get_colors(dm)

dm_get_available_colors()
```

## Arguments

- dm:

  A [`dm`](https://dm.cynkra.com/reference/dm.md) object.

- ...:

  Colors to set in the form `color = table`. Allowed colors are all hex
  coded colors (quoted) and the color names from
  `dm_get_available_colors()`. `tidyselect` is supported, see
  [`dplyr::select()`](https://dplyr.tidyverse.org/reference/select.html)
  for details on the semantics.

## Value

For `dm_set_colors()`: the updated data model.

For `dm_get_colors()`, a named character vector of table names with the
colors in the names. This allows calling
`dm_set_colors(!!!dm_get_colors(...))`. Use
[`tibble::enframe()`](https://tibble.tidyverse.org/reference/enframe.html)
to convert this to a tibble.

For `dm_get_available_colors()`, a vector with the available colors.

## Examples

``` r
dm_nycflights13(color = FALSE) %>%
  dm_set_colors(
    darkblue = starts_with("air"),
    "#5986C4" = flights
  ) %>%
  dm_draw()
%0


airlines
airlinescarrierairports
airportsfaaflights
flightscarriertailnumoriginorigin, time_hourflights:carrier->airlines:carrier
flights:origin->airports:faa
planes
planestailnumflights:tailnum->planes:tailnum
weather
weatherorigin, time_hourflights:origin, time_hour->weather:origin, time_hour

# Splicing is supported:
nyc_cols <-
  dm_nycflights13() %>%
  dm_get_colors()
nyc_cols
#>  #ED7D31FF  #ED7D31FF  #5B9BD5FF  #ED7D31FF  #70AD47FF 
#> "airlines" "airports"  "flights"   "planes"  "weather" 

dm_nycflights13(color = FALSE) %>%
  dm_set_colors(!!!nyc_cols) %>%
  dm_draw()
%0


airlines
airlinescarrierairports
airportsfaaflights
flightscarriertailnumoriginorigin, time_hourflights:carrier->airlines:carrier
flights:origin->airports:faa
planes
planestailnumflights:tailnum->planes:tailnum
weather
weatherorigin, time_hourflights:origin, time_hour->weather:origin, time_hour
```
