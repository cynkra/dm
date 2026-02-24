# Foreign key candidates

**\[experimental\]**

Determine which columns would be good candidates to be used as foreign
keys of a table, to reference the primary key column of another table of
the [`dm`](https://dm.cynkra.com/reference/dm.md) object.

## Usage

``` r
dm_enum_fk_candidates(dm, table, ref_table, ...)

enum_fk_candidates(dm_zoomed, ref_table, ...)
```

## Arguments

- dm:

  A `dm` object.

- table:

  The table whose columns should be tested for suitability as foreign
  keys.

- ref_table:

  A table with a primary key.

- ...:

  These dots are for future extensions and must be empty.

- dm_zoomed:

  A `dm` with a zoomed table.

## Value

A tibble with the following columns:

- `columns`:

  columns of `table`,

- `candidate`:

  boolean: are these columns a candidate for a foreign key,

- `why`:

  if not a candidate for a foreign key, explanation for for this.

## Details

`dm_enum_fk_candidates()` first checks if `ref_table` has a primary key
set, if not, an error is thrown.

If `ref_table` does have a primary key, then a join operation will be
tried using that key as the `by` argument of join() to match it to each
column of `table`. Attempting to join incompatible columns triggers an
error.

The outcome of the join operation determines the value of the `why`
column in the result:

- an empty value for a column of `table` that is a suitable foreign key
  candidate

- the count and percentage of missing matches for a column that is not
  suitable

- the error message triggered for unsuitable candidates that may include
  the types of mismatched columns

`enum_fk_candidates()` works like `dm_enum_fk_candidates()` with the
zoomed table as `table`.

## Life cycle

These functions are marked "experimental" because we are not yet sure
about the interface, in particular if we need both `dm_enum...()` and
`enum...()` variants. Changing the interface later seems harmless
because these functions are most likely used interactively.

## See also

Other foreign key functions:
[`dm_add_fk()`](https://dm.cynkra.com/reference/dm_add_fk.md),
[`dm_get_all_fks()`](https://dm.cynkra.com/reference/dm_get_all_fks.md),
[`dm_rm_fk()`](https://dm.cynkra.com/reference/dm_rm_fk.md)

## Examples

``` r
dm_nycflights13() %>%
  dm_enum_fk_candidates(flights, airports)
#> # A tibble: 19 × 3
#>    columns        candidate why                                                 
#>    <keys>         <lgl>     <chr>                                               
#>  1 origin         TRUE      ""                                                  
#>  2 year           FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…
#>  3 month          FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…
#>  4 day            FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…
#>  5 dep_time       FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…
#>  6 sched_dep_time FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…
#>  7 dep_delay      FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…
#>  8 arr_time       FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…
#>  9 sched_arr_time FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…
#> 10 arr_delay      FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…
#> 11 carrier        FALSE     "values of `flights$carrier` not in `airports$faa`:…
#> 12 flight         FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…
#> 13 tailnum        FALSE     "values of `flights$tailnum` not in `airports$faa`:…
#> 14 dest           FALSE     "values of `flights$dest` not in `airports$faa`: SJ…
#> 15 air_time       FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…
#> 16 distance       FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…
#> 17 hour           FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…
#> 18 minute         FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…
#> 19 time_hour      FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…

dm_nycflights13() %>%
  dm_zoom_to(flights) %>%
  enum_fk_candidates(airports)
#> # A tibble: 19 × 3
#>    columns        candidate why                                                 
#>    <keys>         <lgl>     <chr>                                               
#>  1 origin         TRUE      ""                                                  
#>  2 year           FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…
#>  3 month          FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…
#>  4 day            FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…
#>  5 dep_time       FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…
#>  6 sched_dep_time FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…
#>  7 dep_delay      FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…
#>  8 arr_time       FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…
#>  9 sched_arr_time FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…
#> 10 arr_delay      FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…
#> 11 carrier        FALSE     "values of `flights$carrier` not in `airports$faa`:…
#> 12 flight         FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…
#> 13 tailnum        FALSE     "values of `flights$tailnum` not in `airports$faa`:…
#> 14 dest           FALSE     "values of `flights$dest` not in `airports$faa`: SJ…
#> 15 air_time       FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…
#> 16 distance       FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…
#> 17 hour           FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…
#> 18 minute         FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…
#> 19 time_hour      FALSE     "\u001b[1m\u001b[22mCan't join `x$value1` with `y$v…
```
