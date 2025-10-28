# Materialize

[`compute()`](https://dplyr.tidyverse.org/reference/compute.html)
materializes all tables in a `dm` to new temporary tables on the
database.

[`collect()`](https://dplyr.tidyverse.org/reference/compute.html)
downloads the tables in a `dm` object as local
[tibble](https://tibble.tidyverse.org/reference/tibble.html)s.

## Usage

``` r
# S3 method for class 'dm'
compute(x, ..., temporary = TRUE)

# S3 method for class 'dm'
collect(x, ..., progress = NA)
```

## Arguments

- x:

  A `dm` object.

- ...:

  Passed on to
  [`compute()`](https://dplyr.tidyverse.org/reference/compute.html).

- temporary:

  Must remain `TRUE`.

- progress:

  Whether to display a progress bar, if `NA` (the default) hide in
  non-interactive mode, show in interactive mode. Requires the
  'progress' package.

## Value

A `dm` object of the same structure as the input.

## Details

Called on a `dm` object, these methods create a copy of all tables in
the `dm`. Depending on the size of your data this may take a long time.

To create permament tables, first create the database schema using
[`copy_dm_to()`](https://dm.cynkra.com/dev/reference/copy_dm_to.md) or
[`dm_sql()`](https://dm.cynkra.com/dev/reference/dm_sql.md), and then
use
[`dm_rows_append()`](https://dm.cynkra.com/dev/reference/rows-dm.md).

## Examples

``` r
financial <- dm_financial_sqlite()

financial %>%
  pull_tbl(districts) %>%
  dbplyr::remote_name()
#> [1] "districts"

# compute() copies the data to new tables:
financial %>%
  compute() %>%
  pull_tbl(districts) %>%
  dbplyr::remote_name()
#> [1] "dbplyr_oPE5ohIAmt"

# collect() returns a local dm:
financial %>%
  collect() %>%
  pull_tbl(districts) %>%
  class()
#> [1] "tbl_df"     "tbl"        "data.frame"
```
