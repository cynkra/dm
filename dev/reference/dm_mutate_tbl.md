# Update tables in a [`dm`](https://dm.cynkra.com/dev/reference/dm.md)

**\[experimental\]**

Updates one or more existing tables in a
[`dm`](https://dm.cynkra.com/dev/reference/dm.md). For now, the column
names must be identical. This restriction may be levied optionally in
the future.

## Usage

``` r
dm_mutate_tbl(dm, ...)
```

## Arguments

- dm:

  A [`dm`](https://dm.cynkra.com/dev/reference/dm.md) object.

- ...:

  One or more tables to update in the `dm`. Must be named.

## See also

[`dm()`](https://dm.cynkra.com/dev/reference/dm.md),
[`dm_select_tbl()`](https://dm.cynkra.com/dev/reference/dm_select_tbl.md)

## Examples

``` r
dm_nycflights13() %>%
  dm_mutate_tbl(flights = nycflights13::flights[1:3, ])
#> ── Metadata ────────────────────────────────────────────────────────────────────
#> Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#> Columns: 53
#> Primary keys: 4
#> Foreign keys: 4
```
