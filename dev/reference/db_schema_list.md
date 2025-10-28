# List schemas on a database

**\[experimental\]**

`db_schema_list()` lists the available schemas on the database.

## Usage

``` r
db_schema_list(con, include_default = TRUE, ...)
```

## Arguments

- con:

  An object of class `"src"` or `"DBIConnection"`.

- include_default:

  Boolean, if `TRUE` (default), also the default schema on the database
  is included in the result

- ...:

  Passed on to the individual methods.

## Value

A tibble with the following columns:

- `schema_name`:

  the names of the schemas,

- `schema_owner`:

  the schema owner names.

## Details

Methods are not available for all DBMS.

Additional arguments are:

- `dbname`: supported for MSSQL. List schemas on a different database on
  the connected MSSQL-server; default: database addressed by `con`.

## See also

Other schema handling functions:
[`db_schema_create()`](https://dm.cynkra.com/dev/reference/db_schema_create.md),
[`db_schema_drop()`](https://dm.cynkra.com/dev/reference/db_schema_drop.md),
[`db_schema_exists()`](https://dm.cynkra.com/dev/reference/db_schema_exists.md)
