# Migration guide: 'cdm' -\> 'dm'

This vignette describes which changes are necessary to adapt your code
when updating the {dm} package version from a version `0.0.5` or lower
to `0.0.6` or higher.

## Changes required when updating from version `0.0.5` to `0.0.6`

### Replace `cdm` with `dm`

During this update the prevalent prefix `cdm` was discarded in favor of
`dm`. The old prefix would still do its job, but a warning message would
be issued each time a function beginning with `cdm` was being used,
informing that the function is soft-deprecated and suggesting the use of
its newer version.

If you have a script which is based on an older {dm} version, it should
still work with the newer version, albeit complaining each time an
outdated function is being used. This can be repaired by:

1.  either going through the script step by step, testing the output of
    each line of code and use the new function names provided in the
    generated warnings to update the function calls.
2.  or just by replacing all occurrences of `cdm` by `dm` in this
    script. This can e.g. be done in RStudio using “Find” or in the
    terminal using `sed -e 's/cdm/dm/g' path-to-file` on Windows or
    `sed -i '' -e 's/cdm/dm/g' path-to-file` on a Mac. If the script
    errors after this step, you will need to check where exactly the
    error happens and manually repair the damage.

### Be careful with methods for `dm`: `tbl`, `[[`, `$`

Furthermore, you need to pay attention if you used one of
[`tbl.dm()`](https://dm.cynkra.com/dev/reference/dplyr_src.md),
`[[.dm()`, `$.dm()`. During the same update the implementation for those
methods changed as well, and here you don’t get the convenient warning
messages. The change was, that before the update, the mentioned methods
would return the table after “filtering” it to just contain the rows
with values that relate via foreign key relations to other tables that
were filtered earlier. After the update just the table as is would be
returned. If you want to retain the former behavior, you need to replace
each of the methods with the function
[`dm_apply_filters_to_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md),
which was made available with the update.

The methods are of course not to be avoided in general, if no filters
are set anyway the result will not change after the update.

Here a short example for the different cases:

Formerly you would access the “filtered” tables using the following
syntax:

``` r
library(dm)
flights_dm <- dm_nycflights13()
tbl(flights_dm, "airports")
#> Warning: `tbl.dm()` was deprecated in dm 0.2.0.
#> ℹ Use `dm[[table_name]]` instead to access a specific table.
#> This warning is displayed once per session.
#> Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
#> generated.
```

``` fansi
#> # A tibble: 86 × 8
#>    faa   name                            lat    lon   alt    tz dst   tzone
#>    <chr> <chr>                         <dbl>  <dbl> <dbl> <dbl> <chr> <chr>
#>  1 ALB   Albany Intl                    42.7  -73.8   285    -5 A     Amer…
#>  2 ATL   Hartsfield Jackson Atlanta I…  33.6  -84.4  1026    -5 A     Amer…
#>  3 AUS   Austin Bergstrom Intl          30.2  -97.7   542    -6 A     Amer…
#>  4 BDL   Bradley Intl                   41.9  -72.7   173    -5 A     Amer…
#>  5 BHM   Birmingham Intl                33.6  -86.8   644    -6 A     Amer…
#>  6 BNA   Nashville Intl                 36.1  -86.7   599    -6 A     Amer…
#>  7 BOS   General Edward Lawrence Loga…  42.4  -71.0    19    -5 A     Amer…
#>  8 BTV   Burlington Intl                44.5  -73.2   335    -5 A     Amer…
#>  9 BUF   Buffalo Niagara Intl           42.9  -78.7   724    -5 A     Amer…
#> 10 BUR   Bob Hope                       34.2 -118.    778    -8 A     Amer…
#> # ℹ 76 more rows
```

``` r
flights_dm$planes
```

``` fansi
#> # A tibble: 945 × 9
#>    tailnum  year type         manufacturer model engines seats speed engine
#>    <chr>   <int> <chr>        <chr>        <chr>   <int> <int> <int> <chr> 
#>  1 N10156   2004 Fixed wing … EMBRAER      EMB-…       2    55    NA Turbo…
#>  2 N104UW   1999 Fixed wing … AIRBUS INDU… A320…       2   182    NA Turbo…
#>  3 N10575   2002 Fixed wing … EMBRAER      EMB-…       2    55    NA Turbo…
#>  4 N105UW   1999 Fixed wing … AIRBUS INDU… A320…       2   182    NA Turbo…
#>  5 N110UW   1999 Fixed wing … AIRBUS INDU… A320…       2   182    NA Turbo…
#>  6 N11106   2002 Fixed wing … EMBRAER      EMB-…       2    55    NA Turbo…
#>  7 N11107   2002 Fixed wing … EMBRAER      EMB-…       2    55    NA Turbo…
#>  8 N11109   2002 Fixed wing … EMBRAER      EMB-…       2    55    NA Turbo…
#>  9 N11121   2003 Fixed wing … EMBRAER      EMB-…       2    55    NA Turbo…
#> 10 N11137   2003 Fixed wing … EMBRAER      EMB-…       2    55    NA Turbo…
#> # ℹ 935 more rows
```

``` r
flights_dm[["weather"]]
```

``` fansi
#> # A tibble: 144 × 15
#>    origin  year month   day  hour  temp  dewp humid wind_dir wind_speed
#>    <chr>  <int> <int> <int> <int> <dbl> <dbl> <dbl>    <dbl>      <dbl>
#>  1 EWR     2013     1    10     0  41    32    70.1      230       8.06
#>  2 EWR     2013     1    10     1  39.0  30.0  69.9      210       9.21
#>  3 EWR     2013     1    10     2  39.0  28.9  66.8      230       6.90
#>  4 EWR     2013     1    10     3  39.9  27.0  59.5      270       5.75
#>  5 EWR     2013     1    10     4  41    26.1  55.0      320       6.90
#>  6 EWR     2013     1    10     5  41    26.1  55.0      300      12.7 
#>  7 EWR     2013     1    10     6  39.9  25.0  54.8      280       6.90
#>  8 EWR     2013     1    10     7  41    25.0  52.6      330       6.90
#>  9 EWR     2013     1    10     8  43.0  25.0  48.7      330       8.06
#> 10 EWR     2013     1    10     9  45.0  23    41.6      320      17.3 
#> # ℹ 134 more rows
#> # ℹ 5 more variables: wind_gust <dbl>, precip <dbl>, pressure <dbl>,
#> #   visib <dbl>, time_hour <dttm>
```

After the update the same result is achieved by this type of function
call:

``` r
dm_apply_filters_to_tbl(flights_dm, airlines)
#> Warning: `dm_apply_filters_to_tbl()` was deprecated in dm 1.0.0.
#> ℹ Access tables directly after `dm_filter()`.
#> This warning is displayed once per session.
#> Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
#> generated.
```

``` fansi
#> # A tibble: 15 × 2
#>    carrier name                       
#>    <chr>   <chr>                      
#>  1 9E      Endeavor Air Inc.          
#>  2 AA      American Airlines Inc.     
#>  3 AS      Alaska Airlines Inc.       
#>  4 B6      JetBlue Airways            
#>  5 DL      Delta Air Lines Inc.       
#>  6 EV      ExpressJet Airlines Inc.   
#>  7 F9      Frontier Airlines Inc.     
#>  8 FL      AirTran Airways Corporation
#>  9 HA      Hawaiian Airlines Inc.     
#> 10 MQ      Envoy Air                  
#> 11 UA      United Air Lines Inc.      
#> 12 US      US Airways Inc.            
#> 13 VX      Virgin America             
#> 14 WN      Southwest Airlines Co.     
#> 15 YV      Mesa Airlines Inc.
```
