# Check column values for set equality

`check_set_equality()` is a wrapper of
[`check_subset()`](https://dm.cynkra.com/reference/check_subset.md).

It tests if one table is a subset of another and vice versa, i.e., if
both sets are the same. If not, it throws an error.

## Usage

``` r
check_set_equality(
  x,
  y,
  ...,
  x_select = NULL,
  y_select = NULL,
  by_position = NULL
)
```

## Arguments

- x, y:

  A data frame or lazy table.

- ...:

  These dots are for future extensions and must be empty.

- x_select, y_select:

  Key columns to restrict the check, processed with
  [`dplyr::select()`](https://dplyr.tidyverse.org/reference/select.html).

- by_position:

  Set to `TRUE` to ignore column names and match by position instead.
  The default means matching by name, use `x_select` and/or `y_select`
  to align the names.

## Value

Returns `x`, invisibly, if the check is passed. Otherwise an error is
thrown and the reason for it is explained.

## Examples

``` r
data_1 <- tibble::tibble(a = c(1, 2, 1), b = c(1, 4, 1), c = c(5, 6, 7))
data_2 <- tibble::tibble(a = c(1, 2, 3), b = c(4, 5, 6), c = c(7, 8, 9))
# this is failing:
try(check_set_equality(data_1, data_2, x_select = a, y_select = a))
#> # A tibble: 1 × 1
#>       a
#>   <dbl>
#> 1     3
#> Error in check_set_equality(data_1, data_2, x_select = a, y_select = a) : 
#>   Column (`a`) of table data_2 contains values (see examples above) that
#> are not present in column (`a`) of table data_1.

data_3 <- tibble::tibble(a = c(2, 1, 2), b = c(4, 5, 6), c = c(7, 8, 9))
# this is passing:
check_set_equality(data_1, data_3, x_select = a, y_select = a)
# this is still failing:
try(check_set_equality(data_2, data_3))
#> # A tibble: 3 × 3
#>       a     b     c
#>   <dbl> <dbl> <dbl>
#> 1     1     4     7
#> 2     2     5     8
#> 3     3     6     9
#> # A tibble: 3 × 3
#>       a     b     c
#>   <dbl> <dbl> <dbl>
#> 1     2     4     7
#> 2     1     5     8
#> 3     2     6     9
#> Error in check_set_equality(data_2, data_3) : 
#>   Columns (`a`, `b`, `c`) of table data_2 contain values (see examples
#> above) that are not present in columns (`a`, `b`, `c`) of table data_3.
#> Columns (`a`, `b`, `c`) of table data_3 contain values (see examples above)
#> that are not present in columns (`a`, `b`, `c`) of table data_2.
```
