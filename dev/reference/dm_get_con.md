# Get connection

`dm_get_con()` returns the DBI connection for a `dm` object. This works
only if the tables are stored on a database, otherwise an error is
thrown.

## Usage

``` r
dm_get_con(dm)
```

## Arguments

- dm:

  A `dm` object.

## Value

The
[`DBI::DBIConnection`](https://dbi.r-dbi.org/reference/DBIConnection-class.html)
object for a `dm` object.

## Details

All lazy tables in a dm object must be stored on the same database
server and accessed through the same connection, because a large part of
the package's functionality relies on efficient joins.

## Examples

``` r
dm_financial() %>%
  dm_get_con()
#> <MariaDBConnection>
#>   Connection: guest@relational.fel.cvut.cz<Financial_ijs>[772330] via TCP/IP
```
