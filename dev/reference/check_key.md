# Check if column(s) can be used as keys

`check_key()` accepts a data frame and, optionally, columns. It throws
an error if the specified columns are NOT a unique key of the data
frame. If the columns given in the ellipsis ARE a key, the data frame
itself is returned silently, so that it can be used for piping.

## Usage

``` r
check_key(x, ..., .data = deprecated())
```

## Arguments

- x:

  The data frame whose columns should be tested for key properties.

- ...:

  The names of the columns to be checked, processed with
  [`dplyr::select()`](https://dplyr.tidyverse.org/reference/select.html).
  If omitted, all columns will be checked.

- .data:

  Deprecated.

## Value

Returns `x`, invisibly, if the check is passed. Otherwise an error is
thrown and the reason for it is explained.

## Examples

``` r
data <- tibble::tibble(a = c(1, 2, 1), b = c(1, 4, 1), c = c(5, 6, 7))
# this is failing:
try(check_key(data, a, b))
#> Error in check_key(data, a, b) : 
#>   (`a`, `b`) not a unique key of `data`.

# this is passing:
check_key(data, a, c)
check_key(data)
```
