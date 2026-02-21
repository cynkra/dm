# Load a dm from a remote data source

`dm_from_con()` creates a
[dm](https://dm.cynkra.com/dev/reference/dm.md) from some or all tables
in a [dplyr::src](https://dplyr.tidyverse.org/reference/src.html) (a
database or an environment) or which are accessible via a
DBI-Connection. For Postgres/Redshift and SQL Server databases, primary
and foreign keys are imported from the database.

## Usage

``` r
dm_from_con(
  con = NULL,
  table_names = NULL,
  learn_keys = NULL,
  .names = NULL,
  ...
)
```

## Arguments

- con:

  A
  [`DBI::DBIConnection`](https://dbi.r-dbi.org/reference/DBIConnection-class.html)
  or a `Pool` object.

- table_names:

  A character vector of the names of the tables to include.

- learn_keys:

  **\[experimental\]**

  Set to `TRUE` to query the definition of primary and foreign keys from
  the database. Currently works for Postgres/Redshift, MariaDB/MySQL,
  SQLite, SQL Server, and DuckDB databases. The default attempts to
  query and issues an informative message.

- .names:

  **\[experimental\]**

  A glue specification that describes how to name the tables within the
  output, currently only for MSSQL, Postgres/Redshift and MySQL/MariaDB.
  This can use `{.table}` to stand for the table name, and `{.schema}`
  to stand for the name of the schema which the table lives within. The
  default (`NULL`) is equivalent to `"{.table}"` when a single schema is
  specified in `schema`, and `"{.schema}.{.table}"` for the case where
  multiple schemas are given, and may change in future versions.

- ...:

  **\[experimental\]**

  Additional parameters for the schema learning query.

  - `schema`: supported for MSSQL (default: `"dbo"`), Postgres/Redshift
    (default: `"public"`), MariaDB/MySQL (default: current database) and
    SQLite (default: main schema). Learn the tables in a specific schema
    (or database for MariaDB/MySQL).

  - `dbname`: supported for MSSQL. Access different databases on the
    connected MSSQL-server; default: active database.

  - `table_type`: supported for Postgres/Redshift (default:
    `"BASE TABLE"`). Specify the table type. Options are:

    1.  `"BASE TABLE"` for a persistent table (normal table type)

    2.  `"VIEW"` for a view

    3.  `"FOREIGN TABLE"` for a foreign table

    4.  `"LOCAL TEMPORARY"` for a temporary table

## Value

A `dm` object.

## Examples

``` r
con <- dm_get_con(dm_financial())

# Avoid DBI::dbDisconnect() here, because we don't own the connection
```
