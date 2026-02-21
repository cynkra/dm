# Class dm and basic operations

The goal of the {dm} package and the `dm` class that comes with it, is
to make your life easier when you are dealing with data from several
different tables.

Let’s take a look at the `dm` class.

## Class `dm`

The `dm` class consists of a collection of tables and metadata about the
tables, such as

- the names of the tables
- the names of the columns of the tables
- the primary and foreign keys of the tables to link the tables together
- the data (either as data frames or as references to database tables)

All tables in a `dm` must be obtained from the same data source; csv
files and spreadsheets would need to be imported to data frames in R.

## Examples of `dm` objects

There are currently three options available for creating a `dm` object.
The relevant functions for creating `dm` objects are:

1.  [`dm()`](https://dm.cynkra.com/dev/reference/dm.md)
2.  [`as_dm()`](https://dm.cynkra.com/dev/reference/dm.md)
3.  [`new_dm()`](https://dm.cynkra.com/dev/reference/dm.md)
4.  [`dm_from_con()`](https://dm.cynkra.com/dev/reference/dm_from_con.md)

To illustrate these options, we will now create the same `dm` in several
different ways. We can use the tables from the well-known {nycflights13}
package.

### Pass the tables directly

Create a `dm` object directly by providing data frames to
[`dm()`](https://dm.cynkra.com/dev/reference/dm.md):

``` r
library(nycflights13)
library(dm)
dm(airlines, airports, flights, planes, weather)
```

``` fansi
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#> Columns: 53
#> Primary keys: 0
#> Foreign keys: 0
```

### Start with an empty `dm`

Start with an empty `dm` object that has been created with
[`dm()`](https://dm.cynkra.com/dev/reference/dm.md) or
[`new_dm()`](https://dm.cynkra.com/dev/reference/dm.md), and add tables
to that object:

``` r
library(nycflights13)
library(dm)
empty_dm <- dm()
empty_dm
#> dm()
dm(empty_dm, airlines, airports, flights, planes, weather)
```

``` fansi
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#> Columns: 53
#> Primary keys: 0
#> Foreign keys: 0
```

### Coerce a list of tables

Turn a named list of tables into a `dm` with
[`as_dm()`](https://dm.cynkra.com/dev/reference/dm.md):

``` r
as_dm(list(
  airlines = airlines,
  airports = airports,
  flights = flights,
  planes = planes,
  weather = weather
))
```

``` fansi
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#> Columns: 53
#> Primary keys: 0
#> Foreign keys: 0
```

### Turn tables from a `src` into a `dm`

Squeeze all (or a subset of) tables belonging to a `src` object into a
`dm` using
[`dm_from_con()`](https://dm.cynkra.com/dev/reference/dm_from_con.md):

``` r
sqlite_con <- dbplyr::nycflights13_sqlite()

flights_dm <- dm_from_con(sqlite_con)
flights_dm
```

``` fansi
#> ── Table source ───────────────────────────────────────────────────────────
#> src:  sqlite 3.51.2 [/tmp/RtmpMDf5rX/nycflights13.sqlite]
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `airlines`, `airports`, `flights`, `planes`, `sqlite_stat1`, … (7 total)
#> Columns: 62
#> Primary keys: 0
#> Foreign keys: 0
```

The function `dm_from_con(con, table_names = NULL)` includes all
available tables on a source in the `dm` object. This means that you can
use this, for example, on a postgres database that you access via
`DBI::dbConnect(RPostgres::Postgres())` (with the appropriate arguments
`dbname`, `host`, `port`, …), to produce a `dm` object with all the
tables on the database.

### Low-level construction

Another way of creating a `dm` object is calling
[`new_dm()`](https://dm.cynkra.com/dev/reference/dm.md) on a list of
`tbl` objects:

``` r
base_dm <- new_dm(list(
  airlines = airlines,
  airports = airports,
  flights = flights,
  planes = planes,
  weather = weather
))
base_dm
```

``` fansi
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#> Columns: 53
#> Primary keys: 0
#> Foreign keys: 0
```

This constructor is optimized for speed and does not perform integrity
checks. Use with caution, validate using
[`dm_validate()`](https://dm.cynkra.com/dev/reference/dm_validate.md) if
necessary.

``` r
dm_validate(base_dm)
```

## Access tables

We can get the list of tables with
[`dm_get_tables()`](https://dm.cynkra.com/dev/reference/dm_get_tables.md)
and the `src` object with
[`dm_get_con()`](https://dm.cynkra.com/dev/reference/dm_get_con.md).

In order to pull a specific table from a `dm`, use:

``` r
flights_dm[["airports"]]
```

``` fansi
#> # Source:   table<`airports`> [?? x 8]
#> # Database: sqlite 3.51.2 [/tmp/RtmpMDf5rX/nycflights13.sqlite]
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
#> # ℹ more rows
```

But how can we use {dm}-functions to manage the primary keys of the
tables in a `dm` object?

## Primary keys of `dm` objects

Some useful functions for managing primary key settings are:

1.  [`dm_add_pk()`](https://dm.cynkra.com/dev/reference/dm_add_pk.md)
2.  [`dm_get_all_pks()`](https://dm.cynkra.com/dev/reference/dm_get_all_pks.md)
3.  [`dm_rm_pk()`](https://dm.cynkra.com/dev/reference/dm_rm_pk.md)
4.  [`dm_enum_pk_candidates()`](https://dm.cynkra.com/dev/reference/dm_enum_pk_candidates.md)

If you created a `dm` object according to the examples in [“Examples of
`dm` objects”](#ex_dm), your object does not yet have any primary keys
set. So let’s add one.

We use the `nycflights13` tables, i.e. `flights_dm` from above.

``` r
dm_has_pk(flights_dm, airports)
#> [1] FALSE
flights_dm_with_key <- dm_add_pk(flights_dm, airports, faa)
flights_dm_with_key
```

``` fansi
#> ── Table source ───────────────────────────────────────────────────────────
#> src:  sqlite 3.51.2 [/tmp/RtmpMDf5rX/nycflights13.sqlite]
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `airlines`, `airports`, `flights`, `planes`, `sqlite_stat1`, … (7 total)
#> Columns: 62
#> Primary keys: 1
#> Foreign keys: 0
```

The `dm` now has a primary key:

``` r
dm_has_pk(flights_dm_with_key, airports)
#> [1] TRUE
```

To get an overview over all tables with primary keys, use
[`dm_get_all_pks()`](https://dm.cynkra.com/dev/reference/dm_get_all_pks.md):

``` r
dm_get_all_pks(flights_dm_with_key)
```

``` fansi
#> # A tibble: 1 × 3
#>   table    pk_col autoincrement
#>   <chr>    <keys> <lgl>        
#> 1 airports faa    FALSE
```

Remove a primary key:

``` r
dm_rm_pk(flights_dm_with_key, airports) %>%
  dm_has_pk(airports)
#> [1] FALSE
```

If you still need to get to know your data better, and it is already
available in the form of a `dm` object, you can use the
[`dm_enum_pk_candidates()`](https://dm.cynkra.com/dev/reference/dm_enum_pk_candidates.md)
function in order to get information about which columns of the table
are unique keys:

``` r
dm_enum_pk_candidates(flights_dm_with_key, airports)
```

``` fansi
#> # A tibble: 8 × 3
#>   columns candidate why                                                    
#>   <keys>  <lgl>     <chr>                                                  
#> 1 faa     TRUE      ""                                                     
#> 2 lon     TRUE      ""                                                     
#> 3 name    FALSE     "has duplicate values: Municipal Airport (5), All Airp…
#> 4 lat     FALSE     "has duplicate values: 38.88944 (2), 40.63975 (2)"     
#> 5 alt     FALSE     "has duplicate values: 0 (51), 13 (13), 14 (12), 15 (1…
#> 6 tz      FALSE     "has duplicate values: -5 (521), -6 (342), -9 (240), -…
#> 7 dst     FALSE     "has duplicate values: A (1388), U (47), N (23)"       
#> 8 tzone   FALSE     "has duplicate values: America/New_York (519), America…
```

The `flights` table does not have any one-column primary key candidates:

``` r
dm_enum_pk_candidates(flights_dm_with_key, flights) %>% dplyr::count(candidate)
```

``` fansi
#> # A tibble: 1 × 2
#>   candidate     n
#>   <lgl>     <int>
#> 1 FALSE        19
```

[`dm_add_pk()`](https://dm.cynkra.com/dev/reference/dm_add_pk.md) has a
`check` argument. If set to `TRUE`, the function checks if the column of
the table given by the user is unique. For performance reasons, the
default is `check = FALSE`. See also \[dm_examine_constraints()\] for
checking all constraints in a `dm`.

``` r
try(
  dm_add_pk(flights_dm, airports, tzone, check = TRUE)
)
#> Error in abort_not_unique_key(x_label, orig_names) : 
#>   (`tzone`) not a unique key of `airports`.
```

## Foreign keys

Useful functions for managing foreign key relations include:

1.  [`dm_add_fk()`](https://dm.cynkra.com/dev/reference/dm_add_fk.md)
2.  [`dm_get_all_fks()`](https://dm.cynkra.com/dev/reference/dm_get_all_fks.md)
3.  [`dm_rm_fk()`](https://dm.cynkra.com/dev/reference/dm_rm_fk.md)
4.  [`dm_enum_fk_candidates()`](https://dm.cynkra.com/dev/reference/dm_enum_fk_candidates.md)

Now it gets (even more) interesting: we want to define relations between
different tables. With the
[`dm_add_fk()`](https://dm.cynkra.com/dev/reference/dm_add_fk.md)
function you can define which column of which table points to another
table’s column.

This is done by choosing a foreign key from one table that will point to
a primary key of another table. The primary key of the referred table
must be set with
[`dm_add_pk()`](https://dm.cynkra.com/dev/reference/dm_add_pk.md).
[`dm_add_fk()`](https://dm.cynkra.com/dev/reference/dm_add_fk.md) will
find the primary key column of the referenced table by itself and make
the indicated column of the child table point to it.

``` r
flights_dm_with_key %>% dm_add_fk(flights, origin, airports)
```

``` fansi
#> ── Table source ───────────────────────────────────────────────────────────
#> src:  sqlite 3.51.2 [/tmp/RtmpMDf5rX/nycflights13.sqlite]
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `airlines`, `airports`, `flights`, `planes`, `sqlite_stat1`, … (7 total)
#> Columns: 62
#> Primary keys: 1
#> Foreign keys: 1
```

This will throw an error:

``` r
try(
  flights_dm %>% dm_add_fk(flights, origin, airports)
)
#> Error in abort_ref_tbl_has_no_pk(ref_table_name) : 
#>   ref_table `airports` needs a primary key first. Use `dm_enum_pk_candidates()` to find appropriate columns and `dm_add_pk()` to define a primary key.
```

Let’s create a `dm` object with a foreign key relation to work with
later on:

``` r
flights_dm_with_fk <- dm_add_fk(flights_dm_with_key, flights, origin, airports)
```

What if we tried to add another foreign key relation from `flights` to
`airports` to the object? Column `dest` might work, since it also
contains airport codes:

``` r
try(
  flights_dm_with_fk %>% dm_add_fk(flights, dest, airports, check = TRUE)
)
#> Error in abort_not_subset_of(table_name, col_name, ref_table_name, ref_col_name) : 
#>   Column (`dest`) of table `flights` contains values (see examples above) that are not present in column (`faa`) of table `airports`.
```

Checks are opt-in and executed only if `check = TRUE`. You can still add
a foreign key with the default `check = FALSE`. See also
[`dm_examine_constraints()`](https://dm.cynkra.com/dev/reference/dm_examine_constraints.md)
for checking all constraints in a `dm`.

Get an overview of all foreign key relations
with[`dm_get_all_fks()`](https://dm.cynkra.com/dev/reference/dm_get_all_fks.md):

``` r
dm_get_all_fks(dm_nycflights13(cycle = TRUE))
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

Remove foreign key relations with
[`dm_rm_fk()`](https://dm.cynkra.com/dev/reference/dm_rm_fk.md)
(parameter `columns = NULL` means that all relations will be removed,
with a message):

``` r
try(
  flights_dm_with_fk %>%
    dm_rm_fk(table = flights, column = dest, ref_table = airports) %>%
    dm_get_all_fks(c(flights, airports))
)
#> Error in abort_is_not_fkc() : No foreign keys to remove.

flights_dm_with_fk %>%
  dm_rm_fk(flights, origin, airports) %>%
  dm_get_all_fks(c(flights, airports))
```

``` fansi
#> # A tibble: 0 × 5
#> # ℹ 5 variables: child_table <chr>, child_fk_cols <keys>,
#> #   parent_table <chr>, parent_key_cols <keys>, on_delete <chr>
```

``` r

flights_dm_with_fk %>%
  dm_rm_fk(flights, columns = NULL, airports) %>%
  dm_get_all_fks(c(flights, airports))
#> Removing foreign keys: %>%
#>   dm_rm_fk(flights, origin, airports)
```

``` fansi
#> # A tibble: 0 × 5
#> # ℹ 5 variables: child_table <chr>, child_fk_cols <keys>,
#> #   parent_table <chr>, parent_key_cols <keys>, on_delete <chr>
```

Since the primary keys are defined in the `dm` object, you do not
usually need to provide the referenced column name of `ref_table`.

Another function for getting to know your data better
(cf. [`dm_enum_pk_candidates()`](https://dm.cynkra.com/dev/reference/dm_enum_pk_candidates.md)
in [“Primary keys of `dm` objects”](#pk)) is
[`dm_enum_fk_candidates()`](https://dm.cynkra.com/dev/reference/dm_enum_fk_candidates.md).
Use it to get an overview over foreign key candidates that point from
one table to another:

``` r
dm_enum_fk_candidates(flights_dm_with_key, weather, airports)
```

``` fansi
#> # A tibble: 15 × 3
#>    columns    candidate why                                                
#>    <keys>     <lgl>     <chr>                                              
#>  1 origin     TRUE      ""                                                 
#>  2 year       FALSE     "values of `weather$year` not in `airports$faa`: 2…
#>  3 month      FALSE     "values of `weather$month` not in `airports$faa`: …
#>  4 day        FALSE     "values of `weather$day` not in `airports$faa`: 3 …
#>  5 hour       FALSE     "values of `weather$hour` not in `airports$faa`: 1…
#>  6 temp       FALSE     "values of `weather$temp` not in `airports$faa`: 3…
#>  7 dewp       FALSE     "values of `weather$dewp` not in `airports$faa`: 2…
#>  8 humid      FALSE     "values of `weather$humid` not in `airports$faa`: …
#>  9 wind_dir   FALSE     "values of `weather$wind_dir` not in `airports$faa…
#> 10 wind_speed FALSE     "values of `weather$wind_speed` not in `airports$f…
#> 11 wind_gust  FALSE     "values of `weather$wind_gust` not in `airports$fa…
#> 12 precip     FALSE     "values of `weather$precip` not in `airports$faa`:…
#> 13 pressure   FALSE     "values of `weather$pressure` not in `airports$faa…
#> 14 visib      FALSE     "values of `weather$visib` not in `airports$faa`: …
#> 15 time_hour  FALSE     "values of `weather$time_hour` not in `airports$fa…
```
