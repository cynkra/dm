# Unwrap a single table dm

**\[experimental\]**

`dm_unwrap_tbl()` unwraps all tables in a dm object so that the
resulting dm matches a given ptype dm. It runs a sequence of
[`dm_unnest_tbl()`](https://dm.cynkra.com/reference/dm_unnest_tbl.md)
and
[`dm_unpack_tbl()`](https://dm.cynkra.com/reference/dm_unpack_tbl.md)
operations on the dm.

## Usage

``` r
dm_unwrap_tbl(dm, ptype, progress = NA)
```

## Arguments

- dm:

  A dm.

- ptype:

  A dm, only used to query names of primary and foreign keys.

- progress:

  Whether to display a progress bar, if `NA` (the default) hide in
  non-interactive mode, show in interactive mode. Requires the
  'progress' package.

## Value

A dm.

## See also

[`dm_wrap_tbl()`](https://dm.cynkra.com/reference/dm_wrap_tbl.md),
[`dm_unnest_tbl()`](https://dm.cynkra.com/reference/dm_unnest_tbl.md),
[`dm_examine_constraints()`](https://dm.cynkra.com/reference/dm_examine_constraints.md),
[`dm_examine_cardinalities()`](https://dm.cynkra.com/reference/dm_examine_cardinalities.md),
[`dm_ptype()`](https://dm.cynkra.com/reference/dm_ptype.md).

## Examples

``` r
roundtrip <-
  dm_nycflights13() %>%
  dm_wrap_tbl(root = flights) %>%
  dm_unwrap_tbl(ptype = dm_ptype(dm_nycflights13()))
roundtrip
#> ── Metadata ────────────────────────────────────────────────────────────────────
#> Tables: `flights`, `airlines`, `airports`, `planes`, `weather`
#> Columns: 53
#> Primary keys: 4
#> Foreign keys: 4

# The roundtrip has the same structure but fewer rows:
dm_nrow(dm_nycflights13())
#> airlines airports  flights   planes  weather 
#>       15       86     1761      945      144 
dm_nrow(roundtrip)
#>  flights airlines airports   planes  weather 
#>     1761       15        3     1112      105 
```
