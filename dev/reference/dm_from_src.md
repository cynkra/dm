# Load a dm from a remote data source

Deprecated in dm 0.3.0 in favor of
[`dm_from_con()`](https://dm.cynkra.com/dev/reference/dm_from_con.md).

## Usage

``` r
dm_from_src(src = NULL, table_names = NULL, learn_keys = NULL, ...)
```

## Arguments

- src:

  A dbplyr source, DBI connection object or a Pool object.

- table_names:

  A character vector of the names of the tables to include.

- learn_keys:

  **\[experimental\]**

  Set to `TRUE` to query the definition of primary and foreign keys from
  the database. Currently works only for Postgres/Redshift and SQL
  Server databases. The default attempts to query and issues an
  informative message.

- ...:

  **\[experimental\]**

  Additional parameters for the schema learning query.

  - `schema`: supported for MSSQL (default: `"dbo"`), Postgres/Redshift
    (default: `"public"`), and MariaDB/MySQL (default: current
    database). Learn the tables in a specific schema (or database for
    MariaDB/MySQL).

  - `dbname`: supported for MSSQL. Access different databases on the
    connected MSSQL-server; default: active database.

  - `table_type`: supported for Postgres/Redshift (default:
    `"BASE TABLE"`). Specify the table type. Options are:

    1.  `"BASE TABLE"` for a persistent table (normal table type)

    2.  `"VIEW"` for a view

    3.  `"FOREIGN TABLE"` for a foreign table

    4.  `"LOCAL TEMPORARY"` for a temporary table
