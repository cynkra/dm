# Add a unique key

`dm_add_uk()` marks the specified columns as a unique key of the
specified table. If `check == TRUE`, then it will first check if the
given combination of columns is a unique key of the table.

## Usage

``` r
dm_add_uk(dm, table, columns, ..., check = FALSE)
```

## Arguments

- dm:

  A `dm` object.

- table:

  A table in the `dm`.

- columns:

  Table columns, unquoted. To define a compound key, use
  `c(col1, col2)`.

- ...:

  These dots are for future extensions and must be empty.

- check:

  Boolean, if `TRUE`, a check is made if the combination of columns is a
  unique key of the table.

## Value

An updated `dm` with an additional unqiue key.

## Details

The difference between a primary key (PK) and a unique key (UK) consists
in the following:

- When a local `dm` is copied to a database (DB) with
  [`copy_dm_to()`](https://dm.cynkra.com/dev/reference/copy_dm_to.md), a
  PK will be set on the DB by default, whereas a UK is being ignored.

- A PK can be set as an `autoincrement` key (also implemented on certain
  DBMS when the `dm` is transferred to the DB)

- There can be only one PK for each table, whereas there can be
  unlimited UKs

- A UK will be used, if the same table has an autoincrement PK in
  addition, to ensure that during delta load processes on the DB (cf.
  [`dm_rows_append()`](https://dm.cynkra.com/dev/reference/rows-dm.md))
  the foreign keys are updated accordingly. If no UK is available, the
  insertion is done row-wise, which also ensures a correct matching, but
  can be much slower.

- A UK can generally enhance the data model by adding additional
  information

- There can also be implicit UKs, when the columns addressed by a
  foreign key are neither a PK nor a UK. These implicit UKs are also
  listed by
  [`dm_get_all_uks()`](https://dm.cynkra.com/dev/reference/dm_get_all_uks.md)

## See also

Other primary key functions:
[`dm_add_pk()`](https://dm.cynkra.com/dev/reference/dm_add_pk.md),
[`dm_get_all_pks()`](https://dm.cynkra.com/dev/reference/dm_get_all_pks.md),
[`dm_get_all_uks()`](https://dm.cynkra.com/dev/reference/dm_get_all_uks.md),
[`dm_has_pk()`](https://dm.cynkra.com/dev/reference/dm_has_pk.md),
[`dm_rm_pk()`](https://dm.cynkra.com/dev/reference/dm_rm_pk.md),
[`dm_rm_uk()`](https://dm.cynkra.com/dev/reference/dm_rm_uk.md),
[`enum_pk_candidates()`](https://dm.cynkra.com/dev/reference/dm_enum_pk_candidates.md)

## Examples

``` r
nycflights_dm <- dm(
  planes = nycflights13::planes,
  airports = nycflights13::airports,
  weather = nycflights13::weather
)

# Create unique keys:
nycflights_dm %>%
  dm_add_uk(planes, tailnum) %>%
  dm_add_uk(airports, faa, check = TRUE) %>%
  dm_add_uk(weather, c(origin, time_hour)) %>%
  dm_get_all_uks()
#> # A tibble: 3 × 3
#>   table    uk_col            kind       
#>   <chr>    <keys>            <chr>      
#> 1 planes   tailnum           explicit UK
#> 2 airports faa               explicit UK
#> 3 weather  origin, time_hour explicit UK

# Keys can be checked during creation:
try(
  nycflights_dm %>%
    dm_add_uk(planes, manufacturer, check = TRUE)
)
#> Error in check_key(planes, manufacturer) : 
#>   (`manufacturer`) not a unique key of `planes`.
```
