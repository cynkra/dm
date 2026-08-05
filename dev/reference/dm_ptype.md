# Prototype for a dm object

The prototype contains all tables, all primary and foreign keys, but no
data. All tables are truncated and converted to zero-row tibbles, also
for remote data models. Columns retain their type. This is useful for
performing creation and population of a database in separate steps.

## Usage

``` r
dm_ptype(dm)
```

## Arguments

- dm:

  A `dm` object.

## Examples

``` r
if (FALSE) { # dm:::dm_has_financial()
dm_financial() %>%
  dm_ptype()

dm_financial() %>%
  dm_ptype() %>%
  dm_nrow()
}
```
