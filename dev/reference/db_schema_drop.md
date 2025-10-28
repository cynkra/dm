# Remove a schema from a database

**\[experimental\]**

`db_schema_drop()` deletes a schema from the database. For certain DBMS
it is possible to force the removal of a non-empty schema, see below.

## Usage

``` r
db_schema_drop(con, schema, force = FALSE, ...)
```

## Arguments

- con:

  An object of class `"src"` or `"DBIConnection"`.

- schema:

  Class `character` or `SQL` (cf. Details), name of the schema

- force:

  Boolean, default `FALSE`. Set to `TRUE` to drop a schema and all
  objects it contains at once. Currently only supported for
  Postgres/Redshift.

- ...:

  Passed on to the individual methods.

## Value

`NULL` invisibly.

## Details

Methods are not available for all DBMS.

An error is thrown if no schema of that name exists.

The argument `schema` (and `dbname` for MSSQL) can be provided as `SQL`
objects. Keep in mind, that in this case it is assumed that they are
already correctly quoted as identifiers.

Additional arguments are:

- `dbname`: supported for MSSQL. Remove a schema from a different
  database on the connected MSSQL-server; default: database addressed by
  `con`.

## See also

Other schema handling functions:
[`db_schema_create()`](https://dm.cynkra.com/dev/reference/db_schema_create.md),
[`db_schema_exists()`](https://dm.cynkra.com/dev/reference/db_schema_exists.md),
[`db_schema_list()`](https://dm.cynkra.com/dev/reference/db_schema_list.md)
