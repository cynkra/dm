# Number of rows

Returns a named vector with the number of rows for each table.

## Usage

``` r
dm_nrow(dm)
```

## Arguments

- dm:

  A [`dm`](https://dm.cynkra.com/reference/dm.md) object.

## Value

A named vector with the number of rows for each table.

## Examples

``` r
dm_nycflights13() %>%
  dm_filter(airports = (faa %in% c("EWR", "LGA"))) %>%
  dm_nrow()
#> airlines airports  flights   planes  weather 
#>       13        2     1159      658       67 
```
