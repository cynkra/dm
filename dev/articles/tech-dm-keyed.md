# Manipulating individual tables

This vignette deals with situations where you want to transform tables
of your `dm` object and then update an existing table or add a new table
to the `dm` object. There are two approaches:

1.  extract the tables relevant to the calculation, perform the
    necessary transformations, and (if needed) recombine the resulting
    table into a `dm`,
2.  do all this within the `dm` object by zooming to a table and
    manipulating it.

Both approaches aim at maintaining the key relations whenever possible.
We will explore the first approach here. For the second approach, see
[`vignette("tech-dm-zoom")`](https://dm.cynkra.com/dev/articles/tech-dm-zoom.md).

## Enabling {dplyr}-workflow within a `dm`

The
[`dm_get_tables()`](https://dm.cynkra.com/dev/reference/dm_get_tables.md)
and [`pull_tbl()`](https://dm.cynkra.com/dev/reference/pull_tbl.md)
functions have a new experimental argument `keyed`, which defaults to
`FALSE`. If set to `TRUE`, a list of objects of class `dm_keyed_tbl` is
returned instead. Because `dm_keyed_tbl` inherits from `tbl` or
`tbl_lazy`, many {dplyr} and {tidyr} verbs will work unchanged. These
objects will also attempt to track primary and foreign keys, so that
they are available for joins and when recombining these tables later
into a `dm` object.

When you are finished with transforming your data, you can use
[`dm()`](https://dm.cynkra.com/dev/reference/dm.md) or
[`new_dm()`](https://dm.cynkra.com/dev/reference/dm.md) to recombine the
tables into a `dm` object. The resulting tables in the `dm` will have
all the primary and foreign keys available that could be tracked from
the original table. Reconstructing the `dm` object is not strictly
necessary if you’re primarily interested in deriving one or multiple
separate tables for analysis.

If this workflow proves as useful as it seems, subsetting tables via
`$`, `[[` will default to `keyed = TRUE` in a forthcoming major release
of {dm}.

## Examples

So much for the theory, but how does it look and feel? To explore this,
we once more make use of our trusted {nycflights13} data.

### Use case 1: Add a new column to an existing table

Imagine you want to have a column in `flights`, specifying if a flight
left before noon or after. Just like with {dplyr}, we can tackle this
with [`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html).
Let us do this step by step:

``` r
library(dm)
library(dplyr)

flights_dm <- dm_nycflights13(cycle = TRUE)
flights_dm
```

``` fansi
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#> Columns: 53
#> Primary keys: 4
#> Foreign keys: 5
```

``` r
flights_keyed <-
  flights_dm %>%
  dm_get_tables(keyed = TRUE)

# The print output for a `dm_keyed_tbl` looks very much like that from a normal
# `tibble`, with additional details about keys.
flights_keyed$flights
```

``` fansi
#> # A tibble: 1,761 × 19
#> # Keys:     — | 0 | 5
#>     year month   day dep_time sched_dep_time dep_delay arr_time
#>    <int> <int> <int>    <int>          <int>     <dbl>    <int>
#>  1  2013     1    10        3           2359         4      426
#>  2  2013     1    10       16           2359        17      447
#>  3  2013     1    10      450            500       -10      634
#>  4  2013     1    10      520            525        -5      813
#>  5  2013     1    10      530            530         0      824
#>  6  2013     1    10      531            540        -9      832
#>  7  2013     1    10      535            540        -5     1015
#>  8  2013     1    10      546            600       -14      645
#>  9  2013     1    10      549            600       -11      652
#> 10  2013     1    10      550            600       -10      649
#> # ℹ 1,751 more rows
#> # ℹ 12 more variables: sched_arr_time <int>, arr_delay <dbl>,
#> #   carrier <chr>, flight <int>, tailnum <chr>, origin <chr>, dest <chr>,
#> #   air_time <dbl>, distance <dbl>, hour <dbl>, minute <dbl>,
#> #   time_hour <dttm>
```

``` r
flights_tbl_mutate <-
  flights_keyed$flights %>%
  mutate(am_pm_dep = if_else(dep_time < 1200, "am", "pm"), .after = dep_time)

flights_tbl_mutate
```

``` fansi
#> # A tibble: 1,761 × 20
#> # Keys:     — | 0 | 5
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
#> # ℹ 12 more variables: sched_arr_time <int>, arr_delay <dbl>,
#> #   carrier <chr>, flight <int>, tailnum <chr>, origin <chr>, dest <chr>,
#> #   air_time <dbl>, distance <dbl>, hour <dbl>, minute <dbl>,
#> #   time_hour <dttm>
```

To update the original `dm` with a new `flights` table we use
[`dm()`](https://dm.cynkra.com/dev/reference/dm.md). The bang-bang-bang
(`!!!`) is a technical necessity that will become superfluous in a
forthcoming release.

``` r
updated_flights_dm <- dm(
  flights = flights_tbl_mutate,
  !!!flights_keyed[c("airlines", "airports", "planes", "weather")]
)

# The only difference in the `dm` print output is the increased number of
# columns
updated_flights_dm
```

``` fansi
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `flights`, `airlines`, `airports`, `planes`, `weather`
#> Columns: 54
#> Primary keys: 4
#> Foreign keys: 5
```

``` r
# The schematic view of the data model remains unchanged
dm_draw(updated_flights_dm)
```

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjUwcHQiIGhlaWdodD0iMjMwcHQiIHZpZXdib3g9IjAuMDAgMC4wMCAyNTAuMDAgMjMwLjAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIj48ZyBpZD0iZ3JhcGgwIiBjbGFzcz0iZ3JhcGgiIHRyYW5zZm9ybT0ic2NhbGUoMSAxKSByb3RhdGUoMCkgdHJhbnNsYXRlKDQgMjI2KSI+PHRpdGxlPiUwPC90aXRsZT4KPGcgaWQ9ImFfZ3JhcGgwIj48YSB4bGluazp0aXRsZT0iRGF0YSBNb2RlbCI+Cjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iLTQsNCAtNCwtMjI2IDI0NiwtMjI2IDI0Niw0IC00LDQiPjwvcG9seWdvbj48L2E+CjwvZz48IS0tIGFpcmxpbmVzIC0tPjxnIGlkPSJhaXJsaW5lcyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJsaW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY4LjUsLTIwMSAxNjguNSwtMjIxIDIxMy41LC0yMjEgMjEzLjUsLTIwMSAxNjguNSwtMjAxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzAuMzk2OSIgeT0iLTIwNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiMwMDAwMDAiPmFpcmxpbmVzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY4LjUsLTE4MSAxNjguNSwtMjAxIDIxMy41LC0yMDEgMjEzLjUsLTE4MSAxNjguNSwtMTgxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzAuNSIgeT0iLTE4Ny40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5jYXJyaWVyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxNjcsLTE4MCAxNjcsLTIyMiAyMTQsLTIyMiAyMTQsLTE4MCAxNjcsLTE4MCI+PC9wb2x5Z29uPjwvZz48IS0tIGFpcnBvcnRzIC0tPjxnIGlkPSJhaXJwb3J0cyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJwb3J0czwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY3LjUsLTgxIDE2Ny41LC0xMDEgMjEzLjUsLTEwMSAyMTMuNSwtODEgMTY3LjUsLTgxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNjkuMTE5MiIgeT0iLTg2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzAwMDAwMCI+YWlycG9ydHM8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNjcuNSwtNjEgMTY3LjUsLTgxIDIxMy41LC04MSAyMTMuNSwtNjEgMTY3LjUsLTYxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNjkuNSIgeT0iLTY3LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmZhYTwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTY2LjUsLTYwIDE2Ni41LC0xMDIgMjE0LjUsLTEwMiAyMTQuNSwtNjAgMTY2LjUsLTYwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyAtLT48ZyBpZD0iZmxpZ2h0cyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5mbGlnaHRzPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iI2VmZWJkZCIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLjUsLTE0MSAxLjUsLTE2MSAxMDIuNSwtMTYxIDEwMi41LC0xNDEgMS41LC0xNDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjM0LjExMTUiIHk9Ii0xNDYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjMDAwMDAwIj5mbGlnaHRzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC0xMjEgMS41LC0xNDEgMTAyLjUsLTE0MSAxMDIuNSwtMTIxIDEuNSwtMTIxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzLjUiIHk9Ii0xMjYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5jYXJyaWVyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC0xMDEgMS41LC0xMjEgMTAyLjUsLTEyMSAxMDIuNSwtMTAxIDEuNSwtMTAxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzLjUiIHk9Ii0xMDYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij50YWlsbnVtPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC04MSAxLjUsLTEwMSAxMDIuNSwtMTAxIDEwMi41LC04MSAxLjUsLTgxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzLjUiIHk9Ii04Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPm9yaWdpbjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtNjEgMS41LC04MSAxMDIuNSwtODEgMTAyLjUsLTYxIDEuNSwtNjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjMuNSIgeT0iLTY2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+ZGVzdDwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtNDEgMS41LC02MSAxMDIuNSwtNjEgMTAyLjUsLTQxIDEuNSwtNDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjMuMDA1NiIgeT0iLTQ2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+b3JpZ2luLCB0aW1lX2hvdXI8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjAsLTQwIDAsLTE2MiAxMDMsLTE2MiAxMDMsLTQwIDAsLTQwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O2FpcmxpbmVzIC0tPjxnIGlkPSJmbGlnaHRzXzEiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czpjYXJyaWVyLSZndDthaXJsaW5lczpjYXJyaWVyPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTAyLjUsLTEzMUMxMjYuNTY2OCwtMTMxIDEyMC44MDI5LC0xNTUuMjQ5NiAxMzksLTE3MSAxNDcuNzk1NiwtMTc4LjYxMyAxNTEuMDM5NCwtMTg1LjgzMDUgMTU4LjQxNTcsLTE4OS4xMjc3IiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxNTguMDI5MSwtMTkyLjYxNTcgMTY4LjUsLTE5MSAxNTkuMzA3LC0xODUuNzMzMyAxNTguMDI5MSwtMTkyLjYxNTciPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzJiM0NTsmZ3Q7YWlycG9ydHMgLS0+PGcgaWQ9ImZsaWdodHNfMiIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOm9yaWdpbi0mZ3Q7YWlycG9ydHM6ZmFhPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTAyLjUsLTkxQzEyOC45NDczLC05MSAxMzUuNzM2MSwtNzUuNjg3NSAxNTcuMjY4NywtNzEuODU5NCIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTU3LjgyODEsLTc1LjMyNDggMTY3LjUsLTcxIDE1Ny4yNDIxLC02OC4zNDk0IDE1Ny44MjgxLC03NS4zMjQ4Ij48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O2FpcnBvcnRzIC0tPjxnIGlkPSJmbGlnaHRzXzMiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czpkZXN0LSZndDthaXJwb3J0czpmYWE8L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik0xMDIuNSwtNzFDMTI3LjY2NDksLTcxIDEzNi4zODkxLC03MSAxNTcuMzE1NCwtNzEiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjE1Ny41LC03NC41MDAxIDE2Ny41LC03MSAxNTcuNSwtNjcuNTAwMSAxNTcuNSwtNzQuNTAwMSI+PC9wb2x5Z29uPjwvZz48IS0tIHBsYW5lcyAtLT48ZyBpZD0icGxhbmVzIiBjbGFzcz0ibm9kZSI+PHRpdGxlPnBsYW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY3LjUsLTE0MSAxNjcuNSwtMTYxIDIxMy41LC0xNjEgMjEzLjUsLTE0MSAxNjcuNSwtMTQxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzIuNjE3OCIgeT0iLTE0Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiMwMDAwMDAiPnBsYW5lczwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE2Ny41LC0xMjEgMTY3LjUsLTE0MSAyMTMuNSwtMTQxIDIxMy41LC0xMjEgMTY3LjUsLTEyMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTY5LjExMTUiIHk9Ii0xMjcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+dGFpbG51bTwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTY2LjUsLTEyMCAxNjYuNSwtMTYyIDIxNC41LC0xNjIgMjE0LjUsLTEyMCAxNjYuNSwtMTIwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O3BsYW5lcyAtLT48ZyBpZD0iZmxpZ2h0c180IiBjbGFzcz0iZWRnZSI+PHRpdGxlPmZsaWdodHM6dGFpbG51bS0mZ3Q7cGxhbmVzOnRhaWxudW08L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik0xMDIuNSwtMTExQzEyOC45NDczLC0xMTEgMTM1LjczNjEsLTEyNi4zMTI1IDE1Ny4yNjg3LC0xMzAuMTQwNiIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTU3LjI0MjEsLTEzMy42NTA2IDE2Ny41LC0xMzEgMTU3LjgyODEsLTEyNi42NzUyIDE1Ny4yNDIxLC0xMzMuNjUwNiI+PC9wb2x5Z29uPjwvZz48IS0tIHdlYXRoZXIgLS0+PGcgaWQ9IndlYXRoZXIiIGNsYXNzPSJub2RlIj48dGl0bGU+d2VhdGhlcjwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTQwLjUsLTIxIDE0MC41LC00MSAyNDEuNSwtNDEgMjQxLjUsLTIxIDE0MC41LC0yMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTY4Ljg0OTIiIHk9Ii0yNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiMwMDAwMDAiPndlYXRoZXI8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNDAuNSwtMSAxNDAuNSwtMjEgMjQxLjUsLTIxIDI0MS41LC0xIDE0MC41LC0xIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNDIuMDA1NiIgeT0iLTcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+b3JpZ2luLCB0aW1lX2hvdXI8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjEzOSwwIDEzOSwtNDIgMjQyLC00MiAyNDIsMCAxMzksMCI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMmIzQ1OyZndDt3ZWF0aGVyIC0tPjxnIGlkPSJmbGlnaHRzXzUiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czpvcmlnaW4sIHRpbWVfaG91ci0mZ3Q7d2VhdGhlcjpvcmlnaW4sIHRpbWVfaG91cjwvdGl0bGU+CjxwYXRoIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgZD0iTTEwMi41LC01MUMxMjIuODA2NSwtNTEgMTE4LjcyNDEsLTIzLjU2ODQgMTMwLjY0NjksLTE0LjEzODciIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjEzMi4wMzQxLC0xNy4zNzAyIDE0MC41LC0xMSAxMjkuOTA5NCwtMTAuNzAwNCAxMzIuMDM0MSwtMTcuMzcwMiI+PC9wb2x5Z29uPjwvZz48L2c+PC9zdmc+)

### Use case 2: Creation of a surrogate key

The same course of action could, for example, be employed to create a
surrogate key for a table, a synthetic simple key that replaces a
compound key. We can do this for the `weather` table.

``` r
library(tidyr)

flights_keyed$weather
```

``` fansi
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
```

``` r

# Maybe there is some hidden candidate for a primary key that we overlooked?
enum_pk_candidates(flights_keyed$weather)
```

``` fansi
#> # A tibble: 15 × 3
#>    columns    candidate why                                                
#>    <keys>     <lgl>     <chr>                                              
#>  1 origin     FALSE     has duplicate values: EWR (48), JFK (48), LGA (48) 
#>  2 year       FALSE     has duplicate values: 2013 (144)                   
#>  3 month      FALSE     has duplicate values: 1 (72), 2 (72)               
#>  4 day        FALSE     has duplicate values: 10 (144)                     
#>  5 hour       FALSE     has duplicate values: 0 (6), 1 (6), 2 (6), 3 (6), …
#>  6 temp       FALSE     has duplicate values: 44.06 (12), 41.00 (8), 44.96…
#>  7 dewp       FALSE     has duplicate values: 21.92 (16), 24.98 (16), 6.98…
#>  8 humid      FALSE     has duplicate values: 53.71 (4), 56.56 (4), 32.53 …
#>  9 wind_dir   FALSE     has duplicate values: 320 (25), 330 (17), 310 (15)…
#> 10 wind_speed FALSE     has duplicate values: 6.90468 (20), 8.05546 (19), …
#> 11 wind_gust  FALSE     has 123 missing values, and duplicate values: 23.0…
#> 12 precip     FALSE     has duplicate values: 0 (144)                      
#> 13 pressure   FALSE     has duplicate values: 1028.9 (6), 1029.0 (5), 1032…
#> 14 visib      FALSE     has duplicate values: 10 (144)                     
#> 15 time_hour  FALSE     has duplicate values: 2013-01-10 00:00:00 (3), 201…
```

``` r
# Seems we have to construct a column with unique values
# This can be done by combining column `origin` with `time_hour`, if the latter
# is converted to a single time zone first; all within the `dm`:
weather_tbl_mutate <-
  flights_keyed$weather %>%
  # first convert all times to the same time zone:
  mutate(time_hour_fmt = format(time_hour, tz = "UTC")) %>%
  # paste together as character the airport code and the time
  unite("origin_slot_id", origin, time_hour_fmt) %>%
  select(origin_slot_id, everything())

# check if we the result is as expected:
weather_tbl_mutate %>%
  enum_pk_candidates() %>%
  filter(candidate)
```

``` fansi
#> # A tibble: 1 × 3
#>   columns        candidate why  
#>   <keys>         <lgl>     <chr>
#> 1 origin_slot_id TRUE      ""
```

``` r
# We apply the same transformation to create
# the foreign key in the flights table:
flights_tbl_mutate <-
  flights_keyed$flights %>%
  mutate(time_hour_fmt = format(time_hour, tz = "UTC")) %>%
  unite("origin_slot_id", origin, time_hour_fmt) %>%
  select(origin_slot_id, everything())

surrogate_flights_dm <-
  dm(
    weather = weather_tbl_mutate,
    flights = flights_tbl_mutate,
    !!!flights_keyed[c("airlines", "airports", "planes")]
  ) %>%
  dm_add_pk(weather, origin_slot_id) %>%
  dm_add_fk(flights, origin_slot_id, weather)

surrogate_flights_dm %>%
  dm_draw()
```

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjEycHQiIGhlaWdodD0iMjMwcHQiIHZpZXdib3g9IjAuMDAgMC4wMCAyMTIuMDAgMjMwLjAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIj48ZyBpZD0iZ3JhcGgwIiBjbGFzcz0iZ3JhcGgiIHRyYW5zZm9ybT0ic2NhbGUoMSAxKSByb3RhdGUoMCkgdHJhbnNsYXRlKDQgMjI2KSI+PHRpdGxlPiUwPC90aXRsZT4KPGcgaWQ9ImFfZ3JhcGgwIj48YSB4bGluazp0aXRsZT0iRGF0YSBNb2RlbCI+Cjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iLTQsNCAtNCwtMjI2IDIwOCwtMjI2IDIwOCw0IC00LDQiPjwvcG9seWdvbj48L2E+CjwvZz48IS0tIGFpcmxpbmVzIC0tPjxnIGlkPSJhaXJsaW5lcyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJsaW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTQwLC0xNDEgMTQwLC0xNjEgMTg1LC0xNjEgMTg1LC0xNDEgMTQwLC0xNDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE0MS44OTY5IiB5PSItMTQ2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzAwMDAwMCI+YWlybGluZXM8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNDAsLTEyMSAxNDAsLTE0MSAxODUsLTE0MSAxODUsLTEyMSAxNDAsLTEyMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTQyIiB5PSItMTI3LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmNhcnJpZXI8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjEzOC41LC0xMjAgMTM4LjUsLTE2MiAxODUuNSwtMTYyIDE4NS41LC0xMjAgMTM4LjUsLTEyMCI+PC9wb2x5Z29uPjwvZz48IS0tIGFpcnBvcnRzIC0tPjxnIGlkPSJhaXJwb3J0cyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJwb3J0czwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTM5LC0yMSAxMzksLTQxIDE4NSwtNDEgMTg1LC0yMSAxMzksLTIxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNDAuNjE5MiIgeT0iLTI2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzAwMDAwMCI+YWlycG9ydHM8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxMzksLTEgMTM5LC0yMSAxODUsLTIxIDE4NSwtMSAxMzksLTEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE0MSIgeT0iLTcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+ZmFhPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxMzgsMCAxMzgsLTQyIDE4NiwtNDIgMTg2LDAgMTM4LDAiPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzIC0tPjxnIGlkPSJmbGlnaHRzIiBjbGFzcz0ibm9kZSI+PHRpdGxlPmZsaWdodHM8L3RpdGxlPgo8cG9seWdvbiBmaWxsPSIjZWZlYmRkIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEsLTE0MSAxLC0xNjEgODMsLTE2MSA4MywtMTQxIDEsLTE0MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMjQuMTExNSIgeT0iLTE0Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiMwMDAwMDAiPmZsaWdodHM8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLC0xMjEgMSwtMTQxIDgzLC0xNDEgODMsLTEyMSAxLC0xMjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjIuNzIwOSIgeT0iLTEyNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPm9yaWdpbl9zbG90X2lkPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMSwtMTAxIDEsLTEyMSA4MywtMTIxIDgzLC0xMDEgMSwtMTAxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzIiB5PSItMTA2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+Y2FycmllcjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEsLTgxIDEsLTEwMSA4MywtMTAxIDgzLC04MSAxLC04MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMyIgeT0iLTg2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+dGFpbG51bTwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEsLTYxIDEsLTgxIDgzLC04MSA4MywtNjEgMSwtNjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjMiIHk9Ii02Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmRlc3Q8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjAsLTYwIDAsLTE2MiA4NCwtMTYyIDg0LC02MCAwLC02MCI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMmIzQ1OyZndDthaXJsaW5lcyAtLT48ZyBpZD0iZmxpZ2h0c18yIiBjbGFzcz0iZWRnZSI+PHRpdGxlPmZsaWdodHM6Y2Fycmllci0mZ3Q7YWlybGluZXM6Y2FycmllcjwvdGl0bGU+CjxwYXRoIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgZD0iTTgzLC0xMTFDMTA2LjA3MjEsLTExMSAxMTEuNzU3NCwtMTI1Ljc3MDUgMTI5LjkzOTQsLTEyOS45MjQ3IiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxMjkuNjg0NiwtMTMzLjQxNzMgMTQwLC0xMzEgMTMwLjQyODYsLTEyNi40NTcgMTI5LjY4NDYsLTEzMy40MTczIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O2FpcnBvcnRzIC0tPjxnIGlkPSJmbGlnaHRzXzMiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czpkZXN0LSZndDthaXJwb3J0czpmYWE8L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik04MywtNzFDMTE1LjYyOTgsLTcxIDEwNS41MDQ5LC0yMi45ODg4IDEyOS4xMTYxLC0xMi44NjE1IiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxMjkuODIwNiwtMTYuMjkwNCAxMzksLTExIDEyOC41MjUsLTkuNDExNCAxMjkuODIwNiwtMTYuMjkwNCI+PC9wb2x5Z29uPjwvZz48IS0tIHBsYW5lcyAtLT48ZyBpZD0icGxhbmVzIiBjbGFzcz0ibm9kZSI+PHRpdGxlPnBsYW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTM5LC04MSAxMzksLTEwMSAxODUsLTEwMSAxODUsLTgxIDEzOSwtODEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE0NC4xMTc4IiB5PSItODYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjMDAwMDAwIj5wbGFuZXM8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxMzksLTYxIDEzOSwtODEgMTg1LC04MSAxODUsLTYxIDEzOSwtNjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE0MC42MTE1IiB5PSItNjcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+dGFpbG51bTwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTM4LC02MCAxMzgsLTEwMiAxODYsLTEwMiAxODYsLTYwIDEzOCwtNjAiPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzJiM0NTsmZ3Q7cGxhbmVzIC0tPjxnIGlkPSJmbGlnaHRzXzQiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czp0YWlsbnVtLSZndDtwbGFuZXM6dGFpbG51bTwvdGl0bGU+CjxwYXRoIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgZD0iTTgzLC05MUMxMDUuNTA1NiwtOTEgMTExLjEyNTMsLTc2LjQ5NjggMTI4LjYxNzksLTcyLjE5MTIiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjEyOS40NjQyLC03NS42MTcyIDEzOSwtNzEgMTI4LjY2NjIsLTY4LjY2MjggMTI5LjQ2NDIsLTc1LjYxNzIiPjwvcG9seWdvbj48L2c+PCEtLSB3ZWF0aGVyIC0tPjxnIGlkPSJ3ZWF0aGVyIiBjbGFzcz0ibm9kZSI+PHRpdGxlPndlYXRoZXI8L3RpdGxlPgo8cG9seWdvbiBmaWxsPSIjZWZlYmRkIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEyMSwtMjAxIDEyMSwtMjIxIDIwMywtMjIxIDIwMywtMjAxIDEyMSwtMjAxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxMzkuODQ5MiIgeT0iLTIwNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiMwMDAwMDAiPndlYXRoZXI8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxMjEsLTE4MSAxMjEsLTIwMSAyMDMsLTIwMSAyMDMsLTE4MSAxMjEsLTE4MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTIyLjcyMDkiIHk9Ii0xODcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+b3JpZ2luX3Nsb3RfaWQ8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjEyMCwtMTgwIDEyMCwtMjIyIDIwNCwtMjIyIDIwNCwtMTgwIDEyMCwtMTgwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O3dlYXRoZXIgLS0+PGcgaWQ9ImZsaWdodHNfMSIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOm9yaWdpbl9zbG90X2lkLSZndDt3ZWF0aGVyOm9yaWdpbl9zbG90X2lkPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNODMsLTEzMUMxMTAuMzcyNywtMTMxIDk1LjExMDEsLTE3Ni4xMjA4IDExMS4xNTc5LC0xODguMTA2MSIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTEwLjQxODgsLTE5MS41MzY5IDEyMSwtMTkxIDExMi4zOTM1LC0xODQuODIxMSAxMTAuNDE4OCwtMTkxLjUzNjkiPjwvcG9seWdvbj48L2c+PC9nPjwvc3ZnPg==)

### Use case 3: Disentangle `dm`

If you look at the `dm` created by `dm_nycflights13(cycle = TRUE)`, you
see that two columns of `flights` relate to the same table, `airports`.
One column stands for the departure airport and the other for the
arrival airport. This generates a cycle which leads to failures with
many operations that only work on cycle-free data models, such as
[`dm_flatten_to_tbl()`](https://dm.cynkra.com/dev/reference/dm_flatten_to_tbl.md),
[`dm_filter()`](https://dm.cynkra.com/dev/reference/dm_filter.md) or
[`dm_wrap_tbl()`](https://dm.cynkra.com/dev/reference/dm_wrap_tbl.md).
In such cases, it can be beneficial to “disentangle” the `dm` by
duplicating the referred table. One way to do this in the {dm}-framework
is as follows:

``` r
disentangled_flights_dm <-
  dm(
    destination = flights_keyed$airports,
    origin = flights_keyed$airports,
    !!!flights_keyed[c("flights", "airlines", "planes", "weather")]
  ) %>%
  # Key relations are also duplicated, so the wrong ones need to be removed
  dm_rm_fk(flights, dest, origin) %>%
  dm_rm_fk(flights, origin, destination)

disentangled_flights_dm %>%
  dm_draw()
```

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjUwcHQiIGhlaWdodD0iMjkwcHQiIHZpZXdib3g9IjAuMDAgMC4wMCAyNTAuMDAgMjkwLjAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIj48ZyBpZD0iZ3JhcGgwIiBjbGFzcz0iZ3JhcGgiIHRyYW5zZm9ybT0ic2NhbGUoMSAxKSByb3RhdGUoMCkgdHJhbnNsYXRlKDQgMjg2KSI+PHRpdGxlPiUwPC90aXRsZT4KPGcgaWQ9ImFfZ3JhcGgwIj48YSB4bGluazp0aXRsZT0iRGF0YSBNb2RlbCI+Cjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iLTQsNCAtNCwtMjg2IDI0NiwtMjg2IDI0Niw0IC00LDQiPjwvcG9seWdvbj48L2E+CjwvZz48IS0tIGFpcmxpbmVzIC0tPjxnIGlkPSJhaXJsaW5lcyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJsaW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY4LjUsLTI2MSAxNjguNSwtMjgxIDIxMy41LC0yODEgMjEzLjUsLTI2MSAxNjguNSwtMjYxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzAuMzk2OSIgeT0iLTI2Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiMwMDAwMDAiPmFpcmxpbmVzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY4LjUsLTI0MSAxNjguNSwtMjYxIDIxMy41LC0yNjEgMjEzLjUsLTI0MSAxNjguNSwtMjQxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzAuNSIgeT0iLTI0Ny40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5jYXJyaWVyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxNjcsLTI0MCAxNjcsLTI4MiAyMTQsLTI4MiAyMTQsLTI0MCAxNjcsLTI0MCI+PC9wb2x5Z29uPjwvZz48IS0tIGRlc3RpbmF0aW9uIC0tPjxnIGlkPSJkZXN0aW5hdGlvbiIgY2xhc3M9Im5vZGUiPjx0aXRsZT5kZXN0aW5hdGlvbjwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTU4LjUsLTgxIDE1OC41LC0xMDEgMjIzLjUsLTEwMSAyMjMuNSwtODEgMTU4LjUsLTgxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNjAuMjgxOSIgeT0iLTg2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzAwMDAwMCI+ZGVzdGluYXRpb248L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNTguNSwtNjEgMTU4LjUsLTgxIDIyMy41LC04MSAyMjMuNSwtNjEgMTU4LjUsLTYxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNjAuNSIgeT0iLTY3LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmZhYTwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTU3LC02MCAxNTcsLTEwMiAyMjQsLTEwMiAyMjQsLTYwIDE1NywtNjAiPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzIC0tPjxnIGlkPSJmbGlnaHRzIiBjbGFzcz0ibm9kZSI+PHRpdGxlPmZsaWdodHM8L3RpdGxlPgo8cG9seWdvbiBmaWxsPSIjZWZlYmRkIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtMTgxIDEuNSwtMjAxIDEwMi41LC0yMDEgMTAyLjUsLTE4MSAxLjUsLTE4MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMzQuMTExNSIgeT0iLTE4Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiMwMDAwMDAiPmZsaWdodHM8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLjUsLTE2MSAxLjUsLTE4MSAxMDIuNSwtMTgxIDEwMi41LC0xNjEgMS41LC0xNjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjMuNSIgeT0iLTE2Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmNhcnJpZXI8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLjUsLTE0MSAxLjUsLTE2MSAxMDIuNSwtMTYxIDEwMi41LC0xNDEgMS41LC0xNDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjMuNSIgeT0iLTE0Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPnRhaWxudW08L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLjUsLTEyMSAxLjUsLTE0MSAxMDIuNSwtMTQxIDEwMi41LC0xMjEgMS41LC0xMjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjMuNSIgeT0iLTEyNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPm9yaWdpbjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtMTAxIDEuNSwtMTIxIDEwMi41LC0xMjEgMTAyLjUsLTEwMSAxLjUsLTEwMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMy41IiB5PSItMTA2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+ZGVzdDwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtODEgMS41LC0xMDEgMTAyLjUsLTEwMSAxMDIuNSwtODEgMS41LC04MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMy4wMDU2IiB5PSItODYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5vcmlnaW4sIHRpbWVfaG91cjwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMCwtODAgMCwtMjAyIDEwMywtMjAyIDEwMywtODAgMCwtODAiPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzJiM0NTsmZ3Q7YWlybGluZXMgLS0+PGcgaWQ9ImZsaWdodHNfMyIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOmNhcnJpZXItJmd0O2FpcmxpbmVzOmNhcnJpZXI8L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik0xMDIuNSwtMTcxQzEzMy43MTMzLC0xNzEgMTE3LjQ3OTEsLTIwOC4zOTIgMTM5LC0yMzEgMTQ3LjAyMDUsLTIzOS40MjU2IDE1MC42Mjc3LC0yNDYuMjYyMiAxNTguMjUxNywtMjQ5LjI5OTciIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjE1OC4wNjIsLTI1Mi44MTYgMTY4LjUsLTI1MSAxNTkuMjA3NywtMjQ1LjkxMDQgMTU4LjA2MiwtMjUyLjgxNiI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMmIzQ1OyZndDtkZXN0aW5hdGlvbiAtLT48ZyBpZD0iZmxpZ2h0c18xIiBjbGFzcz0iZWRnZSI+PHRpdGxlPmZsaWdodHM6ZGVzdC0mZ3Q7ZGVzdGluYXRpb246ZmFhPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTAyLjUsLTExMUMxMjkuMjYyOCwtMTExIDEyOC42NDgzLC04MC4zNzUgMTQ4LjU2NjcsLTcyLjcxODgiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjE0OS4yNDMyLC03Ni4xNTM4IDE1OC41LC03MSAxNDguMDQ5NywtNjkuMjU2MyAxNDkuMjQzMiwtNzYuMTUzOCI+PC9wb2x5Z29uPjwvZz48IS0tIG9yaWdpbiAtLT48ZyBpZD0ib3JpZ2luIiBjbGFzcz0ibm9kZSI+PHRpdGxlPm9yaWdpbjwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTcyLjUsLTE0MSAxNzIuNSwtMTYxIDIwOS41LC0xNjEgMjA5LjUsLTE0MSAxNzIuNSwtMTQxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzQuMjc5MSIgeT0iLTE0Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiMwMDAwMDAiPm9yaWdpbjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE3Mi41LC0xMjEgMTcyLjUsLTE0MSAyMDkuNSwtMTQxIDIwOS41LC0xMjEgMTcyLjUsLTEyMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTc0LjUiIHk9Ii0xMjcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+ZmFhPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxNzEsLTEyMCAxNzEsLTE2MiAyMTAsLTE2MiAyMTAsLTEyMCAxNzEsLTEyMCI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMmIzQ1OyZndDtvcmlnaW4gLS0+PGcgaWQ9ImZsaWdodHNfMiIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOm9yaWdpbi0mZ3Q7b3JpZ2luOmZhYTwvdGl0bGU+CjxwYXRoIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgZD0iTTEwMi41LC0xMzFDMTI5Ljk2NTMsLTEzMSAxMzkuMjQ1NSwtMTMxIDE2Mi40NDg3LC0xMzEiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjE2Mi41LC0xMzQuNTAwMSAxNzIuNSwtMTMxIDE2Mi41LC0xMjcuNTAwMSAxNjIuNSwtMTM0LjUwMDEiPjwvcG9seWdvbj48L2c+PCEtLSBwbGFuZXMgLS0+PGcgaWQ9InBsYW5lcyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5wbGFuZXM8L3RpdGxlPgo8cG9seWdvbiBmaWxsPSIjZWZlYmRkIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE2Ny41LC0yMDEgMTY3LjUsLTIyMSAyMTMuNSwtMjIxIDIxMy41LC0yMDEgMTY3LjUsLTIwMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTcyLjYxNzgiIHk9Ii0yMDYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjMDAwMDAwIj5wbGFuZXM8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNjcuNSwtMTgxIDE2Ny41LC0yMDEgMjEzLjUsLTIwMSAyMTMuNSwtMTgxIDE2Ny41LC0xODEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE2OS4xMTE1IiB5PSItMTg3LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPnRhaWxudW08L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjE2Ni41LC0xODAgMTY2LjUsLTIyMiAyMTQuNSwtMjIyIDIxNC41LC0xODAgMTY2LjUsLTE4MCI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMmIzQ1OyZndDtwbGFuZXMgLS0+PGcgaWQ9ImZsaWdodHNfNCIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOnRhaWxudW0tJmd0O3BsYW5lczp0YWlsbnVtPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTAyLjUsLTE1MUMxMzIuNTc4MiwtMTUxIDEzMy43NTEzLC0xODIuNDUwOCAxNTcuMjgwNiwtMTg5LjU3NjQiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjE1Ny4xMTI3LC0xOTMuMDg2NyAxNjcuNSwtMTkxIDE1OC4wNzg2LC0xODYuMTUzNyAxNTcuMTEyNywtMTkzLjA4NjciPjwvcG9seWdvbj48L2c+PCEtLSB3ZWF0aGVyIC0tPjxnIGlkPSJ3ZWF0aGVyIiBjbGFzcz0ibm9kZSI+PHRpdGxlPndlYXRoZXI8L3RpdGxlPgo8cG9seWdvbiBmaWxsPSIjZWZlYmRkIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE0MC41LC0yMSAxNDAuNSwtNDEgMjQxLjUsLTQxIDI0MS41LC0yMSAxNDAuNSwtMjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE2OC44NDkyIiB5PSItMjYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjMDAwMDAwIj53ZWF0aGVyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTQwLjUsLTEgMTQwLjUsLTIxIDI0MS41LC0yMSAyNDEuNSwtMSAxNDAuNSwtMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTQyLjAwNTYiIHk9Ii03LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPm9yaWdpbiwgdGltZV9ob3VyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxMzksMCAxMzksLTQyIDI0MiwtNDIgMjQyLDAgMTM5LDAiPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzJiM0NTsmZ3Q7d2VhdGhlciAtLT48ZyBpZD0iZmxpZ2h0c181IiBjbGFzcz0iZWRnZSI+PHRpdGxlPmZsaWdodHM6b3JpZ2luLCB0aW1lX2hvdXItJmd0O3dlYXRoZXI6b3JpZ2luLCB0aW1lX2hvdXI8L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik0xMDIuNSwtOTFDMTM3LjcxMTMsLTkxIDEwOC44MzY5LC0yNi45ODUxIDEzMC41MzAxLC0xMy40ODIiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjEzMS42NDE3LC0xNi44MTIxIDE0MC41LC0xMSAxMjkuOTUwNiwtMTAuMDE5NSAxMzEuNjQxNywtMTYuODEyMSI+PC9wb2x5Z29uPjwvZz48L2c+PC9zdmc+)

### Use case 4: Add summary table to `dm`

Here is an example for adding a summary of a table as a new table to a
`dm`. Foreign-key relations are taken care of automatically. This
example shows an alternative approach of deconstruction reconstruction
using [`pull_tbl()`](https://dm.cynkra.com/dev/reference/pull_tbl.md).

``` r
flights_derived <-
  flights_dm %>%
  pull_tbl(flights, keyed = TRUE) %>%
  dplyr::count(origin, carrier)

derived_flights_dm <- dm(flights_derived, !!!flights_keyed)

derived_flights_dm %>%
  dm_draw()
```

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjUwcHQiIGhlaWdodD0iMjUwcHQiIHZpZXdib3g9IjAuMDAgMC4wMCAyNTAuMDAgMjUwLjAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIj48ZyBpZD0iZ3JhcGgwIiBjbGFzcz0iZ3JhcGgiIHRyYW5zZm9ybT0ic2NhbGUoMSAxKSByb3RhdGUoMCkgdHJhbnNsYXRlKDQgMjQ2KSI+PHRpdGxlPiUwPC90aXRsZT4KPGcgaWQ9ImFfZ3JhcGgwIj48YSB4bGluazp0aXRsZT0iRGF0YSBNb2RlbCI+Cjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iLTQsNCAtNCwtMjQ2IDI0NiwtMjQ2IDI0Niw0IC00LDQiPjwvcG9seWdvbj48L2E+CjwvZz48IS0tIGFpcmxpbmVzIC0tPjxnIGlkPSJhaXJsaW5lcyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJsaW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY4LjUsLTIwMSAxNjguNSwtMjIxIDIxMy41LC0yMjEgMjEzLjUsLTIwMSAxNjguNSwtMjAxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzAuMzk2OSIgeT0iLTIwNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiMwMDAwMDAiPmFpcmxpbmVzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY4LjUsLTE4MSAxNjguNSwtMjAxIDIxMy41LC0yMDEgMjEzLjUsLTE4MSAxNjguNSwtMTgxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzAuNSIgeT0iLTE4Ny40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5jYXJyaWVyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxNjcsLTE4MCAxNjcsLTIyMiAyMTQsLTIyMiAyMTQsLTE4MCAxNjcsLTE4MCI+PC9wb2x5Z29uPjwvZz48IS0tIGFpcnBvcnRzIC0tPjxnIGlkPSJhaXJwb3J0cyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJwb3J0czwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY3LjUsLTgxIDE2Ny41LC0xMDEgMjEzLjUsLTEwMSAyMTMuNSwtODEgMTY3LjUsLTgxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNjkuMTE5MiIgeT0iLTg2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzAwMDAwMCI+YWlycG9ydHM8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNjcuNSwtNjEgMTY3LjUsLTgxIDIxMy41LC04MSAyMTMuNSwtNjEgMTY3LjUsLTYxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNjkuNSIgeT0iLTY3LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmZhYTwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTY2LjUsLTYwIDE2Ni41LC0xMDIgMjE0LjUsLTEwMiAyMTQuNSwtNjAgMTY2LjUsLTYwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyAtLT48ZyBpZD0iZmxpZ2h0cyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5mbGlnaHRzPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iI2VmZWJkZCIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLjUsLTE0MSAxLjUsLTE2MSAxMDIuNSwtMTYxIDEwMi41LC0xNDEgMS41LC0xNDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjM0LjExMTUiIHk9Ii0xNDYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjMDAwMDAwIj5mbGlnaHRzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC0xMjEgMS41LC0xNDEgMTAyLjUsLTE0MSAxMDIuNSwtMTIxIDEuNSwtMTIxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzLjUiIHk9Ii0xMjYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5jYXJyaWVyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC0xMDEgMS41LC0xMjEgMTAyLjUsLTEyMSAxMDIuNSwtMTAxIDEuNSwtMTAxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzLjUiIHk9Ii0xMDYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij50YWlsbnVtPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC04MSAxLjUsLTEwMSAxMDIuNSwtMTAxIDEwMi41LC04MSAxLjUsLTgxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzLjUiIHk9Ii04Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPm9yaWdpbjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtNjEgMS41LC04MSAxMDIuNSwtODEgMTAyLjUsLTYxIDEuNSwtNjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjMuNSIgeT0iLTY2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+ZGVzdDwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtNDEgMS41LC02MSAxMDIuNSwtNjEgMTAyLjUsLTQxIDEuNSwtNDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjMuMDA1NiIgeT0iLTQ2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+b3JpZ2luLCB0aW1lX2hvdXI8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjAsLTQwIDAsLTE2MiAxMDMsLTE2MiAxMDMsLTQwIDAsLTQwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O2FpcmxpbmVzIC0tPjxnIGlkPSJmbGlnaHRzXzEiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czpjYXJyaWVyLSZndDthaXJsaW5lczpjYXJyaWVyPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTAyLjUsLTEzMUMxMjYuNTY2OCwtMTMxIDEyMC44MDI5LC0xNTUuMjQ5NiAxMzksLTE3MSAxNDcuNzk1NiwtMTc4LjYxMyAxNTEuMDM5NCwtMTg1LjgzMDUgMTU4LjQxNTcsLTE4OS4xMjc3IiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxNTguMDI5MSwtMTkyLjYxNTcgMTY4LjUsLTE5MSAxNTkuMzA3LC0xODUuNzMzMyAxNTguMDI5MSwtMTkyLjYxNTciPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzJiM0NTsmZ3Q7YWlycG9ydHMgLS0+PGcgaWQ9ImZsaWdodHNfMiIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOm9yaWdpbi0mZ3Q7YWlycG9ydHM6ZmFhPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTAyLjUsLTkxQzEyOC45NDczLC05MSAxMzUuNzM2MSwtNzUuNjg3NSAxNTcuMjY4NywtNzEuODU5NCIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTU3LjgyODEsLTc1LjMyNDggMTY3LjUsLTcxIDE1Ny4yNDIxLC02OC4zNDk0IDE1Ny44MjgxLC03NS4zMjQ4Ij48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O2FpcnBvcnRzIC0tPjxnIGlkPSJmbGlnaHRzXzMiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czpkZXN0LSZndDthaXJwb3J0czpmYWE8L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik0xMDIuNSwtNzFDMTI3LjY2NDksLTcxIDEzNi4zODkxLC03MSAxNTcuMzE1NCwtNzEiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjE1Ny41LC03NC41MDAxIDE2Ny41LC03MSAxNTcuNSwtNjcuNTAwMSAxNTcuNSwtNzQuNTAwMSI+PC9wb2x5Z29uPjwvZz48IS0tIHBsYW5lcyAtLT48ZyBpZD0icGxhbmVzIiBjbGFzcz0ibm9kZSI+PHRpdGxlPnBsYW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY3LjUsLTE0MSAxNjcuNSwtMTYxIDIxMy41LC0xNjEgMjEzLjUsLTE0MSAxNjcuNSwtMTQxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzIuNjE3OCIgeT0iLTE0Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiMwMDAwMDAiPnBsYW5lczwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE2Ny41LC0xMjEgMTY3LjUsLTE0MSAyMTMuNSwtMTQxIDIxMy41LC0xMjEgMTY3LjUsLTEyMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTY5LjExMTUiIHk9Ii0xMjcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+dGFpbG51bTwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTY2LjUsLTEyMCAxNjYuNSwtMTYyIDIxNC41LC0xNjIgMjE0LjUsLTEyMCAxNjYuNSwtMTIwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O3BsYW5lcyAtLT48ZyBpZD0iZmxpZ2h0c180IiBjbGFzcz0iZWRnZSI+PHRpdGxlPmZsaWdodHM6dGFpbG51bS0mZ3Q7cGxhbmVzOnRhaWxudW08L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik0xMDIuNSwtMTExQzEyOC45NDczLC0xMTEgMTM1LjczNjEsLTEyNi4zMTI1IDE1Ny4yNjg3LC0xMzAuMTQwNiIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTU3LjI0MjEsLTEzMy42NTA2IDE2Ny41LC0xMzEgMTU3LjgyODEsLTEyNi42NzUyIDE1Ny4yNDIxLC0xMzMuNjUwNiI+PC9wb2x5Z29uPjwvZz48IS0tIHdlYXRoZXIgLS0+PGcgaWQ9IndlYXRoZXIiIGNsYXNzPSJub2RlIj48dGl0bGU+d2VhdGhlcjwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTQwLjUsLTIxIDE0MC41LC00MSAyNDEuNSwtNDEgMjQxLjUsLTIxIDE0MC41LC0yMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTY4Ljg0OTIiIHk9Ii0yNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiMwMDAwMDAiPndlYXRoZXI8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNDAuNSwtMSAxNDAuNSwtMjEgMjQxLjUsLTIxIDI0MS41LC0xIDE0MC41LC0xIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNDIuMDA1NiIgeT0iLTcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+b3JpZ2luLCB0aW1lX2hvdXI8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjEzOSwwIDEzOSwtNDIgMjQyLC00MiAyNDIsMCAxMzksMCI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMmIzQ1OyZndDt3ZWF0aGVyIC0tPjxnIGlkPSJmbGlnaHRzXzUiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czpvcmlnaW4sIHRpbWVfaG91ci0mZ3Q7d2VhdGhlcjpvcmlnaW4sIHRpbWVfaG91cjwvdGl0bGU+CjxwYXRoIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgZD0iTTEwMi41LC01MUMxMjIuODA2NSwtNTEgMTE4LjcyNDEsLTIzLjU2ODQgMTMwLjY0NjksLTE0LjEzODciIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjEzMi4wMzQxLC0xNy4zNzAyIDE0MC41LC0xMSAxMjkuOTA5NCwtMTAuNzAwNCAxMzIuMDM0MSwtMTcuMzcwMiI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHNfZGVyaXZlZCAtLT48ZyBpZD0iZmxpZ2h0c19kZXJpdmVkIiBjbGFzcz0ibm9kZSI+PHRpdGxlPmZsaWdodHNfZGVyaXZlZDwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iNy41LC0yMjEgNy41LC0yNDEgOTUuNSwtMjQxIDk1LjUsLTIyMSA3LjUsLTIyMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iOS4xMjEzIiB5PSItMjI2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzAwMDAwMCI+ZmxpZ2h0c19kZXJpdmVkPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iNy41LC0yMDEgNy41LC0yMjEgOTUuNSwtMjIxIDk1LjUsLTIwMSA3LjUsLTIwMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iOS41IiB5PSItMjA2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+b3JpZ2luPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iNy41LC0xODEgNy41LC0yMDEgOTUuNSwtMjAxIDk1LjUsLTE4MSA3LjUsLTE4MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iOS41IiB5PSItMTg2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+Y2FycmllcjwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iNi41LC0xODAgNi41LC0yNDIgOTYuNSwtMjQyIDk2LjUsLTE4MCA2LjUsLTE4MCI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHNfZGVyaXZlZCYjNDU7Jmd0O2FpcmxpbmVzIC0tPjxnIGlkPSJmbGlnaHRzX2Rlcml2ZWRfMSIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzX2Rlcml2ZWQ6Y2Fycmllci0mZ3Q7YWlybGluZXM6Y2FycmllcjwvdGl0bGU+CjxwYXRoIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgZD0iTTk1LjUsLTE5MUMxMjQuMjY5MSwtMTkxIDEzMy45MDU2LC0xOTEgMTU4LjM0LC0xOTEiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjE1OC41LC0xOTQuNTAwMSAxNjguNSwtMTkxIDE1OC41LC0xODcuNTAwMSAxNTguNSwtMTk0LjUwMDEiPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzX2Rlcml2ZWQmIzQ1OyZndDthaXJwb3J0cyAtLT48ZyBpZD0iZmxpZ2h0c19kZXJpdmVkXzIiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0c19kZXJpdmVkOm9yaWdpbi0mZ3Q7YWlycG9ydHM6ZmFhPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNOTUuNSwtMjExQzE2MS43Nzg4LC0yMTEgMTA0LjMxMzEsLTg1LjM3NjMgMTU3LjU0MDgsLTcyLjEyNjkiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjE1Ny45NTcsLTc1LjYwMjMgMTY3LjUsLTcxIDE1Ny4xNjk5LC02OC42NDY2IDE1Ny45NTcsLTc1LjYwMjMiPjwvcG9seWdvbj48L2c+PC9nPjwvc3ZnPg==)

### Use case 5: Joining tables

If you would like to join some or all of the columns of one table to
another, you can make use of one of the `..._join()` methods for a
`dm_keyed_tbl`. In many cases, using keyed tables derived from a `dm`
object allows omitting the `by` argument without triggering a message,
because they are safely inferred from the foreign keys stored in the
`dm_keyed_tbl` objects. For the syntax, please see the example below.

``` r
planes_for_join <-
  flights_keyed$planes %>%
  select(tailnum, plane_type = type)

joined_flights_tbl <-
  flights_keyed$flights %>%
  # let's first reduce the number of columns of flights
  select(-dep_delay:-arr_delay, -air_time:-minute, -starts_with("sched_")) %>%
  # in the {dm}-method for the joins you can specify which columns you want to
  # add to the subsetted table
  left_join(planes_for_join)

joined_flights_dm <- dm(
  flights_plane_type = joined_flights_tbl,
  !!!flights_keyed[c("airlines", "airports", "weather")]
)

# this is how the table looks now
joined_flights_dm$flights_plane_type
```

``` fansi
#> # A tibble: 1,761 × 11
#>     year month   day dep_time carrier flight tailnum origin dest 
#>    <int> <int> <int>    <int> <chr>    <int> <chr>   <chr>  <chr>
#>  1  2013     1    10        3 B6         727 N571JB  JFK    BQN  
#>  2  2013     1    10       16 B6         739 N564JB  JFK    PSE  
#>  3  2013     1    10      450 US        1117 N171US  EWR    CLT  
#>  4  2013     1    10      520 UA        1018 N35204  EWR    IAH  
#>  5  2013     1    10      530 UA         404 N815UA  LGA    IAH  
#>  6  2013     1    10      531 AA        1141 N5EAAA  JFK    MIA  
#>  7  2013     1    10      535 B6         725 N784JB  JFK    BQN  
#>  8  2013     1    10      546 B6         380 N337JB  EWR    BOS  
#>  9  2013     1    10      549 EV        6055 N19554  LGA    IAD  
#> 10  2013     1    10      550 US        2114 N740UW  LGA    BOS  
#> # ℹ 1,751 more rows
#> # ℹ 2 more variables: time_hour <dttm>, plane_type <chr>
```

``` r
# also here, the FK-relations are transferred to the new table
joined_flights_dm %>%
  dm_draw()
```

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjU3cHQiIGhlaWdodD0iMTcwcHQiIHZpZXdib3g9IjAuMDAgMC4wMCAyNTcuMDAgMTcwLjAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIj48ZyBpZD0iZ3JhcGgwIiBjbGFzcz0iZ3JhcGgiIHRyYW5zZm9ybT0ic2NhbGUoMSAxKSByb3RhdGUoMCkgdHJhbnNsYXRlKDQgMTY2KSI+PHRpdGxlPiUwPC90aXRsZT4KPGcgaWQ9ImFfZ3JhcGgwIj48YSB4bGluazp0aXRsZT0iRGF0YSBNb2RlbCI+Cjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iLTQsNCAtNCwtMTY2IDI1MywtMTY2IDI1Myw0IC00LDQiPjwvcG9seWdvbj48L2E+CjwvZz48IS0tIGFpcmxpbmVzIC0tPjxnIGlkPSJhaXJsaW5lcyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJsaW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTc1LjUsLTE0MSAxNzUuNSwtMTYxIDIyMC41LC0xNjEgMjIwLjUsLTE0MSAxNzUuNSwtMTQxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzcuMzk2OSIgeT0iLTE0Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiMwMDAwMDAiPmFpcmxpbmVzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTc1LjUsLTEyMSAxNzUuNSwtMTQxIDIyMC41LC0xNDEgMjIwLjUsLTEyMSAxNzUuNSwtMTIxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzcuNSIgeT0iLTEyNy40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5jYXJyaWVyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxNzQsLTEyMCAxNzQsLTE2MiAyMjEsLTE2MiAyMjEsLTEyMCAxNzQsLTEyMCI+PC9wb2x5Z29uPjwvZz48IS0tIGFpcnBvcnRzIC0tPjxnIGlkPSJhaXJwb3J0cyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJwb3J0czwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTc0LjUsLTgxIDE3NC41LC0xMDEgMjIwLjUsLTEwMSAyMjAuNSwtODEgMTc0LjUsLTgxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzYuMTE5MiIgeT0iLTg2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzAwMDAwMCI+YWlycG9ydHM8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNzQuNSwtNjEgMTc0LjUsLTgxIDIyMC41LC04MSAyMjAuNSwtNjEgMTc0LjUsLTYxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzYuNSIgeT0iLTY3LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmZhYTwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTczLjUsLTYwIDE3My41LC0xMDIgMjIxLjUsLTEwMiAyMjEuNSwtNjAgMTczLjUsLTYwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0c19wbGFuZV90eXBlIC0tPjxnIGlkPSJmbGlnaHRzX3BsYW5lX3R5cGUiIGNsYXNzPSJub2RlIj48dGl0bGU+ZmxpZ2h0c19wbGFuZV90eXBlPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iI2VmZWJkZCIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLC0xMTEgMSwtMTMxIDEwOSwtMTMxIDEwOSwtMTExIDEsLTExMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMi44OTkiIHk9Ii0xMTYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjMDAwMDAwIj5mbGlnaHRzX3BsYW5lX3R5cGU8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLC05MSAxLC0xMTEgMTA5LC0xMTEgMTA5LC05MSAxLC05MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMyIgeT0iLTk2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+Y2FycmllcjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEsLTcxIDEsLTkxIDEwOSwtOTEgMTA5LC03MSAxLC03MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMyIgeT0iLTc2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+b3JpZ2luPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMSwtNTEgMSwtNzEgMTA5LC03MSAxMDksLTUxIDEsLTUxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzIiB5PSItNTYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5kZXN0PC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMSwtMzEgMSwtNTEgMTA5LC01MSAxMDksLTMxIDEsLTMxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzIiB5PSItMzYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5vcmlnaW4sIHRpbWVfaG91cjwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMCwtMzAgMCwtMTMyIDExMCwtMTMyIDExMCwtMzAgMCwtMzAiPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzX3BsYW5lX3R5cGUmIzQ1OyZndDthaXJsaW5lcyAtLT48ZyBpZD0iZmxpZ2h0c19wbGFuZV90eXBlXzEiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0c19wbGFuZV90eXBlOmNhcnJpZXItJmd0O2FpcmxpbmVzOmNhcnJpZXI8L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik0xMDksLTEwMUMxMzcuNjI0MiwtMTAxIDE0Mi4yNjYzLC0xMjQuMzgwNyAxNjUuMjY5NywtMTI5Ljg2MDYiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjE2NS4xNzQsLTEzMy4zNzE1IDE3NS41LC0xMzEgMTY1Ljk0ODksLTEyNi40MTQ1IDE2NS4xNzQsLTEzMy4zNzE1Ij48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0c19wbGFuZV90eXBlJiM0NTsmZ3Q7YWlycG9ydHMgLS0+PGcgaWQ9ImZsaWdodHNfcGxhbmVfdHlwZV8yIiBjbGFzcz0iZWRnZSI+PHRpdGxlPmZsaWdodHNfcGxhbmVfdHlwZTpvcmlnaW4tJmd0O2FpcnBvcnRzOmZhYTwvdGl0bGU+CjxwYXRoIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgZD0iTTEwOSwtODFDMTM0Ljc2NzQsLTgxIDE0My4wNDM4LC03My4zNDM4IDE2NC40Mzg1LC03MS40Mjk3IiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxNjQuNjU4NSwtNzQuOTIzNiAxNzQuNSwtNzEgMTY0LjM1OTcsLTY3LjkzIDE2NC42NTg1LC03NC45MjM2Ij48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0c19wbGFuZV90eXBlJiM0NTsmZ3Q7YWlycG9ydHMgLS0+PGcgaWQ9ImZsaWdodHNfcGxhbmVfdHlwZV8zIiBjbGFzcz0iZWRnZSI+PHRpdGxlPmZsaWdodHNfcGxhbmVfdHlwZTpkZXN0LSZndDthaXJwb3J0czpmYWE8L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik0xMDksLTYxQzEzNC43Njc0LC02MSAxNDMuMDQzOCwtNjguNjU2MyAxNjQuNDM4NSwtNzAuNTcwMyIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTY0LjM1OTcsLTc0LjA3IDE3NC41LC03MSAxNjQuNjU4NSwtNjcuMDc2NCAxNjQuMzU5NywtNzQuMDciPjwvcG9seWdvbj48L2c+PCEtLSB3ZWF0aGVyIC0tPjxnIGlkPSJ3ZWF0aGVyIiBjbGFzcz0ibm9kZSI+PHRpdGxlPndlYXRoZXI8L3RpdGxlPgo8cG9seWdvbiBmaWxsPSIjZWZlYmRkIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE0Ny41LC0yMSAxNDcuNSwtNDEgMjQ4LjUsLTQxIDI0OC41LC0yMSAxNDcuNSwtMjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE3NS44NDkyIiB5PSItMjYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjMDAwMDAwIj53ZWF0aGVyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTQ3LjUsLTEgMTQ3LjUsLTIxIDI0OC41LC0yMSAyNDguNSwtMSAxNDcuNSwtMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTQ5LjAwNTYiIHk9Ii03LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPm9yaWdpbiwgdGltZV9ob3VyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxNDYsMCAxNDYsLTQyIDI0OSwtNDIgMjQ5LDAgMTQ2LDAiPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzX3BsYW5lX3R5cGUmIzQ1OyZndDt3ZWF0aGVyIC0tPjxnIGlkPSJmbGlnaHRzX3BsYW5lX3R5cGVfNCIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzX3BsYW5lX3R5cGU6b3JpZ2luLCB0aW1lX2hvdXItJmd0O3dlYXRoZXI6b3JpZ2luLCB0aW1lX2hvdXI8L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik0xMDksLTQxQzEyNi42MjUyLC00MSAxMjYuNzA1LC0yMS4xOTUzIDEzNy43NTA3LC0xMy43Njg2IiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxMzguODM2NSwtMTcuMDk4NyAxNDcuNSwtMTEgMTM2LjkyNDIsLTEwLjM2NDkgMTM4LjgzNjUsLTE3LjA5ODciPjwvcG9seWdvbj48L2c+PC9nPjwvc3ZnPg==)

### Use case 6: Retrieve all tables

Retrieving all tables from a `dm` object requires a lot of boilerplate
code. The
[`dm_deconstruct()`](https://dm.cynkra.com/dev/reference/dm_deconstruct.md)
function helps creating that boilerplate. For a `dm` object, it prints
the code necessary to create local variables for all tables.

``` r
dm <- dm_nycflights13()
dm_deconstruct(dm)
#> airlines <- pull_tbl(dm, "airlines", keyed = TRUE)
#> airports <- pull_tbl(dm, "airports", keyed = TRUE)
#> flights <- pull_tbl(dm, "flights", keyed = TRUE)
#> planes <- pull_tbl(dm, "planes", keyed = TRUE)
#> weather <- pull_tbl(dm, "weather", keyed = TRUE)
```

This code can be copy-pasted into your script or function.
