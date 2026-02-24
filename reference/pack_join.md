# Pack Join

**\[experimental\]**

`pack_join()` returns all rows and columns in `x` with a new packed
column that contains all matches from `y`.

## Usage

``` r
pack_join(x, y, by = NULL, ..., copy = FALSE, keep = FALSE, name = NULL)

# S3 method for class 'dm_zoomed'
pack_join(x, y, by = NULL, ..., copy = FALSE, keep = FALSE, name = NULL)
```

## Arguments

- x, y:

  A pair of data frames or data frame extensions (e.g. a tibble).

- by:

  A join specification created with
  [`join_by()`](https://dplyr.tidyverse.org/reference/join_by.html), or
  a character vector of variables to join by.

  If `NULL`, the default, `*_join()` will perform a natural join, using
  all variables in common across `x` and `y`. A message lists the
  variables so that you can check they're correct; suppress the message
  by supplying `by` explicitly.

  To join on different variables between `x` and `y`, use a
  [`join_by()`](https://dplyr.tidyverse.org/reference/join_by.html)
  specification. For example, `join_by(a == b)` will match `x$a` to
  `y$b`.

  To join by multiple variables, use a
  [`join_by()`](https://dplyr.tidyverse.org/reference/join_by.html)
  specification with multiple expressions. For example,
  `join_by(a == b, c == d)` will match `x$a` to `y$b` and `x$c` to
  `y$d`. If the column names are the same between `x` and `y`, you can
  shorten this by listing only the variable names, like `join_by(a, c)`.

  [`join_by()`](https://dplyr.tidyverse.org/reference/join_by.html) can
  also be used to perform inequality, rolling, and overlap joins. See
  the documentation at
  [?join_by](https://dplyr.tidyverse.org/reference/join_by.html) for
  details on these types of joins.

  For simple equality joins, you can alternatively specify a character
  vector of variable names to join by. For example, `by = c("a", "b")`
  joins `x$a` to `y$a` and `x$b` to `y$b`. If variable names differ
  between `x` and `y`, use a named character vector like
  `by = c("x_a" = "y_a", "x_b" = "y_b")`.

  To perform a cross-join, generating all combinations of `x` and `y`,
  see
  [`cross_join()`](https://dplyr.tidyverse.org/reference/cross_join.html).

- ...:

  Other parameters passed onto methods.

- copy:

  If `x` and `y` are not from the same data source, and `copy` is
  `TRUE`, then `y` will be copied into the same src as `x`. This allows
  you to join tables across srcs, but it is a potentially expensive
  operation so you must opt into it.

- keep:

  Should the new list-column contain join keys? The default will
  preserve the join keys for inequality joins.

- name:

  The name of the list-column created by the join. If `NULL`, the
  default, the name of `y` is used.

## See also

[`dplyr::nest_join()`](https://dplyr.tidyverse.org/reference/nest_join.html),
[`tidyr::pack()`](https://tidyr.tidyverse.org/reference/pack.html)

## Examples

``` r
df1 <- tibble::tibble(x = 1:3)
df2 <- tibble::tibble(x = c(1, 1, 2), y = c("first", "second", "third"))
pack_join(df1, df2)
#> Joining with `by = join_by(x)`
#> # A tibble: 4 × 2
#>       x df2$y 
#>   <dbl> <chr> 
#> 1     1 first 
#> 2     1 second
#> 3     2 third 
#> 4     3 NA    
```
