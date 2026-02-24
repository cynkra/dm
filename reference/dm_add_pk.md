# Add a primary key

`dm_add_pk()` marks the specified columns as the primary key of the
specified table. If `check == TRUE`, then it will first check if the
given combination of columns is a unique key of the table. If
`force == TRUE`, the function will replace an already set key, without
altering foreign keys previously pointing to that primary key.

## Usage

``` r
dm_add_pk(
  dm,
  table,
  columns,
  ...,
  autoincrement = FALSE,
  check = FALSE,
  force = FALSE
)
```

## Arguments

- dm:

  A `dm` object.

- table:

  A table in the `dm`.

- columns:

  Table columns, unquoted. To define a compound key, use
  `c(col1, col2)`.

- ...:

  These dots are for future extensions and must be empty.

- autoincrement:

  **\[experimental\]** If `TRUE`, the column specified in `columns` will
  be populated automatically with a sequence of integers.

- check:

  Boolean, if `TRUE`, a check is made if the combination of columns is a
  unique key of the table.

- force:

  Boolean, if `FALSE` (default), an error will be thrown if there is
  already a primary key set for this table. If `TRUE`, a potential old
  `pk` is deleted before setting a new one.

## Value

An updated `dm` with an additional primary key.

## Details

There can be only one primary key per table in a
[`dm`](https://dm.cynkra.com/reference/dm.md). It's possible though to
set an unlimited number of unique keys using
[`dm_add_uk()`](https://dm.cynkra.com/reference/dm_add_uk.md) or adding
foreign keys pointing to columns other than the primary key columns with
[`dm_add_fk()`](https://dm.cynkra.com/reference/dm_add_fk.md).

## See also

Other primary key functions:
[`dm_add_uk()`](https://dm.cynkra.com/reference/dm_add_uk.md),
[`dm_get_all_pks()`](https://dm.cynkra.com/reference/dm_get_all_pks.md),
[`dm_get_all_uks()`](https://dm.cynkra.com/reference/dm_get_all_uks.md),
[`dm_has_pk()`](https://dm.cynkra.com/reference/dm_has_pk.md),
[`dm_rm_pk()`](https://dm.cynkra.com/reference/dm_rm_pk.md),
[`dm_rm_uk()`](https://dm.cynkra.com/reference/dm_rm_uk.md),
[`enum_pk_candidates()`](https://dm.cynkra.com/reference/dm_enum_pk_candidates.md)

## Examples

``` r
nycflights_dm <- dm(
  planes = nycflights13::planes,
  airports = nycflights13::airports,
  weather = nycflights13::weather
)

nycflights_dm %>%
  dm_draw()
%0


airports
airportsplanes
planesweather
weather
# Create primary keys:
nycflights_dm %>%
  dm_add_pk(planes, tailnum) %>%
  dm_add_pk(airports, faa, check = TRUE) %>%
  dm_add_pk(weather, c(origin, time_hour)) %>%
  dm_draw()
%0


airports
airportsfaaplanes
planestailnumweather
weatherorigin, time_hour
# Keys can be checked during creation:
try(
  nycflights_dm %>%
    dm_add_pk(planes, manufacturer, check = TRUE)
)
#> Error in check_key(planes, manufacturer) : 
#>   (`manufacturer`) not a unique key of `planes`.
```
