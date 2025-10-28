# dplyr join methods for zoomed dm objects

Use these methods without the '.dm_zoomed' suffix (see examples).

## Usage

``` r
# S3 method for class 'dm_zoomed'
left_join(x, y, by = NULL, copy = NULL, suffix = NULL, select = NULL, ...)

# S3 method for class 'dm_keyed_tbl'
left_join(x, y, by = NULL, copy = NULL, suffix = NULL, ..., keep = FALSE)

# S3 method for class 'dm_zoomed'
inner_join(x, y, by = NULL, copy = NULL, suffix = NULL, select = NULL, ...)

# S3 method for class 'dm_keyed_tbl'
inner_join(x, y, by = NULL, copy = NULL, suffix = NULL, ..., keep = FALSE)

# S3 method for class 'dm_zoomed'
full_join(x, y, by = NULL, copy = NULL, suffix = NULL, select = NULL, ...)

# S3 method for class 'dm_keyed_tbl'
full_join(x, y, by = NULL, copy = NULL, suffix = NULL, ..., keep = FALSE)

# S3 method for class 'dm_zoomed'
right_join(x, y, by = NULL, copy = NULL, suffix = NULL, select = NULL, ...)

# S3 method for class 'dm_keyed_tbl'
right_join(x, y, by = NULL, copy = NULL, suffix = NULL, ..., keep = FALSE)

# S3 method for class 'dm_zoomed'
semi_join(x, y, by = NULL, copy = NULL, suffix = NULL, select = NULL, ...)

# S3 method for class 'dm_keyed_tbl'
semi_join(x, y, by = NULL, copy = NULL, ...)

# S3 method for class 'dm_zoomed'
anti_join(x, y, by = NULL, copy = NULL, suffix = NULL, select = NULL, ...)

# S3 method for class 'dm_keyed_tbl'
anti_join(x, y, by = NULL, copy = NULL, ...)

# S3 method for class 'dm_zoomed'
nest_join(x, y, by = NULL, copy = FALSE, keep = FALSE, name = NULL, ...)
```

## Arguments

- x, y:

  tbls to join. `x` is the `dm_zoomed` and `y` is another table in the
  `dm`.

- by:

  If left `NULL` (default), the join will be performed by via the
  foreign key relation that exists between the originally zoomed table
  (now `x`) and the other table (`y`). If you provide a value (for the
  syntax see
  [`dplyr::join`](https://dplyr.tidyverse.org/reference/mutate-joins.html)),
  you can also join tables that are not connected in the `dm`.

- copy:

  Disabled, since all tables in a `dm` are by definition on the same
  `src`.

- suffix:

  Disabled, since columns are disambiguated automatically if necessary,
  changing the column names to `table_name.column_name`.

- select:

  Select a subset of the **RHS-table**'s columns, the syntax being
  `select = c(col_1, col_2, col_3)` (unquoted or quoted). This argument
  is specific for the `join`-methods for `dm_zoomed`. The table's `by`
  column(s) are automatically added if missing in the selection.

- ...:

  see
  [`dplyr::join`](https://dplyr.tidyverse.org/reference/mutate-joins.html)

- keep:

  Should the new list-column contain join keys? The default will
  preserve the join keys for inequality joins.

- name:

  The name of the list-column created by the join. If `NULL`, the
  default, the name of `y` is used.

## Examples

``` r
flights_dm <- dm_nycflights13()
dm_zoom_to(flights_dm, flights) %>%
  left_join(airports, select = c(faa, name))
#> # Zoomed table: flights
#> # A tibble:     1,761 × 20
#>     year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
#>    <int> <int> <int>    <int>          <int>     <dbl>    <int>          <int>
#>  1  2013     1    10        3           2359         4      426            437
#>  2  2013     1    10       16           2359        17      447            444
#>  3  2013     1    10      450            500       -10      634            648
#>  4  2013     1    10      520            525        -5      813            820
#>  5  2013     1    10      530            530         0      824            829
#>  6  2013     1    10      531            540        -9      832            850
#>  7  2013     1    10      535            540        -5     1015           1017
#>  8  2013     1    10      546            600       -14      645            709
#>  9  2013     1    10      549            600       -11      652            724
#> 10  2013     1    10      550            600       -10      649            703
#> # ℹ 1,751 more rows
#> # ℹ 12 more variables: arr_delay <dbl>, carrier <chr>, flight <int>,
#> #   tailnum <chr>, origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>,
#> #   hour <dbl>, minute <dbl>, time_hour <dttm>, name <chr>

# this should illustrate that tables don't necessarily need to be connected
dm_zoom_to(flights_dm, airports) %>%
  semi_join(airlines, by = "name")
#> # Zoomed table: airports
#> # A tibble:     0 × 8
#> # ℹ 8 variables: faa <chr>, name <chr>, lat <dbl>, lon <dbl>, alt <dbl>,
#> #   tz <dbl>, dst <chr>, tzone <chr>
```
