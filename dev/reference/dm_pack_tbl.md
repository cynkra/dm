# dm_pack_tbl()

**\[experimental\]**

`dm_pack_tbl()` converts a parent table to a packed column in its child
table. The parent table should not have parent tables itself (i.e. it
needs to be a *terminal parent table*).

## Usage

``` r
dm_pack_tbl(dm, parent_table, into = NULL)
```

## Arguments

- dm:

  A dm.

- parent_table:

  A terminal table with one child table.

- into:

  The table to pack `parent_tables` into, optional as it can be guessed
  from the foreign keys unambiguously but useful to be explicit.

## See also

[`dm_wrap_tbl()`](https://dm.cynkra.com/dev/reference/dm_wrap_tbl.md),
[`dm_unwrap_tbl()`](https://dm.cynkra.com/dev/reference/dm_unwrap_tbl.md),
[`dm_nest_tbl()`](https://dm.cynkra.com/dev/reference/dm_nest_tbl.md).

## Examples

``` r
dm_packed <-
  dm_nycflights13() %>%
  dm_pack_tbl(planes)

dm_packed
#> ── Metadata ────────────────────────────────────────────────────────────────────
#> Tables: `airlines`, `airports`, `flights`, `weather`
#> Columns: 45
#> Primary keys: 3
#> Foreign keys: 3

dm_packed$flights
#> # A tibble: 1,761 × 20
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
#> # ℹ 12 more variables: arr_delay <dbl>, carrier <chr>, flight <int>,
#> #   tailnum <chr>, origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>,
#> #   hour <dbl>, minute <dbl>, time_hour <dttm>, planes <packed[,8]>

dm_packed$flights$planes
#> # A tibble: 1,761 × 8
#>     year type                    manufacturer   model engines seats speed engine
#>    <int> <chr>                   <chr>          <chr>   <int> <int> <int> <chr> 
#>  1  2003 Fixed wing multi engine AIRBUS         A320…       2   200    NA Turbo…
#>  2  2003 Fixed wing multi engine AIRBUS         A320…       2   200    NA Turbo…
#>  3  2001 Fixed wing multi engine AIRBUS INDUST… A321…       2   199    NA Turbo…
#>  4  2000 Fixed wing multi engine BOEING         737-…       2   149    NA Turbo…
#>  5  1998 Fixed wing multi engine AIRBUS INDUST… A319…       2   179    NA Turbo…
#>  6    NA NA                      NA             NA         NA    NA    NA NA    
#>  7  2011 Fixed wing multi engine AIRBUS         A320…       2   200    NA Turbo…
#>  8  2011 Fixed wing multi engine EMBRAER        ERJ …       2    20    NA Turbo…
#>  9  2002 Fixed wing multi engine EMBRAER        EMB-…       2    55    NA Turbo…
#> 10  2000 Fixed wing multi engine AIRBUS INDUST… A319…       2   179    NA Turbo…
#> # ℹ 1,751 more rows
```
