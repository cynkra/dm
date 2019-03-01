
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dm

The goal of `dm` is to provide functions for frequently required tasks
when working with data models.

## Installation

You can receive the package as a file `dm.tar.gz` from Kirill Müller,
Email: <kirill@cynkra.com> .

One way to install it to your R-Library is by opening R-Studio and
selecting “Install Packages…” from the `Tools` menu. In the appearing
window, choose the option “Install from: Package Archive File (.tgz;
.tar.gz)” and browse to `dm.tar.gz`.

## Examples for employing helper functions to test for key constraints

This section contains information and examples for the functions:

1.  `check_key(.data, ...)`
2.  `check_if_subset(t1, c1, t2, c2)`
3.  `check_set_equality(t1, c1, t2, c2)`

When you have tables (data frames) that are connected by key relations,
this package might help you verify the assumed key relations and/or
determine existing key relations between the tables. For example, if you
have tables:

``` r
data_1 <- tibble(a = c(1, 2, 1), b = c(1, 4, 1), c = c(5, 6, 7))
data_2 <- tibble(a = c(1, 2, 3), b = c(4, 5, 6), c = c(7, 8, 9))
```

and you want to know if `a` is a primary key for `data_1`, you can use
the `check_key()` function:

``` r
check_key(data_1, a)
#> Error: `a` is not a unique key of `data_1`
```

Mind the error message when a test is not passed.

In case of `data_2` column `a` is a key:

``` r
check_key(data_2, a)
```

To see if a column of one table contains only values, that are also in
another column of another table (one of the two criteria of it being a
foreign key to this other table, the other being if this other table’s
column is one of its unique keys), you can use `check_if_subset()`:

``` r
check_if_subset(data_1, a, data_2, a)
```

What about the inverse relation?

``` r
check_if_subset(data_2, a, data_1, a)
#> # A tibble: 1 x 3
#>       a     b     c
#>   <dbl> <dbl> <dbl>
#> 1     3     6     9
#> Error: Column `a` in table `data_2` contains values (see above) that are not present in column `a` in table `data_1`
```

One should keep in mind, that `check_if_subset()` does NOT test, if
parameter `c2` is a unique key of table `t2`. In order to find out if a
(child) table `t1` contains a column `c1` that is a foreign key to a
(parent) table `t2` with the corresponding column `c2`, one would use
the following approach:

``` r
check_key(t2, c2)
check_if_subset(t1, c1, t2, c2)
```

To check both directions at once - basically answering the questions:
are the unique values of `c_1` in `t_1` the same as those of `c_2` in
`t_2`? - `dm` provides the function `check_set_equality()`:

``` r
check_set_equality(data_1, a, data_2, a)
#> # A tibble: 1 x 3
#>       a     b     c
#>   <dbl> <dbl> <dbl>
#> 1     3     6     9
#> Error in check_set_equality(data_1, a, data_2, a): Column `a` in table `data_2` contains values (see above) that are not present in column `a` in table `data_1`
```

Bringing one more table into the game, we can show how it looks, when
the test is passed:

``` r
data_3 <- tibble(a = c(2, 1, 2), b = c(4, 5, 6), c = c(7, 8, 9))

check_set_equality(data_1, a, data_3, a)
```

If for any of these three functions the test is passed, the return value
of the function will be the first table parameter (invisibly). This
ensures, that the functions can conveniently be used in a
pipe.

## Examples for testing the cardinalities of relations between two tables

This section contains information and examples for the functions:

1.  `check_cardinality_0_n(parent_table, primary_key_column,
    child_table, foreign_key_column)`
2.  `check_cardinality_1_n(parent_table, primary_key_column,
    child_table, foreign_key_column)`
3.  `check_cardinality_0_1(parent_table, primary_key_column,
    child_table, foreign_key_column)`
4.  `check_cardinality_1_1(parent_table, primary_key_column,
    child_table, foreign_key_column)`

The four functions for testing for a specific kind of cardinality of the
relation all require there to be a parent table and a child table. All
these functions first test, if this requirement is fulfilled by checking
if:

1.  `primary_key_column` is a unique key for `parent_table`
2.  The set of values of `foreign_key_column` is a subset of the set of
    values of `primary_key_column`

The cardinality specifications `0_n`, `1_n`, `0_1`, `1_1` refer to the
expected relation, that the child table has with the parent table. The
numbers ‘0’, ‘1’ and ‘n’ refer to the number of values in the child
table’s column (`foreign_key_column`) that correspond to each value of
the parent table’s column (`primary_key_column`). ‘n’ means more than
one in this context, with no upper limit.

`0_n` means, that for each value of the `parent_key_column`, minimally
‘0’ and maximally ‘n’ values have to correspond to it in the child
table’s column (which translates to no further restriction).

`1_n` means, that for each value of the `parent_key_column`, minimally
‘1’ and maximally ‘n’ values have to correspond to it in the child
table’s column. This means that there is a “surjective” relation from
the child table to the parent table w.r.t. the specified columns,
i.e. for each parent table column value there exists at least one equal
child table column value.

`0_1` means, that for each value of the `parent_key_column`, minimally
‘0’ and maximally ‘1’ value has to correspond to it in the child
table’s column. This means that there is a “injective” relation from
the child table to the parent table w.r.t. the specified columns,
i.e. no parent table column value is addressed multiple times. But not
all of the parent table column values have to be referred to.

`1_1` means, that for each value of the `parent_key_column`, precisely
‘1’ value has to correspond to it in the child table’s column. This
means that there is a “bijective” (“injective” AND “surjective”)
relation between the child table and the parent table w.r.t. the
specified columns, i.e. the set of values of the two columns is equal
and there are no duplicates in either of them.

Examples:

Given the following three data frames:

``` r
d1 <- tibble::tibble(a = 1:5)
d2 <- tibble::tibble(c = c(1:5,5))
d3 <- tibble::tibble(c = 1:4)
```

Here are some examples for the usage of the functions:

``` r
# This does not pass, `c` is not unique key of d2:
check_cardinality_0_n(d2, c, d1, a)
#> Error: `c` is not a unique key of `d2`

# This passes, multiple values in d2$c are allowed:
check_cardinality_0_n(d1, a, d2, c)

# This does not pass, injectivity is violated:
check_cardinality_1_1(d1, a, d2, c)
#> Error: 1..1 cardinality (bijectivity) is not given: Column `c` in table `d2` contains duplicate values.

# This passes:
check_cardinality_0_1(d1, a, d3, c)
```

## Package overview

To get an overview of `dm`, you can call the package’s function
`browse_docs()`, which will open a .html-file in your standard web
browser. You can also manually open the file, it is `index.html` in the
folder `pkgdown`.
