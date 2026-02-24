# Check for existence of a schema on a database

**\[experimental\]**

`db_schema_exists()` checks, if a schema exists on the database.

## Usage

``` r
db_schema_exists(con, schema, ...)
```

## Arguments

- con:

  An object of class `"src"` or `"DBIConnection"`.

- schema:

  Class `character` or `SQL`, name of the schema

- ...:

  Passed on to the individual methods.

## Value

A boolean: `TRUE` if schema exists, `FALSE` otherwise.

## Details

Methods are not available for all DBMS.

Additional arguments are:

- `dbname`: supported for MSSQL. Check if a schema exists on a different
  database on the connected MSSQL-server; default: database addressed by
  `con`.

## See also

Other schema handling functions:
[`db_schema_create()`](https://dm.cynkra.com/reference/db_schema_create.md),
[`db_schema_drop()`](https://dm.cynkra.com/reference/db_schema_drop.md),
[`db_schema_list()`](https://dm.cynkra.com/reference/db_schema_list.md)
