# Joining in relational data models

The {dm} package offers functions to work with relational data models in
R. A common task for multiple, separated tables that have a shared
attribute is merging the data.

This document introduces you to the joining functions of {dm} and shows
how to apply them using data from the
[{nycflights13}](https://github.com/tidyverse/nycflights13) package.

[Relational data
models](https://dm.cynkra.com/articles/howto-dm-theory#model) consist of
multiple tables that are linked with [foreign
keys](https://dm.cynkra.com/articles/howto-dm-theory#fk). They are the
building blocks for joining tables. Read more about relational data
models in the vignette [“Introduction to Relational Data
Models”](https://dm.cynkra.com/articles/howto-dm-theory).

First, we load the packages that we need:

``` r
library(dm)
```

## Data: nycflights13

To explore filtering with {dm}, we’ll use the {nycflights13} data with
its tables `flights`, `planes`, `airlines` and `airports`.

This dataset contains information about the 336,776 flights that
departed from New York City in 2013, with 3,322 different planes and
1,458 airports involved. The data comes from the US Bureau of
Transportation Statistics, and is documented in
[`?nycflights13`](https://dbplyr.tidyverse.org/reference/nycflights13.html).

First, we have to create a `dm` object from the {nycflights13} data.
This is implemented with
[`dm_nycflights13()`](https://dm.cynkra.com/dev/reference/dm_nycflights13.md).

A [data model object](https://dm.cynkra.com/articles/tech-dm-class.html)
contains the data as well as metadata.

If you would like to create a `dm` from other tables, please look at
[`?dm`](https://dm.cynkra.com/dev/reference/dm.md) and the function
[`new_dm()`](https://dm.cynkra.com/dev/reference/dm.md).

``` r
dm <- dm_nycflights13()
```

## Joining a `dm` object

{dm} allows you to join two tables of a `dm` object based on a shared
column. You can use all join functions that you know from the {dplyr}
package. Currently {dplyr} supports four types of mutating joins, two
types of filtering joins, and a nesting join. See
[`?dplyr::join`](https://dplyr.tidyverse.org/reference/mutate-joins.html)
for details.

### How it works

A join is the combination of two tables based on shared information. In
technical terms, we merge the tables that need to be directly connected
by a [foreign key
relation](https://dm.cynkra.com/articles/howto-dm-theory#fk).

The existing links can be inspected in two ways:

1.  Visually, by drawing the data model with
    [`dm_draw()`](https://dm.cynkra.com/dev/reference/dm_draw.md)

``` r
dm %>%
  dm_draw()
```

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjUwcHQiIGhlaWdodD0iMjMwcHQiIHZpZXdib3g9IjAuMDAgMC4wMCAyNTAuMDAgMjMwLjAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIj48ZyBpZD0iZ3JhcGgwIiBjbGFzcz0iZ3JhcGgiIHRyYW5zZm9ybT0ic2NhbGUoMSAxKSByb3RhdGUoMCkgdHJhbnNsYXRlKDQgMjI2KSI+PHRpdGxlPiUwPC90aXRsZT4KPGcgaWQ9ImFfZ3JhcGgwIj48YSB4bGluazp0aXRsZT0iRGF0YSBNb2RlbCI+Cjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iLTQsNCAtNCwtMjI2IDI0NiwtMjI2IDI0Niw0IC00LDQiPjwvcG9seWdvbj48L2E+CjwvZz48IS0tIGFpcmxpbmVzIC0tPjxnIGlkPSJhaXJsaW5lcyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJsaW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZDdkMzEiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY4LjUsLTIwMSAxNjguNSwtMjIxIDIxMy41LC0yMjEgMjEzLjUsLTIwMSAxNjguNSwtMjAxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzAuMzk2OSIgeT0iLTIwNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiNmZmZmZmYiPmFpcmxpbmVzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmYmU1ZDUiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY4LjUsLTE4MSAxNjguNSwtMjAxIDIxMy41LC0yMDEgMjEzLjUsLTE4MSAxNjguNSwtMTgxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzAuNSIgeT0iLTE4Ny40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5jYXJyaWVyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzllNTMyMCIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjE2NywtMTgwIDE2NywtMjIyIDIxNCwtMjIyIDIxNCwtMTgwIDE2NywtMTgwIj48L3BvbHlnb24+PC9nPjwhLS0gYWlycG9ydHMgLS0+PGcgaWQ9ImFpcnBvcnRzIiBjbGFzcz0ibm9kZSI+PHRpdGxlPmFpcnBvcnRzPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iI2VkN2QzMSIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNjcuNSwtODEgMTY3LjUsLTEwMSAyMTMuNSwtMTAxIDIxMy41LC04MSAxNjcuNSwtODEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE2OS4xMTkyIiB5PSItODYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjZmZmZmZmIj5haXJwb3J0czwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmJlNWQ1IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE2Ny41LC02MSAxNjcuNSwtODEgMjEzLjUsLTgxIDIxMy41LC02MSAxNjcuNSwtNjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE2OS41IiB5PSItNjcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+ZmFhPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzllNTMyMCIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjE2Ni41LC02MCAxNjYuNSwtMTAyIDIxNC41LC0xMDIgMjE0LjUsLTYwIDE2Ni41LC02MCI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMgLS0+PGcgaWQ9ImZsaWdodHMiIGNsYXNzPSJub2RlIj48dGl0bGU+ZmxpZ2h0czwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiM1YjliZDUiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC0xNDEgMS41LC0xNjEgMTAyLjUsLTE2MSAxMDIuNSwtMTQxIDEuNSwtMTQxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzNC4xMTE1IiB5PSItMTQ2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iI2ZmZmZmZiI+ZmxpZ2h0czwvdGV4dD48cG9seWdvbiBmaWxsPSIjZGVlYmY2IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtMTIxIDEuNSwtMTQxIDEwMi41LC0xNDEgMTAyLjUsLTEyMSAxLjUsLTEyMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMy41IiB5PSItMTI2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+Y2FycmllcjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZGVlYmY2IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtMTAxIDEuNSwtMTIxIDEwMi41LC0xMjEgMTAyLjUsLTEwMSAxLjUsLTEwMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMy41IiB5PSItMTA2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+dGFpbG51bTwvdGV4dD48cG9seWdvbiBmaWxsPSIjZGVlYmY2IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtODEgMS41LC0xMDEgMTAyLjUsLTEwMSAxMDIuNSwtODEgMS41LC04MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMy41IiB5PSItODYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5vcmlnaW48L3RleHQ+PHBvbHlnb24gZmlsbD0iI2RlZWJmNiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLjUsLTYxIDEuNSwtODEgMTAyLjUsLTgxIDEwMi41LC02MSAxLjUsLTYxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzLjAwNTYiIHk9Ii02Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPm9yaWdpbiwgdGltZV9ob3VyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzNjNjc4ZSIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjAsLTYwIDAsLTE2MiAxMDMsLTE2MiAxMDMsLTYwIDAsLTYwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O2FpcmxpbmVzIC0tPjxnIGlkPSJmbGlnaHRzXzEiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czpjYXJyaWVyLSZndDthaXJsaW5lczpjYXJyaWVyPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTAyLjUsLTEzMUMxMjYuNTY2OCwtMTMxIDEyMC44MDI5LC0xNTUuMjQ5NiAxMzksLTE3MSAxNDcuNzk1NiwtMTc4LjYxMyAxNTEuMDM5NCwtMTg1LjgzMDUgMTU4LjQxNTcsLTE4OS4xMjc3IiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxNTguMDI5MSwtMTkyLjYxNTcgMTY4LjUsLTE5MSAxNTkuMzA3LC0xODUuNzMzMyAxNTguMDI5MSwtMTkyLjYxNTciPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzJiM0NTsmZ3Q7YWlycG9ydHMgLS0+PGcgaWQ9ImZsaWdodHNfMiIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOm9yaWdpbi0mZ3Q7YWlycG9ydHM6ZmFhPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTAyLjUsLTkxQzEyOC45NDczLC05MSAxMzUuNzM2MSwtNzUuNjg3NSAxNTcuMjY4NywtNzEuODU5NCIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTU3LjgyODEsLTc1LjMyNDggMTY3LjUsLTcxIDE1Ny4yNDIxLC02OC4zNDk0IDE1Ny44MjgxLC03NS4zMjQ4Ij48L3BvbHlnb24+PC9nPjwhLS0gcGxhbmVzIC0tPjxnIGlkPSJwbGFuZXMiIGNsYXNzPSJub2RlIj48dGl0bGU+cGxhbmVzPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iI2VkN2QzMSIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNjcuNSwtMTQxIDE2Ny41LC0xNjEgMjEzLjUsLTE2MSAyMTMuNSwtMTQxIDE2Ny41LC0xNDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE3Mi42MTc4IiB5PSItMTQ2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iI2ZmZmZmZiI+cGxhbmVzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmYmU1ZDUiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY3LjUsLTEyMSAxNjcuNSwtMTQxIDIxMy41LC0xNDEgMjEzLjUsLTEyMSAxNjcuNSwtMTIxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNjkuMTExNSIgeT0iLTEyNy40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij50YWlsbnVtPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzllNTMyMCIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjE2Ni41LC0xMjAgMTY2LjUsLTE2MiAyMTQuNSwtMTYyIDIxNC41LC0xMjAgMTY2LjUsLTEyMCI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMmIzQ1OyZndDtwbGFuZXMgLS0+PGcgaWQ9ImZsaWdodHNfMyIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOnRhaWxudW0tJmd0O3BsYW5lczp0YWlsbnVtPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTAyLjUsLTExMUMxMjguOTQ3MywtMTExIDEzNS43MzYxLC0xMjYuMzEyNSAxNTcuMjY4NywtMTMwLjE0MDYiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjE1Ny4yNDIxLC0xMzMuNjUwNiAxNjcuNSwtMTMxIDE1Ny44MjgxLC0xMjYuNjc1MiAxNTcuMjQyMSwtMTMzLjY1MDYiPjwvcG9seWdvbj48L2c+PCEtLSB3ZWF0aGVyIC0tPjxnIGlkPSJ3ZWF0aGVyIiBjbGFzcz0ibm9kZSI+PHRpdGxlPndlYXRoZXI8L3RpdGxlPgo8cG9seWdvbiBmaWxsPSIjNzBhZDQ3IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE0MC41LC0yMSAxNDAuNSwtNDEgMjQxLjUsLTQxIDI0MS41LC0yMSAxNDAuNSwtMjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE2OC44NDkyIiB5PSItMjYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjZmZmZmZmIj53ZWF0aGVyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNlMmVlZGEiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTQwLjUsLTEgMTQwLjUsLTIxIDI0MS41LC0yMSAyNDEuNSwtMSAxNDAuNSwtMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTQyLjAwNTYiIHk9Ii03LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPm9yaWdpbiwgdGltZV9ob3VyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzRhNzMyZiIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjEzOSwwIDEzOSwtNDIgMjQyLC00MiAyNDIsMCAxMzksMCI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMmIzQ1OyZndDt3ZWF0aGVyIC0tPjxnIGlkPSJmbGlnaHRzXzQiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czpvcmlnaW4sIHRpbWVfaG91ci0mZ3Q7d2VhdGhlcjpvcmlnaW4sIHRpbWVfaG91cjwvdGl0bGU+CjxwYXRoIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgZD0iTTEwMi41LC03MUMxMjkuODcyNywtNzEgMTE0LjYxMDEsLTI1Ljg3OTIgMTMwLjY1NzksLTEzLjg5MzkiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjEzMS44OTM1LC0xNy4xNzg5IDE0MC41LC0xMSAxMjkuOTE4OCwtMTAuNDYzMSAxMzEuODkzNSwtMTcuMTc4OSI+PC9wb2x5Z29uPjwvZz48L2c+PC9zdmc+)

The directed arrows show explicitly the relation between different
columns.

2.  Printed to the console by calling
    [`dm_get_all_fks()`](https://dm.cynkra.com/dev/reference/dm_get_all_fks.md)

``` r
dm %>%
  dm_get_all_fks()
```

``` fansi
#> # A tibble: 4 × 5
#>   child_table child_fk_cols     parent_table parent_key_cols   on_delete
#>   <chr>       <keys>            <chr>        <keys>            <chr>    
#> 1 flights     carrier           airlines     carrier           no_action
#> 2 flights     origin            airports     faa               no_action
#> 3 flights     tailnum           planes       tailnum           no_action
#> 4 flights     origin, time_hour weather      origin, time_hour no_action
```

### Joining Examples

Let’s look at some examples:

**Add a column with airline names from the `airlines` table to the
`flights` table.**

``` r
dm_joined <-
  dm %>%
  dm_flatten_to_tbl(flights, airlines, .join = left_join)
dm_joined
```

``` fansi
#> # A tibble: 1,761 × 20
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
#> # ℹ 13 more variables: sched_arr_time <int>, arr_delay <dbl>,
#> #   carrier <chr>, flight <int>, tailnum <chr>, origin <chr>, dest <chr>,
#> #   air_time <dbl>, distance <dbl>, hour <dbl>, minute <dbl>,
#> #   time_hour <dttm>, name <chr>
```

As you can see below, the `dm_joined` data frame has one more column
than the `flights` table. The difference is the `name` column from the
`airlines` table.

``` r
dm$flights %>%
  names()
#>  [1] "year"           "month"          "day"            "dep_time"      
#>  [5] "sched_dep_time" "dep_delay"      "arr_time"       "sched_arr_time"
#>  [9] "arr_delay"      "carrier"        "flight"         "tailnum"       
#> [13] "origin"         "dest"           "air_time"       "distance"      
#> [17] "hour"           "minute"         "time_hour"

dm$airlines %>%
  names()
#> [1] "carrier" "name"

dm_joined %>%
  names()
#>  [1] "year"           "month"          "day"            "dep_time"      
#>  [5] "sched_dep_time" "dep_delay"      "arr_time"       "sched_arr_time"
#>  [9] "arr_delay"      "carrier"        "flight"         "tailnum"       
#> [13] "origin"         "dest"           "air_time"       "distance"      
#> [17] "hour"           "minute"         "time_hour"      "name"
```

The result is not a `dm` object anymore, but a (tibble) data frame:

``` r
dm_joined %>%
  class()
#> [1] "tbl_df"     "tbl"        "data.frame"
```

Another example:

**Get all flights that can’t be matched with airlines names.**

We expect the `flights` data from {nycflights13} package to be clean and
well organized, so no flights should remain. You can check this with an
`anti_join`:

``` r
dm %>%
  dm_flatten_to_tbl(flights, airlines, .join = anti_join)
```

``` fansi
#> # A tibble: 0 × 19
#> # ℹ 19 variables: year <int>, month <int>, day <int>, dep_time <int>,
#> #   sched_dep_time <int>, dep_delay <dbl>, arr_time <int>,
#> #   sched_arr_time <int>, arr_delay <dbl>, carrier <chr>, flight <int>,
#> #   tailnum <chr>, origin <chr>, dest <chr>, air_time <dbl>,
#> #   distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>
```

An example with filtering on a `dm` and then merging:

**Get all May 2013 flights from Delta Air Lines which didn’t depart from
John F. Kennedy International Airport in - and join all the airports
data into the `flights` table.**

``` r
dm_nycflights13(subset = FALSE) %>%
  dm_filter(
    airlines = (name == "Delta Air Lines Inc."),
    airports = (name != "John F Kennedy Intl"),
    flights = (month == 5)
  ) %>% 
  dm_flatten_to_tbl(flights, airports, .join = left_join)
```

``` fansi
#> # A tibble: 2,340 × 26
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
#> # ℹ 19 more variables: sched_arr_time <int>, arr_delay <dbl>,
#> #   carrier <chr>, flight <int>, tailnum <chr>, origin <chr>, dest <chr>,
#> #   air_time <dbl>, distance <dbl>, hour <dbl>, minute <dbl>,
#> #   time_hour <dttm>, name <chr>, lat <dbl>, lon <dbl>, alt <dbl>,
#> #   tz <dbl>, dst <chr>, tzone <chr>
```

See
[`vignette("tech-dm-filter")`](https://dm.cynkra.com/dev/articles/tech-dm-filter.md)
for more details on filtering.

A last example:

**Merge all tables into one big table.**

Sometimes you need everything in one place. In this case, you can use
the
[`dm_flatten_to_tbl()`](https://dm.cynkra.com/dev/reference/dm_flatten_to_tbl.md)
function. It joins all the tables in your `dm` object together into one
wide table. All you have to do is to specify the starting table. The
following joins are determined by the foreign key links.

``` r
dm_nycflights13() %>%
  dm_select_tbl(-weather) %>%
  dm_flatten_to_tbl(.start = flights)
#> Renaming ambiguous columns: %>%
#>   dm_rename(flights, year.flights = year) %>%
#>   dm_rename(airlines, name.airlines = name) %>%
#>   dm_rename(airports, name.airports = name) %>%
#>   dm_rename(planes, year.planes = year)
```

``` fansi
#> # A tibble: 1,761 × 35
#>    year.flights month   day dep_time sched_dep_time dep_delay arr_time
#>           <int> <int> <int>    <int>          <int>     <dbl>    <int>
#>  1         2013     1    10        3           2359         4      426
#>  2         2013     1    10       16           2359        17      447
#>  3         2013     1    10      450            500       -10      634
#>  4         2013     1    10      520            525        -5      813
#>  5         2013     1    10      530            530         0      824
#>  6         2013     1    10      531            540        -9      832
#>  7         2013     1    10      535            540        -5     1015
#>  8         2013     1    10      546            600       -14      645
#>  9         2013     1    10      549            600       -11      652
#> 10         2013     1    10      550            600       -10      649
#> # ℹ 1,751 more rows
#> # ℹ 28 more variables: sched_arr_time <int>, arr_delay <dbl>,
#> #   carrier <chr>, flight <int>, tailnum <chr>, origin <chr>, dest <chr>,
#> #   air_time <dbl>, distance <dbl>, hour <dbl>, minute <dbl>,
#> #   time_hour <dttm>, name.airlines <chr>, name.airports <chr>, lat <dbl>,
#> #   lon <dbl>, alt <dbl>, tz <dbl>, dst <chr>, tzone <chr>,
#> #   year.planes <int>, type <chr>, manufacturer <chr>, model <chr>, …
```

To be more precise,
[`dm_flatten_to_tbl()`](https://dm.cynkra.com/dev/reference/dm_flatten_to_tbl.md)
will join all tables from one level of hierarchy (i.e., direct neighbors
to table `.start`). If you want to cover tables from all levels of
hierarchy, use the argument `recursive = TRUE` for
[`dm_flatten_to_tbl()`](https://dm.cynkra.com/dev/reference/dm_flatten_to_tbl.md)
instead.

Also, be aware that all column names need to be unique. The
[`dm_flatten_to_tbl()`](https://dm.cynkra.com/dev/reference/dm_flatten_to_tbl.md)
takes care of this by automatically renaming the relevant columns and
informs the user if any names were changed,
e.g. `dm_rename(airlines, airlines.name = name)`.

If you want to merge all tables, but get a nested table in return, use
[`dm_wrap_tbl()`](https://dm.cynkra.com/dev/reference/dm_wrap_tbl.md)
with [`pull_tbl()`](https://dm.cynkra.com/dev/reference/pull_tbl.md)
instead:

``` r
dm_nycflights13() %>%
  dm_wrap_tbl(root = flights) %>%
  pull_tbl(flights)
```

``` fansi
#> # A tibble: 1,761 × 23
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
#> # ℹ 16 more variables: sched_arr_time <int>, arr_delay <dbl>,
#> #   carrier <chr>, flight <int>, tailnum <chr>, origin <chr>, dest <chr>,
#> #   air_time <dbl>, distance <dbl>, hour <dbl>, minute <dbl>,
#> #   time_hour <dttm>, airlines <packed[,1]>, airports <packed[,7]>,
#> #   planes <packed[,8]>, weather <packed[,13]>
```
