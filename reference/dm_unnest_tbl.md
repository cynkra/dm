# Unnest columns from a wrapped table

**\[experimental\]**

`dm_unnest_tbl()` target a specific column to unnest from the given
table in a given dm. A ptype or a set of keys should be given, not both.

## Usage

``` r
dm_unnest_tbl(dm, parent_table, col, ptype)
```

## Arguments

- dm:

  A dm.

- parent_table:

  A table in the dm with nested columns.

- col:

  The column to unnest (unquoted).

- ptype:

  A dm, only used to query names of primary and foreign keys.

## Value

A dm.

## Details

[`dm_nest_tbl()`](https://dm.cynkra.com/reference/dm_nest_tbl.md) is an
inverse operation to `dm_unnest_tbl()` if differences in row and column
order are ignored. The opposite is true if referential constraints
between both tables are satisfied.

## See also

[`dm_unwrap_tbl()`](https://dm.cynkra.com/reference/dm_unwrap_tbl.md),
[`dm_unpack_tbl()`](https://dm.cynkra.com/reference/dm_unpack_tbl.md),
[`dm_nest_tbl()`](https://dm.cynkra.com/reference/dm_nest_tbl.md),
[`dm_pack_tbl()`](https://dm.cynkra.com/reference/dm_pack_tbl.md),
[`dm_wrap_tbl()`](https://dm.cynkra.com/reference/dm_wrap_tbl.md),
[`dm_examine_constraints()`](https://dm.cynkra.com/reference/dm_examine_constraints.md),
[`dm_examine_cardinalities()`](https://dm.cynkra.com/reference/dm_examine_cardinalities.md),
[`dm_ptype()`](https://dm.cynkra.com/reference/dm_ptype.md).

## Examples

``` r
airlines_wrapped <-
  dm_nycflights13() %>%
  dm_wrap_tbl(airlines)

# The ptype is required for reconstruction.
# It can be an empty dm, only primary and foreign keys are considered.
ptype <- dm_ptype(dm_nycflights13())

airlines_wrapped %>%
  dm_unnest_tbl(airlines, flights, ptype)
#> ── Metadata ────────────────────────────────────────────────────────────────────
#> Tables: `airlines`, `flights`
#> Columns: 24
#> Primary keys: 1
#> Foreign keys: 1
```
