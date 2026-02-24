# Wrap dm into a single tibble dm

**\[experimental\]**

`dm_wrap_tbl()` creates a single tibble dm containing the `root` table
enhanced with all the data related to it through the relationships
stored in the dm. It runs a sequence of
[`dm_nest_tbl()`](https://dm.cynkra.com/reference/dm_nest_tbl.md) and
[`dm_pack_tbl()`](https://dm.cynkra.com/reference/dm_pack_tbl.md)
operations on the dm.

## Usage

``` r
dm_wrap_tbl(dm, root, strict = TRUE, progress = NA)
```

## Arguments

- dm:

  A cycle free dm object.

- root:

  Table to wrap the dm into (unquoted).

- strict:

  Whether to fail for cyclic dms that cannot be wrapped into a single
  table, if `FALSE` a partially wrapped dm will be returned.

- progress:

  Whether to display a progress bar, if `NA` (the default) hide in
  non-interactive mode, show in interactive mode. Requires the
  'progress' package.

## Value

A `dm` object.

## Details

`dm_wrap_tbl()` is an inverse to
[`dm_unwrap_tbl()`](https://dm.cynkra.com/reference/dm_unwrap_tbl.md),
i.e., wrapping after unwrapping returns the same information
(disregarding row and column order). The opposite is not generally true:
since `dm_wrap_tbl()` keeps only rows related directly or indirectly to
rows in the `root` table. Even if all referential constraints are
satisfied, unwrapping after wrapping loses rows in parent tables that
don't have a corresponding row in the child table.

This function differs from
[`dm_flatten_to_tbl()`](https://dm.cynkra.com/reference/dm_flatten_to_tbl.md)
and
[`dm_squash_to_tbl()`](https://dm.cynkra.com/reference/deprecated.md) ,
which always return a single table, and not a `dm` object.

## See also

[`dm_unwrap_tbl()`](https://dm.cynkra.com/reference/dm_unwrap_tbl.md),
[`dm_nest_tbl()`](https://dm.cynkra.com/reference/dm_nest_tbl.md),
[`dm_examine_constraints()`](https://dm.cynkra.com/reference/dm_examine_constraints.md),
[`dm_examine_cardinalities()`](https://dm.cynkra.com/reference/dm_examine_cardinalities.md).

## Examples

``` r
dm_nycflights13() %>%
  dm_wrap_tbl(root = airlines)
#> ── Metadata ────────────────────────────────────────────────────────────────────
#> Tables: `airlines`
#> Columns: 3
#> Primary keys: 1
#> Foreign keys: 0
```
