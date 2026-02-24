# JSON nest join

**\[experimental\]**

A wrapper around
[`dplyr::nest_join()`](https://dplyr.tidyverse.org/reference/nest_join.html)
which stores the joined data into a JSON column. `json_nest_join()`
returns all rows and columns in `x` with a new JSON columns that
contains all nested matches from `y`.

## Usage

``` r
json_nest_join(x, y, by = NULL, ..., copy = FALSE, keep = FALSE, name = NULL)
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
[`json_pack_join()`](https://dm.cynkra.com/reference/json_pack_join.md)

## Examples

``` r
df1 <- tibble::tibble(x = 1:3)
df2 <- tibble::tibble(x = c(1, 1, 2), y = c("first", "second", "third"))
df3 <- json_nest_join(df1, df2)
#> Joining with `by = join_by(x)`
df3
#> # A tibble: 3 × 2
#>       x df2       
#>   <dbl> <list>    
#> 1     1 <json [1]>
#> 2     2 <json [1]>
#> 3     3 <json [1]>
df3$df2
#> [[1]]
#> [{"y":"first"},{"y":"second"}] 
#> 
#> [[2]]
#> [{"y":"third"}] 
#> 
#> [[3]]
#> [] 
#> 
```
