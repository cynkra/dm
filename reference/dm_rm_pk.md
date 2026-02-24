# Remove a primary key

If a table name is provided, `dm_rm_pk()` removes the primary key from
this table and leaves the [`dm`](https://dm.cynkra.com/reference/dm.md)
object otherwise unaltered. If no table is given, the `dm` is stripped
of all primary keys at once. An error is thrown if no primary key
matches the selection criteria. If the selection criteria are ambiguous,
a message with unambiguous replacement code is shown. Foreign keys are
never removed.

## Usage

``` r
dm_rm_pk(dm, table = NULL, columns = NULL, ..., fail_fk = NULL)
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

- ...:

  These dots are for future extensions and must be empty.

- fail_fk:

  **\[deprecated\]**

## Value

An updated `dm` without the indicated primary key(s).

## See also

Other primary key functions:
[`dm_add_pk()`](https://dm.cynkra.com/reference/dm_add_pk.md),
[`dm_add_uk()`](https://dm.cynkra.com/reference/dm_add_uk.md),
[`dm_get_all_pks()`](https://dm.cynkra.com/reference/dm_get_all_pks.md),
[`dm_get_all_uks()`](https://dm.cynkra.com/reference/dm_get_all_uks.md),
[`dm_has_pk()`](https://dm.cynkra.com/reference/dm_has_pk.md),
[`dm_rm_uk()`](https://dm.cynkra.com/reference/dm_rm_uk.md),
[`enum_pk_candidates()`](https://dm.cynkra.com/reference/dm_enum_pk_candidates.md)

## Examples

``` r
dm_nycflights13() %>%
  dm_rm_pk(airports) %>%
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
