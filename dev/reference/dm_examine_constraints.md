# Validate your data model

This function returns a tibble with information about which key
constraints are met (`is_key = TRUE`) or violated (`FALSE`). The
printing for this object is special, use
[`tibble::as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html)
to print as a regular tibble.

## Usage

``` r
dm_examine_constraints(
  .dm,
  ...,
  .progress = NA,
  .max_value = 6L,
  dm = deprecated(),
  progress = deprecated()
)
```

## Arguments

- .dm:

  A `dm` object.

- ...:

  These dots are for future extensions and must be empty.

- .progress:

  Whether to display a progress bar, if `NA` (the default) hide in
  non-interactive mode, show in interactive mode. Requires the
  'progress' package.

- .max_value:

  Maximum number of distinct problematic values to report in the
  `problem` column, defaults to `6`. Set to `Inf` to report all values.

- dm, progress:

  **\[deprecated\]**

## Value

A tibble with the following columns:

- `table`:

  the table in the `dm`,

- `kind`:

  "PK" or "FK",

- `columns`:

  the table columns that define the key,

- `ref_table`:

  for foreign keys, the referenced table,

- `is_key`:

  logical,

- `problem`:

  if `is_key = FALSE`, the reason for that.

## Details

For the primary key constraints, it is tested if the values in the
respective columns are all unique. For the foreign key constraints, the
tests check if for each foreign key constraint, the values of the
foreign key column form a subset of the values of the referenced column.

## Examples

``` r
dm_nycflights13() %>%
  dm_examine_constraints()
#> ! Unsatisfied constraints:
#> • Table `flights`: foreign key `tailnum` into table `planes`: values of `flights$tailnum` not in `planes$tailnum`: N725MQ (6), N537MQ (5), N722MQ (5), N730MQ (5), N736MQ (5), …
```
