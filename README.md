
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

## Example

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
#> Error: (a) is not a primary key of data_1
```

Mind the error message when a test is not passed.

In case of `data_2` the column `a` is a key:

``` r
check_key(data_2, a)
```

To see if a column of one table is a foreign key for another table, you
can use `check_foreign_key()`:

``` r
check_foreign_key(data_1, a, data_2, a)
```

What about the inverse relation?

``` r
check_foreign_key(data_2, a, data_1, a)
#> # A tibble: 1 x 3
#>       a     b     c
#>   <dbl> <dbl> <dbl>
#> 1     3     6     9
#> Error: Foreign key constraint: Column `a` in table `data_2` contains values (see above) that are not present in column `a` in table `data_1`
```

One should keep in mind, that `check_foreign_key()` does NOT test, if
parameter `c_2` is a primary key of table `t_2`.

To check both directions at once - basically answering the questions:
are the unique values of `c_1` in `t_1` the same as those of `c_2` in
`t_2`? - `dm` provides the function `check_overlap()`:

``` r
check_overlap(data_1, a, data_2, a)
#> # A tibble: 1 x 3
#>       a     b     c
#>   <dbl> <dbl> <dbl>
#> 1     3     6     9
#> Error in check_overlap(data_1, a, data_2, a): Foreign key constraint: Column `a` in table `data_2` contains values (see above) that are not present in column `a` in table `data_1`
```

Bringing one more table into the game, we can show how it looks, when
the test is passed:

``` r
data_3 <- tibble(a = c(2, 1, 2), b = c(4, 5, 6), c = c(7, 8, 9))

check_overlap(data_1, a, data_3, a)
```

If for any of these three functions the test is passed, the return value
of the function will be the first table parameter (invisibly). This
ensures, that the functions can conveniently be used in a pipe.

## Package overview

To get an overview of `dm`, you can call the package’s function
`browse_docs()`, which will open a .html-file in your standard web
browser. You can also manually open the file, it is `index.html` in the
folder `pkgdown`.
