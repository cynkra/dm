# JSON pack

**\[experimental\]**

A wrapper around
[`tidyr::pack()`](https://tidyr.tidyverse.org/reference/pack.html) which
stores the packed data into JSON columns.

## Usage

``` r
json_pack(.data, ..., .names_sep = NULL)
```

## Arguments

- .data:

  A data frame, a data frame extension (e.g. a tibble), or a lazy data
  frame (e.g. from dbplyr or dtplyr).

- ...:

  \<[`tidy-select`](https://tidyr.tidyverse.org/reference/tidyr_tidy_select.html)\>
  Columns to pack, specified using name-variable pairs of the form
  `new_col = c(col1, col2, col3)`. The right hand side can be any valid
  tidy select expression.

- .names_sep:

  If `NULL`, the default, the names will be left as is.

## See also

[`tidyr::pack()`](https://tidyr.tidyverse.org/reference/pack.html),
[`json_pack_join()`](https://dm.cynkra.com/reference/json_pack_join.md)

## Examples

``` r
df <- tibble::tibble(x1 = 1:3, x2 = 4:6, x3 = 7:9, y = 1:3)
packed <- json_pack(df, x = c(x1, x2, x3), y = y)
packed
#> # A tibble: 3 × 2
#>   x                              y          
#>   <chr>                          <chr>      
#> 1 "{\"x1\":1,\"x2\":4,\"x3\":7}" "{\"y\":1}"
#> 2 "{\"x1\":2,\"x2\":5,\"x3\":8}" "{\"y\":2}"
#> 3 "{\"x1\":3,\"x2\":6,\"x3\":9}" "{\"y\":3}"
```
