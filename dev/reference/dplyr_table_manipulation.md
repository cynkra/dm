# dplyr table manipulation methods for zoomed dm objects

Use these methods without the '.dm_zoomed' suffix (see examples).

## Usage

``` r
# S3 method for class 'dm_zoomed'
filter(.data, ...)

# S3 method for class 'dm_zoomed'
mutate(.data, ...)

# S3 method for class 'dm_zoomed'
transmute(.data, ...)

# S3 method for class 'dm_zoomed'
select(.data, ...)

# S3 method for class 'dm_zoomed'
relocate(.data, ..., .before = NULL, .after = NULL)

# S3 method for class 'dm_zoomed'
rename(.data, ...)

# S3 method for class 'dm_zoomed'
distinct(.data, ..., .keep_all = FALSE)

# S3 method for class 'dm_zoomed'
arrange(.data, ...)

# S3 method for class 'dm_zoomed'
slice(.data, ..., .keep_pk = NULL)

# S3 method for class 'dm_zoomed'
group_by(.data, ...)

# S3 method for class 'dm_keyed_tbl'
group_by(.data, ...)

# S3 method for class 'dm_zoomed'
ungroup(x, ...)

# S3 method for class 'dm_zoomed'
summarise(.data, ...)

# S3 method for class 'dm_keyed_tbl'
summarise(.data, ...)

# S3 method for class 'dm_zoomed'
count(
  x,
  ...,
  wt = NULL,
  sort = FALSE,
  name = NULL,
  .drop = group_by_drop_default(x)
)

# S3 method for class 'dm_zoomed'
tally(x, ...)

# S3 method for class 'dm_zoomed'
pull(.data, var = -1, ...)

# S3 method for class 'dm_zoomed'
compute(x, ...)
```

## Arguments

- .data:

  object of class `dm_zoomed`

- ...:

  see corresponding function in package dplyr or tidyr

- .before, .after:

  \<[`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html)\>
  Destination of columns selected by `...`. Supplying neither will move
  columns to the left-hand side; specifying both is an error.

- .keep_all:

  For `distinct.dm_zoomed()`: see
  [`dplyr::distinct()`](https://dplyr.tidyverse.org/reference/distinct.html)

- .keep_pk:

  For `slice.dm_zoomed`: Logical, if `TRUE`, the primary key will be
  retained during this transformation. If `FALSE`, it will be dropped.
  By default, the value is `NULL`, which causes the function to issue a
  message in case a primary key is available for the zoomed table. This
  argument is specific for the `slice.dm_zoomed()` method.

- x:

  For `ungroup.dm_zoomed`: object of class `dm_zoomed`

- wt:

  \<[`data-masking`](https://rlang.r-lib.org/reference/args_data_masking.html)\>
  Frequency weights. Can be `NULL` or a variable:

  - If `NULL` (the default), counts the number of rows in each group.

  - If a variable, computes `sum(wt)` for each group.

- sort:

  If `TRUE`, will show the largest groups at the top.

- name:

  The name of the new column in the output.

  If omitted, it will default to `n`. If there's already a column called
  `n`, it will use `nn`. If there's a column called `n` and `nn`, it'll
  use `nnn`, and so on, adding `n`s until it gets a new name.

- .drop:

  Handling of factor levels that don't appear in the data, passed on to
  [`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html).

  For `count()`: if `FALSE` will include counts for empty groups (i.e.
  for levels of factors that don't exist in the data).

  **\[deprecated\]** For `add_count()`: deprecated since it can't
  actually affect the output.

- var:

  A variable specified as:

  - a literal variable name

  - a positive integer, giving the position counting from the left

  - a negative integer, giving the position counting from the right.

  The default returns the last column (on the assumption that's the
  column you've created most recently).

  This argument is taken by expression and supports
  [quasiquotation](https://rlang.r-lib.org/reference/topic-inject.html)
  (you can unquote column names and column locations).

## Examples

``` r
zoomed <- dm_nycflights13() %>%
  dm_zoom_to(flights) %>%
  group_by(month) %>%
  arrange(desc(day)) %>%
  summarize(avg_air_time = mean(air_time, na.rm = TRUE))
zoomed
#> # Zoomed table: flights
#> # A tibble:     2 × 2
#>   month avg_air_time
#>   <int>        <dbl>
#> 1     1         147.
#> 2     2         149.
dm_insert_zoomed(zoomed, new_tbl_name = "avg_air_time_per_month")
#> ── Metadata ────────────────────────────────────────────────────────────────────
#> Tables: `airlines`, `airports`, `flights`, `planes`, `weather`, `avg_air_time_per_month`
#> Columns: 55
#> Primary keys: 4
#> Foreign keys: 4
```
