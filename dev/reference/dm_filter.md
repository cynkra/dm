# Filtering

Filtering a table of a [`dm`](https://dm.cynkra.com/dev/reference/dm.md)
object may affect other tables that are connected to it directly or
indirectly via foreign key relations.

`dm_filter()` can be used to define filter conditions for tables using
syntax that is similar to
[`dplyr::filter()`](https://dplyr.tidyverse.org/reference/filter.html).
The filters work across related tables: The resulting `dm` object only
contains rows that are related (directly or indirectly) to rows that
remain after applying the filters on all tables.

## Usage

``` r
dm_filter(.dm, ...)
```

## Arguments

- .dm:

  A `dm` object.

- ...:

  Named logical predicates. The names correspond to tables in the `dm`
  object. The predicates are defined in terms of the variables in the
  corresponding table, they are passed on to
  [`dplyr::filter()`](https://dplyr.tidyverse.org/reference/filter.html).

  Multiple conditions are combined with `&`. Only the rows where the
  condition evaluates to `TRUE` are kept.

## Value

An updated `dm` object with filters executed across all tables.

## Details

As of dm 1.0.0, these conditions are no longer stored in the `dm`
object, instead they are applied to all tables during the call to
`dm_filter()`. Calling
[`dm_apply_filters()`](https://dm.cynkra.com/dev/reference/deprecated.md)
or
[`dm_apply_filters_to_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md)
is no longer necessary.

Use [`dm_zoom_to()`](https://dm.cynkra.com/dev/reference/dm_zoom_to.md)
and
[`dplyr::filter()`](https://dplyr.tidyverse.org/reference/filter.html)
to filter rows without affecting related tables.

## Examples

``` r
dm_nyc <- dm_nycflights13()
dm_nyc %>%
  dm_nrow()
#> airlines airports  flights   planes  weather 
#>       15       86     1761      945      144 

dm_nyc_filtered <-
  dm_nycflights13() %>%
  dm_filter(airports = (name == "John F Kennedy Intl"))

dm_nyc_filtered %>%
  dm_nrow()
#> airlines airports  flights   planes  weather 
#>       10        1      602      336       38 

# If you want to keep only those rows in the parent tables
# whose primary key values appear as foreign key values in
# `flights`, you can set a `TRUE` filter in `flights`:
dm_nyc %>%
  dm_filter(flights = (1 == 1)) %>%
  dm_nrow()
#> airlines airports  flights   planes  weather 
#>       15        3     1761      945      105 
# note that in this example, the only affected table is
# `airports` because the departure airports in `flights` are
# only the three New York airports.
```
