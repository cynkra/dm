# utils table manipulation methods for `dm_zoomed` objects

Extract the first or last rows from a table. Use these methods without
the '.dm_zoomed' suffix (see examples). The methods for regular `dm`
objects extract the first or last tables.

## Usage

``` r
# S3 method for class 'dm_zoomed'
head(x, n = 6L, ...)

# S3 method for class 'dm_zoomed'
tail(x, n = 6L, ...)
```

## Arguments

- x:

  object of class `dm_zoomed`

- n:

  an integer vector of length up to `dim(x)` (or 1, for non-dimensioned
  objects). A `logical` is silently coerced to integer. Values specify
  the indices to be selected in the corresponding dimension (or along
  the length) of the object. A positive value of `n[i]` includes the
  first/last `n[i]` indices in that dimension, while a negative value
  excludes the last/first `abs(n[i])`, including all remaining indices.
  `NA` or non-specified values (when `length(n) < length(dim(x))`)
  select all indices in that dimension. Must contain at least one
  non-missing value.

- ...:

  arguments to be passed to or from other methods.

## Value

A `dm_zoomed` object.

## Details

see manual for the corresponding functions in utils.

## Examples

``` r
zoomed <- dm_nycflights13() %>%
  dm_zoom_to(flights) %>%
  head(4)
zoomed
#> # Zoomed table: flights
#> # A tibble:     4 × 19
#>    year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
#>   <int> <int> <int>    <int>          <int>     <dbl>    <int>          <int>
#> 1  2013     1    10        3           2359         4      426            437
#> 2  2013     1    10       16           2359        17      447            444
#> 3  2013     1    10      450            500       -10      634            648
#> 4  2013     1    10      520            525        -5      813            820
#> # ℹ 11 more variables: arr_delay <dbl>, carrier <chr>, flight <int>,
#> #   tailnum <chr>, origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>,
#> #   hour <dbl>, minute <dbl>, time_hour <dttm>
dm_insert_zoomed(zoomed, new_tbl_name = "head_flights")
#> ── Metadata ────────────────────────────────────────────────────────────────────
#> Tables: `airlines`, `airports`, `flights`, `planes`, `weather`, `head_flights`
#> Columns: 72
#> Primary keys: 4
#> Foreign keys: 8
```
