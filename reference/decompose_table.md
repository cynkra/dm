# Decompose a table into two linked tables

**\[experimental\]**

Perform table surgery by extracting a 'parent table' from a table,
linking the original table and the new table by a key, and returning
both tables.

`decompose_table()` accepts a data frame, a name for the 'ID column'
that will be newly created, and the names of the columns that will be
extracted into the new data frame.

It creates a 'parent table', which consists of the columns specified in
the ellipsis, and a new 'ID column'. Then it removes those columns from
the original table, which is now called the 'child table, and adds the
'ID column'.

## Usage

``` r
decompose_table(.data, new_id_column, ...)
```

## Arguments

- .data:

  Data frame from which columns `...` are to be extracted.

- new_id_column:

  Name of the identifier column (primary key column) for the parent
  table. A column of this name is also added in 'child table'.

- ...:

  The columns to be extracted from the `.data`.

  One or more unquoted expressions separated by commas. You can treat
  variable names as if they were positions, so you can use expressions
  like x:y to select ranges of variables.

  The arguments in ... are automatically quoted and evaluated in a
  context where column names represent column positions. They also
  support unquoting and splicing. See vignette("programming") for an
  introduction to those concepts.

  See select helpers for more details, and the examples about tidyselect
  helpers, such as starts_with(), everything(), ...

## Value

A named list of length two:

- entry "child_table": the child table with column `new_id_column`
  referring to the same column in `parent_table`,

- entry "parent_table": the "lookup table" for `child_table`.

## Life cycle

This function is marked "experimental" because it seems more useful when
applied to a table in a dm object. Changing the interface later seems
harmless because these functions are most likely used interactively.

## See also

Other table surgery functions:
[`reunite_parent_child()`](https://dm.cynkra.com/reference/reunite_parent_child.md)

## Examples

``` r
decomposed_table <- decompose_table(mtcars, new_id, am, gear, carb)
decomposed_table$child_table
#>     mpg cyl  disp  hp drat    wt  qsec vs new_id
#> 1  21.0   6 160.0 110 3.90 2.620 16.46  0      7
#> 2  21.0   6 160.0 110 3.90 2.875 17.02  0      7
#> 3  22.8   4 108.0  93 3.85 2.320 18.61  1      8
#> 4  21.4   6 258.0 110 3.08 3.215 19.44  1      1
#> 5  18.7   8 360.0 175 3.15 3.440 17.02  0      2
#> 6  18.1   6 225.0 105 2.76 3.460 20.22  1      1
#> 7  14.3   8 360.0 245 3.21 3.570 15.84  0      3
#> 8  24.4   4 146.7  62 3.69 3.190 20.00  1      4
#> 9  22.8   4 140.8  95 3.92 3.150 22.90  1      4
#> 10 19.2   6 167.6 123 3.92 3.440 18.30  1      5
#> 11 17.8   6 167.6 123 3.92 3.440 18.90  1      5
#> 12 16.4   8 275.8 180 3.07 4.070 17.40  0      6
#> 13 17.3   8 275.8 180 3.07 3.730 17.60  0      6
#> 14 15.2   8 275.8 180 3.07 3.780 18.00  0      6
#> 15 10.4   8 472.0 205 2.93 5.250 17.98  0      3
#> 16 10.4   8 460.0 215 3.00 5.424 17.82  0      3
#> 17 14.7   8 440.0 230 3.23 5.345 17.42  0      3
#> 18 32.4   4  78.7  66 4.08 2.200 19.47  1      8
#> 19 30.4   4  75.7  52 4.93 1.615 18.52  1      9
#> 20 33.9   4  71.1  65 4.22 1.835 19.90  1      8
#> 21 21.5   4 120.1  97 3.70 2.465 20.01  1      1
#> 22 15.5   8 318.0 150 2.76 3.520 16.87  0      2
#> 23 15.2   8 304.0 150 3.15 3.435 17.30  0      2
#> 24 13.3   8 350.0 245 3.73 3.840 15.41  0      3
#> 25 19.2   8 400.0 175 3.08 3.845 17.05  0      2
#> 26 27.3   4  79.0  66 4.08 1.935 18.90  1      8
#> 27 26.0   4 120.3  91 4.43 2.140 16.70  0     10
#> 28 30.4   4  95.1 113 3.77 1.513 16.90  1     10
#> 29 15.8   8 351.0 264 4.22 3.170 14.50  0     11
#> 30 19.7   6 145.0 175 3.62 2.770 15.50  0     12
#> 31 15.0   8 301.0 335 3.54 3.570 14.60  0     13
#> 32 21.4   4 121.0 109 4.11 2.780 18.60  1      9
decomposed_table$parent_table
#>                   new_id am gear carb
#> Mazda RX4              7  1    4    4
#> Datsun 710             8  1    4    1
#> Hornet 4 Drive         1  0    3    1
#> Hornet Sportabout      2  0    3    2
#> Duster 360             3  0    3    4
#> Merc 240D              4  0    4    2
#> Merc 280               5  0    4    4
#> Merc 450SE             6  0    3    3
#> Honda Civic            9  1    4    2
#> Porsche 914-2         10  1    5    2
#> Ford Pantera L        11  1    5    4
#> Ferrari Dino          12  1    5    6
#> Maserati Bora         13  1    5    8
```
