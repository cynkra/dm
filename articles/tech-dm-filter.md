# Filtering in relational data models

The {dm} package offers functions to work with relational data models in
R.

This document introduces you to filtering functions, and shows how to
apply them to the data that is separated into multiple tables.

Our example data is drawn from the
[{nycflights13}](https://github.com/tidyverse/nycflights13) package that
contains five inter-linked tables.

First, we will load the packages that we need:

``` r
library(nycflights13)
library(dm)
```

## Data: nycflights13

To explore filtering with {dm}, we’ll use the {nycflights13} data with
its `flights`, `planes`, `airlines`, `airports` and `weather` tables.

This dataset contains information about the 336 776 flights that
departed from New York City in 2013, with 3322 different planes and 1458
airports involved. The data comes from the US Bureau of Transportation
Statistics, and is documented in
[`?nycflights13::flights`](https://rdrr.io/pkg/nycflights13/man/flights.html).

To start with our exploration, we have to create a `dm` object from the
{nycflights13} data. The built-in
[`dm::dm_nycflights13()`](https://dm.cynkra.com/reference/dm_nycflights13.md)
function takes care of this.

By default it only uses a subset of the complete data though: only the
flights on the 10th of each month are considered, reducing the number of
rows in the `flights` table to 11 227.

A [data model object](https://dm.cynkra.com/articles/tech-dm-class.html)
contains data from the source tables, and metadata about the tables.

If you would like to create a `dm` object from tables other than the
example data, you can use the
[`new_dm()`](https://dm.cynkra.com/reference/dm.md),
[`dm()`](https://dm.cynkra.com/reference/dm.md) or
[`as_dm()`](https://dm.cynkra.com/reference/dm.md) functions. See
[`vignette("howto-dm-df")`](https://dm.cynkra.com/articles/howto-dm-df.md)
for details.

``` r
dm <- dm_nycflights13()
```

The console output of the ’dm\` object shows its data and metadata, and
is colored for clarity:

``` r
dm
```

``` fansi
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#> Columns: 53
#> Primary keys: 4
#> Foreign keys: 4
```

Now we know that there are five tables in our `dm` object. But how are
they connected? These relations are best displayed as a visualization of
the entity-relationship model:

``` r
dm_draw(dm)
```

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjUwcHQiIGhlaWdodD0iMjMwcHQiIHZpZXdib3g9IjAuMDAgMC4wMCAyNTAuMDAgMjMwLjAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIj48ZyBpZD0iZ3JhcGgwIiBjbGFzcz0iZ3JhcGgiIHRyYW5zZm9ybT0ic2NhbGUoMSAxKSByb3RhdGUoMCkgdHJhbnNsYXRlKDQgMjI2KSI+PHRpdGxlPiUwPC90aXRsZT4KPGcgaWQ9ImFfZ3JhcGgwIj48YSB4bGluazp0aXRsZT0iRGF0YSBNb2RlbCI+Cjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iLTQsNCAtNCwtMjI2IDI0NiwtMjI2IDI0Niw0IC00LDQiPjwvcG9seWdvbj48L2E+CjwvZz48IS0tIGFpcmxpbmVzIC0tPjxnIGlkPSJhaXJsaW5lcyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJsaW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZDdkMzEiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY4LjUsLTIwMSAxNjguNSwtMjIxIDIxMy41LC0yMjEgMjEzLjUsLTIwMSAxNjguNSwtMjAxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzAuMzk2OSIgeT0iLTIwNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiNmZmZmZmYiPmFpcmxpbmVzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmYmU1ZDUiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY4LjUsLTE4MSAxNjguNSwtMjAxIDIxMy41LC0yMDEgMjEzLjUsLTE4MSAxNjguNSwtMTgxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzAuNSIgeT0iLTE4Ny40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5jYXJyaWVyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzllNTMyMCIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjE2NywtMTgwIDE2NywtMjIyIDIxNCwtMjIyIDIxNCwtMTgwIDE2NywtMTgwIj48L3BvbHlnb24+PC9nPjwhLS0gYWlycG9ydHMgLS0+PGcgaWQ9ImFpcnBvcnRzIiBjbGFzcz0ibm9kZSI+PHRpdGxlPmFpcnBvcnRzPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iI2VkN2QzMSIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNjcuNSwtODEgMTY3LjUsLTEwMSAyMTMuNSwtMTAxIDIxMy41LC04MSAxNjcuNSwtODEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE2OS4xMTkyIiB5PSItODYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjZmZmZmZmIj5haXJwb3J0czwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmJlNWQ1IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE2Ny41LC02MSAxNjcuNSwtODEgMjEzLjUsLTgxIDIxMy41LC02MSAxNjcuNSwtNjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE2OS41IiB5PSItNjcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+ZmFhPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzllNTMyMCIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjE2Ni41LC02MCAxNjYuNSwtMTAyIDIxNC41LC0xMDIgMjE0LjUsLTYwIDE2Ni41LC02MCI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMgLS0+PGcgaWQ9ImZsaWdodHMiIGNsYXNzPSJub2RlIj48dGl0bGU+ZmxpZ2h0czwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiM1YjliZDUiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC0xNDEgMS41LC0xNjEgMTAyLjUsLTE2MSAxMDIuNSwtMTQxIDEuNSwtMTQxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzNC4xMTE1IiB5PSItMTQ2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iI2ZmZmZmZiI+ZmxpZ2h0czwvdGV4dD48cG9seWdvbiBmaWxsPSIjZGVlYmY2IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtMTIxIDEuNSwtMTQxIDEwMi41LC0xNDEgMTAyLjUsLTEyMSAxLjUsLTEyMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMy41IiB5PSItMTI2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+Y2FycmllcjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZGVlYmY2IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtMTAxIDEuNSwtMTIxIDEwMi41LC0xMjEgMTAyLjUsLTEwMSAxLjUsLTEwMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMy41IiB5PSItMTA2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+dGFpbG51bTwvdGV4dD48cG9seWdvbiBmaWxsPSIjZGVlYmY2IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtODEgMS41LC0xMDEgMTAyLjUsLTEwMSAxMDIuNSwtODEgMS41LC04MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMy41IiB5PSItODYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5vcmlnaW48L3RleHQ+PHBvbHlnb24gZmlsbD0iI2RlZWJmNiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLjUsLTYxIDEuNSwtODEgMTAyLjUsLTgxIDEwMi41LC02MSAxLjUsLTYxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzLjAwNTYiIHk9Ii02Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPm9yaWdpbiwgdGltZV9ob3VyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzNjNjc4ZSIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjAsLTYwIDAsLTE2MiAxMDMsLTE2MiAxMDMsLTYwIDAsLTYwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O2FpcmxpbmVzIC0tPjxnIGlkPSJmbGlnaHRzXzEiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czpjYXJyaWVyLSZndDthaXJsaW5lczpjYXJyaWVyPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTAyLjUsLTEzMUMxMjYuNTY2OCwtMTMxIDEyMC44MDI5LC0xNTUuMjQ5NiAxMzksLTE3MSAxNDcuNzk1NiwtMTc4LjYxMyAxNTEuMDM5NCwtMTg1LjgzMDUgMTU4LjQxNTcsLTE4OS4xMjc3IiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxNTguMDI5MSwtMTkyLjYxNTcgMTY4LjUsLTE5MSAxNTkuMzA3LC0xODUuNzMzMyAxNTguMDI5MSwtMTkyLjYxNTciPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzJiM0NTsmZ3Q7YWlycG9ydHMgLS0+PGcgaWQ9ImZsaWdodHNfMiIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOm9yaWdpbi0mZ3Q7YWlycG9ydHM6ZmFhPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTAyLjUsLTkxQzEyOC45NDczLC05MSAxMzUuNzM2MSwtNzUuNjg3NSAxNTcuMjY4NywtNzEuODU5NCIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTU3LjgyODEsLTc1LjMyNDggMTY3LjUsLTcxIDE1Ny4yNDIxLC02OC4zNDk0IDE1Ny44MjgxLC03NS4zMjQ4Ij48L3BvbHlnb24+PC9nPjwhLS0gcGxhbmVzIC0tPjxnIGlkPSJwbGFuZXMiIGNsYXNzPSJub2RlIj48dGl0bGU+cGxhbmVzPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iI2VkN2QzMSIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNjcuNSwtMTQxIDE2Ny41LC0xNjEgMjEzLjUsLTE2MSAyMTMuNSwtMTQxIDE2Ny41LC0xNDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE3Mi42MTc4IiB5PSItMTQ2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iI2ZmZmZmZiI+cGxhbmVzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmYmU1ZDUiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY3LjUsLTEyMSAxNjcuNSwtMTQxIDIxMy41LC0xNDEgMjEzLjUsLTEyMSAxNjcuNSwtMTIxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNjkuMTExNSIgeT0iLTEyNy40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij50YWlsbnVtPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzllNTMyMCIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjE2Ni41LC0xMjAgMTY2LjUsLTE2MiAyMTQuNSwtMTYyIDIxNC41LC0xMjAgMTY2LjUsLTEyMCI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMmIzQ1OyZndDtwbGFuZXMgLS0+PGcgaWQ9ImZsaWdodHNfMyIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOnRhaWxudW0tJmd0O3BsYW5lczp0YWlsbnVtPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTAyLjUsLTExMUMxMjguOTQ3MywtMTExIDEzNS43MzYxLC0xMjYuMzEyNSAxNTcuMjY4NywtMTMwLjE0MDYiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjE1Ny4yNDIxLC0xMzMuNjUwNiAxNjcuNSwtMTMxIDE1Ny44MjgxLC0xMjYuNjc1MiAxNTcuMjQyMSwtMTMzLjY1MDYiPjwvcG9seWdvbj48L2c+PCEtLSB3ZWF0aGVyIC0tPjxnIGlkPSJ3ZWF0aGVyIiBjbGFzcz0ibm9kZSI+PHRpdGxlPndlYXRoZXI8L3RpdGxlPgo8cG9seWdvbiBmaWxsPSIjNzBhZDQ3IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE0MC41LC0yMSAxNDAuNSwtNDEgMjQxLjUsLTQxIDI0MS41LC0yMSAxNDAuNSwtMjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE2OC44NDkyIiB5PSItMjYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjZmZmZmZmIj53ZWF0aGVyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNlMmVlZGEiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTQwLjUsLTEgMTQwLjUsLTIxIDI0MS41LC0yMSAyNDEuNSwtMSAxNDAuNSwtMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTQyLjAwNTYiIHk9Ii03LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPm9yaWdpbiwgdGltZV9ob3VyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzRhNzMyZiIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjEzOSwwIDEzOSwtNDIgMjQyLC00MiAyNDIsMCAxMzksMCI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMmIzQ1OyZndDt3ZWF0aGVyIC0tPjxnIGlkPSJmbGlnaHRzXzQiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czpvcmlnaW4sIHRpbWVfaG91ci0mZ3Q7d2VhdGhlcjpvcmlnaW4sIHRpbWVfaG91cjwvdGl0bGU+CjxwYXRoIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgZD0iTTEwMi41LC03MUMxMjkuODcyNywtNzEgMTE0LjYxMDEsLTI1Ljg3OTIgMTMwLjY1NzksLTEzLjg5MzkiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjEzMS44OTM1LC0xNy4xNzg5IDE0MC41LC0xMSAxMjkuOTE4OCwtMTAuNDYzMSAxMzEuODkzNSwtMTcuMTc4OSI+PC9wb2x5Z29uPjwvZz48L2c+PC9zdmc+)

You can look at a single table with `tbl`. To print the `airports`
table, call

``` r
tbl(dm, "airports")
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

## Filtering a `dm` object

[`dm_filter()`](https://dm.cynkra.com/reference/dm_filter.md) allows you
to select a subset of a `dm` object.

### How it works

Filtering a `dm` object is not that different from filtering a dataframe
or tibble with
[`dplyr::filter()`](https://dplyr.tidyverse.org/reference/filter.html).

The corresponding {dm} function is
[`dm::dm_filter()`](https://dm.cynkra.com/reference/dm_filter.md). With
this function one or more filtering conditions can be set for one of the
tables of the `dm` object. These conditions are immediately evaluated
for their respective tables and for all related tables. For each
resulting table, all related tables (directly or indirectly) with a
filter condition them are taken into account in the following way: -
filtering semi-joins are successively performed along the paths from
each of the filtered tables to the requested table, each join reducing
the left-hand side tables of the joins to only those of their rows with
key values that have corresponding values in key columns of the
right-hand side tables of the join. - eventually the requested table is
returned, containing only the the remaining rows after the filtering
joins

Currently, this only works if the graph induced by the foreign key
relations is cycle free. Fortunately, this is the default for
[`dm_nycflights13()`](https://dm.cynkra.com/reference/dm_nycflights13.md).

### Filtering Examples

Let’s see filtering in action:

**We only want the data that is related to John F. Kennedy International
Airport.**

``` r
filtered_dm <-
  dm %>%
  dm_filter(airports = (name == "John F Kennedy Intl"))
filtered_dm
```

``` fansi
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#> Columns: 53
#> Primary keys: 4
#> Foreign keys: 4
```

You can get the numbers of rows of each table with
[`dm_nrow()`](https://dm.cynkra.com/reference/dm_nrow.md).

``` r
rows_per_table <-
  filtered_dm %>%
  dm_nrow()
rows_per_table
#> airlines airports  flights   planes  weather 
#>       10        1      602      336       38
sum(rows_per_table)
#> [1] 987
```

``` r
sum_nrow <- sum(dm_nrow(dm))
sum_nrow_filtered <- sum(dm_nrow(dm_apply_filters(filtered_dm)))
#> Warning: `dm_apply_filters()` was deprecated in dm 1.0.0.
#> ℹ Calling `dm_apply_filters()` after `dm_filter()` is no longer necessary.
#> This warning is displayed once per session.
#> Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
#> generated.
```

The total number of rows in the `dm` drops from 2 951 to 987 (the only
unaffected table is the disconnected `weather` table).

Next example:

**Get a `dm` object containing data for flights from New York to the
Dulles International Airport in Washington D.C., abbreviated with
`IAD`.**

``` r
dm %>%
  dm_filter(flights = (dest == "IAD")) %>%
  dm_nrow()
#> airlines airports  flights   planes  weather 
#>        4        3       32       28       30
```

Applying multiple filters to different tables is also supported.

An example:

**Get all January 2013 flights from Delta Air Lines which didn’t depart
from John F. Kennedy International Airport.**

``` r
dm_delta_may <-
  dm %>%
  dm_filter(
    airlines = (name == "Delta Air Lines Inc."),
    airports = (name != "John F Kennedy Intl"),
    flights = (month == 1)
  )
dm_delta_may
```

``` fansi
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#> Columns: 53
#> Primary keys: 4
#> Foreign keys: 4
```

``` r
dm_delta_may %>%
  dm_nrow()
#> airlines airports  flights   planes  weather 
#>        1        2       75       58       25
```

You can inspect the filtered tables by subsetting them.

In the `airlines` table, Delta is the only remaining carrier:

``` r
dm_delta_may$airlines
```

``` fansi
#> # A tibble: 1 × 2
#>   carrier name                
#>   <chr>   <chr>               
#> 1 DL      Delta Air Lines Inc.
```

Which planes were used to service these flights?

``` r
dm_delta_may$planes
```

``` fansi
#> # A tibble: 58 × 9
#>    tailnum  year type         manufacturer model engines seats speed engine
#>    <chr>   <int> <chr>        <chr>        <chr>   <int> <int> <int> <chr> 
#>  1 N302NB   1999 Fixed wing … AIRBUS INDU… A319…       2   145    NA Turbo…
#>  2 N304DQ   2008 Fixed wing … BOEING       737-…       2   149    NA Turbo…
#>  3 N306DQ   2009 Fixed wing … BOEING       737-…       2   149    NA Turbo…
#>  4 N307DQ   2009 Fixed wing … BOEING       737-…       2   149    NA Turbo…
#>  5 N309US   1990 Fixed wing … AIRBUS INDU… A320…       2   182    NA Turbo…
#>  6 N316US   1991 Fixed wing … AIRBUS INDU… A320…       2   182    NA Turbo…
#>  7 N317NB   2000 Fixed wing … AIRBUS INDU… A319…       2   145    NA Turbo…
#>  8 N318NB   2000 Fixed wing … AIRBUS INDU… A319…       2   145    NA Turbo…
#>  9 N318US   1991 Fixed wing … AIRBUS INDU… A320…       2   182    NA Turbo…
#> 10 N322NB   2001 Fixed wing … AIRBUS INDU… A319…       2   145    NA Turbo…
#> # ℹ 48 more rows
```

And indeed, all included flights departed in January (`month == 1`):

``` r
dm_delta_may$flights %>%
  dplyr::count(month)
```

``` fansi
#> # A tibble: 1 × 2
#>   month     n
#>   <int> <int>
#> 1     1    75
```

For comparison, let’s review the equivalent manual query for `flights`
in `dplyr` syntax:

``` r
airlines_filtered <- filter(airlines, name == "Delta Air Lines Inc.")
airports_filtered <- filter(airports, name != "John F Kennedy Intl")
flights %>%
  semi_join(airlines_filtered, by = "carrier") %>%
  semi_join(airports_filtered, by = c("origin" = "faa")) %>%
  filter(month == 5)
```

``` fansi
#> # A tibble: 2,340 × 19
#>     year month   day dep_time sched_dep_time dep_delay arr_time
#>    <int> <int> <int>    <int>          <int>     <dbl>    <int>
#>  1  2013     5     1      554            600        -6      731
#>  2  2013     5     1      555            600        -5      819
#>  3  2013     5     1      603            610        -7      754
#>  4  2013     5     1      622            630        -8      848
#>  5  2013     5     1      654            700        -6      931
#>  6  2013     5     1      655            700        -5      944
#>  7  2013     5     1      656            705        -9     1005
#>  8  2013     5     1      658            700        -2      925
#>  9  2013     5     1      743            745        -2     1014
#> 10  2013     5     1      755            800        -5      929
#> # ℹ 2,330 more rows
#> # ℹ 12 more variables: sched_arr_time <int>, arr_delay <dbl>,
#> #   carrier <chr>, flight <int>, tailnum <chr>, origin <chr>, dest <chr>,
#> #   air_time <dbl>, distance <dbl>, hour <dbl>, minute <dbl>,
#> #   time_hour <dttm>
```

The {dm} code is leaner because the foreign key information is encoded
in the object.

## SQL statements behind filtering a `dm` object on a database

{dm} is meant to work with relational data models, locally as well as on
databases. In your project, the data is probably not stored locally but
in a remote [relational
database](https://dm.cynkra.com/articles/howto-dm-theory.html) that can
be queried with SQL statements.

You can check the queries by using
[`sql_render()`](https://dbplyr.tidyverse.org/reference/sql_build.html)
from the [{dbplyr}](https://dbplyr.tidyverse.org/) package.

Example:

**Print the SQL statements for getting all January 2013 flights from
Delta Air Lines, which did not depart from John F. Kennedy International
Airport, with the data stored in a sqlite database.**

To show the SQL query behind a
[`dm_filter()`](https://dm.cynkra.com/reference/dm_filter.md), we copy
the `flights`, `airlines` and `airports` tables from the `nyflights13`
dataset to a temporary in-memory database using the built-in function
[`copy_dm_to()`](https://dm.cynkra.com/reference/copy_dm_to.md) and
[`dbplyr::src_memdb`](https://dbplyr.tidyverse.org/reference/memdb_frame.html).

Then we filter the data, and print the corresponding SQL statement with
[`dbplyr::sql_render()`](https://dbplyr.tidyverse.org/reference/sql_build.html).

``` r
dm %>%
  dm_select_tbl(flights, airlines, airports) %>%
  copy_dm_to(dbplyr::src_memdb(), .) %>%
  dm_filter(
    airlines = (name == "Delta Air Lines Inc."),
    airports = (name != "John F Kennedy Intl"),
    flights = (month == 1)
  ) %>%
  dm_get_tables() %>%
  purrr::map(dbplyr::sql_render)
#> $flights
#> <SQL> SELECT `LHS`.*
#> FROM (
#>   SELECT `LHS`.*
#>   FROM (
#>     SELECT `flights_1_20200828_071303_12345`.*
#>     FROM `flights_1_20200828_071303_12345`
#>     WHERE ((`month` = 1.0))
#> ) AS `LHS`
#>   WHERE EXISTS (
#>     SELECT 1 FROM `airlines_1_20200828_071303_12345`
#>     WHERE
#>       (`LHS`.`carrier` = `airlines_1_20200828_071303_12345`.`carrier`) AND
#>       ((`airlines_1_20200828_071303_12345`.`name` = 'Delta Air Lines Inc.'))
#>   )
#> ) AS `LHS`
#> WHERE EXISTS (
#>   SELECT 1 FROM `airports_1_20200828_071303_12345`
#>   WHERE
#>     (`LHS`.`origin` = `airports_1_20200828_071303_12345`.`faa`) AND
#>     ((`airports_1_20200828_071303_12345`.`name` != 'John F Kennedy Intl'))
#> )
#> 
#> $airlines
#> <SQL> SELECT `LHS`.*
#> FROM (
#>   SELECT `airlines_1_20200828_071303_12345`.*
#>   FROM `airlines_1_20200828_071303_12345`
#>   WHERE ((`name` = 'Delta Air Lines Inc.'))
#> ) AS `LHS`
#> WHERE EXISTS (
#>   SELECT 1 FROM (
#>   SELECT `LHS`.*
#>   FROM (
#>     SELECT `flights_1_20200828_071303_12345`.*
#>     FROM `flights_1_20200828_071303_12345`
#>     WHERE ((`month` = 1.0))
#> ) AS `LHS`
#>   WHERE EXISTS (
#>     SELECT 1 FROM `airports_1_20200828_071303_12345`
#>     WHERE
#>       (`LHS`.`origin` = `airports_1_20200828_071303_12345`.`faa`) AND
#>       ((`airports_1_20200828_071303_12345`.`name` != 'John F Kennedy Intl'))
#>   )
#> ) AS `RHS`
#>   WHERE (`LHS`.`carrier` = `RHS`.`carrier`)
#> )
#> 
#> $airports
#> <SQL> SELECT `LHS`.*
#> FROM (
#>   SELECT `airports_1_20200828_071303_12345`.*
#>   FROM `airports_1_20200828_071303_12345`
#>   WHERE ((`name` != 'John F Kennedy Intl'))
#> ) AS `LHS`
#> WHERE EXISTS (
#>   SELECT 1 FROM (
#>   SELECT `LHS`.*
#>   FROM (
#>     SELECT `flights_1_20200828_071303_12345`.*
#>     FROM `flights_1_20200828_071303_12345`
#>     WHERE ((`month` = 1.0))
#> ) AS `LHS`
#>   WHERE EXISTS (
#>     SELECT 1 FROM `airlines_1_20200828_071303_12345`
#>     WHERE
#>       (`LHS`.`carrier` = `airlines_1_20200828_071303_12345`.`carrier`) AND
#>       ((`airlines_1_20200828_071303_12345`.`name` = 'Delta Air Lines Inc.'))
#>   )
#> ) AS `RHS`
#>   WHERE (`LHS`.`faa` = `RHS`.`origin`)
#> )
```

Further reading: {dm}’s function for copying data [from and to
databases](https://dm.cynkra.com/articles/howto-dm-copy.html).
