# Check for primary key

`dm_has_pk()` checks if a given table has columns marked as its primary
key.

## Usage

``` r
dm_has_pk(dm, table, ...)
```

## Arguments

- dm:

  A `dm` object.

- table:

  A table in the `dm`.

- ...:

  These dots are for future extensions and must be empty.

## Value

A logical value: `TRUE` if the given table has a primary key, `FALSE`
otherwise.

## See also

Other primary key functions:
[`dm_add_pk()`](https://dm.cynkra.com/reference/dm_add_pk.md),
[`dm_add_uk()`](https://dm.cynkra.com/reference/dm_add_uk.md),
[`dm_get_all_pks()`](https://dm.cynkra.com/reference/dm_get_all_pks.md),
[`dm_get_all_uks()`](https://dm.cynkra.com/reference/dm_get_all_uks.md),
[`dm_rm_pk()`](https://dm.cynkra.com/reference/dm_rm_pk.md),
[`dm_rm_uk()`](https://dm.cynkra.com/reference/dm_rm_uk.md),
[`enum_pk_candidates()`](https://dm.cynkra.com/reference/dm_enum_pk_candidates.md)

## Examples

``` r
dm_nycflights13() %>%
  dm_has_pk(flights)
#> [1] FALSE
dm_nycflights13() %>%
  dm_has_pk(planes)
#> [1] TRUE
```
