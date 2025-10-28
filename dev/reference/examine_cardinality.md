# Check table relations

All `check_cardinality_...()` functions test the following conditions:

1.  Are all rows in `x` unique?

2.  Are the rows in `y` a subset of the rows in `x`?

3.  Does the relation between `x` and `y` meet the cardinality
    requirements? One row from `x` must correspond to the requested
    number of rows in `y`, e.g. `_0_1` means that there must be zero or
    one rows in `y` for each row in `x`.

`examine_cardinality()` also checks the first two points and
subsequently determines the type of cardinality.

For convenience, the `x_select` and `y_select` arguments allow
restricting the check to a set of key columns without affecting the
return value.

## Usage

``` r
check_cardinality_0_n(
  x,
  y,
  ...,
  x_select = NULL,
  y_select = NULL,
  by_position = NULL
)

check_cardinality_1_n(
  x,
  y,
  ...,
  x_select = NULL,
  y_select = NULL,
  by_position = NULL
)

check_cardinality_1_1(
  x,
  y,
  ...,
  x_select = NULL,
  y_select = NULL,
  by_position = NULL
)

check_cardinality_0_1(
  x,
  y,
  ...,
  x_select = NULL,
  y_select = NULL,
  by_position = NULL
)

examine_cardinality(
  x,
  y,
  ...,
  x_select = NULL,
  y_select = NULL,
  by_position = NULL
)
```

## Arguments

- x:

  Parent table, data frame or lazy table.

- y:

  Child table, data frame or lazy table.

- ...:

  These dots are for future extensions and must be empty.

- x_select, y_select:

  Key columns to restrict the check, processed with
  [`dplyr::select()`](https://dplyr.tidyverse.org/reference/select.html).

- by_position:

  Set to `TRUE` to ignore column names and match by position instead.
  The default means matching by name, use `x_select` and/or `y_select`
  to align the names.

## Value

`check_cardinality_...()` return `x`, invisibly, if the check is passed,
to support pipes. Otherwise an error is thrown and the reason for it is
explained.

`examine_cardinality()` returns a character variable specifying the type
of relationship between the two columns.

## Details

All cardinality functions accept a parent and a child table (`x` and
`y`). All rows in `x` must be unique, and all rows in `y` must be a
subset of the rows in `x`. The `x_select` and `y_select` arguments allow
restricting the check to a set of key columns without affecting the
return value. If given, both arguments must refer to the same number of
key columns.

The cardinality specifications "0_n", "1_n", "0_1", "1_1" refer to the
expected relation that the child table has with the parent table. "0",
"1" and "n" refer to the occurrences of value combinations in `y` that
correspond to each combination in the columns of the parent table. "n"
means "more than one" in this context, with no upper limit.

**"0_n"**: no restrictions, each row in `x` has at least 0 and at most n
corresponding occurrences in `y`.

**"1_n"**: each row in `x` has at least 1 and at most n corresponding
occurrences in `y`. This means that there is a "surjective" mapping from
the child table to the parent table, i.e. each parent table row exists
at least once in the child table.

**"0_1"**: each row in `x` has at least 0 and at most 1 corresponding
occurrence in `y`. This means that there is a "injective" mapping from
the child table to the parent table, i.e. no combination of values in
the parent table columns is addressed multiple times. But not all parent
table rows have to be referred to.

**"1_1"**: each row in `x` occurs exactly once in `y`. This means that
there is a "bijective" ("injective" AND "surjective") mapping between
the child table and the parent table, i.e. the sets of rows are
identical.

Finally, `examine_cardinality()` tests for and returns the nature of the
relationship (injective, surjective, bijective, or none of these)
between the two given sets of columns. If either `x` is not unique or
there are rows in `y` that are missing from `x`, the requirements for a
cardinality test is not fulfilled. No error will be thrown, but the
result will contain the information which prerequisite was violated.

## See also

Other cardinality functions:
[`dm_examine_cardinalities()`](https://dm.cynkra.com/dev/reference/dm_examine_cardinalities.md)

## Examples

``` r
d1 <- tibble::tibble(a = 1:5)
d2 <- tibble::tibble(a = c(1:4, 4L))
d3 <- tibble::tibble(c = c(1:5, 5L), d = 0)
# This does not pass, `a` is not unique key of d2:
try(check_cardinality_0_n(d2, d1))
#> Error in abort_not_unique_key(x_label, orig_names) : 
#>   (`a`) not a unique key of `d2`.

# Columns are matched by name by default:
try(check_cardinality_0_n(d1, d3))
#> Error in check_card_api_impl({ : 
#>   `by_position = FALSE` or `by_position = NULL` require column names in `x` to match those in `y`.

# This passes, multiple values in d3$c are allowed:
check_cardinality_0_n(d1, d2)

# This does not pass, injectivity is violated:
try(check_cardinality_1_1(d1, d3, y_select = c(a = c)))
#> Error in abort_not_bijective(y_label, colnames(y)) : 
#>   1..1 cardinality (bijectivity) is not given: Column (`a`) in table `d3` contains duplicate values.
try(check_cardinality_0_1(d1, d3, x_select = c(c = a)))
#> Error in abort_not_injective(y_label, colnames(y)) : 
#>   0..1 cardinality (injectivity from child table to parent table) is not given: Column (`c`) in table `d3` contains duplicate values.

# What kind of cardinality is it?
examine_cardinality(d1, d3, x_select = c(c = a))
#> [1] "surjective mapping (child: 1 to n -> parent: 1)"
examine_cardinality(d1, d2)
#> [1] "generic mapping (child: 0 to n -> parent: 1)"
```
