# Flatten a table in a `dm` by joining its parent tables

**\[experimental\]**

`dm_flatten()` updates a table in-place by joining its parent tables
into it, and removes the now integrated parent tables from the dm.

## Usage

``` r
dm_flatten(
  dm,
  table,
  ...,
  parent_tables = NULL,
  recursive = FALSE,
  allow_deep = FALSE,
  join = left_join
)
```

## Arguments

- dm:

  A [`dm`](https://dm.cynkra.com/reference/dm.md) object.

- table:

  The table to flatten by joining its parent tables. An interesting
  choice could be for example a fact table in a star schema.

- ...:

  These dots are for future extensions and must be empty.

- parent_tables:

  **\[experimental\]**

  Unquoted names of the parent tables to be joined into `table`. The
  order of the tables here determines the order of the joins. If `NULL`
  (the default), all direct parent tables are joined in non-recursive
  mode, or all reachable ancestor tables in recursive mode. `tidyselect`
  is supported, see
  [`dplyr::select()`](https://dplyr.tidyverse.org/reference/select.html)
  for details on the semantics.

- recursive:

  Logical, defaults to `FALSE`. If `TRUE`, recursively flatten parent
  tables before joining them into `table`. Uses simple recursion:
  recursively flattening the parents and then doing a join in order. If
  `FALSE`, fails if a parent table has further parents (unless
  `allow_deep` is `TRUE`). Cannot be `TRUE` when `allow_deep` is `TRUE`.

- allow_deep:

  Logical, defaults to `FALSE`. Only relevant if `recursive = FALSE`. If
  `TRUE`, parent tables with further parents are allowed and will remain
  in the result with a foreign-key relationship to the flattened table.
  Cannot be `TRUE` when `recursive` is `TRUE`.

- join:

  The type of join to use when combining parent tables, see
  [`dplyr::join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html).
  Defaults to
  [`dplyr::left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html).
  `nest_join` is not supported. When `recursive = TRUE`, only
  [`dplyr::left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html),
  [`dplyr::inner_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html),
  and
  [`dplyr::full_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html)
  are supported.

## Value

A [`dm`](https://dm.cynkra.com/reference/dm.md) object with the
flattened table and removed parent tables.

## See also

Other flattening functions:
[`dm_flatten_to_tbl()`](https://dm.cynkra.com/reference/dm_flatten_to_tbl.md)

## Examples

``` r
dm_nycflights13() %>%
  dm_select_tbl(-weather) %>%
  dm_flatten(flights, recursive = TRUE)
#> Renaming ambiguous columns: %>%
#>   dm_rename(airports, name.airports = name) %>%
#>   dm_rename(planes, year.planes = year)
#> ── Metadata ────────────────────────────────────────────────────────────────────
#> Tables: `flights`
#> Columns: 35
#> Primary keys: 0
#> Foreign keys: 0
```
