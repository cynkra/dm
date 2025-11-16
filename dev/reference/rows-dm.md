# Modifying rows for multiple tables

**\[experimental\]**

These functions provide a framework for updating data in existing
tables. Unlike
[`compute()`](https://dplyr.tidyverse.org/reference/compute.html),
[`copy_to()`](https://dplyr.tidyverse.org/reference/copy_to.html) or
[`copy_dm_to()`](https://dm.cynkra.com/dev/reference/copy_dm_to.md), no
new tables are created on the database. All operations expect that both
existing and new data are presented in two compatible
[dm](https://dm.cynkra.com/dev/reference/dm.md) objects on the same data
source.

The functions make sure that the tables in the target dm are processed
in topological order so that parent (dimension) tables receive
insertions before child (fact) tables.

These operations, in contrast to all other operations, may lead to
irreversible changes to the underlying database. Therefore, in-place
operation must be requested explicitly with `in_place = TRUE`. By
default, an informative message is given.

`dm_rows_insert()` adds new records via
[`rows_insert()`](https://dplyr.tidyverse.org/reference/rows.html) with
`conflict = "ignore"`. Duplicate records will be silently discarded.
This operation requires primary keys on all tables, use
`dm_rows_append()` to insert unconditionally.

`dm_rows_append()` adds new records via
[`rows_append()`](https://dplyr.tidyverse.org/reference/rows.html). The
primary keys must differ from existing records. This must be ensured by
the caller and might be checked by the underlying database. Use
`in_place = FALSE` and apply
[`dm_examine_constraints()`](https://dm.cynkra.com/dev/reference/dm_examine_constraints.md)
to check beforehand.

`dm_rows_update()` updates existing records via
[`rows_update()`](https://dplyr.tidyverse.org/reference/rows.html).
Primary keys must match for all records to be updated.

`dm_rows_patch()` updates missing values in existing records via
[`rows_patch()`](https://dplyr.tidyverse.org/reference/rows.html).
Primary keys must match for all records to be patched.

`dm_rows_upsert()` updates existing records and adds new records, based
on the primary key, via
[`rows_upsert()`](https://dplyr.tidyverse.org/reference/rows.html).

`dm_rows_delete()` removes matching records via
[`rows_delete()`](https://dplyr.tidyverse.org/reference/rows.html),
based on the primary key. The order in which the tables are processed is
reversed.

## Usage

``` r
dm_rows_insert(x, y, ..., in_place = NULL, progress = NA)

dm_rows_append(x, y, ..., in_place = NULL, progress = NA)

dm_rows_update(x, y, ..., in_place = NULL, progress = NA)

dm_rows_patch(x, y, ..., in_place = NULL, progress = NA)

dm_rows_upsert(x, y, ..., in_place = NULL, progress = NA)

dm_rows_delete(x, y, ..., in_place = NULL, progress = NA)
```

## Arguments

- x:

  Target `dm` object.

- y:

  `dm` object with new data.

- ...:

  These dots are for future extensions and must be empty.

- in_place:

  Should `x` be modified in place? This argument is only relevant for
  mutable backends (e.g. databases, data.tables).

  When `TRUE`, a modified version of `x` is returned invisibly; when
  `FALSE`, a new object representing the resulting changes is returned.

- progress:

  Whether to display a progress bar, if `NA` (the default) hide in
  non-interactive mode, show in interactive mode. Requires the
  'progress' package.

## Value

A dm object of the same
[`dm_ptype()`](https://dm.cynkra.com/dev/reference/dm_ptype.md) as `x`.
If `in_place = TRUE`, the underlying data is updated as a side effect,
and `x` is returned, invisibly.

## Examples

``` r
# Establish database connection:
sqlite <- DBI::dbConnect(RSQLite::SQLite())

# Entire dataset with all dimension tables populated
# with flights and weather data truncated:
flights_init <-
  dm_nycflights13() %>%
  dm_zoom_to(flights) %>%
  filter(FALSE) %>%
  dm_update_zoomed() %>%
  dm_zoom_to(weather) %>%
  filter(FALSE) %>%
  dm_update_zoomed()

# Target database:
flights_sqlite <- copy_dm_to(sqlite, flights_init, temporary = FALSE)
print(dm_nrow(flights_sqlite))
#> airlines airports  flights   planes  weather 
#>       15       86        0      945        0 

# First update:
flights_jan <-
  dm_nycflights13() %>%
  dm_select_tbl(flights, weather) %>%
  dm_zoom_to(flights) %>%
  filter(month == 1) %>%
  dm_update_zoomed() %>%
  dm_zoom_to(weather) %>%
  filter(month == 1) %>%
  dm_update_zoomed()
print(dm_nrow(flights_jan))
#> flights weather 
#>     932      72 

# Copy to temporary tables on the target database:
flights_jan_sqlite <- copy_dm_to(sqlite, flights_jan)

# Dry run by default:
dm_rows_append(flights_sqlite, flights_jan_sqlite)
#> Result is returned as a dm object with lazy tables. Use `in_place = FALSE` to mute this message, or `in_place = TRUE` to write to the underlying tables.
#> ── Table source ────────────────────────────────────────────────────────────────
#> src:  sqlite 3.51.0 []
#> ── Metadata ────────────────────────────────────────────────────────────────────
#> Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#> Columns: 53
#> Primary keys: 4
#> Foreign keys: 4
print(dm_nrow(flights_sqlite))
#> airlines airports  flights   planes  weather 
#>       15       86        0      945        0 

# Explicitly request persistence:
dm_rows_append(flights_sqlite, flights_jan_sqlite, in_place = TRUE)
print(dm_nrow(flights_sqlite))
#> airlines airports  flights   planes  weather 
#>       15       86      932      945       72 

# Second update:
flights_feb <-
  dm_nycflights13() %>%
  dm_select_tbl(flights, weather) %>%
  dm_zoom_to(flights) %>%
  filter(month == 2) %>%
  dm_update_zoomed() %>%
  dm_zoom_to(weather) %>%
  filter(month == 2) %>%
  dm_update_zoomed()

# Copy to temporary tables on the target database:
flights_feb_sqlite <- copy_dm_to(sqlite, flights_feb)

# Explicit dry run:
flights_new <- dm_rows_append(
  flights_sqlite,
  flights_feb_sqlite,
  in_place = FALSE
)
print(dm_nrow(flights_new))
#> airlines airports  flights   planes  weather 
#>       15       86     1761      945      144 
print(dm_nrow(flights_sqlite))
#> airlines airports  flights   planes  weather 
#>       15       86      932      945       72 

# Check for consistency before applying:
flights_new %>%
  dm_examine_constraints()
#> ! Unsatisfied constraints:
#> • Table `flights`: foreign key `tailnum` into table `planes`: values of `flights$tailnum` not in `planes$tailnum`: N725MQ (6), N537MQ (5), N722MQ (5), N730MQ (5), N736MQ (5), …

# Apply:
dm_rows_append(flights_sqlite, flights_feb_sqlite, in_place = TRUE)
print(dm_nrow(flights_sqlite))
#> airlines airports  flights   planes  weather 
#>       15       86     1761      945      144 

DBI::dbDisconnect(sqlite)
```
