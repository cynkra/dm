# Flatten a part of a `dm` into a wide table

`dm_flatten_to_tbl()` gathers all information of interest in one place
in a wide table. It performs a disambiguation of column names and a
cascade of joins.

## Usage

``` r
dm_flatten_to_tbl(dm, .start, ..., .recursive = FALSE, .join = left_join)
```

## Arguments

- dm:

  A [`dm`](https://dm.cynkra.com/reference/dm.md) object.

- .start:

  The table from which all outgoing foreign key relations are considered
  when establishing a processing order for the joins. An interesting
  choice could be for example a fact table in a star schema.

- ...:

  **\[experimental\]**

  Unquoted names of the tables to be included in addition to the
  `.start` table. The order of the tables here determines the order of
  the joins. If the argument is empty, all tables that can be reached
  will be included. `tidyselect` is supported, see
  [`dplyr::select()`](https://dplyr.tidyverse.org/reference/select.html)
  for details on the semantics.

- .recursive:

  Logical, defaults to `FALSE`. Should not only parent tables be joined
  to `.start`, but also their ancestors?

- .join:

  The type of join to be performed, see
  [`dplyr::join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html).

## Value

A single table that results from consecutively joining all affected
tables to the `.start` table.

## Details

With `...` left empty, this function will join together all the tables
of your [`dm`](https://dm.cynkra.com/reference/dm.md) object that can be
reached from the `.start` table, in the direction of the foreign key
relations (pointing from the child tables to the parent tables), using
the foreign key relations to determine the argument `by` for the
necessary joins. The result is one table with unique column names. Use
the `...` argument if you would like to control which tables should be
joined to the `.start` table.

Mind that calling `dm_flatten_to_tbl()` with `.join = right_join` and no
table order determined in the `...` argument will not lead to a
well-defined result if two or more foreign tables are to be joined to
`.start`. The resulting table would depend on the order the tables that
are listed in the `dm`. Therefore, trying this will result in a warning.

Since `.join = nest_join` does not make sense in this direction (LHS =
child table, RHS = parent table: for valid key constraints each nested
column entry would be a tibble of one row), an error will be thrown if
this method is chosen.

The difference between `.recursive = FALSE` and `.recursive = TRUE` is
the following (see the examples):

- `.recursive = FALSE` allows only one level of hierarchy (i.e., direct
  neighbors to table `.start`), while

- `.recursive = TRUE` will go through all levels of hierarchy while
  joining.

Additionally, these functions differ from
[`dm_wrap_tbl()`](https://dm.cynkra.com/reference/dm_wrap_tbl.md), which
always returns a `dm` object.

## See also

Other flattening functions:
[`dm_flatten()`](https://dm.cynkra.com/reference/dm_flatten.md)

## Examples

``` r
if (FALSE) { # dm:::dm_has_financial()

dm_financial() %>%
  dm_select_tbl(-loans) %>%
  dm_flatten_to_tbl(.start = cards)

dm_financial() %>%
  dm_select_tbl(-loans) %>%
  dm_flatten_to_tbl(.start = cards, .recursive = TRUE)
}
```
