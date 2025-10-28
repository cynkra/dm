# Unpack columns from a wrapped table

\#' @description **\[experimental\]**

## Usage

``` r
dm_unpack_tbl(dm, child_table, col, ptype)
```

## Arguments

- dm:

  A dm.

- child_table:

  A table in the dm with packed columns.

- col:

  The column to unpack (unquoted).

- ptype:

  A dm, only used to query names of primary and foreign keys.

## Details

`dm_unpack_tbl()` targets a specific column to unpack from the given
table in a given dm. A ptype or a set of keys should be given, not both.

[`dm_pack_tbl()`](https://dm.cynkra.com/dev/reference/dm_pack_tbl.md) is
an inverse operation to `dm_unpack_tbl()` if differences in row and
column order are ignored. The opposite is true if referential
constraints between both tables are satisfied and if all rows in the
parent table have at least one child row, i.e. if the relationship is of
cardinality 1:n or 1:1.

## See also

[`dm_unwrap_tbl()`](https://dm.cynkra.com/dev/reference/dm_unwrap_tbl.md),
[`dm_unnest_tbl()`](https://dm.cynkra.com/dev/reference/dm_unnest_tbl.md),
[`dm_nest_tbl()`](https://dm.cynkra.com/dev/reference/dm_nest_tbl.md),
[`dm_pack_tbl()`](https://dm.cynkra.com/dev/reference/dm_pack_tbl.md),
[`dm_wrap_tbl()`](https://dm.cynkra.com/dev/reference/dm_wrap_tbl.md),
[`dm_examine_constraints()`](https://dm.cynkra.com/dev/reference/dm_examine_constraints.md),
[`dm_examine_cardinalities()`](https://dm.cynkra.com/dev/reference/dm_examine_cardinalities.md),
[`dm_ptype()`](https://dm.cynkra.com/dev/reference/dm_ptype.md).

## Examples

``` r
flights_wrapped <-
  dm_nycflights13() %>%
  dm_wrap_tbl(flights)

# The ptype is required for reconstruction.
# It can be an empty dm, only primary and foreign keys are considered.
ptype <- dm_ptype(dm_nycflights13())

flights_wrapped %>%
  dm_unpack_tbl(flights, airlines, ptype)
#> ── Metadata ────────────────────────────────────────────────────────────────────
#> Tables: `flights`, `airlines`
#> Columns: 24
#> Primary keys: 1
#> Foreign keys: 1
```
