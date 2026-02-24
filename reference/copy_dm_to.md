# Copy data model to data source

`copy_dm_to()` takes a
[`dbplyr::src_dbi`](https://dbplyr.tidyverse.org/reference/src_dbi.html)
object or a
[`DBI::DBIConnection`](https://dbi.r-dbi.org/reference/DBIConnection-class.html)
object as its first argument and a
[`dm`](https://dm.cynkra.com/reference/dm.md) object as its second
argument. The latter is copied to the former. The default is to create
temporary tables, set `temporary = FALSE` to create permanent tables.
Unless `set_key_constraints` is `FALSE`, primary key, foreign key, and
unique constraints are set, and indexes for foreign keys are created, on
all databases.

## Usage

``` r
copy_dm_to(
  dest,
  dm,
  ...,
  set_key_constraints = TRUE,
  table_names = NULL,
  temporary = TRUE,
  schema = NULL,
  progress = NA,
  unique_table_names = NULL,
  copy_to = NULL
)
```

## Arguments

- dest:

  An object of class `"src"` or `"DBIConnection"`.

- dm:

  A `dm` object.

- ...:

  These dots are for future extensions and must be empty.

- set_key_constraints:

  If `TRUE` will mirror the primary, foreign, and unique key constraints
  and create indexes for foreign key constraints for the primary and
  foreign keys in the `dm` object. Set to `FALSE` if your data model
  currently does not satisfy primary or foreign key constraints.

- table_names:

  Desired names for the tables on `dest`; the names within the `dm`
  remain unchanged. Can be `NULL`, a named character vector, or a vector
  of [`DBI::Id`](https://dbi.r-dbi.org/reference/Id.html) objects.

  If left `NULL` (default), the names will be determined automatically
  depending on the `temporary` argument:

  1.  `temporary = TRUE` (default): unique table names based on the
      names of the tables in the `dm` are created.

  2.  `temporary = FALSE`: the table names in the `dm` are used as names
      for the tables on `dest`.

  If a function or one-sided formula, `table_names` is converted to a
  function using
  [`rlang::as_function()`](https://rlang.r-lib.org/reference/as_function.html).
  This function is called with the unquoted table names of the `dm`
  object as the only argument. The output of this function is processed
  by
  [`DBI::dbQuoteIdentifier()`](https://dbi.r-dbi.org/reference/dbQuoteIdentifier.html),
  that result should be a vector of identifiers of the same length as
  the original table names.

  Use a variant of
  `table_names = ~ DBI::SQL(paste0("schema_name", ".", .x))` to specify
  the same schema for all tables. Use `table_names = identity` with
  `temporary = TRUE` to avoid giving temporary tables unique names.

  If a named character vector, the names of this vector need to
  correspond to the table names in the `dm`, and its values are the
  desired names on `dest`. The value is processed by
  [`DBI::dbQuoteIdentifier()`](https://dbi.r-dbi.org/reference/dbQuoteIdentifier.html),
  that result should be a vector of identifiers of the same length as
  the original table names.

  Use qualified names corresponding to your database's syntax to specify
  e.g. database and schema for your tables.

- temporary:

  If `TRUE`, only temporary tables will be created. These tables will
  vanish when disconnecting from the database.

- schema:

  Name of schema to copy the `dm` to. If `schema` is provided, an error
  will be thrown if `temporary = FALSE` or `table_names` is not `NULL`.

  Not all DBMS are supported.

- progress:

  Whether to display a progress bar, if `NA` (the default) hide in
  non-interactive mode, show in interactive mode. Requires the
  'progress' package.

- unique_table_names, copy_to:

  Must be `NULL`.

## Value

A `dm` object on the given `src` with the same table names as the input
`dm`.

## Examples

``` r
con <- DBI::dbConnect(RSQLite::SQLite())

# Copy to temporary tables, unique table names by default:
temp_dm <- copy_dm_to(
  con,
  dm_nycflights13(),
  set_key_constraints = FALSE
)

# Persist, explicitly specify table names:
persistent_dm <- copy_dm_to(
  con,
  dm_nycflights13(),
  temporary = FALSE,
  table_names = ~ paste0("flights_", .x)
)
dbplyr::remote_name(persistent_dm$planes)
#> [1] "flights_planes"

DBI::dbDisconnect(con)
```
