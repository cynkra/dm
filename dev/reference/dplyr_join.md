# dplyr join methods for zoomed dm objects

Use these methods without the '.dm_zoomed' suffix (see examples).

## Usage

``` r
# S3 method for class 'dm_zoomed'
left_join(
  x,
  y,
  by = NULL,
  copy = NULL,
  suffix = NULL,
  ...,
  keep = NULL,
  na_matches = c("na", "never"),
  multiple = "all",
  unmatched = "drop",
  relationship = NULL,
  select = NULL
)

# S3 method for class 'dm_keyed_tbl'
left_join(
  x,
  y,
  by = NULL,
  copy = NULL,
  suffix = NULL,
  ...,
  keep = FALSE,
  na_matches = c("na", "never"),
  multiple = "all",
  unmatched = "drop",
  relationship = NULL
)

# S3 method for class 'dm_zoomed'
inner_join(
  x,
  y,
  by = NULL,
  copy = NULL,
  suffix = NULL,
  ...,
  keep = NULL,
  na_matches = c("na", "never"),
  multiple = "all",
  unmatched = "drop",
  relationship = NULL,
  select = NULL
)

# S3 method for class 'dm_keyed_tbl'
inner_join(
  x,
  y,
  by = NULL,
  copy = NULL,
  suffix = NULL,
  ...,
  keep = FALSE,
  na_matches = c("na", "never"),
  multiple = "all",
  unmatched = "drop",
  relationship = NULL
)

# S3 method for class 'dm_zoomed'
full_join(
  x,
  y,
  by = NULL,
  copy = NULL,
  suffix = NULL,
  ...,
  keep = NULL,
  na_matches = c("na", "never"),
  multiple = "all",
  relationship = NULL,
  select = NULL
)

# S3 method for class 'dm_keyed_tbl'
full_join(
  x,
  y,
  by = NULL,
  copy = NULL,
  suffix = NULL,
  ...,
  keep = FALSE,
  na_matches = c("na", "never"),
  multiple = "all",
  relationship = NULL
)

# S3 method for class 'dm_zoomed'
right_join(
  x,
  y,
  by = NULL,
  copy = NULL,
  suffix = NULL,
  ...,
  keep = NULL,
  na_matches = c("na", "never"),
  multiple = "all",
  unmatched = "drop",
  relationship = NULL,
  select = NULL
)

# S3 method for class 'dm_keyed_tbl'
right_join(
  x,
  y,
  by = NULL,
  copy = NULL,
  suffix = NULL,
  ...,
  keep = FALSE,
  na_matches = c("na", "never"),
  multiple = "all",
  unmatched = "drop",
  relationship = NULL
)

# S3 method for class 'dm_zoomed'
semi_join(
  x,
  y,
  by = NULL,
  copy = NULL,
  ...,
  na_matches = c("na", "never"),
  suffix = NULL,
  select = NULL
)

# S3 method for class 'dm_keyed_tbl'
semi_join(x, y, by = NULL, copy = NULL, ..., na_matches = c("na", "never"))

# S3 method for class 'dm_zoomed'
anti_join(
  x,
  y,
  by = NULL,
  copy = NULL,
  ...,
  na_matches = c("na", "never"),
  suffix = NULL,
  select = NULL
)

# S3 method for class 'dm_keyed_tbl'
anti_join(x, y, by = NULL, copy = NULL, ..., na_matches = c("na", "never"))

# S3 method for class 'dm_zoomed'
nest_join(
  x,
  y,
  by = NULL,
  copy = FALSE,
  keep = NULL,
  name = NULL,
  ...,
  na_matches = c("na", "never"),
  unmatched = "drop"
)

# S3 method for class 'dm_zoomed'
cross_join(x, y, ..., copy = NULL, suffix = c(".x", ".y"))

# S3 method for class 'dm_keyed_tbl'
cross_join(x, y, ..., copy = NULL, suffix = c(".x", ".y"))
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

- ...:

  see
  [`dplyr::join`](https://dplyr.tidyverse.org/reference/mutate-joins.html)

- keep:

  Should the join keys from both `x` and `y` be preserved in the output?

  - If `NULL`, the default, joins on equality retain only the keys from
    `x`, while joins on inequality retain the keys from both inputs.

  - If `TRUE`, all keys from both inputs are retained.

  - If `FALSE`, only keys from `x` are retained. For right and full
    joins, the data in key columns corresponding to rows that only exist
    in `y` are merged into the key columns from `x`. Can't be used when
    joining on inequality conditions.

- na_matches:

  Should two `NA` or two `NaN` values match?

  - `"na"`, the default, treats two `NA` or two `NaN` values as equal,
    like `%in%`, [`match()`](https://rdrr.io/r/base/match.html), and
    [`merge()`](https://rdrr.io/r/base/merge.html).

  - `"never"` treats two `NA` or two `NaN` values as different, and will
    never match them together or to any other values. This is similar to
    joins for database sources and to `base::merge(incomparables = NA)`.

- multiple:

  Handling of rows in `x` with multiple matches in `y`. For each row of
  `x`:

  - `"all"`, the default, returns every match detected in `y`. This is
    the same behavior as SQL.

  - `"any"` returns one match detected in `y`, with no guarantees on
    which match will be returned. It is often faster than `"first"` and
    `"last"` if you just need to detect if there is at least one match.

  - `"first"` returns the first match detected in `y`.

  - `"last"` returns the last match detected in `y`.

- unmatched:

  How should unmatched keys that would result in dropped rows be
  handled?

  - `"drop"` drops unmatched keys from the result.

  - `"error"` throws an error if unmatched keys are detected.

  `unmatched` is intended to protect you from accidentally dropping rows
  during a join. It only checks for unmatched keys in the input that
  could potentially drop rows.

  - For left joins, it checks `y`.

  - For right joins, it checks `x`.

  - For inner joins, it checks both `x` and `y`. In this case,
    `unmatched` is also allowed to be a character vector of length 2 to
    specify the behavior for `x` and `y` independently.

- relationship:

  Handling of the expected relationship between the keys of `x` and `y`.
  If the expectations chosen from the list below are invalidated, an
  error is thrown.

  - `NULL`, the default, doesn't expect there to be any relationship
    between `x` and `y`. However, for equality joins it will check for a
    many-to-many relationship (which is typically unexpected) and will
    warn if one occurs, encouraging you to either take a closer look at
    your inputs or make this relationship explicit by specifying
    `"many-to-many"`.

    See the *Many-to-many relationships* section for more details.

  - `"one-to-one"` expects:

    - Each row in `x` matches at most 1 row in `y`.

    - Each row in `y` matches at most 1 row in `x`.

  - `"one-to-many"` expects:

    - Each row in `y` matches at most 1 row in `x`.

  - `"many-to-one"` expects:

    - Each row in `x` matches at most 1 row in `y`.

  - `"many-to-many"` doesn't perform any relationship checks, but is
    provided to allow you to be explicit about this relationship if you
    know it exists.

  `relationship` doesn't handle cases where there are zero matches. For
  that, see `unmatched`.

- select:

  Select a subset of the **RHS-table**'s columns, the syntax being
  `select = c(col_1, col_2, col_3)` (unquoted or quoted). This argument
  is specific for the `join`-methods for `dm_zoomed`. The table's `by`
  column(s) are automatically added if missing in the selection.

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
