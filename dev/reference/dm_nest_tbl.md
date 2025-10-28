# Nest a table inside its dm

**\[experimental\]**

`dm_nest_tbl()` converts a child table to a nested column in its parent
table. The child table should not have children itself (i.e. it needs to
be a *terminal child table*).

## Usage

``` r
dm_nest_tbl(dm, child_table, into = NULL)
```

## Arguments

- dm:

  A dm.

- child_table:

  A terminal table with one parent table.

- into:

  The table to nest `child_tables` into, optional as it can be guessed
  from the foreign keys unambiguously but useful to be explicit.

## See also

[`dm_wrap_tbl()`](https://dm.cynkra.com/dev/reference/dm_wrap_tbl.md),
[`dm_unwrap_tbl()`](https://dm.cynkra.com/dev/reference/dm_unwrap_tbl.md),
[`dm_pack_tbl()`](https://dm.cynkra.com/dev/reference/dm_pack_tbl.md)

## Examples

``` r
nested_dm <-
  dm_nycflights13() %>%
  dm_select_tbl(airlines, flights) %>%
  dm_nest_tbl(flights)

nested_dm
#> ── Metadata ────────────────────────────────────────────────────────────────────
#> Tables: `airlines`
#> Columns: 3
#> Primary keys: 1
#> Foreign keys: 0

nested_dm$airlines
#> # A tibble: 15 × 3
#>    carrier name                        flights            
#>    <chr>   <chr>                       <nested>           
#>  1 9E      Endeavor Air Inc.           <tibble [104 × 18]>
#>  2 AA      American Airlines Inc.      <tibble [180 × 18]>
#>  3 AS      Alaska Airlines Inc.        <tibble [4 × 18]>  
#>  4 B6      JetBlue Airways             <tibble [296 × 18]>
#>  5 DL      Delta Air Lines Inc.        <tibble [239 × 18]>
#>  6 EV      ExpressJet Airlines Inc.    <tibble [278 × 18]>
#>  7 F9      Frontier Airlines Inc.      <tibble [4 × 18]>  
#>  8 FL      AirTran Airways Corporation <tibble [20 × 18]> 
#>  9 HA      Hawaiian Airlines Inc.      <tibble [2 × 18]>  
#> 10 MQ      Envoy Air                   <tibble [147 × 18]>
#> 11 UA      United Air Lines Inc.       <tibble [294 × 18]>
#> 12 US      US Airways Inc.             <tibble [109 × 18]>
#> 13 VX      Virgin America              <tibble [19 × 18]> 
#> 14 WN      Southwest Airlines Co.      <tibble [62 × 18]> 
#> 15 YV      Mesa Airlines Inc.          <tibble [3 × 18]>  
```
