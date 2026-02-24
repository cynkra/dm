# Zooming and manipulating tables

This vignette deals with situations where you want to transform tables
of your `dm` and then update an existing table or add a new table to the
`dm`. There are two straightforward approaches:

1.  extract the tables relevant to the calculation, perform the
    necessary transformations, and (if needed) recombine the resulting
    table into a `dm`,
2.  do all this within the `dm` object by zooming to a table and
    manipulating it while maintaining the key relations whenever
    possible.

Both approaches aim at maintaining the key relations whenever possible.
We will explore the second approach here. For the first approach, see
[`vignette("tech-dm-zoom")`](https://dm.cynkra.com/articles/tech-dm-zoom.md).

## Enabling {dplyr}-workflow within a `dm`

“Zooming” to a table of a `dm` means:

- all information stored in the original `dm` is kept, including the
  originally zoomed table
- an object of class `dm_zoomed` is produced, presenting a view of the
  table for transformations
- you do not need to specify the table when calling
  [`select()`](https://dplyr.tidyverse.org/reference/select.html),
  [`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html) and
  other table manipulation functions

{dm} provides methods for many of the {dplyr}-verbs for a `dm_zoomed`
which behave the way you are used to, affecting only the zoomed table
and leaving the rest of the `dm` untouched. When you are finished with
transforming the table, there are three options to proceed:

1.  use
    [`dm_update_zoomed()`](https://dm.cynkra.com/reference/dm_zoom_to.md)
    if you want to replace the originally zoomed table with the new
    table
2.  use
    [`dm_insert_zoomed()`](https://dm.cynkra.com/reference/dm_zoom_to.md)
    if you are creating a new table for your `dm`
3.  use
    [`dm_discard_zoomed()`](https://dm.cynkra.com/reference/dm_zoom_to.md)
    if you do not need the result and want to discard it

When employing one of the first two options, the resulting table in the
`dm` will have all the primary and foreign keys available that could be
tracked from the originally zoomed table.

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
flights_dm <- dm_nycflights13()
flights_dm
```

``` fansi
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#> Columns: 53
#> Primary keys: 4
#> Foreign keys: 4
```

``` r
flights_zoomed <-
  flights_dm %>%
  dm_zoom_to(flights)
# The print output for a `dm_zoomed` looks very much like that from a normal `tibble`.
flights_zoomed
```

``` fansi
#> # Zoomed table: flights
#> # A tibble:     1,761 × 19
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

flights_zoomed_mutate <-
  flights_zoomed %>%
  mutate(am_pm_dep = if_else(dep_time < 1200, "am", "pm")) %>%
  # in order to see our changes in the output we use `select()` for reordering the columns
  select(year:dep_time, am_pm_dep, everything())

flights_zoomed_mutate
```

``` fansi
#> # Zoomed table: flights
#> # A tibble:     1,761 × 20
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

``` r

# To update the original `dm` with a new `flights` table we use `dm_update_zoomed()`:
updated_flights_dm <-
  flights_zoomed_mutate %>%
  dm_update_zoomed()
# The only difference in the `dm` print output is the increased number of columns
updated_flights_dm
```

``` fansi
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#> Columns: 54
#> Primary keys: 4
#> Foreign keys: 4
```

``` r
# The schematic view of the data model remains unchanged
dm_draw(updated_flights_dm)
```

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjUwcHQiIGhlaWdodD0iMjMwcHQiIHZpZXdib3g9IjAuMDAgMC4wMCAyNTAuMDAgMjMwLjAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIj48ZyBpZD0iZ3JhcGgwIiBjbGFzcz0iZ3JhcGgiIHRyYW5zZm9ybT0ic2NhbGUoMSAxKSByb3RhdGUoMCkgdHJhbnNsYXRlKDQgMjI2KSI+PHRpdGxlPiUwPC90aXRsZT4KPGcgaWQ9ImFfZ3JhcGgwIj48YSB4bGluazp0aXRsZT0iRGF0YSBNb2RlbCI+Cjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iLTQsNCAtNCwtMjI2IDI0NiwtMjI2IDI0Niw0IC00LDQiPjwvcG9seWdvbj48L2E+CjwvZz48IS0tIGFpcmxpbmVzIC0tPjxnIGlkPSJhaXJsaW5lcyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJsaW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZDdkMzEiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY4LjUsLTIwMSAxNjguNSwtMjIxIDIxMy41LC0yMjEgMjEzLjUsLTIwMSAxNjguNSwtMjAxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzAuMzk2OSIgeT0iLTIwNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiNmZmZmZmYiPmFpcmxpbmVzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmYmU1ZDUiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY4LjUsLTE4MSAxNjguNSwtMjAxIDIxMy41LC0yMDEgMjEzLjUsLTE4MSAxNjguNSwtMTgxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzAuNSIgeT0iLTE4Ny40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5jYXJyaWVyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzllNTMyMCIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjE2NywtMTgwIDE2NywtMjIyIDIxNCwtMjIyIDIxNCwtMTgwIDE2NywtMTgwIj48L3BvbHlnb24+PC9nPjwhLS0gYWlycG9ydHMgLS0+PGcgaWQ9ImFpcnBvcnRzIiBjbGFzcz0ibm9kZSI+PHRpdGxlPmFpcnBvcnRzPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iI2VkN2QzMSIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNjcuNSwtODEgMTY3LjUsLTEwMSAyMTMuNSwtMTAxIDIxMy41LC04MSAxNjcuNSwtODEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE2OS4xMTkyIiB5PSItODYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjZmZmZmZmIj5haXJwb3J0czwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmJlNWQ1IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE2Ny41LC02MSAxNjcuNSwtODEgMjEzLjUsLTgxIDIxMy41LC02MSAxNjcuNSwtNjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE2OS41IiB5PSItNjcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+ZmFhPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzllNTMyMCIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjE2Ni41LC02MCAxNjYuNSwtMTAyIDIxNC41LC0xMDIgMjE0LjUsLTYwIDE2Ni41LC02MCI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMgLS0+PGcgaWQ9ImZsaWdodHMiIGNsYXNzPSJub2RlIj48dGl0bGU+ZmxpZ2h0czwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiM1YjliZDUiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC0xNDEgMS41LC0xNjEgMTAyLjUsLTE2MSAxMDIuNSwtMTQxIDEuNSwtMTQxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzNC4xMTE1IiB5PSItMTQ2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iI2ZmZmZmZiI+ZmxpZ2h0czwvdGV4dD48cG9seWdvbiBmaWxsPSIjZGVlYmY2IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtMTIxIDEuNSwtMTQxIDEwMi41LC0xNDEgMTAyLjUsLTEyMSAxLjUsLTEyMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMy41IiB5PSItMTI2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+Y2FycmllcjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZGVlYmY2IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtMTAxIDEuNSwtMTIxIDEwMi41LC0xMjEgMTAyLjUsLTEwMSAxLjUsLTEwMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMy41IiB5PSItMTA2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+dGFpbG51bTwvdGV4dD48cG9seWdvbiBmaWxsPSIjZGVlYmY2IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtODEgMS41LC0xMDEgMTAyLjUsLTEwMSAxMDIuNSwtODEgMS41LC04MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMy41IiB5PSItODYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5vcmlnaW48L3RleHQ+PHBvbHlnb24gZmlsbD0iI2RlZWJmNiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLjUsLTYxIDEuNSwtODEgMTAyLjUsLTgxIDEwMi41LC02MSAxLjUsLTYxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzLjAwNTYiIHk9Ii02Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPm9yaWdpbiwgdGltZV9ob3VyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzNjNjc4ZSIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjAsLTYwIDAsLTE2MiAxMDMsLTE2MiAxMDMsLTYwIDAsLTYwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O2FpcmxpbmVzIC0tPjxnIGlkPSJmbGlnaHRzXzEiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czpjYXJyaWVyLSZndDthaXJsaW5lczpjYXJyaWVyPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTAyLjUsLTEzMUMxMjYuNTY2OCwtMTMxIDEyMC44MDI5LC0xNTUuMjQ5NiAxMzksLTE3MSAxNDcuNzk1NiwtMTc4LjYxMyAxNTEuMDM5NCwtMTg1LjgzMDUgMTU4LjQxNTcsLTE4OS4xMjc3IiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxNTguMDI5MSwtMTkyLjYxNTcgMTY4LjUsLTE5MSAxNTkuMzA3LC0xODUuNzMzMyAxNTguMDI5MSwtMTkyLjYxNTciPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzJiM0NTsmZ3Q7YWlycG9ydHMgLS0+PGcgaWQ9ImZsaWdodHNfMiIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOm9yaWdpbi0mZ3Q7YWlycG9ydHM6ZmFhPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTAyLjUsLTkxQzEyOC45NDczLC05MSAxMzUuNzM2MSwtNzUuNjg3NSAxNTcuMjY4NywtNzEuODU5NCIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTU3LjgyODEsLTc1LjMyNDggMTY3LjUsLTcxIDE1Ny4yNDIxLC02OC4zNDk0IDE1Ny44MjgxLC03NS4zMjQ4Ij48L3BvbHlnb24+PC9nPjwhLS0gcGxhbmVzIC0tPjxnIGlkPSJwbGFuZXMiIGNsYXNzPSJub2RlIj48dGl0bGU+cGxhbmVzPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iI2VkN2QzMSIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNjcuNSwtMTQxIDE2Ny41LC0xNjEgMjEzLjUsLTE2MSAyMTMuNSwtMTQxIDE2Ny41LC0xNDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE3Mi42MTc4IiB5PSItMTQ2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iI2ZmZmZmZiI+cGxhbmVzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmYmU1ZDUiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY3LjUsLTEyMSAxNjcuNSwtMTQxIDIxMy41LC0xNDEgMjEzLjUsLTEyMSAxNjcuNSwtMTIxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNjkuMTExNSIgeT0iLTEyNy40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij50YWlsbnVtPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzllNTMyMCIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjE2Ni41LC0xMjAgMTY2LjUsLTE2MiAyMTQuNSwtMTYyIDIxNC41LC0xMjAgMTY2LjUsLTEyMCI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMmIzQ1OyZndDtwbGFuZXMgLS0+PGcgaWQ9ImZsaWdodHNfMyIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOnRhaWxudW0tJmd0O3BsYW5lczp0YWlsbnVtPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTAyLjUsLTExMUMxMjguOTQ3MywtMTExIDEzNS43MzYxLC0xMjYuMzEyNSAxNTcuMjY4NywtMTMwLjE0MDYiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjE1Ny4yNDIxLC0xMzMuNjUwNiAxNjcuNSwtMTMxIDE1Ny44MjgxLC0xMjYuNjc1MiAxNTcuMjQyMSwtMTMzLjY1MDYiPjwvcG9seWdvbj48L2c+PCEtLSB3ZWF0aGVyIC0tPjxnIGlkPSJ3ZWF0aGVyIiBjbGFzcz0ibm9kZSI+PHRpdGxlPndlYXRoZXI8L3RpdGxlPgo8cG9seWdvbiBmaWxsPSIjNzBhZDQ3IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE0MC41LC0yMSAxNDAuNSwtNDEgMjQxLjUsLTQxIDI0MS41LC0yMSAxNDAuNSwtMjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE2OC44NDkyIiB5PSItMjYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjZmZmZmZmIj53ZWF0aGVyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNlMmVlZGEiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTQwLjUsLTEgMTQwLjUsLTIxIDI0MS41LC0yMSAyNDEuNSwtMSAxNDAuNSwtMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTQyLjAwNTYiIHk9Ii03LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPm9yaWdpbiwgdGltZV9ob3VyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzRhNzMyZiIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjEzOSwwIDEzOSwtNDIgMjQyLC00MiAyNDIsMCAxMzksMCI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMmIzQ1OyZndDt3ZWF0aGVyIC0tPjxnIGlkPSJmbGlnaHRzXzQiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czpvcmlnaW4sIHRpbWVfaG91ci0mZ3Q7d2VhdGhlcjpvcmlnaW4sIHRpbWVfaG91cjwvdGl0bGU+CjxwYXRoIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgZD0iTTEwMi41LC03MUMxMjkuODcyNywtNzEgMTE0LjYxMDEsLTI1Ljg3OTIgMTMwLjY1NzksLTEzLjg5MzkiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjEzMS44OTM1LC0xNy4xNzg5IDE0MC41LC0xMSAxMjkuOTE4OCwtMTAuNDYzMSAxMzEuODkzNSwtMTcuMTc4OSI+PC9wb2x5Z29uPjwvZz48L2c+PC9zdmc+)

### Use case 2: Creation of a surrogate key

The same course of action could, for example, be employed to create a
surrogate key for a table, a synthetic simple key that replaces a
compound key. We can do this for the `weather` table.

``` r
library(tidyr)

weather_zoomed <-
  flights_dm %>%
  dm_zoom_to(weather)
weather_zoomed
```

``` fansi
#> # Zoomed table: weather
#> # A tibble:     144 × 15
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
# Maybe there is some hidden candidate for a primary key that we overlooked
enum_pk_candidates(weather_zoomed)
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
weather_zoomed_mutate <-
  weather_zoomed %>%
  # first convert all times to the same time zone:
  mutate(time_hour_fmt = format(time_hour, tz = "UTC")) %>%
  # paste together as character the airport code and the time
  unite("origin_slot_id", origin, time_hour_fmt) %>%
  select(origin_slot_id, everything())
# check if we the result is as expected:
enum_pk_candidates(weather_zoomed_mutate) %>% filter(candidate)
```

``` fansi
#> # A tibble: 1 × 3
#>   columns        candidate why  
#>   <keys>         <lgl>     <chr>
#> 1 origin_slot_id TRUE      ""
```

``` r
flights_upd_weather_dm <-
  weather_zoomed_mutate %>%
  dm_update_zoomed() %>%
  dm_add_pk(weather, origin_slot_id)
flights_upd_weather_dm
```

``` fansi
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#> Columns: 53
#> Primary keys: 4
#> Foreign keys: 3
```

``` r
# creating the coveted FK relation between `flights` and `weather`
extended_flights_dm <-
  flights_upd_weather_dm %>%
  dm_zoom_to(flights) %>%
  mutate(time_hour_fmt = format(time_hour, tz = "UTC")) %>%
  # need to keep `origin` as FK to airports, so `remove = FALSE`
  unite("origin_slot_id", origin, time_hour_fmt, remove = FALSE) %>%
  dm_update_zoomed() %>%
  dm_add_fk(flights, origin_slot_id, weather)
extended_flights_dm %>% dm_draw()
```

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjEycHQiIGhlaWdodD0iMjMwcHQiIHZpZXdib3g9IjAuMDAgMC4wMCAyMTIuMDAgMjMwLjAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIj48ZyBpZD0iZ3JhcGgwIiBjbGFzcz0iZ3JhcGgiIHRyYW5zZm9ybT0ic2NhbGUoMSAxKSByb3RhdGUoMCkgdHJhbnNsYXRlKDQgMjI2KSI+PHRpdGxlPiUwPC90aXRsZT4KPGcgaWQ9ImFfZ3JhcGgwIj48YSB4bGluazp0aXRsZT0iRGF0YSBNb2RlbCI+Cjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iLTQsNCAtNCwtMjI2IDIwOCwtMjI2IDIwOCw0IC00LDQiPjwvcG9seWdvbj48L2E+CjwvZz48IS0tIGFpcmxpbmVzIC0tPjxnIGlkPSJhaXJsaW5lcyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJsaW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZDdkMzEiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTQwLC0yMDEgMTQwLC0yMjEgMTg1LC0yMjEgMTg1LC0yMDEgMTQwLC0yMDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE0MS44OTY5IiB5PSItMjA2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iI2ZmZmZmZiI+YWlybGluZXM8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZiZTVkNSIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNDAsLTE4MSAxNDAsLTIwMSAxODUsLTIwMSAxODUsLTE4MSAxNDAsLTE4MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTQyIiB5PSItMTg3LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmNhcnJpZXI8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjOWU1MzIwIiBzdHJva2Utb3BhY2l0eT0iMC42NjY2NjciIHBvaW50cz0iMTM4LjUsLTE4MCAxMzguNSwtMjIyIDE4NS41LC0yMjIgMTg1LjUsLTE4MCAxMzguNSwtMTgwIj48L3BvbHlnb24+PC9nPjwhLS0gYWlycG9ydHMgLS0+PGcgaWQ9ImFpcnBvcnRzIiBjbGFzcz0ibm9kZSI+PHRpdGxlPmFpcnBvcnRzPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iI2VkN2QzMSIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxMzksLTIxIDEzOSwtNDEgMTg1LC00MSAxODUsLTIxIDEzOSwtMjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE0MC42MTkyIiB5PSItMjYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjZmZmZmZmIj5haXJwb3J0czwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmJlNWQ1IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEzOSwtMSAxMzksLTIxIDE4NSwtMjEgMTg1LC0xIDEzOSwtMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTQxIiB5PSItNy40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5mYWE8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjOWU1MzIwIiBzdHJva2Utb3BhY2l0eT0iMC42NjY2NjciIHBvaW50cz0iMTM4LDAgMTM4LC00MiAxODYsLTQyIDE4NiwwIDEzOCwwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyAtLT48ZyBpZD0iZmxpZ2h0cyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5mbGlnaHRzPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iIzViOWJkNSIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLC0xNDEgMSwtMTYxIDgzLC0xNjEgODMsLTE0MSAxLC0xNDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjI0LjExMTUiIHk9Ii0xNDYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjZmZmZmZmIj5mbGlnaHRzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNkZWViZjYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMSwtMTIxIDEsLTE0MSA4MywtMTQxIDgzLC0xMjEgMSwtMTIxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzIiB5PSItMTI2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+Y2FycmllcjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZGVlYmY2IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEsLTEwMSAxLC0xMjEgODMsLTEyMSA4MywtMTAxIDEsLTEwMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMyIgeT0iLTEwNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPnRhaWxudW08L3RleHQ+PHBvbHlnb24gZmlsbD0iI2RlZWJmNiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLC04MSAxLC0xMDEgODMsLTEwMSA4MywtODEgMSwtODEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjIuNzIwOSIgeT0iLTg2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+b3JpZ2luX3Nsb3RfaWQ8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2RlZWJmNiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLC02MSAxLC04MSA4MywtODEgODMsLTYxIDEsLTYxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzIiB5PSItNjYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5vcmlnaW48L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjM2M2NzhlIiBzdHJva2Utb3BhY2l0eT0iMC42NjY2NjciIHBvaW50cz0iMCwtNjAgMCwtMTYyIDg0LC0xNjIgODQsLTYwIDAsLTYwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O2FpcmxpbmVzIC0tPjxnIGlkPSJmbGlnaHRzXzEiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czpjYXJyaWVyLSZndDthaXJsaW5lczpjYXJyaWVyPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNODMsLTEzMUMxMTUuOTAyMywtMTMxIDEwNi4xMTg4LC0xNzkuMDExMiAxMzAuMDE3MSwtMTg5LjEzODUiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjEyOS41Mjc4LC0xOTIuNjA3NiAxNDAsLTE5MSAxMzAuODExLC0xODUuNzI2MiAxMjkuNTI3OCwtMTkyLjYwNzYiPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzJiM0NTsmZ3Q7YWlycG9ydHMgLS0+PGcgaWQ9ImZsaWdodHNfMiIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOm9yaWdpbi0mZ3Q7YWlycG9ydHM6ZmFhPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNODMsLTcxQzExNS42Mjk4LC03MSAxMDUuNTA0OSwtMjIuOTg4OCAxMjkuMTE2MSwtMTIuODYxNSIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTI5LjgyMDYsLTE2LjI5MDQgMTM5LC0xMSAxMjguNTI1LC05LjQxMTQgMTI5LjgyMDYsLTE2LjI5MDQiPjwvcG9seWdvbj48L2c+PCEtLSBwbGFuZXMgLS0+PGcgaWQ9InBsYW5lcyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5wbGFuZXM8L3RpdGxlPgo8cG9seWdvbiBmaWxsPSIjZWQ3ZDMxIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEzOSwtMTQxIDEzOSwtMTYxIDE4NSwtMTYxIDE4NSwtMTQxIDEzOSwtMTQxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNDQuMTE3OCIgeT0iLTE0Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiNmZmZmZmYiPnBsYW5lczwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmJlNWQ1IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEzOSwtMTIxIDEzOSwtMTQxIDE4NSwtMTQxIDE4NSwtMTIxIDEzOSwtMTIxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNDAuNjExNSIgeT0iLTEyNy40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij50YWlsbnVtPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzllNTMyMCIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjEzOCwtMTIwIDEzOCwtMTYyIDE4NiwtMTYyIDE4NiwtMTIwIDEzOCwtMTIwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O3BsYW5lcyAtLT48ZyBpZD0iZmxpZ2h0c18zIiBjbGFzcz0iZWRnZSI+PHRpdGxlPmZsaWdodHM6dGFpbG51bS0mZ3Q7cGxhbmVzOnRhaWxudW08L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik04MywtMTExQzEwNS41MDU2LC0xMTEgMTExLjEyNTMsLTEyNS41MDMyIDEyOC42MTc5LC0xMjkuODA4OCIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTI4LjY2NjIsLTEzMy4zMzcyIDEzOSwtMTMxIDEyOS40NjQyLC0xMjYuMzgyOCAxMjguNjY2MiwtMTMzLjMzNzIiPjwvcG9seWdvbj48L2c+PCEtLSB3ZWF0aGVyIC0tPjxnIGlkPSJ3ZWF0aGVyIiBjbGFzcz0ibm9kZSI+PHRpdGxlPndlYXRoZXI8L3RpdGxlPgo8cG9seWdvbiBmaWxsPSIjNzBhZDQ3IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEyMSwtODEgMTIxLC0xMDEgMjAzLC0xMDEgMjAzLC04MSAxMjEsLTgxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxMzkuODQ5MiIgeT0iLTg2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iI2ZmZmZmZiI+d2VhdGhlcjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZTJlZWRhIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEyMSwtNjEgMTIxLC04MSAyMDMsLTgxIDIwMywtNjEgMTIxLC02MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTIyLjcyMDkiIHk9Ii02Ny40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5vcmlnaW5fc2xvdF9pZDwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM0YTczMmYiIHN0cm9rZS1vcGFjaXR5PSIwLjY2NjY2NyIgcG9pbnRzPSIxMjAsLTYwIDEyMCwtMTAyIDIwNCwtMTAyIDIwNCwtNjAgMTIwLC02MCI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMmIzQ1OyZndDt3ZWF0aGVyIC0tPjxnIGlkPSJmbGlnaHRzXzQiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czpvcmlnaW5fc2xvdF9pZC0mZ3Q7d2VhdGhlcjpvcmlnaW5fc2xvdF9pZDwvdGl0bGU+CjxwYXRoIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgZD0iTTgzLC05MUM5OC4wNTk1LC05MSAxMDEuMTI5OSwtNzguNTQ3NiAxMTEuMTMxNSwtNzMuMjk0MyIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTEyLjA1MjMsLTc2LjY3MzYgMTIxLC03MSAxMTAuNDY3MiwtNjkuODU1NCAxMTIuMDUyMywtNzYuNjczNiI+PC9wb2x5Z29uPjwvZz48L2c+PC9zdmc+)

### Use case 3: Disentangle `dm`

If you look at the `dm` created by `dm_nycflights13(cycle = TRUE)`, you
see that two columns of `flights` relate to one and the same table,
`airports`. One column stands for the departure airport and the other
for the arrival airport.

``` r
dm_draw(dm_nycflights13(cycle = TRUE))
```

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjUwcHQiIGhlaWdodD0iMjMwcHQiIHZpZXdib3g9IjAuMDAgMC4wMCAyNTAuMDAgMjMwLjAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIj48ZyBpZD0iZ3JhcGgwIiBjbGFzcz0iZ3JhcGgiIHRyYW5zZm9ybT0ic2NhbGUoMSAxKSByb3RhdGUoMCkgdHJhbnNsYXRlKDQgMjI2KSI+PHRpdGxlPiUwPC90aXRsZT4KPGcgaWQ9ImFfZ3JhcGgwIj48YSB4bGluazp0aXRsZT0iRGF0YSBNb2RlbCI+Cjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iLTQsNCAtNCwtMjI2IDI0NiwtMjI2IDI0Niw0IC00LDQiPjwvcG9seWdvbj48L2E+CjwvZz48IS0tIGFpcmxpbmVzIC0tPjxnIGlkPSJhaXJsaW5lcyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJsaW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZDdkMzEiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY4LjUsLTIwMSAxNjguNSwtMjIxIDIxMy41LC0yMjEgMjEzLjUsLTIwMSAxNjguNSwtMjAxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzAuMzk2OSIgeT0iLTIwNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiNmZmZmZmYiPmFpcmxpbmVzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmYmU1ZDUiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY4LjUsLTE4MSAxNjguNSwtMjAxIDIxMy41LC0yMDEgMjEzLjUsLTE4MSAxNjguNSwtMTgxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzAuNSIgeT0iLTE4Ny40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5jYXJyaWVyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzllNTMyMCIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjE2NywtMTgwIDE2NywtMjIyIDIxNCwtMjIyIDIxNCwtMTgwIDE2NywtMTgwIj48L3BvbHlnb24+PC9nPjwhLS0gYWlycG9ydHMgLS0+PGcgaWQ9ImFpcnBvcnRzIiBjbGFzcz0ibm9kZSI+PHRpdGxlPmFpcnBvcnRzPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iI2VkN2QzMSIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNjcuNSwtODEgMTY3LjUsLTEwMSAyMTMuNSwtMTAxIDIxMy41LC04MSAxNjcuNSwtODEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE2OS4xMTkyIiB5PSItODYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjZmZmZmZmIj5haXJwb3J0czwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmJlNWQ1IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE2Ny41LC02MSAxNjcuNSwtODEgMjEzLjUsLTgxIDIxMy41LC02MSAxNjcuNSwtNjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE2OS41IiB5PSItNjcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+ZmFhPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzllNTMyMCIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjE2Ni41LC02MCAxNjYuNSwtMTAyIDIxNC41LC0xMDIgMjE0LjUsLTYwIDE2Ni41LC02MCI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMgLS0+PGcgaWQ9ImZsaWdodHMiIGNsYXNzPSJub2RlIj48dGl0bGU+ZmxpZ2h0czwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiM1YjliZDUiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC0xNDEgMS41LC0xNjEgMTAyLjUsLTE2MSAxMDIuNSwtMTQxIDEuNSwtMTQxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzNC4xMTE1IiB5PSItMTQ2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iI2ZmZmZmZiI+ZmxpZ2h0czwvdGV4dD48cG9seWdvbiBmaWxsPSIjZGVlYmY2IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtMTIxIDEuNSwtMTQxIDEwMi41LC0xNDEgMTAyLjUsLTEyMSAxLjUsLTEyMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMy41IiB5PSItMTI2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+Y2FycmllcjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZGVlYmY2IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtMTAxIDEuNSwtMTIxIDEwMi41LC0xMjEgMTAyLjUsLTEwMSAxLjUsLTEwMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMy41IiB5PSItMTA2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+dGFpbG51bTwvdGV4dD48cG9seWdvbiBmaWxsPSIjZGVlYmY2IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtODEgMS41LC0xMDEgMTAyLjUsLTEwMSAxMDIuNSwtODEgMS41LC04MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMy41IiB5PSItODYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5vcmlnaW48L3RleHQ+PHBvbHlnb24gZmlsbD0iI2RlZWJmNiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLjUsLTYxIDEuNSwtODEgMTAyLjUsLTgxIDEwMi41LC02MSAxLjUsLTYxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzLjUiIHk9Ii02Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmRlc3Q8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2RlZWJmNiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLjUsLTQxIDEuNSwtNjEgMTAyLjUsLTYxIDEwMi41LC00MSAxLjUsLTQxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzLjAwNTYiIHk9Ii00Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPm9yaWdpbiwgdGltZV9ob3VyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzNjNjc4ZSIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjAsLTQwIDAsLTE2MiAxMDMsLTE2MiAxMDMsLTQwIDAsLTQwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O2FpcmxpbmVzIC0tPjxnIGlkPSJmbGlnaHRzXzEiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czpjYXJyaWVyLSZndDthaXJsaW5lczpjYXJyaWVyPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTAyLjUsLTEzMUMxMjYuNTY2OCwtMTMxIDEyMC44MDI5LC0xNTUuMjQ5NiAxMzksLTE3MSAxNDcuNzk1NiwtMTc4LjYxMyAxNTEuMDM5NCwtMTg1LjgzMDUgMTU4LjQxNTcsLTE4OS4xMjc3IiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxNTguMDI5MSwtMTkyLjYxNTcgMTY4LjUsLTE5MSAxNTkuMzA3LC0xODUuNzMzMyAxNTguMDI5MSwtMTkyLjYxNTciPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzJiM0NTsmZ3Q7YWlycG9ydHMgLS0+PGcgaWQ9ImZsaWdodHNfMiIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOm9yaWdpbi0mZ3Q7YWlycG9ydHM6ZmFhPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTAyLjUsLTkxQzEyOC45NDczLC05MSAxMzUuNzM2MSwtNzUuNjg3NSAxNTcuMjY4NywtNzEuODU5NCIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTU3LjgyODEsLTc1LjMyNDggMTY3LjUsLTcxIDE1Ny4yNDIxLC02OC4zNDk0IDE1Ny44MjgxLC03NS4zMjQ4Ij48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O2FpcnBvcnRzIC0tPjxnIGlkPSJmbGlnaHRzXzMiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czpkZXN0LSZndDthaXJwb3J0czpmYWE8L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik0xMDIuNSwtNzFDMTI3LjY2NDksLTcxIDEzNi4zODkxLC03MSAxNTcuMzE1NCwtNzEiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjE1Ny41LC03NC41MDAxIDE2Ny41LC03MSAxNTcuNSwtNjcuNTAwMSAxNTcuNSwtNzQuNTAwMSI+PC9wb2x5Z29uPjwvZz48IS0tIHBsYW5lcyAtLT48ZyBpZD0icGxhbmVzIiBjbGFzcz0ibm9kZSI+PHRpdGxlPnBsYW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZDdkMzEiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY3LjUsLTE0MSAxNjcuNSwtMTYxIDIxMy41LC0xNjEgMjEzLjUsLTE0MSAxNjcuNSwtMTQxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzIuNjE3OCIgeT0iLTE0Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiNmZmZmZmYiPnBsYW5lczwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmJlNWQ1IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE2Ny41LC0xMjEgMTY3LjUsLTE0MSAyMTMuNSwtMTQxIDIxMy41LC0xMjEgMTY3LjUsLTEyMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTY5LjExMTUiIHk9Ii0xMjcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+dGFpbG51bTwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM5ZTUzMjAiIHN0cm9rZS1vcGFjaXR5PSIwLjY2NjY2NyIgcG9pbnRzPSIxNjYuNSwtMTIwIDE2Ni41LC0xNjIgMjE0LjUsLTE2MiAyMTQuNSwtMTIwIDE2Ni41LC0xMjAiPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzJiM0NTsmZ3Q7cGxhbmVzIC0tPjxnIGlkPSJmbGlnaHRzXzQiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czp0YWlsbnVtLSZndDtwbGFuZXM6dGFpbG51bTwvdGl0bGU+CjxwYXRoIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgZD0iTTEwMi41LC0xMTFDMTI4Ljk0NzMsLTExMSAxMzUuNzM2MSwtMTI2LjMxMjUgMTU3LjI2ODcsLTEzMC4xNDA2IiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxNTcuMjQyMSwtMTMzLjY1MDYgMTY3LjUsLTEzMSAxNTcuODI4MSwtMTI2LjY3NTIgMTU3LjI0MjEsLTEzMy42NTA2Ij48L3BvbHlnb24+PC9nPjwhLS0gd2VhdGhlciAtLT48ZyBpZD0id2VhdGhlciIgY2xhc3M9Im5vZGUiPjx0aXRsZT53ZWF0aGVyPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iIzcwYWQ0NyIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNDAuNSwtMjEgMTQwLjUsLTQxIDI0MS41LC00MSAyNDEuNSwtMjEgMTQwLjUsLTIxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNjguODQ5MiIgeT0iLTI2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iI2ZmZmZmZiI+d2VhdGhlcjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZTJlZWRhIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE0MC41LC0xIDE0MC41LC0yMSAyNDEuNSwtMjEgMjQxLjUsLTEgMTQwLjUsLTEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE0Mi4wMDU2IiB5PSItNy40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5vcmlnaW4sIHRpbWVfaG91cjwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM0YTczMmYiIHN0cm9rZS1vcGFjaXR5PSIwLjY2NjY2NyIgcG9pbnRzPSIxMzksMCAxMzksLTQyIDI0MiwtNDIgMjQyLDAgMTM5LDAiPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzJiM0NTsmZ3Q7d2VhdGhlciAtLT48ZyBpZD0iZmxpZ2h0c181IiBjbGFzcz0iZWRnZSI+PHRpdGxlPmZsaWdodHM6b3JpZ2luLCB0aW1lX2hvdXItJmd0O3dlYXRoZXI6b3JpZ2luLCB0aW1lX2hvdXI8L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik0xMDIuNSwtNTFDMTIyLjgwNjUsLTUxIDExOC43MjQxLC0yMy41Njg0IDEzMC42NDY5LC0xNC4xMzg3IiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxMzIuMDM0MSwtMTcuMzcwMiAxNDAuNSwtMTEgMTI5LjkwOTQsLTEwLjcwMDQgMTMyLjAzNDEsLTE3LjM3MDIiPjwvcG9seWdvbj48L2c+PC9nPjwvc3ZnPg==)

This generates a cycle which leads to failures with many operations that
only work on cycle-free data models, such as
[`dm_flatten_to_tbl()`](https://dm.cynkra.com/reference/dm_flatten_to_tbl.md),
[`dm_filter()`](https://dm.cynkra.com/reference/dm_filter.md) or
`dm_wrap_to_tbl()`. In such cases, it can be beneficial to “disentangle”
the `dm` by duplicating the referred table. One way to do this in the
{dm}-framework is as follows:

``` r
disentangled_flights_dm <-
  dm_nycflights13(cycle = TRUE) %>%
  # zooming and immediately inserting essentially creates a copy of the original table
  dm_zoom_to(airports) %>%
  # reinserting the `airports` table under the name `destination`
  dm_insert_zoomed("destination") %>%
  # renaming the originally zoomed table
  dm_rename_tbl(origin = airports) %>%
  # Key relations are also duplicated, so the wrong ones need to be removed
  dm_rm_fk(flights, dest, origin) %>%
  dm_rm_fk(flights, origin, destination)
dm_draw(disentangled_flights_dm)
```

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjUwcHQiIGhlaWdodD0iMjkwcHQiIHZpZXdib3g9IjAuMDAgMC4wMCAyNTAuMDAgMjkwLjAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIj48ZyBpZD0iZ3JhcGgwIiBjbGFzcz0iZ3JhcGgiIHRyYW5zZm9ybT0ic2NhbGUoMSAxKSByb3RhdGUoMCkgdHJhbnNsYXRlKDQgMjg2KSI+PHRpdGxlPiUwPC90aXRsZT4KPGcgaWQ9ImFfZ3JhcGgwIj48YSB4bGluazp0aXRsZT0iRGF0YSBNb2RlbCI+Cjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iLTQsNCAtNCwtMjg2IDI0NiwtMjg2IDI0Niw0IC00LDQiPjwvcG9seWdvbj48L2E+CjwvZz48IS0tIGFpcmxpbmVzIC0tPjxnIGlkPSJhaXJsaW5lcyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJsaW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZDdkMzEiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY4LjUsLTI2MSAxNjguNSwtMjgxIDIxMy41LC0yODEgMjEzLjUsLTI2MSAxNjguNSwtMjYxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzAuMzk2OSIgeT0iLTI2Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiNmZmZmZmYiPmFpcmxpbmVzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmYmU1ZDUiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY4LjUsLTI0MSAxNjguNSwtMjYxIDIxMy41LC0yNjEgMjEzLjUsLTI0MSAxNjguNSwtMjQxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzAuNSIgeT0iLTI0Ny40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5jYXJyaWVyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzllNTMyMCIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjE2NywtMjQwIDE2NywtMjgyIDIxNCwtMjgyIDIxNCwtMjQwIDE2NywtMjQwIj48L3BvbHlnb24+PC9nPjwhLS0gZGVzdGluYXRpb24gLS0+PGcgaWQ9ImRlc3RpbmF0aW9uIiBjbGFzcz0ibm9kZSI+PHRpdGxlPmRlc3RpbmF0aW9uPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iI2VkN2QzMSIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNTguNSwtODEgMTU4LjUsLTEwMSAyMjMuNSwtMTAxIDIyMy41LC04MSAxNTguNSwtODEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE2MC4yODE5IiB5PSItODYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjZmZmZmZmIj5kZXN0aW5hdGlvbjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmJlNWQ1IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE1OC41LC02MSAxNTguNSwtODEgMjIzLjUsLTgxIDIyMy41LC02MSAxNTguNSwtNjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE2MC41IiB5PSItNjcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+ZmFhPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzllNTMyMCIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjE1NywtNjAgMTU3LC0xMDIgMjI0LC0xMDIgMjI0LC02MCAxNTcsLTYwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyAtLT48ZyBpZD0iZmxpZ2h0cyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5mbGlnaHRzPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iIzViOWJkNSIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLjUsLTE4MSAxLjUsLTIwMSAxMDIuNSwtMjAxIDEwMi41LC0xODEgMS41LC0xODEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjM0LjExMTUiIHk9Ii0xODYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjZmZmZmZmIj5mbGlnaHRzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNkZWViZjYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC0xNjEgMS41LC0xODEgMTAyLjUsLTE4MSAxMDIuNSwtMTYxIDEuNSwtMTYxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzLjUiIHk9Ii0xNjYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5jYXJyaWVyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNkZWViZjYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC0xNDEgMS41LC0xNjEgMTAyLjUsLTE2MSAxMDIuNSwtMTQxIDEuNSwtMTQxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzLjUiIHk9Ii0xNDYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij50YWlsbnVtPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNkZWViZjYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC0xMjEgMS41LC0xNDEgMTAyLjUsLTE0MSAxMDIuNSwtMTIxIDEuNSwtMTIxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzLjUiIHk9Ii0xMjYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5vcmlnaW48L3RleHQ+PHBvbHlnb24gZmlsbD0iI2RlZWJmNiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLjUsLTEwMSAxLjUsLTEyMSAxMDIuNSwtMTIxIDEwMi41LC0xMDEgMS41LC0xMDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjMuNSIgeT0iLTEwNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmRlc3Q8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2RlZWJmNiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLjUsLTgxIDEuNSwtMTAxIDEwMi41LC0xMDEgMTAyLjUsLTgxIDEuNSwtODEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjMuMDA1NiIgeT0iLTg2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+b3JpZ2luLCB0aW1lX2hvdXI8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjM2M2NzhlIiBzdHJva2Utb3BhY2l0eT0iMC42NjY2NjciIHBvaW50cz0iMCwtODAgMCwtMjAyIDEwMywtMjAyIDEwMywtODAgMCwtODAiPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzJiM0NTsmZ3Q7YWlybGluZXMgLS0+PGcgaWQ9ImZsaWdodHNfMSIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOmNhcnJpZXItJmd0O2FpcmxpbmVzOmNhcnJpZXI8L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik0xMDIuNSwtMTcxQzEzMy43MTMzLC0xNzEgMTE3LjQ3OTEsLTIwOC4zOTIgMTM5LC0yMzEgMTQ3LjAyMDUsLTIzOS40MjU2IDE1MC42Mjc3LC0yNDYuMjYyMiAxNTguMjUxNywtMjQ5LjI5OTciIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjE1OC4wNjIsLTI1Mi44MTYgMTY4LjUsLTI1MSAxNTkuMjA3NywtMjQ1LjkxMDQgMTU4LjA2MiwtMjUyLjgxNiI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMmIzQ1OyZndDtkZXN0aW5hdGlvbiAtLT48ZyBpZD0iZmxpZ2h0c181IiBjbGFzcz0iZWRnZSI+PHRpdGxlPmZsaWdodHM6ZGVzdC0mZ3Q7ZGVzdGluYXRpb246ZmFhPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTAyLjUsLTExMUMxMjkuMjYyOCwtMTExIDEyOC42NDgzLC04MC4zNzUgMTQ4LjU2NjcsLTcyLjcxODgiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjE0OS4yNDMyLC03Ni4xNTM4IDE1OC41LC03MSAxNDguMDQ5NywtNjkuMjU2MyAxNDkuMjQzMiwtNzYuMTUzOCI+PC9wb2x5Z29uPjwvZz48IS0tIG9yaWdpbiAtLT48ZyBpZD0ib3JpZ2luIiBjbGFzcz0ibm9kZSI+PHRpdGxlPm9yaWdpbjwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZDdkMzEiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTcyLjUsLTE0MSAxNzIuNSwtMTYxIDIwOS41LC0xNjEgMjA5LjUsLTE0MSAxNzIuNSwtMTQxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzQuMjc5MSIgeT0iLTE0Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiNmZmZmZmYiPm9yaWdpbjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmJlNWQ1IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE3Mi41LC0xMjEgMTcyLjUsLTE0MSAyMDkuNSwtMTQxIDIwOS41LC0xMjEgMTcyLjUsLTEyMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTc0LjUiIHk9Ii0xMjcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+ZmFhPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzllNTMyMCIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjE3MSwtMTIwIDE3MSwtMTYyIDIxMCwtMTYyIDIxMCwtMTIwIDE3MSwtMTIwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O29yaWdpbiAtLT48ZyBpZD0iZmxpZ2h0c18yIiBjbGFzcz0iZWRnZSI+PHRpdGxlPmZsaWdodHM6b3JpZ2luLSZndDtvcmlnaW46ZmFhPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTAyLjUsLTEzMUMxMjkuOTY1MywtMTMxIDEzOS4yNDU1LC0xMzEgMTYyLjQ0ODcsLTEzMSIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTYyLjUsLTEzNC41MDAxIDE3Mi41LC0xMzEgMTYyLjUsLTEyNy41MDAxIDE2Mi41LC0xMzQuNTAwMSI+PC9wb2x5Z29uPjwvZz48IS0tIHBsYW5lcyAtLT48ZyBpZD0icGxhbmVzIiBjbGFzcz0ibm9kZSI+PHRpdGxlPnBsYW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZDdkMzEiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY3LjUsLTIwMSAxNjcuNSwtMjIxIDIxMy41LC0yMjEgMjEzLjUsLTIwMSAxNjcuNSwtMjAxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzIuNjE3OCIgeT0iLTIwNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiNmZmZmZmYiPnBsYW5lczwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmJlNWQ1IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE2Ny41LC0xODEgMTY3LjUsLTIwMSAyMTMuNSwtMjAxIDIxMy41LC0xODEgMTY3LjUsLTE4MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTY5LjExMTUiIHk9Ii0xODcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+dGFpbG51bTwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM5ZTUzMjAiIHN0cm9rZS1vcGFjaXR5PSIwLjY2NjY2NyIgcG9pbnRzPSIxNjYuNSwtMTgwIDE2Ni41LC0yMjIgMjE0LjUsLTIyMiAyMTQuNSwtMTgwIDE2Ni41LC0xODAiPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzJiM0NTsmZ3Q7cGxhbmVzIC0tPjxnIGlkPSJmbGlnaHRzXzMiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czp0YWlsbnVtLSZndDtwbGFuZXM6dGFpbG51bTwvdGl0bGU+CjxwYXRoIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgZD0iTTEwMi41LC0xNTFDMTMyLjU3ODIsLTE1MSAxMzMuNzUxMywtMTgyLjQ1MDggMTU3LjI4MDYsLTE4OS41NzY0IiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxNTcuMTEyNywtMTkzLjA4NjcgMTY3LjUsLTE5MSAxNTguMDc4NiwtMTg2LjE1MzcgMTU3LjExMjcsLTE5My4wODY3Ij48L3BvbHlnb24+PC9nPjwhLS0gd2VhdGhlciAtLT48ZyBpZD0id2VhdGhlciIgY2xhc3M9Im5vZGUiPjx0aXRsZT53ZWF0aGVyPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iIzcwYWQ0NyIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNDAuNSwtMjEgMTQwLjUsLTQxIDI0MS41LC00MSAyNDEuNSwtMjEgMTQwLjUsLTIxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNjguODQ5MiIgeT0iLTI2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iI2ZmZmZmZiI+d2VhdGhlcjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZTJlZWRhIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE0MC41LC0xIDE0MC41LC0yMSAyNDEuNSwtMjEgMjQxLjUsLTEgMTQwLjUsLTEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE0Mi4wMDU2IiB5PSItNy40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5vcmlnaW4sIHRpbWVfaG91cjwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM0YTczMmYiIHN0cm9rZS1vcGFjaXR5PSIwLjY2NjY2NyIgcG9pbnRzPSIxMzksMCAxMzksLTQyIDI0MiwtNDIgMjQyLDAgMTM5LDAiPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzJiM0NTsmZ3Q7d2VhdGhlciAtLT48ZyBpZD0iZmxpZ2h0c180IiBjbGFzcz0iZWRnZSI+PHRpdGxlPmZsaWdodHM6b3JpZ2luLCB0aW1lX2hvdXItJmd0O3dlYXRoZXI6b3JpZ2luLCB0aW1lX2hvdXI8L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik0xMDIuNSwtOTFDMTM3LjcxMTMsLTkxIDEwOC44MzY5LC0yNi45ODUxIDEzMC41MzAxLC0xMy40ODIiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjEzMS42NDE3LC0xNi44MTIxIDE0MC41LC0xMSAxMjkuOTUwNiwtMTAuMDE5NSAxMzEuNjQxNywtMTYuODEyMSI+PC9wb2x5Z29uPjwvZz48L2c+PC9zdmc+)

In a future update, we will provide a more convenient way to
“disentangle” `dm` objects, so that the individual steps will be done
automatically.

### Use case 4: Add summary table to `dm`

Here is an example for adding a summary of a table as a new table to a
`dm` (FK-relations are taken care of automatically):

``` r
dm_with_summary <-
  flights_dm %>%
  dm_zoom_to(flights) %>%
  dplyr::count(origin, carrier) %>%
  dm_insert_zoomed("dep_carrier_count")
dm_draw(dm_with_summary)
```

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjU0cHQiIGhlaWdodD0iMjMwcHQiIHZpZXdib3g9IjAuMDAgMC4wMCAyNTQuMDAgMjMwLjAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIj48ZyBpZD0iZ3JhcGgwIiBjbGFzcz0iZ3JhcGgiIHRyYW5zZm9ybT0ic2NhbGUoMSAxKSByb3RhdGUoMCkgdHJhbnNsYXRlKDQgMjI2KSI+PHRpdGxlPiUwPC90aXRsZT4KPGcgaWQ9ImFfZ3JhcGgwIj48YSB4bGluazp0aXRsZT0iRGF0YSBNb2RlbCI+Cjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iLTQsNCAtNCwtMjI2IDI1MCwtMjI2IDI1MCw0IC00LDQiPjwvcG9seWdvbj48L2E+CjwvZz48IS0tIGFpcmxpbmVzIC0tPjxnIGlkPSJhaXJsaW5lcyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJsaW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZDdkMzEiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTcyLjUsLTE0MSAxNzIuNSwtMTYxIDIxNy41LC0xNjEgMjE3LjUsLTE0MSAxNzIuNSwtMTQxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzQuMzk2OSIgeT0iLTE0Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiNmZmZmZmYiPmFpcmxpbmVzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmYmU1ZDUiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTcyLjUsLTEyMSAxNzIuNSwtMTQxIDIxNy41LC0xNDEgMjE3LjUsLTEyMSAxNzIuNSwtMTIxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzQuNSIgeT0iLTEyNy40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5jYXJyaWVyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzllNTMyMCIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjE3MSwtMTIwIDE3MSwtMTYyIDIxOCwtMTYyIDIxOCwtMTIwIDE3MSwtMTIwIj48L3BvbHlnb24+PC9nPjwhLS0gYWlycG9ydHMgLS0+PGcgaWQ9ImFpcnBvcnRzIiBjbGFzcz0ibm9kZSI+PHRpdGxlPmFpcnBvcnRzPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iI2VkN2QzMSIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNzEuNSwtMjAxIDE3MS41LC0yMjEgMjE3LjUsLTIyMSAyMTcuNSwtMjAxIDE3MS41LC0yMDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE3My4xMTkyIiB5PSItMjA2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iI2ZmZmZmZiI+YWlycG9ydHM8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZiZTVkNSIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNzEuNSwtMTgxIDE3MS41LC0yMDEgMjE3LjUsLTIwMSAyMTcuNSwtMTgxIDE3MS41LC0xODEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE3My41IiB5PSItMTg3LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmZhYTwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM5ZTUzMjAiIHN0cm9rZS1vcGFjaXR5PSIwLjY2NjY2NyIgcG9pbnRzPSIxNzAuNSwtMTgwIDE3MC41LC0yMjIgMjE4LjUsLTIyMiAyMTguNSwtMTgwIDE3MC41LC0xODAiPjwvcG9seWdvbj48L2c+PCEtLSBkZXBfY2Fycmllcl9jb3VudCAtLT48ZyBpZD0iZGVwX2NhcnJpZXJfY291bnQiIGNsYXNzPSJub2RlIj48dGl0bGU+ZGVwX2NhcnJpZXJfY291bnQ8L3RpdGxlPgo8cG9seWdvbiBmaWxsPSIjNWI5YmQ1IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtMTk2IDEuNSwtMjE2IDEwNi41LC0yMTYgMTA2LjUsLTE5NiAxLjUsLTE5NiI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMy4wODIiIHk9Ii0yMDEuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjZmZmZmZmIj5kZXBfY2Fycmllcl9jb3VudDwvdGV4dD48cG9seWdvbiBmaWxsPSIjZGVlYmY2IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtMTc2IDEuNSwtMTk2IDEwNi41LC0xOTYgMTA2LjUsLTE3NiAxLjUsLTE3NiI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMy41IiB5PSItMTgxLjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+b3JpZ2luPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNkZWViZjYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC0xNTYgMS41LC0xNzYgMTA2LjUsLTE3NiAxMDYuNSwtMTU2IDEuNSwtMTU2Ij48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzLjUiIHk9Ii0xNjEuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5jYXJyaWVyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzNjNjc4ZSIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjAsLTE1NSAwLC0yMTcgMTA3LC0yMTcgMTA3LC0xNTUgMCwtMTU1Ij48L3BvbHlnb24+PC9nPjwhLS0gZGVwX2NhcnJpZXJfY291bnQmIzQ1OyZndDthaXJsaW5lcyAtLT48ZyBpZD0iZGVwX2NhcnJpZXJfY291bnRfMSIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5kZXBfY2Fycmllcl9jb3VudDpjYXJyaWVyLSZndDthaXJsaW5lczpjYXJyaWVyPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTA2LjUsLTE2NkMxMzUuOTQxNSwtMTY2IDEzOC45NTc5LC0xMzguNDgwNSAxNjIuNDEyNCwtMTMyLjI0NTciIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjE2My4wMDQ0LC0xMzUuNjk5MiAxNzIuNSwtMTMxIDE2Mi4xNDY0LC0xMjguNzUyIDE2My4wMDQ0LC0xMzUuNjk5MiI+PC9wb2x5Z29uPjwvZz48IS0tIGRlcF9jYXJyaWVyX2NvdW50JiM0NTsmZ3Q7YWlycG9ydHMgLS0+PGcgaWQ9ImRlcF9jYXJyaWVyX2NvdW50XzIiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZGVwX2NhcnJpZXJfY291bnQ6b3JpZ2luLSZndDthaXJwb3J0czpmYWE8L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik0xMDYuNSwtMTg2QzEzMS43MzkzLC0xODYgMTQwLjM0MzUsLTE4OS43OTQgMTYxLjI5NDEsLTE5MC43NzIyIiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxNjEuNDI0MywtMTk0LjI3NTkgMTcxLjUsLTE5MSAxNjEuNTgwNiwtMTg3LjI3NzYgMTYxLjQyNDMsLTE5NC4yNzU5Ij48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyAtLT48ZyBpZD0iZmxpZ2h0cyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5mbGlnaHRzPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iIzViOWJkNSIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIzLjUsLTExMSAzLjUsLTEzMSAxMDQuNSwtMTMxIDEwNC41LC0xMTEgMy41LC0xMTEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjM2LjExMTUiIHk9Ii0xMTYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjZmZmZmZmIj5mbGlnaHRzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNkZWViZjYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMy41LC05MSAzLjUsLTExMSAxMDQuNSwtMTExIDEwNC41LC05MSAzLjUsLTkxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSI1LjUiIHk9Ii05Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmNhcnJpZXI8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2RlZWJmNiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIzLjUsLTcxIDMuNSwtOTEgMTA0LjUsLTkxIDEwNC41LC03MSAzLjUsLTcxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSI1LjUiIHk9Ii03Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPnRhaWxudW08L3RleHQ+PHBvbHlnb24gZmlsbD0iI2RlZWJmNiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIzLjUsLTUxIDMuNSwtNzEgMTA0LjUsLTcxIDEwNC41LC01MSAzLjUsLTUxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSI1LjUiIHk9Ii01Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPm9yaWdpbjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZGVlYmY2IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjMuNSwtMzEgMy41LC01MSAxMDQuNSwtNTEgMTA0LjUsLTMxIDMuNSwtMzEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjUuMDA1NiIgeT0iLTM2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+b3JpZ2luLCB0aW1lX2hvdXI8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjM2M2NzhlIiBzdHJva2Utb3BhY2l0eT0iMC42NjY2NjciIHBvaW50cz0iMiwtMzAgMiwtMTMyIDEwNSwtMTMyIDEwNSwtMzAgMiwtMzAiPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzJiM0NTsmZ3Q7YWlybGluZXMgLS0+PGcgaWQ9ImZsaWdodHNfMSIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOmNhcnJpZXItJmd0O2FpcmxpbmVzOmNhcnJpZXI8L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik0xMDQuNSwtMTAxQzEzMy43OTA3LC0xMDEgMTM4LjYyOTksLTEyNC41ODgxIDE2Mi4zODA4LC0xMjkuOTMyMyIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTYyLjE4NzksLTEzMy40MzEzIDE3Mi41LC0xMzEgMTYyLjkyMjUsLTEyNi40Njk5IDE2Mi4xODc5LC0xMzMuNDMxMyI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMmIzQ1OyZndDthaXJwb3J0cyAtLT48ZyBpZD0iZmxpZ2h0c18yIiBjbGFzcz0iZWRnZSI+PHRpdGxlPmZsaWdodHM6b3JpZ2luLSZndDthaXJwb3J0czpmYWE8L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik0xMDQuNSwtNjFDMTY1LjY5MTMsLTYxIDExMy40NDM0LC0xNzYuMjExOSAxNjEuMzQxMSwtMTg5LjcxMzMiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjE2MS4xMzk0LC0xOTMuMjE1NyAxNzEuNSwtMTkxIDE2Mi4wMTkxLC0xODYuMjcxMiAxNjEuMTM5NCwtMTkzLjIxNTciPjwvcG9seWdvbj48L2c+PCEtLSBwbGFuZXMgLS0+PGcgaWQ9InBsYW5lcyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5wbGFuZXM8L3RpdGxlPgo8cG9seWdvbiBmaWxsPSIjZWQ3ZDMxIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE3MS41LC04MSAxNzEuNSwtMTAxIDIxNy41LC0xMDEgMjE3LjUsLTgxIDE3MS41LC04MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTc2LjYxNzgiIHk9Ii04Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiNmZmZmZmYiPnBsYW5lczwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmJlNWQ1IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE3MS41LC02MSAxNzEuNSwtODEgMjE3LjUsLTgxIDIxNy41LC02MSAxNzEuNSwtNjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE3My4xMTE1IiB5PSItNjcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+dGFpbG51bTwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM5ZTUzMjAiIHN0cm9rZS1vcGFjaXR5PSIwLjY2NjY2NyIgcG9pbnRzPSIxNzAuNSwtNjAgMTcwLjUsLTEwMiAyMTguNSwtMTAyIDIxOC41LC02MCAxNzAuNSwtNjAiPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzJiM0NTsmZ3Q7cGxhbmVzIC0tPjxnIGlkPSJmbGlnaHRzXzMiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czp0YWlsbnVtLSZndDtwbGFuZXM6dGFpbG51bTwvdGl0bGU+CjxwYXRoIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgZD0iTTEwNC41LC04MUMxMzAuOTYxOCwtODEgMTM5LjQwNzIsLTczLjI3NTIgMTYxLjUwNTYsLTcxLjQwNDQiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjE2MS42NDk3LC03NC45MDE1IDE3MS41LC03MSAxNjEuMzY2NiwtNjcuOTA3MyAxNjEuNjQ5NywtNzQuOTAxNSI+PC9wb2x5Z29uPjwvZz48IS0tIHdlYXRoZXIgLS0+PGcgaWQ9IndlYXRoZXIiIGNsYXNzPSJub2RlIj48dGl0bGU+d2VhdGhlcjwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiM3MGFkNDciIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTQ0LjUsLTIxIDE0NC41LC00MSAyNDUuNSwtNDEgMjQ1LjUsLTIxIDE0NC41LC0yMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTcyLjg0OTIiIHk9Ii0yNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiNmZmZmZmYiPndlYXRoZXI8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2UyZWVkYSIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNDQuNSwtMSAxNDQuNSwtMjEgMjQ1LjUsLTIxIDI0NS41LC0xIDE0NC41LC0xIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNDYuMDA1NiIgeT0iLTcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+b3JpZ2luLCB0aW1lX2hvdXI8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNGE3MzJmIiBzdHJva2Utb3BhY2l0eT0iMC42NjY2NjciIHBvaW50cz0iMTQzLDAgMTQzLC00MiAyNDYsLTQyIDI0NiwwIDE0MywwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O3dlYXRoZXIgLS0+PGcgaWQ9ImZsaWdodHNfNCIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOm9yaWdpbiwgdGltZV9ob3VyLSZndDt3ZWF0aGVyOm9yaWdpbiwgdGltZV9ob3VyPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTA0LjUsLTQxQzEyMi43MjkyLC00MSAxMjMuMDE0LC0yMC44MTI2IDEzNC43OTQ0LC0xMy41NTc4IiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxMzUuNzIyMSwtMTYuOTMyOSAxNDQuNSwtMTEgMTMzLjkzODIsLTEwLjE2NCAxMzUuNzIyMSwtMTYuOTMyOSI+PC9wb2x5Z29uPjwvZz48L2c+PC9zdmc+)

### Use case 5: Joining tables

If you would like to join some or all of the columns of one table to
another, you can make use of one of the `join`-methods for a
`dm_zoomed`. In addition to the usual arguments for the {dplyr}-joins,
by supplying the `select` argument you can specify which columns of the
RHS-table you want to be included in the join. For the syntax please see
the example below. The LHS-table of a join is always the zoomed table.

``` r
joined_flights_dm <-
  flights_dm %>%
  dm_zoom_to(flights) %>%
  # let's first reduce the number of columns of flights
  select(-dep_delay:-arr_delay, -air_time:-time_hour) %>%
  # in the {dm}-method for the joins you can specify which columns you want to add to the zoomed table
  left_join(planes, select = c(tailnum, plane_type = type)) %>%
  dm_insert_zoomed("flights_plane_type")
# this is how the table looks now
joined_flights_dm$flights_plane_type
```

``` fansi
#> # A tibble: 1,761 × 11
#>     year month   day dep_time sched_dep_time carrier flight tailnum origin
#>    <int> <int> <int>    <int>          <int> <chr>    <int> <chr>   <chr> 
#>  1  2013     1    10        3           2359 B6         727 N571JB  JFK   
#>  2  2013     1    10       16           2359 B6         739 N564JB  JFK   
#>  3  2013     1    10      450            500 US        1117 N171US  EWR   
#>  4  2013     1    10      520            525 UA        1018 N35204  EWR   
#>  5  2013     1    10      530            530 UA         404 N815UA  LGA   
#>  6  2013     1    10      531            540 AA        1141 N5EAAA  JFK   
#>  7  2013     1    10      535            540 B6         725 N784JB  JFK   
#>  8  2013     1    10      546            600 B6         380 N337JB  EWR   
#>  9  2013     1    10      549            600 EV        6055 N19554  LGA   
#> 10  2013     1    10      550            600 US        2114 N740UW  LGA   
#> # ℹ 1,751 more rows
#> # ℹ 2 more variables: dest <chr>, plane_type <chr>
```

``` r
# also here, the FK-relations are transferred to the new table
dm_draw(joined_flights_dm)
```

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjU3cHQiIGhlaWdodD0iMjMwcHQiIHZpZXdib3g9IjAuMDAgMC4wMCAyNTcuMDAgMjMwLjAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIj48ZyBpZD0iZ3JhcGgwIiBjbGFzcz0iZ3JhcGgiIHRyYW5zZm9ybT0ic2NhbGUoMSAxKSByb3RhdGUoMCkgdHJhbnNsYXRlKDQgMjI2KSI+PHRpdGxlPiUwPC90aXRsZT4KPGcgaWQ9ImFfZ3JhcGgwIj48YSB4bGluazp0aXRsZT0iRGF0YSBNb2RlbCI+Cjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iLTQsNCAtNCwtMjI2IDI1MywtMjI2IDI1Myw0IC00LDQiPjwvcG9seWdvbj48L2E+CjwvZz48IS0tIGFpcmxpbmVzIC0tPjxnIGlkPSJhaXJsaW5lcyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJsaW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZDdkMzEiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTc1LjUsLTIwMSAxNzUuNSwtMjIxIDIyMC41LC0yMjEgMjIwLjUsLTIwMSAxNzUuNSwtMjAxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzcuMzk2OSIgeT0iLTIwNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiNmZmZmZmYiPmFpcmxpbmVzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmYmU1ZDUiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTc1LjUsLTE4MSAxNzUuNSwtMjAxIDIyMC41LC0yMDEgMjIwLjUsLTE4MSAxNzUuNSwtMTgxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzcuNSIgeT0iLTE4Ny40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5jYXJyaWVyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzllNTMyMCIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjE3NCwtMTgwIDE3NCwtMjIyIDIyMSwtMjIyIDIyMSwtMTgwIDE3NCwtMTgwIj48L3BvbHlnb24+PC9nPjwhLS0gYWlycG9ydHMgLS0+PGcgaWQ9ImFpcnBvcnRzIiBjbGFzcz0ibm9kZSI+PHRpdGxlPmFpcnBvcnRzPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iI2VkN2QzMSIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNzQuNSwtODEgMTc0LjUsLTEwMSAyMjAuNSwtMTAxIDIyMC41LC04MSAxNzQuNSwtODEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE3Ni4xMTkyIiB5PSItODYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjZmZmZmZmIj5haXJwb3J0czwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmJlNWQ1IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE3NC41LC02MSAxNzQuNSwtODEgMjIwLjUsLTgxIDIyMC41LC02MSAxNzQuNSwtNjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE3Ni41IiB5PSItNjcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+ZmFhPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzllNTMyMCIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjE3My41LC02MCAxNzMuNSwtMTAyIDIyMS41LC0xMDIgMjIxLjUsLTYwIDE3My41LC02MCI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMgLS0+PGcgaWQ9ImZsaWdodHMiIGNsYXNzPSJub2RlIj48dGl0bGU+ZmxpZ2h0czwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiM1YjliZDUiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iNSwtMTAxIDUsLTEyMSAxMDYsLTEyMSAxMDYsLTEwMSA1LC0xMDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjM3LjYxMTUiIHk9Ii0xMDYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjZmZmZmZmIj5mbGlnaHRzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNkZWViZjYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iNSwtODEgNSwtMTAxIDEwNiwtMTAxIDEwNiwtODEgNSwtODEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjciIHk9Ii04Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmNhcnJpZXI8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2RlZWJmNiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSI1LC02MSA1LC04MSAxMDYsLTgxIDEwNiwtNjEgNSwtNjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjciIHk9Ii02Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPnRhaWxudW08L3RleHQ+PHBvbHlnb24gZmlsbD0iI2RlZWJmNiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSI1LC00MSA1LC02MSAxMDYsLTYxIDEwNiwtNDEgNSwtNDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjciIHk9Ii00Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPm9yaWdpbjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZGVlYmY2IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjUsLTIxIDUsLTQxIDEwNiwtNDEgMTA2LC0yMSA1LC0yMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iNi41MDU2IiB5PSItMjYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5vcmlnaW4sIHRpbWVfaG91cjwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiMzYzY3OGUiIHN0cm9rZS1vcGFjaXR5PSIwLjY2NjY2NyIgcG9pbnRzPSIzLjUsLTIwIDMuNSwtMTIyIDEwNi41LC0xMjIgMTA2LjUsLTIwIDMuNSwtMjAiPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzJiM0NTsmZ3Q7YWlybGluZXMgLS0+PGcgaWQ9ImZsaWdodHNfMSIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOmNhcnJpZXItJmd0O2FpcmxpbmVzOmNhcnJpZXI8L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik0xMDYsLTkxQzE0NS43NTIzLC05MSAxMTkuODA4LC0xNDEuMDk2NCAxNDYsLTE3MSAxNTMuNjY0NiwtMTc5Ljc1MDcgMTU3LjQzODYsLTE4Ni40MzQ5IDE2NS4xNzYzLC0xODkuMzY4NSIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTY1LjA3NjIsLTE5Mi44OTYxIDE3NS41LC0xOTEgMTY2LjE2ODksLTE4NS45ODE5IDE2NS4wNzYyLC0xOTIuODk2MSI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMmIzQ1OyZndDthaXJwb3J0cyAtLT48ZyBpZD0iZmxpZ2h0c18yIiBjbGFzcz0iZWRnZSI+PHRpdGxlPmZsaWdodHM6b3JpZ2luLSZndDthaXJwb3J0czpmYWE8L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik0xMDYsLTUxQzEzMy45OTg5LC01MSAxNDEuMjMwNSwtNjYuNTg3MiAxNjQuMzYyLC03MC4yNDA0IiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxNjQuMjY2NCwtNzMuNzQzIDE3NC41LC03MSAxNjQuNzg5NSwtNjYuNzYyNSAxNjQuMjY2NCwtNzMuNzQzIj48L3BvbHlnb24+PC9nPjwhLS0gcGxhbmVzIC0tPjxnIGlkPSJwbGFuZXMiIGNsYXNzPSJub2RlIj48dGl0bGU+cGxhbmVzPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iI2VkN2QzMSIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNzQuNSwtMTQxIDE3NC41LC0xNjEgMjIwLjUsLTE2MSAyMjAuNSwtMTQxIDE3NC41LC0xNDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE3OS42MTc4IiB5PSItMTQ2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iI2ZmZmZmZiI+cGxhbmVzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmYmU1ZDUiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTc0LjUsLTEyMSAxNzQuNSwtMTQxIDIyMC41LC0xNDEgMjIwLjUsLTEyMSAxNzQuNSwtMTIxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzYuMTExNSIgeT0iLTEyNy40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij50YWlsbnVtPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzllNTMyMCIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjE3My41LC0xMjAgMTczLjUsLTE2MiAyMjEuNSwtMTYyIDIyMS41LC0xMjAgMTczLjUsLTEyMCI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMmIzQ1OyZndDtwbGFuZXMgLS0+PGcgaWQ9ImZsaWdodHNfMyIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOnRhaWxudW0tJmd0O3BsYW5lczp0YWlsbnVtPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTA2LC03MUMxNDIuNjc3NywtNzEgMTM1Ljg5NjIsLTEyMC4yNzczIDE2NC40MjUzLC0xMjkuNTE2OCIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTY0LjA5NjgsLTEzMy4wMDYxIDE3NC41LC0xMzEgMTY1LjExNjQsLTEyNi4wODA4IDE2NC4wOTY4LC0xMzMuMDA2MSI+PC9wb2x5Z29uPjwvZz48IS0tIHdlYXRoZXIgLS0+PGcgaWQ9IndlYXRoZXIiIGNsYXNzPSJub2RlIj48dGl0bGU+d2VhdGhlcjwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiM3MGFkNDciIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTQ3LjUsLTIxIDE0Ny41LC00MSAyNDguNSwtNDEgMjQ4LjUsLTIxIDE0Ny41LC0yMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTc1Ljg0OTIiIHk9Ii0yNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiNmZmZmZmYiPndlYXRoZXI8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2UyZWVkYSIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNDcuNSwtMSAxNDcuNSwtMjEgMjQ4LjUsLTIxIDI0OC41LC0xIDE0Ny41LC0xIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNDkuMDA1NiIgeT0iLTcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+b3JpZ2luLCB0aW1lX2hvdXI8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNGE3MzJmIiBzdHJva2Utb3BhY2l0eT0iMC42NjY2NjciIHBvaW50cz0iMTQ2LDAgMTQ2LC00MiAyNDksLTQyIDI0OSwwIDE0NiwwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O3dlYXRoZXIgLS0+PGcgaWQ9ImZsaWdodHNfNCIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOm9yaWdpbiwgdGltZV9ob3VyLSZndDt3ZWF0aGVyOm9yaWdpbiwgdGltZV9ob3VyPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTA2LC0zMUMxMjIuNDc1NywtMzEgMTI2LjA1MDIsLTE4LjA0OTYgMTM3LjQ4NjQsLTEyLjk5MDgiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjEzOC4zNzQ1LC0xNi4zODI4IDE0Ny41LC0xMSAxMzcuMDA5NCwtOS41MTcyIDEzOC4zNzQ1LC0xNi4zODI4Ij48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0c19wbGFuZV90eXBlIC0tPjxnIGlkPSJmbGlnaHRzX3BsYW5lX3R5cGUiIGNsYXNzPSJub2RlIj48dGl0bGU+ZmxpZ2h0c19wbGFuZV90eXBlPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iIzViOWJkNSIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLC0yMDEgMSwtMjIxIDEwOSwtMjIxIDEwOSwtMjAxIDEsLTIwMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMi44OTkiIHk9Ii0yMDYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjZmZmZmZmIj5mbGlnaHRzX3BsYW5lX3R5cGU8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2RlZWJmNiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLC0xODEgMSwtMjAxIDEwOSwtMjAxIDEwOSwtMTgxIDEsLTE4MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMyIgeT0iLTE4Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmNhcnJpZXI8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2RlZWJmNiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLC0xNjEgMSwtMTgxIDEwOSwtMTgxIDEwOSwtMTYxIDEsLTE2MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMyIgeT0iLTE2Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPnRhaWxudW08L3RleHQ+PHBvbHlnb24gZmlsbD0iI2RlZWJmNiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLC0xNDEgMSwtMTYxIDEwOSwtMTYxIDEwOSwtMTQxIDEsLTE0MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMyIgeT0iLTE0Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPm9yaWdpbjwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiMzYzY3OGUiIHN0cm9rZS1vcGFjaXR5PSIwLjY2NjY2NyIgcG9pbnRzPSIwLC0xNDAgMCwtMjIyIDExMCwtMjIyIDExMCwtMTQwIDAsLTE0MCI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHNfcGxhbmVfdHlwZSYjNDU7Jmd0O2FpcmxpbmVzIC0tPjxnIGlkPSJmbGlnaHRzX3BsYW5lX3R5cGVfMSIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzX3BsYW5lX3R5cGU6Y2Fycmllci0mZ3Q7YWlybGluZXM6Y2FycmllcjwvdGl0bGU+CjxwYXRoIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgZD0iTTEwOSwtMTkxQzEzNC44NjExLC0xOTEgMTQzLjc1MDksLTE5MSAxNjUuMzY5MSwtMTkxIiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxNjUuNSwtMTk0LjUwMDEgMTc1LjUsLTE5MSAxNjUuNSwtMTg3LjUwMDEgMTY1LjUsLTE5NC41MDAxIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0c19wbGFuZV90eXBlJiM0NTsmZ3Q7YWlycG9ydHMgLS0+PGcgaWQ9ImZsaWdodHNfcGxhbmVfdHlwZV8yIiBjbGFzcz0iZWRnZSI+PHRpdGxlPmZsaWdodHNfcGxhbmVfdHlwZTpvcmlnaW4tJmd0O2FpcnBvcnRzOmZhYTwvdGl0bGU+CjxwYXRoIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgZD0iTTEwOSwtMTUxQzE1MS4xODMyLC0xNTEgMTMyLjM5MjUsLTgzLjU4NjcgMTY0LjU3MjIsLTcyLjUyNjciIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjE2NS4xNDgyLC03NS45NzkzIDE3NC41LC03MSAxNjQuMDg0MiwtNjkuMDYwNiAxNjUuMTQ4MiwtNzUuOTc5MyI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHNfcGxhbmVfdHlwZSYjNDU7Jmd0O3BsYW5lcyAtLT48ZyBpZD0iZmxpZ2h0c19wbGFuZV90eXBlXzMiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0c19wbGFuZV90eXBlOnRhaWxudW0tJmd0O3BsYW5lczp0YWlsbnVtPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTA5LC0xNzFDMTM5LjM3OTQsLTE3MSAxNDAuNTQ0MywtMTM5LjI3MTUgMTY0LjUzMywtMTMyLjMzMDkiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjE2NS4wNTEyLC0xMzUuNzkyOCAxNzQuNSwtMTMxIDE2NC4xMjQ3LC0xMjguODU0NCAxNjUuMDUxMiwtMTM1Ljc5MjgiPjwvcG9seWdvbj48L2c+PC9nPjwvc3ZnPg==)

### Tip: Accessing the zoomed table

At each point, you can retrieve the zoomed table by calling
[`pull_tbl()`](https://dm.cynkra.com/reference/pull_tbl.md) on a
`dm_zoomed`. To use our last example once more:

``` r
flights_dm %>%
  dm_zoom_to(flights) %>%
  select(-dep_delay:-arr_delay, -air_time:-time_hour) %>%
  left_join(planes, select = c(tailnum, plane_type = type)) %>%
  pull_tbl()
```

``` fansi
#> # A tibble: 1,761 × 11
#>     year month   day dep_time sched_dep_time carrier flight tailnum origin
#>    <int> <int> <int>    <int>          <int> <chr>    <int> <chr>   <chr> 
#>  1  2013     1    10        3           2359 B6         727 N571JB  JFK   
#>  2  2013     1    10       16           2359 B6         739 N564JB  JFK   
#>  3  2013     1    10      450            500 US        1117 N171US  EWR   
#>  4  2013     1    10      520            525 UA        1018 N35204  EWR   
#>  5  2013     1    10      530            530 UA         404 N815UA  LGA   
#>  6  2013     1    10      531            540 AA        1141 N5EAAA  JFK   
#>  7  2013     1    10      535            540 B6         725 N784JB  JFK   
#>  8  2013     1    10      546            600 B6         380 N337JB  EWR   
#>  9  2013     1    10      549            600 EV        6055 N19554  LGA   
#> 10  2013     1    10      550            600 US        2114 N740UW  LGA   
#> # ℹ 1,751 more rows
#> # ℹ 2 more variables: dest <chr>, plane_type <chr>
```

### Possible pitfalls and caveats

1.  Currently, not all {dplyr}-verbs have their own method for a
    `dm_zoomed` object, so be aware that in some cases it will still be
    necessary to resort to extracting one or more tables from a `dm` and
    reinserting a transformed version back into the `dm` object. The
    supported functions are:
    [`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html),
    [`ungroup()`](https://dplyr.tidyverse.org/reference/group_by.html),
    [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html),
    [`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html),
    [`transmute()`](https://dplyr.tidyverse.org/reference/transmute.html),
    [`filter()`](https://dplyr.tidyverse.org/reference/filter.html),
    [`select()`](https://dplyr.tidyverse.org/reference/select.html),
    [`relocate()`](https://dplyr.tidyverse.org/reference/relocate.html),
    [`rename()`](https://dplyr.tidyverse.org/reference/rename.html),
    [`distinct()`](https://dplyr.tidyverse.org/reference/distinct.html),
    [`arrange()`](https://dplyr.tidyverse.org/reference/arrange.html),
    [`slice()`](https://dplyr.tidyverse.org/reference/slice.html),
    [`left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html),
    [`inner_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html),
    [`full_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html),
    [`right_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html),
    [`semi_join()`](https://dplyr.tidyverse.org/reference/filter-joins.html),
    and
    [`anti_join()`](https://dplyr.tidyverse.org/reference/filter-joins.html).

2.  The same is true for {tidyr}-functions. Methods are provided for:
    [`unite()`](https://tidyr.tidyverse.org/reference/unite.html) and
    [`separate()`](https://tidyr.tidyverse.org/reference/separate.html).

3.  There might be situations when you would like the key relations to
    remain intact, but they are dropped nevertheless. This is because a
    rigid logic is implemented, that does drop a key when its associated
    column is acted upon with e.g. a
    [`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html)
    call. In these cases, the key relations will need to be
    re-established after finishing with the manipulations.

4.  For each implemented {dplyr}-verb, there is a logic for tracking key
    relations between the tables. Up to {dm} version 0.2.4 we tried to
    track the columns in a very detailed manner. This has become
    increasingly difficult, especially with
    [`dplyr::across()`](https://dplyr.tidyverse.org/reference/across.html).
    As of {dm} 0.2.5, we give more responsibility to the {dm} user: Now
    those columns are tracked whose **names** remain in the resulting
    table. Affected by these changes are the methods for:
    [`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html),
    [`transmute()`](https://dplyr.tidyverse.org/reference/transmute.html),
    [`distinct()`](https://dplyr.tidyverse.org/reference/distinct.html).
    When using one of these functions, be aware that if you want to
    replace a key column with a column with a different content but of
    the same name, this column will automatically become a key column.
