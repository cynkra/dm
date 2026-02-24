# Get all unique keys of a [`dm`](https://dm.cynkra.com/reference/dm.md) object

`dm_get_all_uks()` checks the `dm` object for unique keys (primary keys,
explicit and implicit unique keys) and returns the tables and the
respective unique key columns.

## Usage

``` r
dm_get_all_uks(dm, table = NULL, ...)
```

## Arguments

- dm:

  A `dm` object.

- table:

  One or more table names, unquoted, to return unique key information
  for. The default `NULL` returns information for all tables.

- ...:

  These dots are for future extensions and must be empty.

## Value

A tibble with the following columns:

- `table`:

  table name,

- `uk_col`:

  column name(s) of primary key, as list of character vectors,

- `kind`:

  kind of unique key, see details.

## Details

There are 3 kinds of unique keys:

- `PK`: Primary key, set by
  [`dm_add_pk()`](https://dm.cynkra.com/reference/dm_add_pk.md)

- `explicit UK`: Unique key, set by
  [`dm_add_uk()`](https://dm.cynkra.com/reference/dm_add_uk.md)

- `implicit UK`: Unique key, not explicitly set, but referenced by a
  foreign key.

## See also

Other primary key functions:
[`dm_add_pk()`](https://dm.cynkra.com/reference/dm_add_pk.md),
[`dm_add_uk()`](https://dm.cynkra.com/reference/dm_add_uk.md),
[`dm_get_all_pks()`](https://dm.cynkra.com/reference/dm_get_all_pks.md),
[`dm_has_pk()`](https://dm.cynkra.com/reference/dm_has_pk.md),
[`dm_rm_pk()`](https://dm.cynkra.com/reference/dm_rm_pk.md),
[`dm_rm_uk()`](https://dm.cynkra.com/reference/dm_rm_uk.md),
[`enum_pk_candidates()`](https://dm.cynkra.com/reference/dm_enum_pk_candidates.md)

## Examples

``` r
dm_nycflights13() %>%
  dm_get_all_uks()
#> # A tibble: 4 × 3
#>   table    uk_col            kind 
#>   <chr>    <keys>            <chr>
#> 1 airlines carrier           PK   
#> 2 airports faa               PK   
#> 3 planes   tailnum           PK   
#> 4 weather  origin, time_hour PK   
```
