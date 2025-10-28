# JSON nest

**\[experimental\]**

A wrapper around
[`tidyr::nest()`](https://tidyr.tidyverse.org/reference/nest.html) which
stores the nested data into JSON columns.

## Usage

``` r
json_nest(.data, ..., .names_sep = NULL)
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

[`tidyr::nest()`](https://tidyr.tidyverse.org/reference/nest.html),
[`json_nest_join()`](https://dm.cynkra.com/dev/reference/json_nest_join.md)

## Examples

``` r
df <- tibble::tibble(x = c(1, 1, 1, 2, 2, 3), y = 1:6, z = 6:1)
nested <- json_nest(df, data = c(y, z))
nested
#> # A tibble: 3 × 2
#>       x data                                                     
#>   <dbl> <chr>                                                    
#> 1     1 "[{\"y\":1,\"z\":6},{\"y\":2,\"z\":5},{\"y\":3,\"z\":4}]"
#> 2     2 "[{\"y\":4,\"z\":3},{\"y\":5,\"z\":2}]"                  
#> 3     3 "[{\"y\":6,\"z\":1}]"                                    
```
