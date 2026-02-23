# Model verification - keys, constraints and normalization

In this document, we will present several specialized functions for
conducting basic tests about key conditions and about relations between
tables. We will also describe functions that can be used for splitting
and uniting tables.

``` r
library(dm)
```

## Testing key constraints

This section contains information and examples about the following
functions:

1.  `check_key(.data, ...)`
2.  `check_subset(t1, c1, t2, c2)`
3.  `check_set_equality(t1, c1, t2, c2)`

When you have tables (data frames) that are connected by key relations,
{dm} can help you to verify the assumed key relations and/or determine
the existing key relations between the tables. For example, if you have
tables:

``` r
data_1 <- tibble(a = c(1, 2, 1), b = c(1, 4, 1), c = c(5, 6, 7))
data_2 <- tibble(a = c(1, 2, 3), b = c(4, 5, 6), c = c(7, 8, 9))
```

and you want to know if `a` is a primary key for `data_1`, you can use
the [`check_key()`](https://dm.cynkra.com/dev/reference/check_key.md)
function:

``` r
check_key(data_1, a)
#> Error in `check_key()`:
#> ! (`a`) not a unique key of `data_1`.
```

Mind the error message when a test is not passed.

For `data_2`, column `a` is a key:

``` r
check_key(data_2, a)
```

To see if a column of one table contains only those values that are also
present in another column of another table, the
[`check_subset()`](https://dm.cynkra.com/dev/reference/check_subset.md)
function can be used:

``` r
check_subset(data_1, a, data_2, a)
#> Warning: The `c1` argument of `check_subset()` is deprecated as of dm 1.0.0.
#> ℹ Please use the `x_select` argument instead.
#> ℹ Use `y_select` instead of `c2`, and `x` and `y` instead of `t1` and
#>   `t2`.
#> ℹ Using `by_position = TRUE` for compatibility.
#> ℹ The deprecated feature was likely used in the dm package.
#>   Please report the issue at <https://github.com/cynkra/dm/issues>.
#> This warning is displayed once per session.
#> Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
#> generated.
```

This function is important for determining if a column is a foreign key
to some other table. What about the inverse relation?

``` r
check_subset(data_2, a, data_1, a)
```

``` fansi
#> # A tibble: 1 × 1
#>       a
#>   <dbl>
#> 1     3
```

    #> Error in `check_subset()`:
    #> ! Column (`a`) of table data_2 contains values (see examples above)
    #>   that are not present in column (`a`) of table data_1.

It should be kept in mind that
[`check_subset()`](https://dm.cynkra.com/dev/reference/check_subset.md)
does not test if column `c2` is a unique key of table `t2`. In order to
find out if a (child) table `t1` contains a column `c1` that is a
foreign key to a (parent) table `t2` with the corresponding column `c2`,
the following method should be used:

``` r
check_key(t2, c2)
check_subset(t1, c1, t2, c2)
```

To check both directions at once, and to find out if the unique values
of `c_1` in `t_1` are the same as those of `c_2` in `t_2`, {dm} provides
the function
[`check_set_equality()`](https://dm.cynkra.com/dev/reference/check_set_equality.md):

``` r
check_set_equality(data_1, a, data_2, a)
#> Warning: The `c1` argument of `check_set_equality()` is deprecated as of dm 1.0.0.
#> ℹ Please use the `x_select` argument instead.
#> ℹ Use `y_select` instead of `c2`, and `x` and `y` instead of `t1` and
#>   `t2`.
#> ℹ Using `by_position = TRUE` for compatibility.
#> ℹ The deprecated feature was likely used in the dm package.
#>   Please report the issue at <https://github.com/cynkra/dm/issues>.
#> This warning is displayed once per session.
#> Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
#> generated.
```

``` fansi
#> # A tibble: 1 × 1
#>       a
#>   <dbl>
#> 1     3
```

    #> Error in `check_set_equality()`:
    #> ! Column (`a`) of table data_2 contains values (see examples above)
    #>   that are not present in column (`a`) of table data_1.

Introducing one more table enables us to show how it looks when the test
is passed:

``` r
data_3 <- tibble(a = c(2, 1, 2), b = c(4, 5, 6), c = c(7, 8, 9))

check_set_equality(data_1, a, data_3, a)
```

If the test is passed, the return value of the function will be the
first table parameter (invisibly). This ensures that the functions can
be conveniently used in a pipe configuration.

## Testing cardinalities between two tables

This section contains information and examples for the functions

1.  `check_cardinality_0_n(parent_table, primary_key_column, child_table, foreign_key_column)`
2.  `check_cardinality_1_n(parent_table, primary_key_column, child_table, foreign_key_column)`
3.  `check_cardinality_0_1(parent_table, primary_key_column, child_table, foreign_key_column)`
4.  `check_cardinality_1_1(parent_table, primary_key_column, child_table, foreign_key_column)`
5.  `examine_cardinality(parent_table, primary_key_column, child_table, foreign_key_column)`

The four functions for testing for a specific kind of cardinality of the
relation all require a parent table and a child table as inputs. The
functions first test if that requirement is fulfilled by checking if:

1.  `primary_key_column` is a unique key for `parent_table`
2.  The set of values of `foreign_key_column` is a subset of the set of
    values of `primary_key_column`

The cardinality specifications `0_n`, `1_n`, `0_1`, `1_1` refer to the
expected relation that the child table has with the parent table. The
numbers ‘0’, ‘1’ and ‘n’ refer to the number of values in the child
table’s column (`foreign_key_column`) that correspond to each value of
the parent table’s column (`primary_key_column`). ‘n’ means more than
one in this context, with no upper limit.

`0_n` means, that for each value of the `parent_key_column`, the number
of corresponding records in the child table is unrestricted. `1_n`
means, that for each value of the `parent_key_column` there is at least
one corresponding record in the child table. This means that there is a
“surjective” relation from the child table to the parent table w.r.t.
the specified columns, i.e. for each parent table column value there
exists at least one equal child table column value.

`0_1` means, that for each value of the `parent_key_column`, at least
zero and at most one value has to correspond to it in the column of the
child table. This means that there is an “injective” relation from the
child table to the parent table w.r.t. the specified columns, i.e. no
parent table column value is addressed multiple times. But not all of
the parent table column values have to be referred to.

`1_1` means, that for each value of the `parent_key_column`, exactly one
value has to correspond to it in the child table’s column. This means
that there is a “bijective” (“injective” AND “surjective”) relation
between the child table and the parent table w.r.t. the specified
columns, i.e. the set of values of the two columns is equal and there
are no duplicates in either of them.

Also
[`examine_cardinality()`](https://dm.cynkra.com/dev/reference/examine_cardinality.md)
first performs the above mentioned tests to figure out, if the
parent-child table relationship criteria are met. Subsequently, two
further checks are made to determine the nature of the relation
(surjective, injective, bijective, or none of these) between the two
columns.

### Examples

Given the following three data frames:

``` r
d1 <- tibble(a = 1:5)
d2 <- tibble(c = c(1:5, 5))
d3 <- tibble(c = 1:4)
d4 <- tibble(a = c(2:5, 5))
```

Here are some examples of how the cardinality testing functions can be
used:

``` r
# This does not pass, `c` is not unique key of d2:
check_cardinality_0_n(d2, c, d1, a)
#> Warning: The `pk_column` argument of `check_cardinality_0_n()` is deprecated as of
#> dm 1.0.0.
#> ℹ Please use the `x_select` argument instead.
#> • Use `y_select` instead of `fk_column`, and `x` and `y` instead of
#>   `parent_table` and `child_table`.
#> • Using `by_position = TRUE` for compatibility.
#> ℹ The deprecated feature was likely used in the dm package.
#>   Please report the issue at <https://github.com/cynkra/dm/issues>.
#> This warning is displayed once per session.
#> Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
#> generated.
#> Error in `check_cardinality_0_n()`:
#> ! (`c`) not a unique key of `d2`.

# This passes, multiple values in d2$c are allowed:
check_cardinality_0_n(d1, a, d2, c)

# This does not pass, injectivity is violated:
check_cardinality_1_1(d1, a, d2, c)
#> Warning: The `pk_column` argument of `check_cardinality_1_1()` is deprecated as of
#> dm 1.0.0.
#> ℹ Please use the `x_select` argument instead.
#> • Use `y_select` instead of `fk_column`, and `x` and `y` instead of
#>   `parent_table` and `child_table`.
#> • Using `by_position = TRUE` for compatibility.
#> ℹ The deprecated feature was likely used in the dm package.
#>   Please report the issue at <https://github.com/cynkra/dm/issues>.
#> This warning is displayed once per session.
#> Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
#> generated.
#> Error in `check_cardinality_1_1()`:
#> ! 1..1 cardinality (bijectivity) is not given: Column (`c`) in
#>   table d2 contains duplicate values.

# This passes:
check_cardinality_0_1(d1, a, d3, c)
#> Warning: The `pk_column` argument of `check_cardinality_0_1()` is deprecated as of
#> dm 1.0.0.
#> ℹ Please use the `x_select` argument instead.
#> • Use `y_select` instead of `fk_column`, and `x` and `y` instead of
#>   `parent_table` and `child_table`.
#> • Using `by_position = TRUE` for compatibility.
#> ℹ The deprecated feature was likely used in the dm package.
#>   Please report the issue at <https://github.com/cynkra/dm/issues>.
#> This warning is displayed once per session.
#> Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
#> generated.
```

[`examine_cardinality()`](https://dm.cynkra.com/dev/reference/examine_cardinality.md)
returns the type of relation, e.g.:

``` r
examine_cardinality(d1, a, d3, c)
#> Warning: The `pk_column` argument of `examine_cardinality()` is deprecated as of dm
#> 1.0.0.
#> ℹ Please use the `x_select` argument instead.
#> • Use `y_select` instead of `fk_column`, and `x` and `y` instead of
#>   `parent_table` and `child_table`.
#> • Using `by_position = TRUE` for compatibility.
#> ℹ The deprecated feature was likely used in the dm package.
#>   Please report the issue at <https://github.com/cynkra/dm/issues>.
#> This warning is displayed once per session.
#> Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
#> generated.
#> [1] "injective mapping (child: 0 or 1 -> parent: 1)"
examine_cardinality(d1, a, d2, c)
#> [1] "surjective mapping (child: 1 to n -> parent: 1)"
examine_cardinality(d1, a, d1, a)
#> [1] "bijective mapping (child: 1 -> parent: 1)"
examine_cardinality(d1, a, d4, a)
#> [1] "generic mapping (child: 0 to n -> parent: 1)"
```

Just like the underlying cardinality functions, it will also inform you
if any restrictions on cardinality are violated:

``` r
examine_cardinality(d2, c, d1, a)
#> Column (`c`) not a unique key of `d2`.
```

## Table surgery

The relevant functions are:

1.  `decompose_table(.data, new_id_column, ...)`
2.  `reunite_parent_child(child_table, parent_table, id_column)`
3.  `reunite_parent_child_from_list(list_of_parent_child_tables, id_column)`

The first function implements table normalization. An existing table is
split into a parent table (i.e. a lookup table) and a child table
(containing the observations), linked by a key column (here:
`new_id_column`). Basically, a foreign key relation would be created,
pointing from the `new_id_column` of the child table to the parent
table’s corresponding column, which can be seen as the parent table’s
primary key column. The function
[`decompose_table()`](https://dm.cynkra.com/dev/reference/decompose_table.md)
does that, as can be seen in the following example:

``` r
mtcars_tibble <- tibble::as_tibble(mtcars)
mtcars_tibble
```

``` fansi
#> # A tibble: 32 × 11
#>      mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1  21       6  160    110  3.9   2.62  16.5     0     1     4     4
#>  2  21       6  160    110  3.9   2.88  17.0     0     1     4     4
#>  3  22.8     4  108     93  3.85  2.32  18.6     1     1     4     1
#>  4  21.4     6  258    110  3.08  3.22  19.4     1     0     3     1
#>  5  18.7     8  360    175  3.15  3.44  17.0     0     0     3     2
#>  6  18.1     6  225    105  2.76  3.46  20.2     1     0     3     1
#>  7  14.3     8  360    245  3.21  3.57  15.8     0     0     3     4
#>  8  24.4     4  147.    62  3.69  3.19  20       1     0     4     2
#>  9  22.8     4  141.    95  3.92  3.15  22.9     1     0     4     2
#> 10  19.2     6  168.   123  3.92  3.44  18.3     1     0     4     4
#> # ℹ 22 more rows
```

``` r
decomposed_table <- decompose_table(mtcars_tibble, am_gear_carb_id, am, gear, carb)
decomposed_table
```

``` fansi
#> $child_table
#> # A tibble: 32 × 9
#>      mpg   cyl  disp    hp  drat    wt  qsec    vs am_gear_carb_id
#>    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>           <int>
#>  1  21       6  160    110  3.9   2.62  16.5     0               7
#>  2  21       6  160    110  3.9   2.88  17.0     0               7
#>  3  22.8     4  108     93  3.85  2.32  18.6     1               8
#>  4  21.4     6  258    110  3.08  3.22  19.4     1               1
#>  5  18.7     8  360    175  3.15  3.44  17.0     0               2
#>  6  18.1     6  225    105  2.76  3.46  20.2     1               1
#>  7  14.3     8  360    245  3.21  3.57  15.8     0               3
#>  8  24.4     4  147.    62  3.69  3.19  20       1               4
#>  9  22.8     4  141.    95  3.92  3.15  22.9     1               4
#> 10  19.2     6  168.   123  3.92  3.44  18.3     1               5
#> # ℹ 22 more rows
#> 
#> $parent_table
#> # A tibble: 13 × 4
#>    am_gear_carb_id    am  gear  carb
#>              <int> <dbl> <dbl> <dbl>
#>  1               7     1     4     4
#>  2               8     1     4     1
#>  3               1     0     3     1
#>  4               2     0     3     2
#>  5               3     0     3     4
#>  6               4     0     4     2
#>  7               5     0     4     4
#>  8               6     0     3     3
#>  9               9     1     4     2
#> 10              10     1     5     2
#> 11              11     1     5     4
#> 12              12     1     5     6
#> 13              13     1     5     8
```

A new column is created, with which the two tables can be joined again,
essentially creating the original table.

The functions that do the inverse operation, i.e. join a parent and a
child table and subsequently drop the `new_id_column`, are
[`reunite_parent_child()`](https://dm.cynkra.com/dev/reference/reunite_parent_child.md)
and
[`reunite_parent_child_from_list()`](https://dm.cynkra.com/dev/reference/reunite_parent_child.md).
The former takes as arguments two tables and the unquoted name of the ID
column, and the latter takes as arguments a list of two tables plus the
unquoted name of the ID column:

``` r
parent_table <- decomposed_table$parent_table
child_table <- decomposed_table$child_table
reunite_parent_child(child_table, parent_table, id_column = am_gear_carb_id)
```

``` fansi
#> # A tibble: 32 × 11
#>      mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1  21       6  160    110  3.9   2.62  16.5     0     1     4     4
#>  2  21       6  160    110  3.9   2.88  17.0     0     1     4     4
#>  3  22.8     4  108     93  3.85  2.32  18.6     1     1     4     1
#>  4  21.4     6  258    110  3.08  3.22  19.4     1     0     3     1
#>  5  18.7     8  360    175  3.15  3.44  17.0     0     0     3     2
#>  6  18.1     6  225    105  2.76  3.46  20.2     1     0     3     1
#>  7  14.3     8  360    245  3.21  3.57  15.8     0     0     3     4
#>  8  24.4     4  147.    62  3.69  3.19  20       1     0     4     2
#>  9  22.8     4  141.    95  3.92  3.15  22.9     1     0     4     2
#> 10  19.2     6  168.   123  3.92  3.44  18.3     1     0     4     4
#> # ℹ 22 more rows
```

``` r
# Shortcut:
reunite_parent_child_from_list(decomposed_table, id_column = am_gear_carb_id)
```

Currently, these functions only exist as a low-level operation on
tables. We plan to extend this operation to `dm` objects in the future.
