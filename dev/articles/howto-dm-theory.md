# Introduction to relational data models

Computer scientists are familiar with multiple, linked tables. But,
because many R users tend to have backgrounds in other disciplines, we
present **six important terms in relational data modeling** to help you
to jump-start working with {dm}. These terms are:

1.  [Data Frames and Tables](#tables)
2.  [Data Model](#model)
3.  [Primary Keys](#pk)
4.  [Foreign Keys](#fk)
5.  [Referential Integrity](#referential-integrity)
6.  [Normalization](#normalization)
7.  [Relational Databases](#relational-databases)

## 1. Data Frames and Tables

A data frame is a fundamental data structure in R. Columns represent
variables, rows represent observations. In more technical terms, a data
frame is a list of variables of identical length and unique row names.
If you imagine it visually, the result is a typical table structure.
That is why working with data from spreadsheets is so convenient and the
users of the popular [{dplyr}](https://dplyr.tidyverse.org) package for
data wrangling mainly rely on data frames.

The downside is that data frames and flat file systems like spreadsheets
can result in bloated tables because they hold many repetitive values.
In the worst case, a data frame can contain multiple columns with only a
single value different in each row.

This calls for better data organization by utilizing the resemblance
between data frames and database tables, which also consist of columns
and rows. The elements are just named differently:

| Data Frame | Table                |
|------------|----------------------|
| Column     | Attribute (or Field) |
| Row        | Tuple (or Record)    |

Additionally, number of rows and columns for a data frame are,
respectively, analogous to the *cardinality* and *degree* of the table.

Relational databases, unlike data frames, do not keep all data in one
large table but instead split it into multiple smaller tables. That
separation into sub-tables has several advantages:

- all information is stored only once, avoiding redundancy and
  conserving memory
- all information needs to be updated only once and in one place,
  improving consistency and avoiding errors that may result from
  updating (or forgetting to update) the same value in multiple
  locations
- all information is organized by topic and segmented into smaller
  tables that are easier to handle

It is for these reasons that separation of data helps with data quality,
and they explain the popularity of relational databases in
production-level data management.

The downside of this approach is that it is harder to merge together
information from different data sources and to identify which entities
refer to the same object, a common task when modeling or plotting data.

Thus, to take full advantage of the relational database approach, an
associated **data model** is needed to overcome the challenges that
arise when working with multiple tables.

Let’s illustrate this challenge with the data from the [`nycflights13`
dataset](https://github.com/tidyverse/nycflights13) that contains
detailed information about the 336,776 flights that departed from New
York City in 2013. The information is stored in five tables.

Details like the full name of an airport are not available immediately;
these can only be obtained by joining or merging the constituent tables,
which can result in long and inflated pipe chains full of
[`left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html),
[`anti_join()`](https://dplyr.tidyverse.org/reference/filter-joins.html)
and other forms of data merging.

In classical {dplyr} notation, you will need four
[`left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html)
calls to gradually merge the `flights` table to the `airlines`,
`planes`, `airports`, and `weather` tables to create one wide data
frame.

``` r
library(dm)
library(nycflights13)

nycflights13_df <-
  flights %>%
  left_join(airlines, by = "carrier") %>%
  left_join(planes, by = "tailnum") %>%
  left_join(airports, by = c("origin" = "faa")) %>%
  left_join(weather, by = c("origin", "time_hour"))

nycflights13_df
```

``` fansi
#> # A tibble: 336,776 × 48
#>    year.x month.x day.x dep_time sched_dep_time dep_delay arr_time
#>     <int>   <int> <int>    <int>          <int>     <dbl>    <int>
#>  1   2013       1     1      517            515         2      830
#>  2   2013       1     1      533            529         4      850
#>  3   2013       1     1      542            540         2      923
#>  4   2013       1     1      544            545        -1     1004
#>  5   2013       1     1      554            600        -6      812
#>  6   2013       1     1      554            558        -4      740
#>  7   2013       1     1      555            600        -5      913
#>  8   2013       1     1      557            600        -3      709
#>  9   2013       1     1      557            600        -3      838
#> 10   2013       1     1      558            600        -2      753
#> # ℹ 336,766 more rows
#> # ℹ 41 more variables: sched_arr_time <int>, arr_delay <dbl>,
#> #   carrier <chr>, flight <int>, tailnum <chr>, origin <chr>, dest <chr>,
#> #   air_time <dbl>, distance <dbl>, hour.x <dbl>, minute <dbl>,
#> #   time_hour <dttm>, name.x <chr>, year.y <int>, type <chr>,
#> #   manufacturer <chr>, model <chr>, engines <int>, seats <int>,
#> #   speed <int>, engine <chr>, name.y <chr>, lat <dbl>, lon <dbl>, …
```

{dm} offers a more elegant and shorter way to combine tables while
augmenting {dplyr}/{dbplyr} workflows.

It is possible to have the best of both worlds: manage your data with
{dm} as linked tables, and, when necessary, flatten multiple tables into
a single data frame for analysis with {dplyr}.

The next step is to create a [data model](#model) based on multiple
tables:

## 2. Data Model

A data model shows the structure between multiple tables that are linked
together.

The `nycflights13` relations can be transferred into the following
graphical representation:

``` r
dm <- dm_nycflights13(cycle = TRUE)

dm %>%
  dm_draw()
```

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjUwcHQiIGhlaWdodD0iMjMwcHQiIHZpZXdib3g9IjAuMDAgMC4wMCAyNTAuMDAgMjMwLjAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIj48ZyBpZD0iZ3JhcGgwIiBjbGFzcz0iZ3JhcGgiIHRyYW5zZm9ybT0ic2NhbGUoMSAxKSByb3RhdGUoMCkgdHJhbnNsYXRlKDQgMjI2KSI+PHRpdGxlPiUwPC90aXRsZT4KPGcgaWQ9ImFfZ3JhcGgwIj48YSB4bGluazp0aXRsZT0iRGF0YSBNb2RlbCI+Cjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iLTQsNCAtNCwtMjI2IDI0NiwtMjI2IDI0Niw0IC00LDQiPjwvcG9seWdvbj48L2E+CjwvZz48IS0tIGFpcmxpbmVzIC0tPjxnIGlkPSJhaXJsaW5lcyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJsaW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZDdkMzEiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY4LjUsLTIwMSAxNjguNSwtMjIxIDIxMy41LC0yMjEgMjEzLjUsLTIwMSAxNjguNSwtMjAxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzAuMzk2OSIgeT0iLTIwNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiNmZmZmZmYiPmFpcmxpbmVzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmYmU1ZDUiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY4LjUsLTE4MSAxNjguNSwtMjAxIDIxMy41LC0yMDEgMjEzLjUsLTE4MSAxNjguNSwtMTgxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzAuNSIgeT0iLTE4Ny40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5jYXJyaWVyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzllNTMyMCIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjE2NywtMTgwIDE2NywtMjIyIDIxNCwtMjIyIDIxNCwtMTgwIDE2NywtMTgwIj48L3BvbHlnb24+PC9nPjwhLS0gYWlycG9ydHMgLS0+PGcgaWQ9ImFpcnBvcnRzIiBjbGFzcz0ibm9kZSI+PHRpdGxlPmFpcnBvcnRzPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iI2VkN2QzMSIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNjcuNSwtODEgMTY3LjUsLTEwMSAyMTMuNSwtMTAxIDIxMy41LC04MSAxNjcuNSwtODEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE2OS4xMTkyIiB5PSItODYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjZmZmZmZmIj5haXJwb3J0czwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmJlNWQ1IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE2Ny41LC02MSAxNjcuNSwtODEgMjEzLjUsLTgxIDIxMy41LC02MSAxNjcuNSwtNjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE2OS41IiB5PSItNjcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+ZmFhPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzllNTMyMCIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjE2Ni41LC02MCAxNjYuNSwtMTAyIDIxNC41LC0xMDIgMjE0LjUsLTYwIDE2Ni41LC02MCI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMgLS0+PGcgaWQ9ImZsaWdodHMiIGNsYXNzPSJub2RlIj48dGl0bGU+ZmxpZ2h0czwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiM1YjliZDUiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC0xNDEgMS41LC0xNjEgMTAyLjUsLTE2MSAxMDIuNSwtMTQxIDEuNSwtMTQxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzNC4xMTE1IiB5PSItMTQ2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iI2ZmZmZmZiI+ZmxpZ2h0czwvdGV4dD48cG9seWdvbiBmaWxsPSIjZGVlYmY2IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtMTIxIDEuNSwtMTQxIDEwMi41LC0xNDEgMTAyLjUsLTEyMSAxLjUsLTEyMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMy41IiB5PSItMTI2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+Y2FycmllcjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZGVlYmY2IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtMTAxIDEuNSwtMTIxIDEwMi41LC0xMjEgMTAyLjUsLTEwMSAxLjUsLTEwMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMy41IiB5PSItMTA2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+dGFpbG51bTwvdGV4dD48cG9seWdvbiBmaWxsPSIjZGVlYmY2IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtODEgMS41LC0xMDEgMTAyLjUsLTEwMSAxMDIuNSwtODEgMS41LC04MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMy41IiB5PSItODYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5vcmlnaW48L3RleHQ+PHBvbHlnb24gZmlsbD0iI2RlZWJmNiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLjUsLTYxIDEuNSwtODEgMTAyLjUsLTgxIDEwMi41LC02MSAxLjUsLTYxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzLjUiIHk9Ii02Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmRlc3Q8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2RlZWJmNiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLjUsLTQxIDEuNSwtNjEgMTAyLjUsLTYxIDEwMi41LC00MSAxLjUsLTQxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzLjAwNTYiIHk9Ii00Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPm9yaWdpbiwgdGltZV9ob3VyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzNjNjc4ZSIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjAsLTQwIDAsLTE2MiAxMDMsLTE2MiAxMDMsLTQwIDAsLTQwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O2FpcmxpbmVzIC0tPjxnIGlkPSJmbGlnaHRzXzEiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czpjYXJyaWVyLSZndDthaXJsaW5lczpjYXJyaWVyPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTAyLjUsLTEzMUMxMjYuNTY2OCwtMTMxIDEyMC44MDI5LC0xNTUuMjQ5NiAxMzksLTE3MSAxNDcuNzk1NiwtMTc4LjYxMyAxNTEuMDM5NCwtMTg1LjgzMDUgMTU4LjQxNTcsLTE4OS4xMjc3IiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxNTguMDI5MSwtMTkyLjYxNTcgMTY4LjUsLTE5MSAxNTkuMzA3LC0xODUuNzMzMyAxNTguMDI5MSwtMTkyLjYxNTciPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzJiM0NTsmZ3Q7YWlycG9ydHMgLS0+PGcgaWQ9ImZsaWdodHNfMiIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOm9yaWdpbi0mZ3Q7YWlycG9ydHM6ZmFhPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTAyLjUsLTkxQzEyOC45NDczLC05MSAxMzUuNzM2MSwtNzUuNjg3NSAxNTcuMjY4NywtNzEuODU5NCIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTU3LjgyODEsLTc1LjMyNDggMTY3LjUsLTcxIDE1Ny4yNDIxLC02OC4zNDk0IDE1Ny44MjgxLC03NS4zMjQ4Ij48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O2FpcnBvcnRzIC0tPjxnIGlkPSJmbGlnaHRzXzMiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czpkZXN0LSZndDthaXJwb3J0czpmYWE8L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik0xMDIuNSwtNzFDMTI3LjY2NDksLTcxIDEzNi4zODkxLC03MSAxNTcuMzE1NCwtNzEiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjE1Ny41LC03NC41MDAxIDE2Ny41LC03MSAxNTcuNSwtNjcuNTAwMSAxNTcuNSwtNzQuNTAwMSI+PC9wb2x5Z29uPjwvZz48IS0tIHBsYW5lcyAtLT48ZyBpZD0icGxhbmVzIiBjbGFzcz0ibm9kZSI+PHRpdGxlPnBsYW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZDdkMzEiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY3LjUsLTE0MSAxNjcuNSwtMTYxIDIxMy41LC0xNjEgMjEzLjUsLTE0MSAxNjcuNSwtMTQxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzIuNjE3OCIgeT0iLTE0Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiNmZmZmZmYiPnBsYW5lczwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmJlNWQ1IiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE2Ny41LC0xMjEgMTY3LjUsLTE0MSAyMTMuNSwtMTQxIDIxMy41LC0xMjEgMTY3LjUsLTEyMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTY5LjExMTUiIHk9Ii0xMjcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+dGFpbG51bTwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM5ZTUzMjAiIHN0cm9rZS1vcGFjaXR5PSIwLjY2NjY2NyIgcG9pbnRzPSIxNjYuNSwtMTIwIDE2Ni41LC0xNjIgMjE0LjUsLTE2MiAyMTQuNSwtMTIwIDE2Ni41LC0xMjAiPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzJiM0NTsmZ3Q7cGxhbmVzIC0tPjxnIGlkPSJmbGlnaHRzXzQiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czp0YWlsbnVtLSZndDtwbGFuZXM6dGFpbG51bTwvdGl0bGU+CjxwYXRoIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgZD0iTTEwMi41LC0xMTFDMTI4Ljk0NzMsLTExMSAxMzUuNzM2MSwtMTI2LjMxMjUgMTU3LjI2ODcsLTEzMC4xNDA2IiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxNTcuMjQyMSwtMTMzLjY1MDYgMTY3LjUsLTEzMSAxNTcuODI4MSwtMTI2LjY3NTIgMTU3LjI0MjEsLTEzMy42NTA2Ij48L3BvbHlnb24+PC9nPjwhLS0gd2VhdGhlciAtLT48ZyBpZD0id2VhdGhlciIgY2xhc3M9Im5vZGUiPjx0aXRsZT53ZWF0aGVyPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iIzcwYWQ0NyIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNDAuNSwtMjEgMTQwLjUsLTQxIDI0MS41LC00MSAyNDEuNSwtMjEgMTQwLjUsLTIxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNjguODQ5MiIgeT0iLTI2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iI2ZmZmZmZiI+d2VhdGhlcjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZTJlZWRhIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE0MC41LC0xIDE0MC41LC0yMSAyNDEuNSwtMjEgMjQxLjUsLTEgMTQwLjUsLTEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE0Mi4wMDU2IiB5PSItNy40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5vcmlnaW4sIHRpbWVfaG91cjwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM0YTczMmYiIHN0cm9rZS1vcGFjaXR5PSIwLjY2NjY2NyIgcG9pbnRzPSIxMzksMCAxMzksLTQyIDI0MiwtNDIgMjQyLDAgMTM5LDAiPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzJiM0NTsmZ3Q7d2VhdGhlciAtLT48ZyBpZD0iZmxpZ2h0c181IiBjbGFzcz0iZWRnZSI+PHRpdGxlPmZsaWdodHM6b3JpZ2luLCB0aW1lX2hvdXItJmd0O3dlYXRoZXI6b3JpZ2luLCB0aW1lX2hvdXI8L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik0xMDIuNSwtNTFDMTIyLjgwNjUsLTUxIDExOC43MjQxLC0yMy41Njg0IDEzMC42NDY5LC0xNC4xMzg3IiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxMzIuMDM0MSwtMTcuMzcwMiAxNDAuNSwtMTEgMTI5LjkwOTQsLTEwLjcwMDQgMTMyLjAzNDEsLTE3LjM3MDIiPjwvcG9seWdvbj48L2c+PC9nPjwvc3ZnPg==)

The `flights` table is linked to four other tables: `airlines`,
`planes`, `weather`, and `airports`. By using directed arrows, the
visualization shows explicitly the connection between different columns
(they are called attributes in the relational data sphere).

For example: The column `carrier` in `flights` can be joined with the
column `carrier` from the `airlines` table.

The links between the tables are established through [primary keys](#pk)
and [foreign keys](#fk).

As an aside, we can also now see how avoiding redundant data by building
data models with multiple tables can save memory compared to storing
data in single a data frame:

``` r
object.size(dm)
#> 476256 bytes

object.size(nycflights13_df)
#> 108020824 bytes
```

Further Reading: The {dm} methods for [visualizing data
models](https://dm.cynkra.com/articles/tech-dm-draw.html).

## 3. Primary Keys

In a relational data model, each table should have **one or several
columns that uniquely identify a row**. These columns define the
*primary key* (abbreviated with “pk”). If the key consists of a single
column, it is called a *simple key*. A key consisting of more than one
column is called a *compound key*.

Example: In the `airlines` table of `nycflights13` the column `carrier`
is the primary key, a simple key. The `weather` table has the
combination of `origin` and `time_hour` as primary key, a compound key.

You can get all primary keys in a `dm` by calling
[`dm_get_all_pks()`](https://dm.cynkra.com/dev/reference/dm_get_all_pks.md):

``` r
dm %>%
  dm_get_all_pks()
```

``` fansi
#> # A tibble: 4 × 3
#>   table    pk_col            autoincrement
#>   <chr>    <keys>            <lgl>        
#> 1 airlines carrier           FALSE        
#> 2 airports faa               FALSE        
#> 3 planes   tailnum           FALSE        
#> 4 weather  origin, time_hour FALSE
```

[`dm_enum_pk_candidates()`](https://dm.cynkra.com/dev/reference/dm_enum_pk_candidates.md)
checks suitability of each column to serve as a simple primary key:

``` r
dm %>%
  dm_enum_pk_candidates(airports)
```

``` fansi
#> # A tibble: 8 × 3
#>   columns candidate why                                                    
#>   <keys>  <lgl>     <chr>                                                  
#> 1 faa     TRUE      ""                                                     
#> 2 name    TRUE      ""                                                     
#> 3 lat     TRUE      ""                                                     
#> 4 lon     TRUE      ""                                                     
#> 5 alt     FALSE     "has duplicate values: 30 (4), 13 (3), 9 (2), 19 (2), …
#> 6 tz      FALSE     "has duplicate values: -5 (48), -6 (21), -8 (12), -7 (…
#> 7 dst     FALSE     "has duplicate values: A (84), N (2)"                  
#> 8 tzone   FALSE     "has duplicate values: America/New_York (48), America/…
```

Further Reading: The {dm} package offers several functions for dealing
with [primary keys](https://dm.cynkra.com/articles/tech-dm-class.html).

## 4. Foreign Keys

The **counterpart of a primary key in one table is the foreign key in
another table**. In order to join two tables, the primary key of the
first table needs to be referenced from the second table. This column or
these columns are called the *foreign key* (abbreviated with “fk”).

For example, if you want to link the `airlines` table to the `flights`
table, the primary key in `airlines` needs to match the foreign key in
`flights`. This condition is satisfied because the column `carrier` is
present as a primary key in the `airlines` table as well as a foreign
key in the `flights` table. In the case of compound keys, the `origin`
and `time_hour` columns (which form the primary key of the `weather`
table) are also present in the `flights` table.

You can find foreign key candidates for simple keys with the function
[`dm_enum_fk_candidates()`](https://dm.cynkra.com/dev/reference/dm_enum_fk_candidates.md);
they are marked with `TRUE` in the `candidate` column.

``` r
dm %>%
  dm_enum_fk_candidates(flights, airlines)
```

``` fansi
#> # A tibble: 19 × 3
#>    columns        candidate why                                            
#>    <keys>         <lgl>     <chr>                                          
#>  1 carrier        TRUE      ""                                             
#>  2 year           FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with…
#>  3 month          FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with…
#>  4 day            FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with…
#>  5 dep_time       FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with…
#>  6 sched_dep_time FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with…
#>  7 dep_delay      FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with…
#>  8 arr_time       FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with…
#>  9 sched_arr_time FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with…
#> 10 arr_delay      FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with…
#> 11 flight         FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with…
#> 12 tailnum        FALSE     "values of `flights$tailnum` not in `airlines$…
#> 13 origin         FALSE     "values of `flights$origin` not in `airlines$c…
#> 14 dest           FALSE     "values of `flights$dest` not in `airlines$car…
#> 15 air_time       FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with…
#> 16 distance       FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with…
#> 17 hour           FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with…
#> 18 minute         FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with…
#> 19 time_hour      FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with…
```

Additionally, you can also extract a summary of all foreign key
relations present in a `dm` object using
[`dm_get_all_fks()`](https://dm.cynkra.com/dev/reference/dm_get_all_fks.md):

``` r
dm %>%
  dm_get_all_fks()
```

``` fansi
#> # A tibble: 5 × 5
#>   child_table child_fk_cols     parent_table parent_key_cols   on_delete
#>   <chr>       <keys>            <chr>        <keys>            <chr>    
#> 1 flights     carrier           airlines     carrier           no_action
#> 2 flights     origin            airports     faa               no_action
#> 3 flights     dest              airports     faa               no_action
#> 4 flights     tailnum           planes       tailnum           no_action
#> 5 flights     origin, time_hour weather      origin, time_hour no_action
```

Further Reading: All {dm} functions for working with [foreign
keys](https://dm.cynkra.com/articles/tech-dm-class.html).

## 5. Referential Integrity

A data set has referential integrity if all relations between tables are
valid. That is, every foreign key holds a primary key that is present in
the parent table. If a foreign key contains a reference where the
corresponding row in the parent table is not available, that row is an
orphan row and the database no longer has referential integrity.

{dm} allows checking referential integrity with the
[`dm_examine_constraints()`](https://dm.cynkra.com/dev/reference/dm_examine_constraints.md)
function. The following conditions are checked:

- All primary key values must be unique and not missing (i.e., `NA`s are
  not allowed).
- Each foreign key value must have a corresponding primary key value.

In the example data model, for a substantial share of the flights,
detailed information for the corresponding airplane is not available:

``` r
dm %>%
  dm_examine_constraints()
```

``` fansi
#> ! Unsatisfied constraints:
```

``` fansi
#> • Table `flights`: foreign key `dest` into table `airports`: values of `flights$dest` not in `airports$faa`: SJU (30), BQN (6), STT (4), PSE (2)
#> • Table `flights`: foreign key `tailnum` into table `planes`: values of `flights$tailnum` not in `planes$tailnum`: N725MQ (6), N537MQ (5), N722MQ (5), N730MQ (5), N736MQ (5), …
```

Establishing referential integrity is important for providing clean data
for analysis or downstream users. See
[`vignette("howto-dm-rows")`](https://dm.cynkra.com/dev/articles/howto-dm-rows.md)
for more information on adding, deleting, or updating individual rows,
and
[`vignette("tech-dm-zoom")`](https://dm.cynkra.com/dev/articles/tech-dm-zoom.md)
for operations on the data in a data model.

## 6. Normalization

Normalization is a technical term that describes the **central design
principle of a relational data model**: splitting data into multiple
tables.

A normalized data schema consists of several relations (tables) that are
linked with attributes (columns). The relations can be joined together
by means of [primary](#pk) and [foreign keys](#fk). The main goal of
normalization is to keep data organization as clean and simple as
possible by avoiding redundant data entries.

For example, if you want to change the name of one airport in the
`nycflights13` dataset, you will only need to update a single data
value. This principle is sometimes called the *single point of truth*.

``` r
#  Update in one single location...
airlines[airlines$carrier == "UA", "name"] <- "United broke my guitar"

airlines %>%
  filter(carrier == "UA")
```

``` fansi
#> # A tibble: 1 × 2
#>   carrier name                  
#>   <chr>   <chr>                 
#> 1 UA      United broke my guitar
```

``` r

# ...propagates to all related records
flights %>%
  left_join(airlines) %>%
  select(flight, name)
```

``` fansi
#> Joining with `by = join_by(carrier)`
```

``` fansi
#> # A tibble: 336,776 × 2
#>    flight name                    
#>     <int> <chr>                   
#>  1   1545 United broke my guitar  
#>  2   1714 United broke my guitar  
#>  3   1141 American Airlines Inc.  
#>  4    725 JetBlue Airways         
#>  5    461 Delta Air Lines Inc.    
#>  6   1696 United broke my guitar  
#>  7    507 JetBlue Airways         
#>  8   5708 ExpressJet Airlines Inc.
#>  9     79 JetBlue Airways         
#> 10    301 American Airlines Inc.  
#> # ℹ 336,766 more rows
```

Another way to demonstrate normalization is splitting a table into two
parts.

Let’s look at the `planes` table, which consists of 3322 individual tail
numbers and corresponding information for the specific airplane, like
the year it was manufactured or the average cruising speed.

The function
[`decompose_table()`](https://dm.cynkra.com/dev/reference/decompose_table.md)
extracts two new tables and creates a new key `model_id`, that links
both tables.

This results in a `parent_table` and a `child_table` that differ
massively in the number of rows:

``` r
planes %>%
  decompose_table(model_id, model, manufacturer, type, engines, seats, speed)
```

``` fansi
#> $child_table
#> # A tibble: 3,322 × 4
#>    tailnum  year engine    model_id
#>    <chr>   <int> <chr>        <int>
#>  1 N10156   2004 Turbo-fan      120
#>  2 N102UW   1998 Turbo-fan       93
#>  3 N103US   1999 Turbo-fan       93
#>  4 N104UW   1999 Turbo-fan       93
#>  5 N10575   2002 Turbo-fan      119
#>  6 N105UW   1999 Turbo-fan       93
#>  7 N107US   1999 Turbo-fan       93
#>  8 N108UW   1999 Turbo-fan       93
#>  9 N109UW   1999 Turbo-fan       93
#> 10 N110UW   1999 Turbo-fan       93
#> # ℹ 3,312 more rows
#> 
#> $parent_table
#> # A tibble: 147 × 7
#>    model_id model       manufacturer     type           engines seats speed
#>       <int> <chr>       <chr>            <chr>            <int> <int> <int>
#>  1      120 EMB-145XR   EMBRAER          Fixed wing mu…       2    55    NA
#>  2       93 A320-214    AIRBUS INDUSTRIE Fixed wing mu…       2   182    NA
#>  3      119 EMB-145LR   EMBRAER          Fixed wing mu…       2    55    NA
#>  4       39 737-824     BOEING           Fixed wing mu…       2   149    NA
#>  5       68 767-332     BOEING           Fixed wing mu…       2   330    NA
#>  6       52 757-224     BOEING           Fixed wing mu…       2   178    NA
#>  7       94 A320-214    AIRBUS           Fixed wing mu…       2   182    NA
#>  8      112 CL-600-2D24 BOMBARDIER INC   Fixed wing mu…       2    95    NA
#>  9       30 737-724     BOEING           Fixed wing mu…       2   149    NA
#> 10       27 737-524     BOEING           Fixed wing mu…       2   149    NA
#> # ℹ 137 more rows
```

While `child_table` contains 3322 unique `tailnum` rows and therefore
consists of 3322 rows, just like the original `planes` table, the
`parent_table` shrunk to just 147 rows, enough to store all relevant
combinations and avoid storing redundant information.

Further Reading: See the [Simple English Wikipedia article on database
normalization](https://simple.wikipedia.org/wiki/Database_normalisation)
for more details.

## 7. Relational Databases

{dm} is built upon relational data models but it is not a database
itself. Databases are systems for data management and many of them are
constructed as relational databases (e.g., SQLite, MySQL, MSSQL,
Postgres, etc.). As you can guess from the names of the databases, SQL,
short for Structured Querying Language, plays an important role: it was
invented for the purpose of querying relational databases.

In production, the data is stored in a relational database and {dm} is
used to work with the data.

Therefore, {dm} can copy data [from and to
databases](https://dm.cynkra.com/articles/howto-dm-copy.html), and works
transparently with both in-memory data and with relational database
systems.

For example, let’s create a local SQLite database and copy the `dm`
object to it:

``` r
con_sqlite <- DBI::dbConnect(RSQLite::SQLite())
con_sqlite
#> <SQLiteConnection>
#>   Path: 
#>   Extensions: TRUE
DBI::dbListTables(con_sqlite)
#> character(0)

copy_dm_to(con_sqlite, dm)
DBI::dbListTables(con_sqlite)
#> [1] "airlines_1_20200828_071303_12345" "airports_1_20200828_071303_12345"
#> [3] "flights_1_20200828_071303_12345"  "planes_1_20200828_071303_12345"  
#> [5] "weather_1_20200828_071303_12345"
```

In the opposite direction, `dm` can also be populated with data from a
database. Unfortunately, keys currently can be learned only for
Microsoft SQL Server and Postgres, but not for SQLite. Therefore, the
`dm` contains the tables but not the keys:

``` r
dm_from_con(con_sqlite)
```

``` fansi
#> ! unable to fetch autoincrement metadata for src 'src_SQLiteConnection'
```

    #> Keys could not be queried.

``` fansi
#> ── Table source ───────────────────────────────────────────────────────────
#> src:  sqlite 3.51.0 []
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `airlines_1_20200828_071303_12345`, `airports_1_20200828_071303_12345`, `flights_1_20200828_071303_12345`, `planes_1_20200828_071303_12345`, `weather_1_20200828_071303_12345`
#> Columns: 53
#> Primary keys: 0
#> Foreign keys: 0
```

Remember to terminate the database connection:

``` r
DBI::dbDisconnect(con_sqlite)
```

## Conclusion

In this article, we have learned about some of the most fundamental
concepts and data structures associated with the relational database
management system (RDBMS).

## Further reading

[`vignette("howto-dm-db")`](https://dm.cynkra.com/dev/articles/howto-dm-db.md)
– This article covers accessing and working with RDBMSs within your R
session, including manipulating data, filling in missing relationships
between tables, getting data out of the RDBMS and into your model, and
deploying your data model to an RDBMS.

[`vignette("howto-dm-df")`](https://dm.cynkra.com/dev/articles/howto-dm-df.md)
– Is your data in local data frames? This article covers creating a data
model from your local data frames, including building the relationships
in your data model, verifying your model, and leveraging the power of
dplyr to operate on your data model.
