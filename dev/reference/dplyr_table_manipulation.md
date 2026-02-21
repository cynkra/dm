# dplyr table manipulation methods for zoomed dm objects

Use these methods without the '.dm_zoomed' suffix (see examples).

## Usage

``` r
# S3 method for class 'dm_zoomed'
filter(.data, ..., .by = NULL, .preserve = FALSE)

# S3 method for class 'dm_keyed_tbl'
filter(.data, ..., .by = NULL, .preserve = FALSE)

# S3 method for class 'dm_zoomed'
filter_out(.data, ..., .by = NULL, .preserve = FALSE)

# S3 method for class 'dm_keyed_tbl'
filter_out(.data, ..., .by = NULL, .preserve = FALSE)

# S3 method for class 'dm_zoomed'
mutate(
  .data,
  ...,
  .by = NULL,
  .keep = c("all", "used", "unused", "none"),
  .before = NULL,
  .after = NULL
)

# S3 method for class 'dm_keyed_tbl'
mutate(
  .data,
  ...,
  .by = NULL,
  .keep = c("all", "used", "unused", "none"),
  .before = NULL,
  .after = NULL
)

# S3 method for class 'dm_zoomed'
transmute(.data, ...)

# S3 method for class 'dm_keyed_tbl'
transmute(.data, ...)

# S3 method for class 'dm_zoomed'
select(.data, ...)

# S3 method for class 'dm_keyed_tbl'
select(.data, ...)

# S3 method for class 'dm_zoomed'
relocate(.data, ..., .before = NULL, .after = NULL)

# S3 method for class 'dm_keyed_tbl'
relocate(.data, ..., .before = NULL, .after = NULL)

# S3 method for class 'dm_zoomed'
rename(.data, ...)

# S3 method for class 'dm_keyed_tbl'
rename(.data, ...)

# S3 method for class 'dm_zoomed'
distinct(.data, ..., .keep_all = FALSE)

# S3 method for class 'dm_keyed_tbl'
distinct(.data, ..., .keep_all = FALSE)

# S3 method for class 'dm_zoomed'
arrange(.data, ..., .by_group = FALSE, .locale = NULL)

# S3 method for class 'dm_keyed_tbl'
arrange(.data, ..., .by_group = FALSE, .locale = NULL)

# S3 method for class 'dm_zoomed'
slice(.data, ..., .by = NULL, .preserve = FALSE, .keep_pk = NULL)

# S3 method for class 'dm_keyed_tbl'
slice(.data, ..., .by = NULL, .preserve = FALSE)

# S3 method for class 'dm_zoomed'
group_by(.data, ..., .add = FALSE, .drop = group_by_drop_default(.data))

# S3 method for class 'dm_keyed_tbl'
group_by(.data, ..., .add = FALSE, .drop = group_by_drop_default(.data))

# S3 method for class 'dm_zoomed'
ungroup(x, ...)

# S3 method for class 'dm_keyed_tbl'
ungroup(x, ...)

# S3 method for class 'dm_zoomed'
summarise(.data, ..., .by = NULL, .groups = NULL)

# S3 method for class 'dm_keyed_tbl'
summarise(.data, ..., .by = NULL, .groups = NULL)

# S3 method for class 'dm_zoomed'
reframe(.data, ..., .by = NULL)

# S3 method for class 'dm_keyed_tbl'
reframe(.data, ..., .by = NULL)

# S3 method for class 'dm_zoomed'
count(
  x,
  ...,
  wt = NULL,
  sort = FALSE,
  name = NULL,
  .drop = group_by_drop_default(x)
)

# S3 method for class 'dm_keyed_tbl'
count(
  x,
  ...,
  wt = NULL,
  sort = FALSE,
  name = NULL,
  .drop = group_by_drop_default(x)
)

# S3 method for class 'dm_zoomed'
tally(x, wt = NULL, sort = FALSE, name = NULL)

# S3 method for class 'dm_keyed_tbl'
tally(x, wt = NULL, sort = FALSE, name = NULL)

# S3 method for class 'dm_zoomed'
pull(.data, var = -1, name = NULL, ...)

# S3 method for class 'dm_zoomed'
compute(x, ...)
```

## Arguments

