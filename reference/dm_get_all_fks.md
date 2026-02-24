# Get foreign key constraints

Get a summary of all foreign key relations in a
[`dm`](https://dm.cynkra.com/reference/dm.md).

## Usage

``` r
dm_get_all_fks(dm, parent_table = NULL, ...)
```

## Arguments

- dm:

  A `dm` object.

- parent_table:

  One or more table names, unquoted, to return foreign key information
  for. If given, foreign keys are returned in that order. The default
  `NULL` returns information for all tables.

- ...:

  These dots are for future extensions and must be empty.

## Value

A tibble with the following columns:

- `child_table`:

  child table,

- `child_fk_cols`:

  foreign key column(s) in child table as list of character vectors,

- `parent_table`:

  parent table,

- `parent_key_cols`:

  key column(s) in parent table as list of character vectors.

- `on_delete`:

  behavior on deletion of rows in the parent table.

## See also

Other foreign key functions:
[`dm_add_fk()`](https://dm.cynkra.com/reference/dm_add_fk.md),
[`dm_enum_fk_candidates()`](https://dm.cynkra.com/reference/dm_enum_fk_candidates.md),
[`dm_rm_fk()`](https://dm.cynkra.com/reference/dm_rm_fk.md)

## Examples

``` r
dm_nycflights13() %>%
  dm_get_all_fks()
#> # A tibble: 4 × 5
#>   child_table child_fk_cols     parent_table parent_key_cols   on_delete
#>   <chr>       <keys>            <chr>        <keys>            <chr>    
#> 1 flights     carrier           airlines     carrier           no_action
#> 2 flights     origin            airports     faa               no_action
#> 3 flights     tailnum           planes       tailnum           no_action
#> 4 flights     origin, time_hour weather      origin, time_hour no_action
```
