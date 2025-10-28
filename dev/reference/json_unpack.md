# Unpack a JSON column

A wrapper around
[`tidyr::unpack()`](https://tidyr.tidyverse.org/reference/pack.html)
that extracts its data from a JSON column. The inverse of
[`json_pack()`](https://dm.cynkra.com/dev/reference/json_pack.md).

## Usage

``` r
json_unpack(data, cols, ..., names_sep = NULL, names_repair = "check_unique")
```

## Arguments

- data:

  A data frame, a data frame extension (e.g. a tibble), or a lazy data
  frame (e.g. from dbplyr or dtplyr).

- cols:

  \<[`tidy-select`](https://tidyr.tidyverse.org/reference/tidyr_tidy_select.html)\>
  Columns to unpack.

- ...:

  Arguments passed to methods.

- names_sep:

  If `NULL`, the default, the names will be left as is. In `pack()`,
  inner names will come from the former outer names; in `unpack()`, the
  new outer names will come from the inner names.

  If a string, the inner and outer names will be used together. In
  `unpack()`, the names of the new outer columns will be formed by
  pasting together the outer and the inner column names, separated by
  `names_sep`. In `pack()`, the new inner names will have the outer
  names + `names_sep` automatically stripped. This makes `names_sep`
  roughly symmetric between packing and unpacking.

- names_repair:

  Used to check that output data frame has valid names. Must be one of
  the following options:

  - `"minimal`": no name repair or checks, beyond basic existence,

  - `"unique`": make sure names are unique and not empty,

  - `"check_unique`": (the default), no name repair, but check they are
    unique,

  - `"universal`": make the names unique and syntactic

  - a function: apply custom name repair.

  - [tidyr_legacy](https://tidyr.tidyverse.org/reference/tidyr_legacy.html):
    use the name repair from tidyr 0.8.

  - a formula: a purrr-style anonymous function (see
    [`rlang::as_function()`](https://rlang.r-lib.org/reference/as_function.html))

  See
  [`vctrs::vec_as_names()`](https://vctrs.r-lib.org/reference/vec_as_names.html)
  for more details on these terms and the strategies used to enforce
  them.

## Value

An object of the same type as `data`

## Examples

``` r
tibble(a = 1, b = '{ "c": 2, "d": 3 }') %>%
  json_unpack(b)
#> # A tibble: 1 × 3
#>       a     c     d
#>   <dbl> <int> <int>
#> 1     1     2     3
```