- .data:

  object of class `dm_zoomed`

- ...:

  see corresponding function in package dplyr or tidyr

- .by:

  \<[`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html)\>
  Optionally, a selection of columns to group by for just this
  operation, functioning as an alternative to
  [`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html).
  For details and examples, see
  [?dplyr_by](https://dplyr.tidyverse.org/reference/dplyr_by.html).

- .preserve:

  Relevant when the `.data` input is grouped. If `.preserve = FALSE`
  (the default), the grouping structure is recalculated based on the
  resulting data, otherwise the grouping is kept as is.

- .keep:

  Control which columns from `.data` are retained in the output.
  Grouping columns and columns created by `...` are always kept.

  - `"all"` retains all columns from `.data`. This is the default.

  - `"used"` retains only the columns used in `...` to create new
    columns. This is useful for checking your work, as it displays
    inputs and outputs side-by-side.

  - `"unused"` retains only the columns *not* used in `...` to create
    new columns. This is useful if you generate new columns, but no
    longer need the columns used to generate them.

  - `"none"` doesn't retain any extra columns from `.data`. Only the
    grouping variables and columns created by `...` are kept.

- .before, .after:

  \<[`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html)\>
  Optionally, control where new columns should appear (the default is to
  add to the right hand side). See
  [`relocate()`](https://dplyr.tidyverse.org/reference/relocate.html)
  for more details.

- .keep_all:

  For `distinct.dm_zoomed()`: see
  [`dplyr::distinct()`](https://dplyr.tidyverse.org/reference/distinct.html)

- .by_group:

  If `TRUE`, will sort first by grouping variable. Applies to grouped
  data frames only.

- .locale:

  The locale to sort character vectors in.

  - If `NULL`, the default, uses the `"C"` locale unless the deprecated
    `dplyr.legacy_locale` global option escape hatch is active. See the
    [dplyr-locale](https://dplyr.tidyverse.org/reference/dplyr-locale.html)
    help page for more details.

  - If a single string from
    [`stringi::stri_locale_list()`](https://rdrr.io/pkg/stringi/man/stri_locale_list.html)
    is supplied, then this will be used as the locale to sort with. For
    example, `"en"` will sort with the American English locale. This
    requires the stringi package.

  - If `"C"` is supplied, then character vectors will always be sorted
    in the C locale. This does not require stringi and is often much
    faster than supplying a locale identifier.

  The C locale is not the same as English locales, such as `"en"`,
  particularly when it comes to data containing a mix of upper and lower
  case letters. This is explained in more detail on the
  [locale](https://dplyr.tidyverse.org/reference/dplyr-locale.html) help
  page under the `Default locale` section.

- .keep_pk:

  For `slice.dm_zoomed`: Logical, if `TRUE`, the primary key will be
  retained during this transformation. If `FALSE`, it will be dropped.
  By default, the value is `NULL`, which causes the function to issue a
  message in case a primary key is available for the zoomed table. This
  argument is specific for the `slice.dm_zoomed()` method.

- .add:

  When `FALSE`, the default,
  [`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html)
  will override existing groups. To add to the existing groups, use
  `.add = TRUE`.

- .drop:

  Drop groups formed by factor levels that don't appear in the data? The
  default is `TRUE` except when `.data` has been previously grouped with
  `.drop = FALSE`. See
  [`group_by_drop_default()`](https://dplyr.tidyverse.org/reference/group_by_drop_default.html)
  for details.

- x:

  For `ungroup.dm_zoomed`: object of class `dm_zoomed`

- .groups:

  **\[experimental\]** Grouping structure of the result.

  - `"drop_last"`: drops the last level of grouping. This was the only
    supported option before version 1.0.0.

  - `"drop"`: All levels of grouping are dropped.

  - `"keep"`: Same grouping structure as `.data`.

  - `"rowwise"`: Each row is its own group.

  When `.groups` is not specified, it is set to `"drop_last"` for a
  grouped data frame, and `"keep"` for a rowwise data frame. In
  addition, a message informs you of how the result will be grouped
  unless the result is ungrouped, the option `"dplyr.summarise.inform"`
  is set to `FALSE`, or when
  [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html)
  is called from a function in a package.

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
