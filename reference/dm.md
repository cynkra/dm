# Data model class

The `dm` class holds a list of tables and their relationships. It is
inspired by [datamodelr](https://github.com/bergant/datamodelr), and
extends the idea by offering operations to access the data in the
tables.

`dm()` creates a `dm` object from
[tbl](https://dplyr.tidyverse.org/reference/tbl.html) objects (tibbles
or lazy data objects).

`new_dm()` is a low-level constructor that creates a new `dm` object.

- If called without arguments, it will create an empty `dm`.

- If called with arguments, no validation checks will be made to
  ascertain that the inputs are of the expected class and internally
  consistent; use
  [`dm_validate()`](https://dm.cynkra.com/reference/dm_validate.md) to
  double-check the returned object.

`is_dm()` returns `TRUE` if the input is of class `dm`.

`as_dm()` coerces objects to the `dm` class

## Usage

``` r
dm(
  ...,
  .name_repair = c("check_unique", "unique", "universal", "minimal"),
  .quiet = FALSE
)

new_dm(tables = list())

is_dm(x)

as_dm(x, ...)
```

## Arguments

- ...:

  Tables or existing `dm` objects to add to the `dm` object. Unnamed
  tables are auto-named, `dm` objects must not be named.

- .name_repair, .quiet:

  Options for name repair. Forwarded as `repair` and `quiet` to
  [`vctrs::vec_as_names()`](https://vctrs.r-lib.org/reference/vec_as_names.html).

- tables:

  A named list of the tables (tibble-objects, not names), to be included
  in the `dm` object.

- x:

  An object.

## Value

For `dm()`, `new_dm()`, `as_dm()`: A `dm` object.

For `is_dm()`: A scalar logical, `TRUE` if is this object is a `dm`.

## See also

- [`dm_from_con()`](https://dm.cynkra.com/reference/dm_from_con.md) for
  connecting to all tables in a database and importing the primary and
  foreign keys

- [`dm_get_tables()`](https://dm.cynkra.com/reference/dm_get_tables.md)
  for returning a list of tables

- [`dm_add_pk()`](https://dm.cynkra.com/reference/dm_add_pk.md) and
  [`dm_add_fk()`](https://dm.cynkra.com/reference/dm_add_fk.md) for
  adding primary and foreign keys

- [`copy_dm_to()`](https://dm.cynkra.com/reference/copy_dm_to.md) for DB
  interaction

- [`dm_draw()`](https://dm.cynkra.com/reference/dm_draw.md) for
  visualization

- [`dm_flatten_to_tbl()`](https://dm.cynkra.com/reference/dm_flatten_to_tbl.md)
  for flattening

- [`dm_filter()`](https://dm.cynkra.com/reference/dm_filter.md) for
  filtering

- [`dm_select_tbl()`](https://dm.cynkra.com/reference/dm_select_tbl.md)
  for creating a `dm` with only a subset of the tables

- [`dm_nycflights13()`](https://dm.cynkra.com/reference/dm_nycflights13.md)
  for creating an example `dm` object

- [`decompose_table()`](https://dm.cynkra.com/reference/decompose_table.md)
  for table surgery

- [`check_key()`](https://dm.cynkra.com/reference/check_key.md) and
  [`check_subset()`](https://dm.cynkra.com/reference/check_subset.md)
  for checking for key properties

- [`examine_cardinality()`](https://dm.cynkra.com/reference/examine_cardinality.md)
  for checking the cardinality of the relation between two tables

## Examples

``` r
dm(trees, mtcars)
#> ── Metadata ────────────────────────────────────────────────────────────────────
#> Tables: `trees`, `mtcars`
#> Columns: 14
#> Primary keys: 0
#> Foreign keys: 0

new_dm(list(trees = trees, mtcars = mtcars))
#> ── Metadata ────────────────────────────────────────────────────────────────────
#> Tables: `trees`, `mtcars`
#> Columns: 14
#> Primary keys: 0
#> Foreign keys: 0

as_dm(list(trees = trees, mtcars = mtcars))
#> ── Metadata ────────────────────────────────────────────────────────────────────
#> Tables: `trees`, `mtcars`
#> Columns: 14
#> Primary keys: 0
#> Foreign keys: 0

is_dm(dm_nycflights13())
#> [1] TRUE

dm_nycflights13()$airports
#> # A tibble: 86 × 8
#>    faa   name                                 lat    lon   alt    tz dst   tzone
#>    <chr> <chr>                              <dbl>  <dbl> <dbl> <dbl> <chr> <chr>
#>  1 ALB   Albany Intl                         42.7  -73.8   285    -5 A     Amer…
#>  2 ATL   Hartsfield Jackson Atlanta Intl     33.6  -84.4  1026    -5 A     Amer…
#>  3 AUS   Austin Bergstrom Intl               30.2  -97.7   542    -6 A     Amer…
#>  4 BDL   Bradley Intl                        41.9  -72.7   173    -5 A     Amer…
#>  5 BHM   Birmingham Intl                     33.6  -86.8   644    -6 A     Amer…
#>  6 BNA   Nashville Intl                      36.1  -86.7   599    -6 A     Amer…
#>  7 BOS   General Edward Lawrence Logan Intl  42.4  -71.0    19    -5 A     Amer…
#>  8 BTV   Burlington Intl                     44.5  -73.2   335    -5 A     Amer…
#>  9 BUF   Buffalo Niagara Intl                42.9  -78.7   724    -5 A     Amer…
#> 10 BUR   Bob Hope                            34.2 -118.    778    -8 A     Amer…
#> # ℹ 76 more rows

dm_nycflights13()["airports"]
#> ── Metadata ────────────────────────────────────────────────────────────────────
#> Tables: `airports`
#> Columns: 8
#> Primary keys: 1
#> Foreign keys: 0

dm_nycflights13()[["airports"]]
#> # A tibble: 86 × 8
#>    faa   name                                 lat    lon   alt    tz dst   tzone
#>    <chr> <chr>                              <dbl>  <dbl> <dbl> <dbl> <chr> <chr>
#>  1 ALB   Albany Intl                         42.7  -73.8   285    -5 A     Amer…
#>  2 ATL   Hartsfield Jackson Atlanta Intl     33.6  -84.4  1026    -5 A     Amer…
#>  3 AUS   Austin Bergstrom Intl               30.2  -97.7   542    -6 A     Amer…
#>  4 BDL   Bradley Intl                        41.9  -72.7   173    -5 A     Amer…
#>  5 BHM   Birmingham Intl                     33.6  -86.8   644    -6 A     Amer…
#>  6 BNA   Nashville Intl                      36.1  -86.7   599    -6 A     Amer…
#>  7 BOS   General Edward Lawrence Logan Intl  42.4  -71.0    19    -5 A     Amer…
#>  8 BTV   Burlington Intl                     44.5  -73.2   335    -5 A     Amer…
#>  9 BUF   Buffalo Niagara Intl                42.9  -78.7   724    -5 A     Amer…
#> 10 BUR   Bob Hope                            34.2 -118.    778    -8 A     Amer…
#> # ℹ 76 more rows

dm_nycflights13() %>% names()
#> [1] "airlines" "airports" "flights"  "planes"   "weather" 
library(dm)
library(nycflights13)

# using `data.frame` objects
new_dm(tibble::lst(weather, airports))
#> ── Metadata ────────────────────────────────────────────────────────────────────
#> Tables: `weather`, `airports`
#> Columns: 23
#> Primary keys: 0
#> Foreign keys: 0

# using `dm_keyed_tbl` objects
dm <- dm_nycflights13()
y1 <- dm$planes %>%
  mutate() %>%
  select(everything())
y2 <- dm$flights %>%
  left_join(dm$airlines, by = "carrier")

new_dm(list("tbl1" = y1, "tbl2" = y2))
#> ── Metadata ────────────────────────────────────────────────────────────────────
#> Tables: `tbl1`, `tbl2`
#> Columns: 29
#> Primary keys: 0
#> Foreign keys: 0
```
