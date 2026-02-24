# Creates a dm object for the nycflights13 data

Creates an example [`dm`](https://dm.cynkra.com/reference/dm.md) object
from the tables in nycflights13, along with the references. See
[`nycflights13::flights`](https://rdrr.io/pkg/nycflights13/man/flights.html)
for a description of the data. As described in
[`nycflights13::planes`](https://rdrr.io/pkg/nycflights13/man/planes.html),
the relationship between the `flights` table and the `planes` tables is
"weak", it does not satisfy data integrity constraints.

## Usage

``` r
dm_nycflights13(
  ...,
  cycle = FALSE,
  color = TRUE,
  subset = TRUE,
  compound = TRUE,
  table_description = FALSE
)
```

## Arguments

- ...:

  These dots are for future extensions and must be empty.

- cycle:

  Boolean. If `FALSE` (default), only one foreign key relation (from
  `flights$origin` to `airports$faa`) between the `flights` table and
  the `airports` table is established. If `TRUE`, a `dm` object with a
  double reference between those tables will be produced.

- color:

  Boolean, if `TRUE` (default), the resulting `dm` object will have
  colors assigned to different tables for visualization with
  [`dm_draw()`](https://dm.cynkra.com/reference/dm_draw.md).

- subset:

  Boolean, if `TRUE` (default), the `flights` table is reduced to
  flights with column `day` equal to 10.

- compound:

  Boolean, if `FALSE`, no link will be established between tables
  `flights` and `weather`, because this requires compound keys.

- table_description:

  Boolean, if `TRUE`, a description will be added for each table that
  will be displayed when drawing the table with
  [`dm_draw()`](https://dm.cynkra.com/reference/dm_draw.md).

## Value

A `dm` object consisting of nycflights13 tables, complete with primary
and foreign keys and optionally colored.

## See also

[`vignette("howto-dm-df")`](https://dm.cynkra.com/articles/howto-dm-df.md)

## Examples

``` r
dm_nycflights13() %>%
  dm_draw()
%0


airlines
airlinescarrierairports
airportsfaaflights
flightscarriertailnumoriginorigin, time_hourflights:carrier->airlines:carrier
flights:origin->airports:faa
planes
planestailnumflights:tailnum->planes:tailnum
weather
weatherorigin, time_hourflights:origin, time_hour->weather:origin, time_hour
```
