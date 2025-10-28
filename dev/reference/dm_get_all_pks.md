# Get all primary keys of a [`dm`](https://dm.cynkra.com/dev/reference/dm.md) object

`dm_get_all_pks()` checks the `dm` object for primary keys and returns
the tables and the respective primary key columns.

## Usage

``` r
dm_get_all_pks(dm, table = NULL, ...)
```

## Arguments

- dm:

  A `dm` object.

- table:

  One or more table names, unquoted, to return primary key information
  for. If given, primary keys are returned in that order. The default
  `NULL` returns information for all tables.

- ...:

  These dots are for future extensions and must be empty.

## Value

A tibble with the following columns:

- `table`:

  table name,

- `pk_col`:

  column name(s) of primary key, as list of character vectors.

## See also

Other primary key functions:
[`dm_add_pk()`](https://dm.cynkra.com/dev/reference/dm_add_pk.md),
[`dm_add_uk()`](https://dm.cynkra.com/dev/reference/dm_add_uk.md),
[`dm_get_all_uks()`](https://dm.cynkra.com/dev/reference/dm_get_all_uks.md),
[`dm_has_pk()`](https://dm.cynkra.com/dev/reference/dm_has_pk.md),
[`dm_rm_pk()`](https://dm.cynkra.com/dev/reference/dm_rm_pk.md),
[`dm_rm_uk()`](https://dm.cynkra.com/dev/reference/dm_rm_uk.md),
[`enum_pk_candidates()`](https://dm.cynkra.com/dev/reference/dm_enum_pk_candidates.md)

## Examples

``` r
dm_nycflights13() %>%
  dm_get_all_pks()
#> # A tibble: 4 × 3
#>   table    pk_col            autoincrement
#>   <chr>    <keys>            <lgl>        
#> 1 airlines carrier           FALSE        
#> 2 airports faa               FALSE        
#> 3 planes   tailnum           FALSE        
#> 4 weather  origin, time_hour FALSE        
```
