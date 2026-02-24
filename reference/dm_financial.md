# Creates a dm object for the Financial data

`dm_financial()` creates an example
[`dm`](https://dm.cynkra.com/reference/dm.md) object from the tables at
https://relational.fel.cvut.cz/dataset/Financial. The connection is
established once per session, subsequent calls return the same
connection.

`dm_financial_sqlite()` copies the data to a temporary SQLite database.
The data is downloaded once per session, subsequent calls return the
same database. The `trans` table is excluded due to its size.

## Usage

``` r
dm_financial()

dm_financial_sqlite()
```

## Value

A `dm` object.

## Examples

``` r
if (FALSE) { # dm:::dm_has_financial() && rlang::is_installed("DiagrammeR")
dm_financial() %>%
  dm_draw()
}
```
