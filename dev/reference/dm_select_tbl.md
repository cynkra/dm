# Select and rename tables

`dm_select_tbl()` keeps the selected tables and their relationships,
optionally renaming them.

`dm_rename_tbl()` renames tables.

## Usage

``` r
dm_select_tbl(dm, ...)

dm_rename_tbl(dm, ...)
```

## Arguments

- dm:

  A [`dm`](https://dm.cynkra.com/dev/reference/dm.md) object.

- ...:

  One or more table names of the tables of the
  [`dm`](https://dm.cynkra.com/dev/reference/dm.md) object. `tidyselect`
  is supported, see
  [`dplyr::select()`](https://dplyr.tidyverse.org/reference/select.html)
  for details on the semantics.

## Value

The input `dm` with tables renamed or removed.

## Examples

``` r
dm_nycflights13() %>%
  dm_select_tbl(airports, fl = flights)
#> ── Metadata ────────────────────────────────────────────────────────────────────
#> Tables: `airports`, `fl`
#> Columns: 27
#> Primary keys: 1
#> Foreign keys: 1
dm_nycflights13() %>%
  dm_rename_tbl(ap = airports, fl = flights)
#> ── Metadata ────────────────────────────────────────────────────────────────────
#> Tables: `airlines`, `ap`, `fl`, `planes`, `weather`
#> Columns: 53
#> Primary keys: 4
#> Foreign keys: 4
```
