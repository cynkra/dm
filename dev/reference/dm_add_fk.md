# Add foreign keys

`dm_add_fk()` marks the specified `columns` as the foreign key of table
`table` with respect to a key of table `ref_table`. Usually the
referenced columns are a primary key in `ref_table`. However, it is also
possible to specify other columns via the `ref_columns` argument. If
`check == TRUE`, then it will first check if the values in `columns` are
a subset of the values of the key in table `ref_table`.

## Usage

``` r
dm_add_fk(
  dm,
  table,
  columns,
  ref_table,
  ref_columns = NULL,
  ...,
  check = FALSE,
  on_delete = c("no_action", "cascade")
)
```

## Arguments

- dm:

  A `dm` object.

- table:

  A table in the `dm`.

- columns:

  The columns of `table` which are to become the foreign key columns
  that reference `ref_table`. To define a compound key, use
  `c(col1, col2)`.

- ref_table:

  The table which `table` will be referencing.

- ref_columns:

  The column(s) of `table` which are to become the referenced column(s)
  in `ref_table`. By default, the primary key is used. To define a
  compound key, use `c(col1, col2)`.

- ...:

  These dots are for future extensions and must be empty.

- check:

  Boolean, if `TRUE`, a check will be performed to determine if the
  values of `columns` are a subset of the values of the key column(s) of
  `ref_table`.

- on_delete:

  **\[experimental\]**

  Defines behavior if a row in the parent table is deleted. -
  `"no_action"`, the default, means that no action is taken and the
  operation is aborted if child rows exist - `"cascade"` means that the
  child row is also deleted This setting is picked up by
  [`copy_dm_to()`](https://dm.cynkra.com/dev/reference/copy_dm_to.md)
  with `set_key_constraints = TRUE`, and by
  [`dm_sql()`](https://dm.cynkra.com/dev/reference/dm_sql.md), and might
  be considered by
  [`dm_rows_delete()`](https://dm.cynkra.com/dev/reference/rows-dm.md)
  in a future version.

## Value

An updated `dm` with an additional foreign key relation.

## Details

It is possible that a foreign key (FK) is pointing to columns that are
neither primary (PK) nor explicit unique keys (UK). This can happen

1.  when a FK is added without a corresponding PK or UK being present in
    the parent table

2.  when the PK or UK is removed
    ([`dm_rm_pk()`](https://dm.cynkra.com/dev/reference/dm_rm_pk.md)/[`dm_rm_uk()`](https://dm.cynkra.com/dev/reference/dm_rm_uk.md))
    without first removing the associated FKs.

These columns are then a so-called "implicit unique key" of the
referenced table and can be listed via
[`dm_get_all_uks()`](https://dm.cynkra.com/dev/reference/dm_get_all_uks.md).

## See also

Other foreign key functions:
[`dm_enum_fk_candidates()`](https://dm.cynkra.com/dev/reference/dm_enum_fk_candidates.md),
[`dm_get_all_fks()`](https://dm.cynkra.com/dev/reference/dm_get_all_fks.md),
[`dm_rm_fk()`](https://dm.cynkra.com/dev/reference/dm_rm_fk.md)

## Examples

``` r
nycflights_dm <- dm(
  planes = nycflights13::planes,
  flights = nycflights13::flights,
  weather = nycflights13::weather
)

nycflights_dm %>%
  dm_draw()
%0


flights
flightsplanes
planesweather
weather
# Create foreign keys:
nycflights_dm %>%
  dm_add_pk(planes, tailnum) %>%
  dm_add_fk(flights, tailnum, planes) %>%
  dm_add_pk(weather, c(origin, time_hour)) %>%
  dm_add_fk(flights, c(origin, time_hour), weather) %>%
  dm_draw()
%0


flights
flightstailnumorigin, time_hourplanes
planestailnumflights:tailnum->planes:tailnum
weather
weatherorigin, time_hourflights:origin, time_hour->weather:origin, time_hour

# Keys can be checked during creation:
try(
  nycflights_dm %>%
    dm_add_pk(planes, tailnum) %>%
    dm_add_fk(flights, tailnum, planes, check = TRUE)
)
#> Error in dm_add_fk(., flights, tailnum, planes, check = TRUE) : 
#>   Column (`tailnum`) of table flights contains values (see examples above)
#> that are not present in column (`tailnum`) of table planes.
```
