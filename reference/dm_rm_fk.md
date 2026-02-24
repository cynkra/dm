# Remove foreign keys

`dm_rm_fk()` can remove either one reference between two tables, or
multiple references at once (with a message). An error is thrown if no
matching foreign key is found.

## Usage

``` r
dm_rm_fk(
  dm,
  table = NULL,
  columns = NULL,
  ref_table = NULL,
  ref_columns = NULL,
  ...
)
```

## Arguments

- dm:

  A `dm` object.

- table:

  A table in the `dm`. Pass `NULL` to remove all matching keys.

- columns:

  Table columns, unquoted. To refer to a compound key, use
  `c(col1, col2)`. Pass `NULL` (the default) to remove all matching
  keys.

- ref_table:

  The table referenced by the `table` argument. Pass `NULL` to remove
  all matching keys.

- ref_columns:

  The columns of `table` that should no longer be referencing the
  primary key of `ref_table`. To refer to a compound key, use
  `c(col1, col2)`.

- ...:

  These dots are for future extensions and must be empty.

## Value

An updated `dm` without the matching foreign key relation(s).

## See also

Other foreign key functions:
[`dm_add_fk()`](https://dm.cynkra.com/reference/dm_add_fk.md),
[`dm_enum_fk_candidates()`](https://dm.cynkra.com/reference/dm_enum_fk_candidates.md),
[`dm_get_all_fks()`](https://dm.cynkra.com/reference/dm_get_all_fks.md)

## Examples

``` r
dm_nycflights13(cycle = TRUE) %>%
  dm_rm_fk(flights, dest, airports) %>%
  dm_draw()
%0


airlines
airlinescarrierairports
airportsfaaflights
flightscarriertailnumoriginorigin, time_hourflights:carrier->airlines:carrier
flights:origin->airports:faa
planes
planestailnumflights:tailnum->planes:tailnum
weather
weatherorigin, time_hourflights:origin, time_hour->weather:origin, time_hour
```
