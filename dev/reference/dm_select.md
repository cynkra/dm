# Select columns

Select columns of your [`dm`](https://dm.cynkra.com/dev/reference/dm.md)
using syntax that is similar to
[`dplyr::select()`](https://dplyr.tidyverse.org/reference/select.html).

## Usage

``` r
dm_select(dm, table, ...)
```

## Arguments

- dm:

  A `dm` object.

- table:

  A table in the `dm`.

- ...:

  One or more unquoted expressions separated by commas. You can treat
  variable names as if they were positions, and use expressions like
  `x:y` to select the ranges of variables.

  Use named arguments, e.g. `new_name = old_name`, to rename the
  selected variables.

  The arguments in ... are automatically quoted and evaluated in a
  context where column names represent column positions. They also
  support unquoting and splicing. See
  [`vignette("programming", package = "dplyr")`](https://dplyr.tidyverse.org/articles/programming.html)
  for an introduction to those concepts.

  See select helpers for more details, and the examples about
  [tidyselect
  helpers](https://tidyselect.r-lib.org/reference/language.html), such
  as `starts_with()`, `everything()`, etc.

## Value

An updated `dm` with the columns of `table` reduced and/or renamed.

## Details

If key columns are renamed, then the meta-information of the `dm` is
updated accordingly. If key columns are removed, then all related
relations are dropped as well.

## Examples

``` r
dm_nycflights13() %>%
  dm_select(airports, code = faa, altitude = alt)
#> ── Metadata ────────────────────────────────────────────────────────────────────
#> Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#> Columns: 47
#> Primary keys: 4
#> Foreign keys: 4
```
