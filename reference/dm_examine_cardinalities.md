# Learn about your data model

**\[experimental\]**

This function returns a tibble with information about the cardinality of
the FK constraints. The printing for this object is special, use
[`tibble::as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html)
to print as a regular tibble.

## Usage

``` r
dm_examine_cardinalities(
  .dm,
  ...,
  .progress = NA,
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

- dm, progress:

  **\[deprecated\]**

## Value

A tibble with the following columns:

- `child_table`:

  child table,

- `child_fk_cols`:

  foreign key column(s) in child table as list of character vectors,

- `parent_table`:

  parent table,

- `parent_key_cols`:

  key column(s) in parent table as list of character vectors,

- `cardinality`:

  the nature of cardinality along the foreign key.

## Details

Uses
[`examine_cardinality()`](https://dm.cynkra.com/reference/examine_cardinality.md)
on each foreign key that is defined in the
[`dm`](https://dm.cynkra.com/reference/dm.md).

## See also

Other cardinality functions:
[`examine_cardinality()`](https://dm.cynkra.com/reference/examine_cardinality.md)

## Examples

``` r
dm_nycflights13() %>%
  dm_examine_cardinalities()
#> • FK: flights$(`carrier`) -> airlines$(`carrier`): surjective mapping (child: 1 to n -> parent: 1)
#> • FK: flights$(`origin`) -> airports$(`faa`): generic mapping (child: 0 to n -> parent: 1)
#> • FK: flights$(`origin`, `time_hour`) -> weather$(`origin`, `time_hour`): generic mapping (child: 0 to n -> parent: 1)
#> • FK: flights$(`tailnum`) -> planes$(`tailnum`): Column (`tailnum`) of table `flights` not a subset of column (`tailnum`) of table `planes`.
#> ! Not all FK constraints satisfied, call `dm_examine_constraints()` for details.
```
