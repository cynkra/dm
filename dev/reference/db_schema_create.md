# Create a schema on a database

**\[experimental\]**

`db_schema_create()` creates a schema on the database.

## Usage

``` r
db_schema_create(con, schema, ...)
```

## Arguments

- con:

  An object of class `"src"` or `"DBIConnection"`.

- schema:

  Class `character` or `SQL` (cf. Details), name of the schema

- ...:

  Passed on to the individual methods.

## Value

`NULL` invisibly.

## Details

Methods are not available for all DBMS.

An error is thrown if a schema of that name already exists.

The argument `schema` (and `dbname` for MSSQL) can be provided as `SQL`
objects. Keep in mind, that in this case it is assumed that they are
already correctly quoted as identifiers using
[`DBI::dbQuoteIdentifier()`](https://dbi.r-dbi.org/reference/dbQuoteIdentifier.html).

Additional arguments are:

- `dbname`: supported for MSSQL. Create a schema in a different database
  on the connected MSSQL-server; default: database addressed by `con`.

## See also

Other schema handling functions:
[`db_schema_drop()`](https://dm.cynkra.com/dev/reference/db_schema_drop.md),
[`db_schema_exists()`](https://dm.cynkra.com/dev/reference/db_schema_exists.md),
[`db_schema_list()`](https://dm.cynkra.com/dev/reference/db_schema_list.md)
