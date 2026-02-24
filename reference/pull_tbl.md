# Retrieve a table

This generic has methods for both `dm` classes:

1.  With `pull_tbl.dm()` you can chose which table of the `dm` you want
    to retrieve.

2.  With `pull_tbl.dm_zoomed()` you will retrieve the zoomed table in
    the current state.

## Usage

``` r
pull_tbl(dm, table, ..., keyed = FALSE)
```

## Arguments

- dm:

  A `dm` object.

- table:

  One unquoted table name for `pull_tbl.dm()`, ignored for
  `pull_tbl.dm_zoomed()`.

- ...:

  These dots are for future extensions and must be empty.

- keyed:

  **\[experimental\]** Set to `TRUE` to return objects of the internal
  class `"dm_keyed_tbl"` that will contain information on primary and
  foreign keys in the individual table objects. This allows using dplyr
  workflows on those tables and later reconstruct them into a `dm`
  object. See
  [`dm_deconstruct()`](https://dm.cynkra.com/reference/dm_deconstruct.md)
  for a function that generates corresponding code for an existing dm
  object, and
  [`vignette("tech-dm-keyed")`](https://dm.cynkra.com/articles/tech-dm-keyed.md)
  for details.

## Value

The requested table.

## See also

[`dm_deconstruct()`](https://dm.cynkra.com/reference/dm_deconstruct.md)
to generate code of the form `pull_tbl(..., keyed = TRUE)` from an
existing `dm` object.

## Examples

``` r
# For an unzoomed dm you need to specify the table to pull:
dm_nycflights13() %>%
  pull_tbl(airports)
#> # A tibble: 86 × 8
#>    faa   name                                 lat    lon   alt    tz dst   tzone
#>    <chr> <chr>                              <dbl>  <dbl> <dbl> <dbl> <chr> <chr>
#>  1 ALB   Albany Intl                         42.7  -73.8   285    -5 A     Amer…
#>  2 ATL   Hartsfield Jackson Atlanta Intl     33.6  -84.4  1026    -5 A     Amer…
#>  3 AUS   Austin Bergstrom Intl               30.2  -97.7   542    -6 A     Amer…
#>  4 BDL   Bradley Intl                        41.9  -72.7   173    -5 A     Amer…
#>  5 BHM   Birmingham Intl                     33.6  -86.8   644    -6 A     Amer…
#>  6 BNA   Nashville Intl                      36.1  -86.7   599    -6 A     Amer…
#>  7 BOS   General Edward Lawrence Logan Intl  42.4  -71.0    19    -5 A     Amer…
#>  8 BTV   Burlington Intl                     44.5  -73.2   335    -5 A     Amer…
#>  9 BUF   Buffalo Niagara Intl                42.9  -78.7   724    -5 A     Amer…
#> 10 BUR   Bob Hope                            34.2 -118.    778    -8 A     Amer…
#> # ℹ 76 more rows

# If zoomed, pulling detaches the zoomed table from the dm:
dm_nycflights13() %>%
  dm_zoom_to(airports) %>%
  pull_tbl()
#> # A tibble: 86 × 8
#>    faa   name                                 lat    lon   alt    tz dst   tzone
#>    <chr> <chr>                              <dbl>  <dbl> <dbl> <dbl> <chr> <chr>
#>  1 ALB   Albany Intl                         42.7  -73.8   285    -5 A     Amer…
#>  2 ATL   Hartsfield Jackson Atlanta Intl     33.6  -84.4  1026    -5 A     Amer…
#>  3 AUS   Austin Bergstrom Intl               30.2  -97.7   542    -6 A     Amer…
#>  4 BDL   Bradley Intl                        41.9  -72.7   173    -5 A     Amer…
#>  5 BHM   Birmingham Intl                     33.6  -86.8   644    -6 A     Amer…
#>  6 BNA   Nashville Intl                      36.1  -86.7   599    -6 A     Amer…
#>  7 BOS   General Edward Lawrence Logan Intl  42.4  -71.0    19    -5 A     Amer…
#>  8 BTV   Burlington Intl                     44.5  -73.2   335    -5 A     Amer…
#>  9 BUF   Buffalo Niagara Intl                42.9  -78.7   724    -5 A     Amer…
#> 10 BUR   Bob Hope                            34.2 -118.    778    -8 A     Amer…
#> # ℹ 76 more rows
```
