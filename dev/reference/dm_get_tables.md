# Get tables

`dm_get_tables()` returns a named list of dplyr
[tbl](https://dplyr.tidyverse.org/reference/tbl.html) objects of a `dm`
object.

## Usage

``` r
dm_get_tables(x, ..., keyed = FALSE)
```

## Arguments

- x:

  A `dm` object.

- ...:

  These dots are for future extensions and must be empty.

- keyed:

  **\[experimental\]** Set to `TRUE` to return objects of the internal
  class `"dm_keyed_tbl"` that will contain information on primary and
  foreign keys in the individual table objects. This allows using dplyr
  workflows on those tables and later reconstruct them into a `dm`
  object. See
  [`dm_deconstruct()`](https://dm.cynkra.com/dev/reference/dm_deconstruct.md)
  for a function that generates corresponding code for an existing dm
  object, and
  [`vignette("tech-dm-keyed")`](https://dm.cynkra.com/dev/articles/tech-dm-keyed.md)
  for details.

## Value

A named list with the tables (data frames or lazy tables) constituting
the `dm`.

## See also

[`dm()`](https://dm.cynkra.com/dev/reference/dm.md) and
[`new_dm()`](https://dm.cynkra.com/dev/reference/dm.md) for constructing
a `dm` object from tables.

## Examples

``` r
dm_nycflights13() %>%
  dm_get_tables()
#> $airlines
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
#> 
#> $airports
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
#> 
#> $flights
#> # A tibble: 1,761 × 19
#>     year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
#>    <int> <int> <int>    <int>          <int>     <dbl>    <int>          <int>
#>  1  2013     1    10        3           2359         4      426            437
#>  2  2013     1    10       16           2359        17      447            444
#>  3  2013     1    10      450            500       -10      634            648
#>  4  2013     1    10      520            525        -5      813            820
#>  5  2013     1    10      530            530         0      824            829
#>  6  2013     1    10      531            540        -9      832            850
#>  7  2013     1    10      535            540        -5     1015           1017
#>  8  2013     1    10      546            600       -14      645            709
#>  9  2013     1    10      549            600       -11      652            724
#> 10  2013     1    10      550            600       -10      649            703
#> # ℹ 1,751 more rows
#> # ℹ 11 more variables: arr_delay <dbl>, carrier <chr>, flight <int>,
#> #   tailnum <chr>, origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>,
#> #   hour <dbl>, minute <dbl>, time_hour <dttm>
#> 
#> $planes
#> # A tibble: 945 × 9
#>    tailnum  year type              manufacturer model engines seats speed engine
#>    <chr>   <int> <chr>             <chr>        <chr>   <int> <int> <int> <chr> 
#>  1 N10156   2004 Fixed wing multi… EMBRAER      EMB-…       2    55    NA Turbo…
#>  2 N104UW   1999 Fixed wing multi… AIRBUS INDU… A320…       2   182    NA Turbo…
#>  3 N10575   2002 Fixed wing multi… EMBRAER      EMB-…       2    55    NA Turbo…
#>  4 N105UW   1999 Fixed wing multi… AIRBUS INDU… A320…       2   182    NA Turbo…
#>  5 N110UW   1999 Fixed wing multi… AIRBUS INDU… A320…       2   182    NA Turbo…
#>  6 N11106   2002 Fixed wing multi… EMBRAER      EMB-…       2    55    NA Turbo…
#>  7 N11107   2002 Fixed wing multi… EMBRAER      EMB-…       2    55    NA Turbo…
#>  8 N11109   2002 Fixed wing multi… EMBRAER      EMB-…       2    55    NA Turbo…
#>  9 N11121   2003 Fixed wing multi… EMBRAER      EMB-…       2    55    NA Turbo…
#> 10 N11137   2003 Fixed wing multi… EMBRAER      EMB-…       2    55    NA Turbo…
#> # ℹ 935 more rows
#> 
#> $weather
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
#> 

dm_nycflights13() %>%
  dm_get_tables(keyed = TRUE)
#> $airlines
#> # A tibble: 15 × 2
#> # Keys:     `carrier` | 1 | 0
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
#> 
#> $airports
#> # A tibble: 86 × 8
#> # Keys:     `faa` | 1 | 0
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
#> 
#> $flights
#> # A tibble: 1,761 × 19
#> # Keys:     — | 0 | 4
#>     year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
#>    <int> <int> <int>    <int>          <int>     <dbl>    <int>          <int>
#>  1  2013     1    10        3           2359         4      426            437
#>  2  2013     1    10       16           2359        17      447            444
#>  3  2013     1    10      450            500       -10      634            648
#>  4  2013     1    10      520            525        -5      813            820
#>  5  2013     1    10      530            530         0      824            829
#>  6  2013     1    10      531            540        -9      832            850
#>  7  2013     1    10      535            540        -5     1015           1017
#>  8  2013     1    10      546            600       -14      645            709
#>  9  2013     1    10      549            600       -11      652            724
#> 10  2013     1    10      550            600       -10      649            703
#> # ℹ 1,751 more rows
#> # ℹ 11 more variables: arr_delay <dbl>, carrier <chr>, flight <int>,
#> #   tailnum <chr>, origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>,
#> #   hour <dbl>, minute <dbl>, time_hour <dttm>
#> 
#> $planes
#> # A tibble: 945 × 9
#> # Keys:     `tailnum` | 1 | 0
#>    tailnum  year type              manufacturer model engines seats speed engine
#>    <chr>   <int> <chr>             <chr>        <chr>   <int> <int> <int> <chr> 
#>  1 N10156   2004 Fixed wing multi… EMBRAER      EMB-…       2    55    NA Turbo…
#>  2 N104UW   1999 Fixed wing multi… AIRBUS INDU… A320…       2   182    NA Turbo…
#>  3 N10575   2002 Fixed wing multi… EMBRAER      EMB-…       2    55    NA Turbo…
#>  4 N105UW   1999 Fixed wing multi… AIRBUS INDU… A320…       2   182    NA Turbo…
#>  5 N110UW   1999 Fixed wing multi… AIRBUS INDU… A320…       2   182    NA Turbo…
#>  6 N11106   2002 Fixed wing multi… EMBRAER      EMB-…       2    55    NA Turbo…
#>  7 N11107   2002 Fixed wing multi… EMBRAER      EMB-…       2    55    NA Turbo…
#>  8 N11109   2002 Fixed wing multi… EMBRAER      EMB-…       2    55    NA Turbo…
#>  9 N11121   2003 Fixed wing multi… EMBRAER      EMB-…       2    55    NA Turbo…
#> 10 N11137   2003 Fixed wing multi… EMBRAER      EMB-…       2    55    NA Turbo…
#> # ℹ 935 more rows
#> 
#> $weather
#> # A tibble: 144 × 15
#> # Keys:     `origin`, `time_hour` | 1 | 0
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
#> 

dm_nycflights13() %>%
  dm_get_tables(keyed = TRUE) %>%
  new_dm()
#> ── Metadata ────────────────────────────────────────────────────────────────────
#> Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#> Columns: 53
#> Primary keys: 4
#> Foreign keys: 4
```
