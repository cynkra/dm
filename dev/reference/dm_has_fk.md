# Check if foreign keys exists

**\[deprecated\]**

These functions are deprecated because of their limited use since the
introduction of foreign keys to arbitrary columns in dm 0.2.1. Use
[`dm_get_all_fks()`](https://dm.cynkra.com/dev/reference/dm_get_all_fks.md)
with table manipulation functions instead.

## Usage

``` r
dm_has_fk(dm, table, ref_table, ...)

dm_get_fk(dm, table, ref_table, ...)
```

## Arguments

- dm:

  A `dm` object.

- table:

  A table in the `dm`.

- ref_table:

  The table which `table` will be referencing.

- ...:

  These dots are for future extensions and must be empty.
