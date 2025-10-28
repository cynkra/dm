# Remove a unique key

`dm_rm_uk()` removes one or more unique keys from a table and leaves the
[`dm`](https://dm.cynkra.com/dev/reference/dm.md) object otherwise
unaltered. An error is thrown if no unique key matches the selection
criteria. If the selection criteria are ambiguous, a message with
unambiguous replacement code is shown. Foreign keys are never removed.

## Usage

``` r
dm_rm_uk(dm, table = NULL, columns = NULL, ...)
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

## Value

An updated `dm` without the indicated unique key(s).

## See also

Other primary key functions:
[`dm_add_pk()`](https://dm.cynkra.com/dev/reference/dm_add_pk.md),
[`dm_add_uk()`](https://dm.cynkra.com/dev/reference/dm_add_uk.md),
[`dm_get_all_pks()`](https://dm.cynkra.com/dev/reference/dm_get_all_pks.md),
[`dm_get_all_uks()`](https://dm.cynkra.com/dev/reference/dm_get_all_uks.md),
[`dm_has_pk()`](https://dm.cynkra.com/dev/reference/dm_has_pk.md),
[`dm_rm_pk()`](https://dm.cynkra.com/dev/reference/dm_rm_pk.md),
[`enum_pk_candidates()`](https://dm.cynkra.com/dev/reference/dm_enum_pk_candidates.md)
