# Create a dm object from data frames

dm allows you to create your own relational data models from local data
frames. Once your data model is complete, you can deploy it to a range
of database management systems (DBMS) using {dm}.

## Creating a dm object from data frames

The example data set that we will be using is available through the
[`nycflights13`](https://github.com/tidyverse/nycflights13) package. The
five tables that we are working with contain information about all
flights that departed from the airports of New York to other
destinations in the United States in 2013:

- `flights` represents the trips taken by planes
- `airlines` includes
  - the names of transport organizations (`name`)
  - their abbreviated codes (`carrier`)
- `airports` indicates the ports of departure (`origin`) and of
  destination (`dest`)
- `weather` contains meteorological information at each hour
- `planes` describes characteristics of the aircraft

Once we’ve loaded {nycflights13}, the aforementioned tables are all in
our work environment, ready to be accessed.

``` r
library(nycflights13)

airports
```

``` fansi
#> # A tibble: 1,458 × 8
#>    faa   name                            lat    lon   alt    tz dst   tzone
#>    <chr> <chr>                         <dbl>  <dbl> <dbl> <dbl> <chr> <chr>
#>  1 04G   Lansdowne Airport              41.1  -80.6  1044    -5 A     Amer…
#>  2 06A   Moton Field Municipal Airport  32.5  -85.7   264    -6 A     Amer…
#>  3 06C   Schaumburg Regional            42.0  -88.1   801    -6 A     Amer…
#>  4 06N   Randall Airport                41.4  -74.4   523    -5 A     Amer…
#>  5 09J   Jekyll Island Airport          31.1  -81.4    11    -5 A     Amer…
#>  6 0A9   Elizabethton Municipal Airpo…  36.4  -82.2  1593    -5 A     Amer…
#>  7 0G6   Williams County Airport        41.5  -84.5   730    -5 A     Amer…
#>  8 0G7   Finger Lakes Regional Airport  42.9  -76.8   492    -5 A     Amer…
#>  9 0P2   Shoestring Aviation Airfield   39.8  -76.6  1000    -5 U     Amer…
#> 10 0S9   Jefferson County Intl          48.1 -123.    108    -8 A     Amer…
#> # ℹ 1,448 more rows
```

Your own data will probably not be available as an R package. Whatever
format it is in, you will need to be able to load it as data frames into
your R session. If the data is too large, consider using dm to connect
to the database instead. See
[`vignette("howto-dm-db")`](https://dm.cynkra.com/articles/howto-dm-db.md)
for details on using dm with databases.

## Adding Tables

Our first step will be to tell `dm` which tables we want to work with
and how they are connected. For that we can use
[`dm()`](https://dm.cynkra.com/reference/dm.md), passing in the table
names as arguments.

``` r
library(dm)

flights_dm_no_keys <- dm(airlines, airports, flights, planes, weather)
flights_dm_no_keys
```

``` fansi
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#> Columns: 53
#> Primary keys: 0
#> Foreign keys: 0
```

The [`as_dm()`](https://dm.cynkra.com/reference/dm.md) function is an
alternative that works if you already have a list of tables.

## A dm is a list

`dm` objects behave like lists with a user- and console-friendly print
format. In fact, using a dm as a nicer list for organizing your data
frames in your environment is an easy first step towards using dm and
its data modeling functionality.

Subsetting syntax for a `dm` object (either by subscript or by name) is
similar to syntax for lists, and so you don’t need to learn any
additional syntax to work with `dm` objects.

``` r
names(flights_dm_no_keys)
#> [1] "airlines" "airports" "flights"  "planes"   "weather"
flights_dm_no_keys$airports
```

``` fansi
#> # A tibble: 1,458 × 8
#>    faa   name                            lat    lon   alt    tz dst   tzone
#>    <chr> <chr>                         <dbl>  <dbl> <dbl> <dbl> <chr> <chr>
#>  1 04G   Lansdowne Airport              41.1  -80.6  1044    -5 A     Amer…
#>  2 06A   Moton Field Municipal Airport  32.5  -85.7   264    -6 A     Amer…
#>  3 06C   Schaumburg Regional            42.0  -88.1   801    -6 A     Amer…
#>  4 06N   Randall Airport                41.4  -74.4   523    -5 A     Amer…
#>  5 09J   Jekyll Island Airport          31.1  -81.4    11    -5 A     Amer…
#>  6 0A9   Elizabethton Municipal Airpo…  36.4  -82.2  1593    -5 A     Amer…
#>  7 0G6   Williams County Airport        41.5  -84.5   730    -5 A     Amer…
#>  8 0G7   Finger Lakes Regional Airport  42.9  -76.8   492    -5 A     Amer…
#>  9 0P2   Shoestring Aviation Airfield   39.8  -76.6  1000    -5 U     Amer…
#> 10 0S9   Jefferson County Intl          48.1 -123.    108    -8 A     Amer…
#> # ℹ 1,448 more rows
```

``` r
flights_dm_no_keys[c("airports", "flights")]
```

``` fansi
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `airports`, `flights`
#> Columns: 27
#> Primary keys: 0
#> Foreign keys: 0
```

## Defining Keys

Even though we now have a `dm` object that contains all our data, we
have not specified how our five tables are connected. To do this, we
need to define primary keys and foreign keys on the tables.

Primary keys and foreign keys are how relational database tables are
linked with each other. A primary key is a column or column tuple that
has a unique value for each row within a table. A foreign key is a
column or column tuple containing the primary key for a row in another
table. Foreign keys act as cross references between tables. They specify
the relationships that gives us the *relational* database. For more
information on keys and a crash course on databases, see
[`vignette("howto-dm-theory")`](https://dm.cynkra.com/articles/howto-dm-theory.md).

## Primary Keys

`dm` offers
[`dm_enum_pk_candidates()`](https://dm.cynkra.com/reference/dm_enum_pk_candidates.md)
to identify viable primary keys for a table in the `dm` object, and
[`dm_add_pk()`](https://dm.cynkra.com/reference/dm_add_pk.md) to add
them.

``` r
dm_enum_pk_candidates(
  dm = flights_dm_no_keys,
  table = planes
)
```

``` fansi
#> # A tibble: 9 × 3
#>   columns      candidate why                                               
#>   <keys>       <lgl>     <chr>                                             
#> 1 tailnum      TRUE      ""                                                
#> 2 year         FALSE     "has duplicate values: 2001 (284), 2000 (244), 20…
#> 3 type         FALSE     "has duplicate values: Fixed wing multi engine (3…
#> 4 manufacturer FALSE     "has duplicate values: BOEING (1630), AIRBUS INDU…
#> 5 model        FALSE     "has duplicate values: 737-7H4 (361), A320-232 (2…
#> 6 engines      FALSE     "has duplicate values: 2 (3288), 1 (27), 4 (4), 3…
#> 7 seats        FALSE     "has duplicate values: 149 (452), 140 (411), 55 (…
#> 8 speed        FALSE     "has 3299 missing values, and duplicate values: 4…
#> 9 engine       FALSE     "has duplicate values: Turbo-fan (2750), Turbo-je…
```

Now, we can add the identified primary keys:

``` r
flights_dm_only_pks <-
  flights_dm_no_keys %>%
  dm_add_pk(table = airlines, columns = carrier) %>%
  dm_add_pk(airports, faa) %>%
  dm_add_pk(planes, tailnum) %>%
  dm_add_pk(weather, c(origin, time_hour))
flights_dm_only_pks
```

``` fansi
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#> Columns: 53
#> Primary keys: 4
#> Foreign keys: 0
```

Note that {dm} functions work with both named and positional argument
specification, and compound keys can be specified using a vector
argument.

## Foreign Keys

To define how our tables are related, we use
[`dm_add_fk()`](https://dm.cynkra.com/reference/dm_add_fk.md) to add
foreign keys. Naturally, this function will deal with two tables: a
table *looking for* a reference, and a table that is *providing* the
reference. Accordingly, while calling
[`dm_add_fk()`](https://dm.cynkra.com/reference/dm_add_fk.md), the
`table` argument specifies the table that needs a foreign key to link it
to a second table, and the `ref_table` argument specifies the table to
be linked to, which needs a primary key already defined for it.

``` r
dm_enum_fk_candidates(
  dm = flights_dm_only_pks,
  table = flights,
  ref_table = airlines
)
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

Having chosen a column from the successful candidates provided by
[`dm_enum_fk_candidates()`](https://dm.cynkra.com/reference/dm_enum_fk_candidates.md),
we use the [`dm_add_fk()`](https://dm.cynkra.com/reference/dm_add_fk.md)
function to establish the foreign key linking the tables. In the second
call to [`dm_add_fk()`](https://dm.cynkra.com/reference/dm_add_fk.md) we
complete the process for the `flights` and `airlines` tables that we
started above. The `carrier` column in the `airlines` table will be
added as the foreign key in `flights`.

``` r
flights_dm_all_keys <-
  flights_dm_only_pks %>%
  dm_add_fk(table = flights, columns = tailnum, ref_table = planes) %>%
  dm_add_fk(flights, carrier, airlines) %>%
  dm_add_fk(flights, origin, airports) %>%
  dm_add_fk(flights, c(origin, time_hour), weather)
flights_dm_all_keys
```

``` fansi
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#> Columns: 53
#> Primary keys: 4
#> Foreign keys: 4
```

Having created the required primary and foreign keys to link all the
tables together, we now have a relational data model we can work with.

## Visualization

Visualizing a data model is a quick and easy way to verify that we have
successfully created the model we were aiming for. We can use
[`dm_draw()`](https://dm.cynkra.com/reference/dm_draw.md) at any stage
of the process to generate a visual representation of the tables and the
links between them:

``` r
flights_dm_no_keys %>%
  dm_draw(rankdir = "TB", view_type = "all")
```

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDE5cHQiIGhlaWdodD0iNDQ5cHQiIHZpZXdib3g9IjAuMDAgMC4wMCA0MTkuMDAgNDQ5LjAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIj48ZyBpZD0iZ3JhcGgwIiBjbGFzcz0iZ3JhcGgiIHRyYW5zZm9ybT0ic2NhbGUoMSAxKSByb3RhdGUoMCkgdHJhbnNsYXRlKDQgNDQ1KSI+PHRpdGxlPiUwPC90aXRsZT4KPGcgaWQ9ImFfZ3JhcGgwIj48YSB4bGluazp0aXRsZT0iRGF0YSBNb2RlbCI+Cjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iLTQsNCAtNCwtNDQ1IDQxNSwtNDQ1IDQxNSw0IC00LDQiPjwvcG9seWdvbj48L2E+CjwvZz48IS0tIGFpcmxpbmVzIC0tPjxnIGlkPSJhaXJsaW5lcyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJsaW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMzksLTE0MyAzOSwtMTYzIDg0LC0xNjMgODQsLTE0MyAzOSwtMTQzIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSI0MC44OTY5IiB5PSItMTQ4LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzAwMDAwMCI+YWlybGluZXM8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIzOSwtMTIzIDM5LC0xNDMgODQsLTE0MyA4NCwtMTIzIDM5LC0xMjMiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjQxIiB5PSItMTI4LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+Y2FycmllcjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjM5LC0xMDMgMzksLTEyMyA4NCwtMTIzIDg0LC0xMDMgMzksLTEwMyI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iNDEiIHk9Ii0xMDguNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5uYW1lPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIzNy41LC0xMDIgMzcuNSwtMTY0IDg0LjUsLTE2NCA4NC41LC0xMDIgMzcuNSwtMTAyIj48L3BvbHlnb24+PC9nPjwhLS0gYWlycG9ydHMgLS0+PGcgaWQ9ImFpcnBvcnRzIiBjbGFzcz0ibm9kZSI+PHRpdGxlPmFpcnBvcnRzPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iI2VmZWJkZCIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIzNjEsLTE3OCAzNjEsLTE5OCA0MDcsLTE5OCA0MDcsLTE3OCAzNjEsLTE3OCI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMzYyLjYxOTIiIHk9Ii0xODMuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjMDAwMDAwIj5haXJwb3J0czwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjM2MSwtMTU4IDM2MSwtMTc4IDQwNywtMTc4IDQwNywtMTU4IDM2MSwtMTU4Ij48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzNjMiIHk9Ii0xNjMuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5mYWE8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIzNjEsLTEzOCAzNjEsLTE1OCA0MDcsLTE1OCA0MDcsLTEzOCAzNjEsLTEzOCI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMzYzIiB5PSItMTQzLjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+bmFtZTwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjM2MSwtMTE4IDM2MSwtMTM4IDQwNywtMTM4IDQwNywtMTE4IDM2MSwtMTE4Ij48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzNjMiIHk9Ii0xMjMuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5sYXQ8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIzNjEsLTk4IDM2MSwtMTE4IDQwNywtMTE4IDQwNywtOTggMzYxLC05OCI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMzYzIiB5PSItMTAzLjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+bG9uPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMzYxLC03OCAzNjEsLTk4IDQwNywtOTggNDA3LC03OCAzNjEsLTc4Ij48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzNjMiIHk9Ii04My40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmFsdDwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjM2MSwtNTggMzYxLC03OCA0MDcsLTc4IDQwNywtNTggMzYxLC01OCI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMzYzIiB5PSItNjMuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij50ejwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjM2MSwtMzggMzYxLC01OCA0MDcsLTU4IDQwNywtMzggMzYxLC0zOCI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMzYzIiB5PSItNDMuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5kc3Q8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIzNjEsLTE4IDM2MSwtMzggNDA3LC0zOCA0MDcsLTE4IDM2MSwtMTgiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjM2MyIgeT0iLTIzLjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+dHpvbmU8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjM2MCwtMTcgMzYwLC0xOTkgNDA4LC0xOTkgNDA4LC0xNyAzNjAsLTE3Ij48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyAtLT48ZyBpZD0iZmxpZ2h0cyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5mbGlnaHRzPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iI2VmZWJkZCIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxMjAsLTM4MSAxMjAsLTQwMSAyMTQsLTQwMSAyMTQsLTM4MSAxMjAsLTM4MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTQ5LjExMTUiIHk9Ii0zODYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjMDAwMDAwIj5mbGlnaHRzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTIwLC0zNjEgMTIwLC0zODEgMjE0LC0zODEgMjE0LC0zNjEgMTIwLC0zNjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjEyMiIgeT0iLTM2Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPnllYXI8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxMjAsLTM0MSAxMjAsLTM2MSAyMTQsLTM2MSAyMTQsLTM0MSAxMjAsLTM0MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTIyIiB5PSItMzQ2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+bW9udGg8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxMjAsLTMyMSAxMjAsLTM0MSAyMTQsLTM0MSAyMTQsLTMyMSAxMjAsLTMyMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTIyIiB5PSItMzI2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+ZGF5PC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTIwLC0zMDEgMTIwLC0zMjEgMjE0LC0zMjEgMjE0LC0zMDEgMTIwLC0zMDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjEyMiIgeT0iLTMwNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmRlcF90aW1lPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTIwLC0yODEgMTIwLC0zMDEgMjE0LC0zMDEgMjE0LC0yODEgMTIwLC0yODEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjEyMS41MTI2IiB5PSItMjg2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+c2NoZWRfZGVwX3RpbWU8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxMjAsLTI2MSAxMjAsLTI4MSAyMTQsLTI4MSAyMTQsLTI2MSAxMjAsLTI2MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTIyIiB5PSItMjY2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+ZGVwX2RlbGF5PC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTIwLC0yNDEgMTIwLC0yNjEgMjE0LC0yNjEgMjE0LC0yNDEgMTIwLC0yNDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjEyMiIgeT0iLTI0Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmFycl90aW1lPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTIwLC0yMjEgMTIwLC0yNDEgMjE0LC0yNDEgMjE0LC0yMjEgMTIwLC0yMjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjEyMiIgeT0iLTIyNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPnNjaGVkX2Fycl90aW1lPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTIwLC0yMDEgMTIwLC0yMjEgMjE0LC0yMjEgMjE0LC0yMDEgMTIwLC0yMDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjEyMiIgeT0iLTIwNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmFycl9kZWxheTwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEyMCwtMTgxIDEyMCwtMjAxIDIxNCwtMjAxIDIxNCwtMTgxIDEyMCwtMTgxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxMjIiIHk9Ii0xODYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5jYXJyaWVyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTIwLC0xNjEgMTIwLC0xODEgMjE0LC0xODEgMjE0LC0xNjEgMTIwLC0xNjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjEyMiIgeT0iLTE2Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmZsaWdodDwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEyMCwtMTQxIDEyMCwtMTYxIDIxNCwtMTYxIDIxNCwtMTQxIDEyMCwtMTQxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxMjIiIHk9Ii0xNDYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij50YWlsbnVtPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTIwLC0xMjEgMTIwLC0xNDEgMjE0LC0xNDEgMjE0LC0xMjEgMTIwLC0xMjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjEyMiIgeT0iLTEyNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPm9yaWdpbjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEyMCwtMTAxIDEyMCwtMTIxIDIxNCwtMTIxIDIxNCwtMTAxIDEyMCwtMTAxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxMjIiIHk9Ii0xMDYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5kZXN0PC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTIwLC04MSAxMjAsLTEwMSAyMTQsLTEwMSAyMTQsLTgxIDEyMCwtODEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjEyMiIgeT0iLTg2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+YWlyX3RpbWU8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxMjAsLTYxIDEyMCwtODEgMjE0LC04MSAyMTQsLTYxIDEyMCwtNjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjEyMiIgeT0iLTY2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+ZGlzdGFuY2U8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxMjAsLTQxIDEyMCwtNjEgMjE0LC02MSAyMTQsLTQxIDEyMCwtNDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjEyMiIgeT0iLTQ2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+aG91cjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEyMCwtMjEgMTIwLC00MSAyMTQsLTQxIDIxNCwtMjEgMTIwLC0yMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTIyIiB5PSItMjYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5taW51dGU8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxMjAsLTEgMTIwLC0yMSAyMTQsLTIxIDIxNCwtMSAxMjAsLTEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjEyMiIgeT0iLTYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij50aW1lX2hvdXI8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjExOSwwIDExOSwtNDAyIDIxNSwtNDAyIDIxNSwwIDExOSwwIj48L3BvbHlnb24+PC9nPjwhLS0gcGxhbmVzIC0tPjxnIGlkPSJwbGFuZXMiIGNsYXNzPSJub2RlIj48dGl0bGU+cGxhbmVzPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iI2VmZWJkZCIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLC0zODUgMSwtNDA1IDc5LC00MDUgNzksLTM4NSAxLC0zODUiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjIyLjExNzgiIHk9Ii0zOTAuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjMDAwMDAwIj5wbGFuZXM8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLC0zNjUgMSwtMzg1IDc5LC0zODUgNzksLTM2NSAxLC0zNjUiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjMiIHk9Ii0zNzAuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij50YWlsbnVtPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMSwtMzQ1IDEsLTM2NSA3OSwtMzY1IDc5LC0zNDUgMSwtMzQ1Ij48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzIiB5PSItMzUwLjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+eWVhcjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEsLTMyNSAxLC0zNDUgNzksLTM0NSA3OSwtMzI1IDEsLTMyNSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMyIgeT0iLTMzMC40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPnR5cGU8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLC0zMDUgMSwtMzI1IDc5LC0zMjUgNzksLTMwNSAxLC0zMDUiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjIuNjg5MyIgeT0iLTMxMC40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPm1hbnVmYWN0dXJlcjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEsLTI4NSAxLC0zMDUgNzksLTMwNSA3OSwtMjg1IDEsLTI4NSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMyIgeT0iLTI5MC40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPm1vZGVsPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMSwtMjY1IDEsLTI4NSA3OSwtMjg1IDc5LC0yNjUgMSwtMjY1Ij48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzIiB5PSItMjcwLjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+ZW5naW5lczwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEsLTI0NSAxLC0yNjUgNzksLTI2NSA3OSwtMjQ1IDEsLTI0NSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMyIgeT0iLTI1MC40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPnNlYXRzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMSwtMjI1IDEsLTI0NSA3OSwtMjQ1IDc5LC0yMjUgMSwtMjI1Ij48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzIiB5PSItMjMwLjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+c3BlZWQ8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLC0yMDUgMSwtMjI1IDc5LC0yMjUgNzksLTIwNSAxLC0yMDUiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjMiIHk9Ii0yMTAuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5lbmdpbmU8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjAsLTIwNCAwLC00MDYgODAsLTQwNiA4MCwtMjA0IDAsLTIwNCI+PC9wb2x5Z29uPjwvZz48IS0tIHdlYXRoZXIgLS0+PGcgaWQ9IndlYXRoZXIiIGNsYXNzPSJub2RlIj48dGl0bGU+d2VhdGhlcjwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMjU2LC00MjAgMjU2LC00NDAgMzI2LC00NDAgMzI2LC00MjAgMjU2LC00MjAiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjI2OC44NDkyIiB5PSItNDI1LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzAwMDAwMCI+d2VhdGhlcjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjI1NiwtNDAwIDI1NiwtNDIwIDMyNiwtNDIwIDMyNiwtNDAwIDI1NiwtNDAwIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIyNTgiIHk9Ii00MDUuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5vcmlnaW48L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIyNTYsLTM4MCAyNTYsLTQwMCAzMjYsLTQwMCAzMjYsLTM4MCAyNTYsLTM4MCI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMjU4IiB5PSItMzg1LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+eWVhcjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjI1NiwtMzYwIDI1NiwtMzgwIDMyNiwtMzgwIDMyNiwtMzYwIDI1NiwtMzYwIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIyNTgiIHk9Ii0zNjUuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5tb250aDwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjI1NiwtMzQwIDI1NiwtMzYwIDMyNiwtMzYwIDMyNiwtMzQwIDI1NiwtMzQwIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIyNTgiIHk9Ii0zNDUuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5kYXk8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIyNTYsLTMyMCAyNTYsLTM0MCAzMjYsLTM0MCAzMjYsLTMyMCAyNTYsLTMyMCI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMjU4IiB5PSItMzI1LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+aG91cjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjI1NiwtMzAwIDI1NiwtMzIwIDMyNiwtMzIwIDMyNiwtMzAwIDI1NiwtMzAwIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIyNTgiIHk9Ii0zMDUuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij50ZW1wPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMjU2LC0yODAgMjU2LC0zMDAgMzI2LC0zMDAgMzI2LC0yODAgMjU2LC0yODAiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjI1OCIgeT0iLTI4NS40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmRld3A8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIyNTYsLTI2MCAyNTYsLTI4MCAzMjYsLTI4MCAzMjYsLTI2MCAyNTYsLTI2MCI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMjU4IiB5PSItMjY1LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+aHVtaWQ8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIyNTYsLTI0MCAyNTYsLTI2MCAzMjYsLTI2MCAzMjYsLTI0MCAyNTYsLTI0MCI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMjU4IiB5PSItMjQ1LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+d2luZF9kaXI8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIyNTYsLTIyMCAyNTYsLTI0MCAzMjYsLTI0MCAzMjYsLTIyMCAyNTYsLTIyMCI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMjU3LjU2NDUiIHk9Ii0yMjUuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij53aW5kX3NwZWVkPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMjU2LC0yMDAgMjU2LC0yMjAgMzI2LC0yMjAgMzI2LC0yMDAgMjU2LC0yMDAiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjI1OCIgeT0iLTIwNS40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPndpbmRfZ3VzdDwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjI1NiwtMTgwIDI1NiwtMjAwIDMyNiwtMjAwIDMyNiwtMTgwIDI1NiwtMTgwIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIyNTgiIHk9Ii0xODUuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5wcmVjaXA8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIyNTYsLTE2MCAyNTYsLTE4MCAzMjYsLTE4MCAzMjYsLTE2MCAyNTYsLTE2MCI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMjU4IiB5PSItMTY1LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+cHJlc3N1cmU8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIyNTYsLTE0MCAyNTYsLTE2MCAzMjYsLTE2MCAzMjYsLTE0MCAyNTYsLTE0MCI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMjU4IiB5PSItMTQ1LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+dmlzaWI8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIyNTYsLTEyMCAyNTYsLTE0MCAzMjYsLTE0MCAzMjYsLTEyMCAyNTYsLTEyMCI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMjU4IiB5PSItMTI1LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+dGltZV9ob3VyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIyNTUsLTExOSAyNTUsLTQ0MSAzMjcsLTQ0MSAzMjcsLTExOSAyNTUsLTExOSI+PC9wb2x5Z29uPjwvZz48L2c+PC9zdmc+)

``` r
flights_dm_no_keys %>%
  dm_add_pk(airlines, carrier) %>%
  dm_draw()
```

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTc2cHQiIGhlaWdodD0iMTY0cHQiIHZpZXdib3g9IjAuMDAgMC4wMCAxNzYuMDAgMTY0LjAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIj48ZyBpZD0iZ3JhcGgwIiBjbGFzcz0iZ3JhcGgiIHRyYW5zZm9ybT0ic2NhbGUoMSAxKSByb3RhdGUoMCkgdHJhbnNsYXRlKDQgMTYwKSI+PHRpdGxlPiUwPC90aXRsZT4KPGcgaWQ9ImFfZ3JhcGgwIj48YSB4bGluazp0aXRsZT0iRGF0YSBNb2RlbCI+Cjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iLTQsNCAtNCwtMTYwIDE3MiwtMTYwIDE3Miw0IC00LDQiPjwvcG9seWdvbj48L2E+CjwvZz48IS0tIGFpcmxpbmVzIC0tPjxnIGlkPSJhaXJsaW5lcyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJsaW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTE5LC02OSAxMTksLTg5IDE2NCwtODkgMTY0LC02OSAxMTksLTY5Ij48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxMjAuODk2OSIgeT0iLTc0LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzAwMDAwMCI+YWlybGluZXM8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxMTksLTQ5IDExOSwtNjkgMTY0LC02OSAxNjQsLTQ5IDExOSwtNDkiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjEyMSIgeT0iLTU1LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmNhcnJpZXI8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjExNy41LC00OCAxMTcuNSwtOTAgMTY0LjUsLTkwIDE2NC41LC00OCAxMTcuNSwtNDgiPjwvcG9seWdvbj48L2c+PCEtLSBhaXJwb3J0cyAtLT48ZyBpZD0iYWlycG9ydHMiIGNsYXNzPSJub2RlIj48dGl0bGU+YWlycG9ydHM8L3RpdGxlPgo8cG9seWdvbiBmaWxsPSIjZWZlYmRkIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjExOCwtMTIyIDExOCwtMTQyIDE2NCwtMTQyIDE2NCwtMTIyIDExOCwtMTIyIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxMTkuNjE5MiIgeT0iLTEyNy40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiMwMDAwMDAiPmFpcnBvcnRzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxMTcsLTEyMSAxMTcsLTE0MyAxNjUsLTE0MyAxNjUsLTEyMSAxMTcsLTEyMSI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMgLS0+PGcgaWQ9ImZsaWdodHMiIGNsYXNzPSJub2RlIj48dGl0bGU+ZmxpZ2h0czwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iNDQsLTEyOCA0NCwtMTQ4IDgzLC0xNDggODMsLTEyOCA0NCwtMTI4Ij48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSI0NS42MTE1IiB5PSItMTMzLjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzAwMDAwMCI+ZmxpZ2h0czwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iNDIuNSwtMTI3IDQyLjUsLTE0OSA4My41LC0xNDkgODMuNSwtMTI3IDQyLjUsLTEyNyI+PC9wb2x5Z29uPjwvZz48IS0tIHBsYW5lcyAtLT48ZyBpZD0icGxhbmVzIiBjbGFzcz0ibm9kZSI+PHRpdGxlPnBsYW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iNDQsLTY4IDQ0LC04OCA4MywtODggODMsLTY4IDQ0LC02OCI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iNDUuNjE3OCIgeT0iLTczLjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzAwMDAwMCI+cGxhbmVzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSI0Mi41LC02NyA0Mi41LC04OSA4My41LC04OSA4My41LC02NyA0Mi41LC02NyI+PC9wb2x5Z29uPjwvZz48IS0tIHdlYXRoZXIgLS0+PGcgaWQ9IndlYXRoZXIiIGNsYXNzPSJub2RlIj48dGl0bGU+d2VhdGhlcjwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMywtOCAzLC0yOCA1MSwtMjggNTEsLTggMywtOCI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iNC44NDkyIiB5PSItMTMuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjMDAwMDAwIj53ZWF0aGVyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIyLC03IDIsLTI5IDUyLC0yOSA1MiwtNyAyLC03Ij48L3BvbHlnb24+PC9nPjwvZz48L3N2Zz4=)

``` r
flights_dm_only_pks %>%
  dm_add_fk(flights, tailnum, planes) %>%
  dm_draw()
```

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjMwcHQiIGhlaWdodD0iMTcwcHQiIHZpZXdib3g9IjAuMDAgMC4wMCAyMzAuMDAgMTcwLjAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIj48ZyBpZD0iZ3JhcGgwIiBjbGFzcz0iZ3JhcGgiIHRyYW5zZm9ybT0ic2NhbGUoMSAxKSByb3RhdGUoMCkgdHJhbnNsYXRlKDQgMTY2KSI+PHRpdGxlPiUwPC90aXRsZT4KPGcgaWQ9ImFfZ3JhcGgwIj48YSB4bGluazp0aXRsZT0iRGF0YSBNb2RlbCI+Cjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iLTQsNCAtNCwtMTY2IDIyNiwtMTY2IDIyNiw0IC00LDQiPjwvcG9seWdvbj48L2E+CjwvZz48IS0tIGFpcmxpbmVzIC0tPjxnIGlkPSJhaXJsaW5lcyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJsaW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iNSwtNzcgNSwtOTcgNTAsLTk3IDUwLC03NyA1LC03NyI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iNi44OTY5IiB5PSItODIuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjMDAwMDAwIj5haXJsaW5lczwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjUsLTU3IDUsLTc3IDUwLC03NyA1MCwtNTcgNSwtNTciPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjciIHk9Ii02My40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5jYXJyaWVyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIzLjUsLTU2IDMuNSwtOTggNTAuNSwtOTggNTAuNSwtNTYgMy41LC01NiI+PC9wb2x5Z29uPjwvZz48IS0tIGFpcnBvcnRzIC0tPjxnIGlkPSJhaXJwb3J0cyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJwb3J0czwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iNCwtMTQxIDQsLTE2MSA1MCwtMTYxIDUwLC0xNDEgNCwtMTQxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSI1LjYxOTIiIHk9Ii0xNDYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjMDAwMDAwIj5haXJwb3J0czwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjQsLTEyMSA0LC0xNDEgNTAsLTE0MSA1MCwtMTIxIDQsLTEyMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iNiIgeT0iLTEyNy40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5mYWE8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjMsLTEyMCAzLC0xNjIgNTEsLTE2MiA1MSwtMTIwIDMsLTEyMCI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMgLS0+PGcgaWQ9ImZsaWdodHMiIGNsYXNzPSJub2RlIj48dGl0bGU+ZmxpZ2h0czwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iODIsLTIxIDgyLC00MSAxMjgsLTQxIDEyOCwtMjEgODIsLTIxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSI4Ny4xMTE1IiB5PSItMjYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjMDAwMDAwIj5mbGlnaHRzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iODIsLTEgODIsLTIxIDEyOCwtMjEgMTI4LC0xIDgyLC0xIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSI4My42MTE1IiB5PSItNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPnRhaWxudW08L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjgxLDAgODEsLTQyIDEyOSwtNDIgMTI5LDAgODEsMCI+PC9wb2x5Z29uPjwvZz48IS0tIHBsYW5lcyAtLT48ZyBpZD0icGxhbmVzIiBjbGFzcz0ibm9kZSI+PHRpdGxlPnBsYW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTcyLC0yMSAxNzIsLTQxIDIxOCwtNDEgMjE4LC0yMSAxNzIsLTIxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzcuMTE3OCIgeT0iLTI2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzAwMDAwMCI+cGxhbmVzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTcyLC0xIDE3MiwtMjEgMjE4LC0yMSAyMTgsLTEgMTcyLC0xIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzMuNjExNSIgeT0iLTcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+dGFpbG51bTwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTcxLDAgMTcxLC00MiAyMTksLTQyIDIxOSwwIDE3MSwwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O3BsYW5lcyAtLT48ZyBpZD0iZmxpZ2h0c18xIiBjbGFzcz0iZWRnZSI+PHRpdGxlPmZsaWdodHM6dGFpbG51bS0mZ3Q7cGxhbmVzOnRhaWxudW08L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik0xMjgsLTExQzE0My41ODMzLC0xMSAxNDkuODUzMiwtMTEgMTYxLjY1MjksLTExIiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxNjIsLTE0LjUwMDEgMTcyLC0xMSAxNjIsLTcuNTAwMSAxNjIsLTE0LjUwMDEiPjwvcG9seWdvbj48L2c+PCEtLSB3ZWF0aGVyIC0tPjxnIGlkPSJ3ZWF0aGVyIiBjbGFzcz0ibm9kZSI+PHRpdGxlPndlYXRoZXI8L3RpdGxlPgo8cG9seWdvbiBmaWxsPSIjZWZlYmRkIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjcyLjUsLTg1IDcyLjUsLTEwNSAxNzMuNSwtMTA1IDE3My41LC04NSA3Mi41LC04NSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTAwLjg0OTIiIHk9Ii05MC40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiMwMDAwMDAiPndlYXRoZXI8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSI3Mi41LC02NSA3Mi41LC04NSAxNzMuNSwtODUgMTczLjUsLTY1IDcyLjUsLTY1Ij48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSI3NC4wMDU2IiB5PSItNzEuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+b3JpZ2luLCB0aW1lX2hvdXI8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjcxLC02NCA3MSwtMTA2IDE3NCwtMTA2IDE3NCwtNjQgNzEsLTY0Ij48L3BvbHlnb24+PC9nPjwvZz48L3N2Zz4=)

``` r
flights_dm_all_keys %>%
  dm_draw()
```

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjUwcHQiIGhlaWdodD0iMjMwcHQiIHZpZXdib3g9IjAuMDAgMC4wMCAyNTAuMDAgMjMwLjAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIj48ZyBpZD0iZ3JhcGgwIiBjbGFzcz0iZ3JhcGgiIHRyYW5zZm9ybT0ic2NhbGUoMSAxKSByb3RhdGUoMCkgdHJhbnNsYXRlKDQgMjI2KSI+PHRpdGxlPiUwPC90aXRsZT4KPGcgaWQ9ImFfZ3JhcGgwIj48YSB4bGluazp0aXRsZT0iRGF0YSBNb2RlbCI+Cjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iLTQsNCAtNCwtMjI2IDI0NiwtMjI2IDI0Niw0IC00LDQiPjwvcG9seWdvbj48L2E+CjwvZz48IS0tIGFpcmxpbmVzIC0tPjxnIGlkPSJhaXJsaW5lcyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJsaW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY4LjUsLTIwMSAxNjguNSwtMjIxIDIxMy41LC0yMjEgMjEzLjUsLTIwMSAxNjguNSwtMjAxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzAuMzk2OSIgeT0iLTIwNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiMwMDAwMDAiPmFpcmxpbmVzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY4LjUsLTE4MSAxNjguNSwtMjAxIDIxMy41LC0yMDEgMjEzLjUsLTE4MSAxNjguNSwtMTgxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzAuNSIgeT0iLTE4Ny40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5jYXJyaWVyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxNjcsLTE4MCAxNjcsLTIyMiAyMTQsLTIyMiAyMTQsLTE4MCAxNjcsLTE4MCI+PC9wb2x5Z29uPjwvZz48IS0tIGFpcnBvcnRzIC0tPjxnIGlkPSJhaXJwb3J0cyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJwb3J0czwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY3LjUsLTgxIDE2Ny41LC0xMDEgMjEzLjUsLTEwMSAyMTMuNSwtODEgMTY3LjUsLTgxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNjkuMTE5MiIgeT0iLTg2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzAwMDAwMCI+YWlycG9ydHM8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNjcuNSwtNjEgMTY3LjUsLTgxIDIxMy41LC04MSAyMTMuNSwtNjEgMTY3LjUsLTYxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNjkuNSIgeT0iLTY3LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmZhYTwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTY2LjUsLTYwIDE2Ni41LC0xMDIgMjE0LjUsLTEwMiAyMTQuNSwtNjAgMTY2LjUsLTYwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyAtLT48ZyBpZD0iZmxpZ2h0cyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5mbGlnaHRzPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iI2VmZWJkZCIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLjUsLTE0MSAxLjUsLTE2MSAxMDIuNSwtMTYxIDEwMi41LC0xNDEgMS41LC0xNDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjM0LjExMTUiIHk9Ii0xNDYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjMDAwMDAwIj5mbGlnaHRzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC0xMjEgMS41LC0xNDEgMTAyLjUsLTE0MSAxMDIuNSwtMTIxIDEuNSwtMTIxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzLjUiIHk9Ii0xMjYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5jYXJyaWVyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC0xMDEgMS41LC0xMjEgMTAyLjUsLTEyMSAxMDIuNSwtMTAxIDEuNSwtMTAxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzLjUiIHk9Ii0xMDYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij50YWlsbnVtPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC04MSAxLjUsLTEwMSAxMDIuNSwtMTAxIDEwMi41LC04MSAxLjUsLTgxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzLjUiIHk9Ii04Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPm9yaWdpbjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtNjEgMS41LC04MSAxMDIuNSwtODEgMTAyLjUsLTYxIDEuNSwtNjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjMuMDA1NiIgeT0iLTY2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+b3JpZ2luLCB0aW1lX2hvdXI8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjAsLTYwIDAsLTE2MiAxMDMsLTE2MiAxMDMsLTYwIDAsLTYwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O2FpcmxpbmVzIC0tPjxnIGlkPSJmbGlnaHRzXzEiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czpjYXJyaWVyLSZndDthaXJsaW5lczpjYXJyaWVyPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTAyLjUsLTEzMUMxMjYuNTY2OCwtMTMxIDEyMC44MDI5LC0xNTUuMjQ5NiAxMzksLTE3MSAxNDcuNzk1NiwtMTc4LjYxMyAxNTEuMDM5NCwtMTg1LjgzMDUgMTU4LjQxNTcsLTE4OS4xMjc3IiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxNTguMDI5MSwtMTkyLjYxNTcgMTY4LjUsLTE5MSAxNTkuMzA3LC0xODUuNzMzMyAxNTguMDI5MSwtMTkyLjYxNTciPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzJiM0NTsmZ3Q7YWlycG9ydHMgLS0+PGcgaWQ9ImZsaWdodHNfMiIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOm9yaWdpbi0mZ3Q7YWlycG9ydHM6ZmFhPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTAyLjUsLTkxQzEyOC45NDczLC05MSAxMzUuNzM2MSwtNzUuNjg3NSAxNTcuMjY4NywtNzEuODU5NCIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTU3LjgyODEsLTc1LjMyNDggMTY3LjUsLTcxIDE1Ny4yNDIxLC02OC4zNDk0IDE1Ny44MjgxLC03NS4zMjQ4Ij48L3BvbHlnb24+PC9nPjwhLS0gcGxhbmVzIC0tPjxnIGlkPSJwbGFuZXMiIGNsYXNzPSJub2RlIj48dGl0bGU+cGxhbmVzPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iI2VmZWJkZCIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNjcuNSwtMTQxIDE2Ny41LC0xNjEgMjEzLjUsLTE2MSAyMTMuNSwtMTQxIDE2Ny41LC0xNDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE3Mi42MTc4IiB5PSItMTQ2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzAwMDAwMCI+cGxhbmVzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY3LjUsLTEyMSAxNjcuNSwtMTQxIDIxMy41LC0xNDEgMjEzLjUsLTEyMSAxNjcuNSwtMTIxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNjkuMTExNSIgeT0iLTEyNy40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij50YWlsbnVtPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxNjYuNSwtMTIwIDE2Ni41LC0xNjIgMjE0LjUsLTE2MiAyMTQuNSwtMTIwIDE2Ni41LC0xMjAiPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzJiM0NTsmZ3Q7cGxhbmVzIC0tPjxnIGlkPSJmbGlnaHRzXzMiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czp0YWlsbnVtLSZndDtwbGFuZXM6dGFpbG51bTwvdGl0bGU+CjxwYXRoIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgZD0iTTEwMi41LC0xMTFDMTI4Ljk0NzMsLTExMSAxMzUuNzM2MSwtMTI2LjMxMjUgMTU3LjI2ODcsLTEzMC4xNDA2IiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxNTcuMjQyMSwtMTMzLjY1MDYgMTY3LjUsLTEzMSAxNTcuODI4MSwtMTI2LjY3NTIgMTU3LjI0MjEsLTEzMy42NTA2Ij48L3BvbHlnb24+PC9nPjwhLS0gd2VhdGhlciAtLT48ZyBpZD0id2VhdGhlciIgY2xhc3M9Im5vZGUiPjx0aXRsZT53ZWF0aGVyPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iI2VmZWJkZCIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNDAuNSwtMjEgMTQwLjUsLTQxIDI0MS41LC00MSAyNDEuNSwtMjEgMTQwLjUsLTIxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNjguODQ5MiIgeT0iLTI2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzAwMDAwMCI+d2VhdGhlcjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE0MC41LC0xIDE0MC41LC0yMSAyNDEuNSwtMjEgMjQxLjUsLTEgMTQwLjUsLTEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE0Mi4wMDU2IiB5PSItNy40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5vcmlnaW4sIHRpbWVfaG91cjwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTM5LDAgMTM5LC00MiAyNDIsLTQyIDI0MiwwIDEzOSwwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O3dlYXRoZXIgLS0+PGcgaWQ9ImZsaWdodHNfNCIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOm9yaWdpbiwgdGltZV9ob3VyLSZndDt3ZWF0aGVyOm9yaWdpbiwgdGltZV9ob3VyPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTAyLjUsLTcxQzEyOS44NzI3LC03MSAxMTQuNjEwMSwtMjUuODc5MiAxMzAuNjU3OSwtMTMuODkzOSIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTMxLjg5MzUsLTE3LjE3ODkgMTQwLjUsLTExIDEyOS45MTg4LC0xMC40NjMxIDEzMS44OTM1LC0xNy4xNzg5Ij48L3BvbHlnb24+PC9nPjwvZz48L3N2Zz4=)

## Integrity Checks

As well as checking our data model visually, dm can examine the
constraints we have created by the addition of keys and verify that they
are sensible.

``` r
flights_dm_no_keys %>%
  dm_examine_constraints()
```

``` fansi
#> ℹ No constraints defined.
```

``` r

flights_dm_only_pks %>%
  dm_examine_constraints()
```

``` fansi
#> ℹ All constraints satisfied.
```

``` r

flights_dm_all_keys %>%
  dm_examine_constraints()
```

``` fansi
#> ! Unsatisfied constraints:
```

``` fansi
#> • Table `flights`: foreign key `tailnum` into table `planes`: values of `flights$tailnum` not in `planes$tailnum`: N725MQ (575), N722MQ (513), N723MQ (507), N713MQ (483), N735MQ (396), …
#> • Table `flights`: foreign key `origin`, `time_hour` into table `weather`: values of `flights$origin`, `flights$time_hour` not in `weather$origin`, `weather$time_hour`: EWR, 2013-10-23 06:00:00 (34), EWR, 2013-08-19 17:00:00 (26), EWR, 2013-12-31 06:00:00 (26), EWR, 2013-12-31 07:00:00 (26), JFK, 2013-08-19 17:00:00 (26), …
```

The results are presented in a human-readable form, and available as a
tibble for programmatic inspection.

## Programming

Helper functions are available to access details on keys and check
results.

A data frame of primary keys is retrieved with
[`dm_get_all_pks()`](https://dm.cynkra.com/reference/dm_get_all_pks.md):

``` r
flights_dm_only_pks %>%
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

Similarly, a data frame of foreign keys is retrieved with
[`dm_get_all_fks()`](https://dm.cynkra.com/reference/dm_get_all_fks.md):

``` r
flights_dm_all_keys %>%
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

We can use
[`tibble::as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html)
on the result of
[`dm_examine_constraints()`](https://dm.cynkra.com/reference/dm_examine_constraints.md)
to programmatically inspect which constraints are not satisfied:

``` r
flights_dm_all_keys %>%
  dm_examine_constraints() %>%
  tibble::as_tibble()
```

``` fansi
#> # A tibble: 8 × 6
#>   table    kind  columns           ref_table is_key problem                
#>   <chr>    <chr> <keys>            <chr>     <lgl>  <chr>                  
#> 1 flights  FK    tailnum           planes    FALSE  "values of `flights$ta…
#> 2 flights  FK    origin, time_hour weather   FALSE  "values of `flights$or…
#> 3 airlines PK    carrier           NA        TRUE   ""                     
#> 4 airports PK    faa               NA        TRUE   ""                     
#> 5 planes   PK    tailnum           NA        TRUE   ""                     
#> 6 weather  PK    origin, time_hour NA        TRUE   ""                     
#> 7 flights  FK    carrier           airlines  TRUE   ""                     
#> 8 flights  FK    origin            airports  TRUE   ""
```

## Conclusion

In this tutorial, we have demonstrated how simple it is to create
relational data models from local data frames using {dm}, including
setting primary and foreign keys and visualizing the resulting
relational model.

## Further reading

[`vignette("howto-dm-db")`](https://dm.cynkra.com/articles/howto-dm-db.md)
– This article covers accessing and working with RDBMSs within your R
session, including manipulating data, filling in missing relationships
between tables, getting data out of the RDBMS and into your model, and
deploying your data model to an RDBMS.

[`vignette("howto-dm-theory")`](https://dm.cynkra.com/articles/howto-dm-theory.md)
– Do you know all about data frames but very little about relational
data models? This quick introduction will walk you through the key
similarities and differences, and show you how to move from individual
data frames to a relational data model.
