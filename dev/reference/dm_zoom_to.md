# Mark table for manipulation

Zooming to a table of a
[`dm`](https://dm.cynkra.com/dev/reference/dm.md) allows for the use of
many `dplyr`-verbs directly on this table, while retaining the context
of the `dm` object.

`dm_zoom_to()` zooms to the given table.

`dm_update_zoomed()` overwrites the originally zoomed table with the
manipulated table. The filter conditions for the zoomed table are added
to the original filter conditions.

`dm_insert_zoomed()` adds a new table to the `dm`.

`dm_discard_zoomed()` discards the zoomed table and returns the `dm` as
it was before zooming.

Please refer to `vignette("tech-db-zoom", package = "dm")` for a more
detailed introduction.

## Usage

``` r
dm_zoom_to(dm, table)

dm_insert_zoomed(dm, new_tbl_name = NULL, repair = "unique", quiet = FALSE)

dm_update_zoomed(dm)

dm_discard_zoomed(dm)
```

## Arguments

- dm:

  A `dm` object.

- table:

  A table in the `dm`.

- new_tbl_name:

  Name of the new table.

- repair:

  Either a string or a function. If a string, it must be one of
  `"check_unique"`, `"minimal"`, `"unique"`, `"universal"`,
  `"unique_quiet"`, or `"universal_quiet"`. If a function, it is invoked
  with a vector of minimal names and must return minimal names,
  otherwise an error is thrown.

  - Minimal names are never `NULL` or `NA`. When an element doesn't have
    a name, its minimal name is an empty string.

  - Unique names are unique. A suffix is appended to duplicate names to
    make them unique.

  - Universal names are unique and syntactic, meaning that you can
    safely use the names as variables without causing a syntax error.

  The `"check_unique"` option doesn't perform any name repair. Instead,
  an error is raised if the names don't suit the `"unique"` criteria.

  The options `"unique_quiet"` and `"universal_quiet"` are here to help
  the user who calls this function indirectly, via another function
  which exposes `repair` but not `quiet`. Specifying
  `repair = "unique_quiet"` is like specifying
  `repair = "unique", quiet = TRUE`. When the `"*_quiet"` options are
  used, any setting of `quiet` is silently overridden.

- quiet:

  By default, the user is informed of any renaming caused by repairing
  the names. This only concerns unique and universal repairing. Set
  `quiet` to `TRUE` to silence the messages.

  Users can silence the name repair messages by setting the
  `"rlib_name_repair_verbosity"` global option to `"quiet"`.

## Value

For `dm_zoom_to()`: A `dm_zoomed` object.

For `dm_insert_zoomed()`, `dm_update_zoomed()` and
`dm_discard_zoomed()`: A `dm` object.

## Details

Whenever possible, the key relations of the original table are
transferred to the resulting table when using `dm_insert_zoomed()` or
`dm_update_zoomed()`.

Functions from `dplyr` that are supported for a `dm_zoomed`:
[`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html),
[`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html),
[`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html),
[`transmute()`](https://dplyr.tidyverse.org/reference/transmute.html),
[`filter()`](https://dplyr.tidyverse.org/reference/filter.html),
[`select()`](https://dplyr.tidyverse.org/reference/select.html),
[`rename()`](https://dplyr.tidyverse.org/reference/rename.html) and
[`ungroup()`](https://dplyr.tidyverse.org/reference/group_by.html). You
can use these functions just like you would with a normal table.

Calling [`filter()`](https://dplyr.tidyverse.org/reference/filter.html)
on a zoomed `dm` is different from calling
[`dm_filter()`](https://dm.cynkra.com/dev/reference/dm_filter.md): only
with the latter, the filter expression is added to the list of table
filters stored in the dm.

Furthermore, different `join()`-variants from dplyr are also supported,
e.g.
[`left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html)
and
[`semi_join()`](https://dplyr.tidyverse.org/reference/filter-joins.html).
(Support for
[`dplyr::nest_join()`](https://dplyr.tidyverse.org/reference/nest_join.html)
is planned.) The join-methods for `dm_zoomed` infer the columns to join
by from the primary and foreign keys, and have an extra argument
`select` that allows choosing the columns of the RHS table.

And – last but not least – also the tidyr-functions
[`unite()`](https://tidyr.tidyverse.org/reference/unite.html) and
[`separate()`](https://tidyr.tidyverse.org/reference/separate.html) are
supported for `dm_zoomed`.

## Examples

``` r
flights_zoomed <- dm_zoom_to(dm_nycflights13(), flights)

flights_zoomed
#> # Zoomed table: flights
#> # A tibble:     1,761 × 19
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

flights_zoomed_transformed <-
  flights_zoomed %>%
  mutate(am_pm_dep = ifelse(dep_time < 1200, "am", "pm")) %>%
  # `by`-argument of `left_join()` can be explicitly given
  # otherwise the key-relation is used
  left_join(airports) %>%
  select(year:dep_time, am_pm_dep, everything())

flights_zoomed_transformed
#> # Zoomed table: flights
#> # A tibble:     1,761 × 27
#>     year month   day dep_time am_pm_dep sched_dep_time dep_delay arr_time
#>    <int> <int> <int>    <int> <chr>              <int>     <dbl>    <int>
#>  1  2013     1    10        3 am                  2359         4      426
#>  2  2013     1    10       16 am                  2359        17      447
#>  3  2013     1    10      450 am                   500       -10      634
#>  4  2013     1    10      520 am                   525        -5      813
#>  5  2013     1    10      530 am                   530         0      824
#>  6  2013     1    10      531 am                   540        -9      832
#>  7  2013     1    10      535 am                   540        -5     1015
#>  8  2013     1    10      546 am                   600       -14      645
#>  9  2013     1    10      549 am                   600       -11      652
#> 10  2013     1    10      550 am                   600       -10      649
#> # ℹ 1,751 more rows
#> # ℹ 19 more variables: sched_arr_time <int>, arr_delay <dbl>, carrier <chr>,
#> #   flight <int>, tailnum <chr>, origin <chr>, dest <chr>, air_time <dbl>,
#> #   distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>, name <chr>,
#> #   lat <dbl>, lon <dbl>, alt <dbl>, tz <dbl>, dst <chr>, tzone <chr>

# replace table `flights` with the zoomed table
flights_zoomed_transformed %>%
  dm_update_zoomed()
#> ── Metadata ────────────────────────────────────────────────────────────────────
#> Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#> Columns: 61
#> Primary keys: 4
#> Foreign keys: 4

# insert the zoomed table as a new table
flights_zoomed_transformed %>%
  dm_insert_zoomed("extended_flights") %>%
  dm_draw()
%0


airlines
airlinescarrierairports
airportsfaaextended_flights
extended_flightscarriertailnumoriginorigin, time_hourextended_flights:carrier->airlines:carrier
extended_flights:origin->airports:faa
planes
planestailnumextended_flights:tailnum->planes:tailnum
weather
weatherorigin, time_hourextended_flights:origin, time_hour->weather:origin, time_hour
flights
flightscarriertailnumoriginorigin, time_hourflights:carrier->airlines:carrier
flights:origin->airports:faa
flights:tailnum->planes:tailnum
flights:origin, time_hour->weather:origin, time_hour

# discard the zoomed table
flights_zoomed_transformed %>%
  dm_discard_zoomed()
#> ── Metadata ────────────────────────────────────────────────────────────────────
#> Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#> Columns: 53
#> Primary keys: 4
#> Foreign keys: 4
```
