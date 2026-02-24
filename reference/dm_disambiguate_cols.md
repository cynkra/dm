# Resolve column name ambiguities

This function ensures that all columns in a `dm` have unique names.

## Usage

``` r
dm_disambiguate_cols(
  dm,
  .sep = ".",
  ...,
  .quiet = FALSE,
  .position = c("suffix", "prefix")
)
```

## Arguments

- dm:

  A `dm` object.

- .sep:

  The character variable that separates the names of the table and the
  names of the ambiguous columns.

- ...:

  These dots are for future extensions and must be empty.

- .quiet:

  Boolean. By default, this function lists the renamed columns in a
  message, pass `TRUE` to suppress this message.

- .position:

  **\[experimental\]** By default, table names are appended to the
  column names to resolve conflicts. Prepending table names was the
  default for versions before 1.0.0, use `"prefix"` to achieve this
  behavior.

## Value

A `dm` whose column names are unambiguous.

## Details

The function first checks if there are any column names that are not
unique. If there are, those columns will be assigned new, unique, names
by prefixing their existing name with the name of their table and a
separator. Columns that act as primary or foreign keys will not be
renamed because only the foreign key column will remain when two tables
are joined, making that column name "unique" as well.

## Examples

``` r
dm_nycflights13() %>%
  dm_disambiguate_cols()
#> Renaming ambiguous columns: %>%
#>   dm_rename(airlines, carrier.airlines = carrier) %>%
#>   dm_rename(airlines, name.airlines = name) %>%
#>   dm_rename(airports, name.airports = name) %>%
#>   dm_rename(flights, year.flights = year) %>%
#>   dm_rename(flights, month.flights = month) %>%
#>   dm_rename(flights, day.flights = day) %>%
#>   dm_rename(flights, carrier.flights = carrier) %>%
#>   dm_rename(flights, tailnum.flights = tailnum) %>%
#>   dm_rename(flights, origin.flights = origin) %>%
#>   dm_rename(flights, hour.flights = hour) %>%
#>   dm_rename(flights, time_hour.flights = time_hour) %>%
#>   dm_rename(planes, tailnum.planes = tailnum) %>%
#>   dm_rename(planes, year.planes = year) %>%
#>   dm_rename(weather, origin.weather = origin) %>%
#>   dm_rename(weather, year.weather = year) %>%
#>   dm_rename(weather, month.weather = month) %>%
#>   dm_rename(weather, day.weather = day) %>%
#>   dm_rename(weather, hour.weather = hour) %>%
#>   dm_rename(weather, time_hour.weather = time_hour)
#> ── Metadata ────────────────────────────────────────────────────────────────────
#> Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#> Columns: 53
#> Primary keys: 4
#> Foreign keys: 4
```
