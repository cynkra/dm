# Primary key candidate

**\[experimental\]**

`enum_pk_candidates()` checks for each column of a table if the column
contains only unique values, and is thus a suitable candidate for a
primary key of the table.

`dm_enum_pk_candidates()` performs these checks for a table in a
[dm](https://dm.cynkra.com/reference/dm.md) object.

## Usage

``` r
enum_pk_candidates(table, ...)

dm_enum_pk_candidates(dm, table, ...)
```

## Arguments

- table:

  A table in the `dm`.

- ...:

  These dots are for future extensions and must be empty.

- dm:

  A `dm` object.

## Value

A tibble with the following columns:

- `columns`:

  columns of `table`,

- `candidate`:

  boolean: are these columns a candidate for a primary key,

- `why`:

  if not a candidate for a primary key column, explanation for this.

## Life cycle

These functions are marked "experimental" because we are not yet sure
about the interface, in particular if we need both `dm_enum...()` and
`enum...()` variants. Changing the interface later seems harmless
because these functions are most likely used interactively.

## See also

Other primary key functions:
[`dm_add_pk()`](https://dm.cynkra.com/reference/dm_add_pk.md),
[`dm_add_uk()`](https://dm.cynkra.com/reference/dm_add_uk.md),
[`dm_get_all_pks()`](https://dm.cynkra.com/reference/dm_get_all_pks.md),
[`dm_get_all_uks()`](https://dm.cynkra.com/reference/dm_get_all_uks.md),
[`dm_has_pk()`](https://dm.cynkra.com/reference/dm_has_pk.md),
[`dm_rm_pk()`](https://dm.cynkra.com/reference/dm_rm_pk.md),
[`dm_rm_uk()`](https://dm.cynkra.com/reference/dm_rm_uk.md)

## Examples

``` r
nycflights13::flights %>%
  enum_pk_candidates()
#> # A tibble: 19 × 3
#>    columns        candidate why                                                 
#>    <keys>         <lgl>     <chr>                                               
#>  1 year           FALSE     has duplicate values: 2013 (336776)                 
#>  2 month          FALSE     has duplicate values: 7 (29425), 8 (29327), 10 (288…
#>  3 day            FALSE     has duplicate values: 18 (11399), 11 (11359), 22 (1…
#>  4 dep_time       FALSE     has 8255 missing values, and duplicate values: 555 …
#>  5 sched_dep_time FALSE     has duplicate values: 600 (7016), 700 (4900), 630 (…
#>  6 dep_delay      FALSE     has duplicate values: -5 (24821), -4 (24619), -3 (2…
#>  7 arr_time       FALSE     has 8713 missing values, and duplicate values: 1008…
#>  8 sched_arr_time FALSE     has duplicate values: 1025 (1324), 2015 (1234), 111…
#>  9 arr_delay      FALSE     has 9430 missing values, and duplicate values: -13 …
#> 10 carrier        FALSE     has duplicate values: UA (58665), B6 (54635), EV (5…
#> 11 flight         FALSE     has duplicate values: 15 (968), 27 (898), 181 (882)…
#> 12 tailnum        FALSE     has 2512 missing values, and duplicate values: N725…
#> 13 origin         FALSE     has duplicate values: EWR (120835), JFK (111279), L…
#> 14 dest           FALSE     has duplicate values: ORD (17283), ATL (17215), LAX…
#> 15 air_time       FALSE     has 9430 missing values, and duplicate values: 42 (…
#> 16 distance       FALSE     has duplicate values: 2475 (11262), 762 (10263), 73…
#> 17 hour           FALSE     has duplicate values: 8 (27242), 6 (25951), 17 (244…
#> 18 minute         FALSE     has duplicate values: 0 (60696), 30 (33899), 45 (20…
#> 19 time_hour      FALSE     has duplicate values: 2013-09-13 08:00:00 (94), 201…

dm_nycflights13() %>%
  dm_enum_pk_candidates(airports)
#> # A tibble: 8 × 3
#>   columns candidate why                                                         
#>   <keys>  <lgl>     <chr>                                                       
#> 1 faa     TRUE      ""                                                          
#> 2 name    TRUE      ""                                                          
#> 3 lat     TRUE      ""                                                          
#> 4 lon     TRUE      ""                                                          
#> 5 alt     FALSE     "has duplicate values: 30 (4), 13 (3), 9 (2), 19 (2), 26 (2…
#> 6 tz      FALSE     "has duplicate values: -5 (48), -6 (21), -8 (12), -7 (4)"   
#> 7 dst     FALSE     "has duplicate values: A (84), N (2)"                       
#> 8 tzone   FALSE     "has duplicate values: America/New_York (48), America/Chica…
```
