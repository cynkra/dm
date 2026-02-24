# dm as data source

**\[deprecated\]**

These methods are deprecated because of their limited use, and because
the notion of a "source" seems to be getting phased out from dplyr. Use
other ways to access the tables in a `dm`.

## Usage

``` r
dm_get_src(x)

# S3 method for class 'dm'
tbl(src, from, ...)

# S3 method for class 'dm'
src_tbls(x, ...)

# S3 method for class 'dm'
copy_to(
  dest,
  df,
  name = deparse(substitute(df)),
  overwrite = FALSE,
  temporary = TRUE,
  repair = "unique",
  quiet = FALSE,
  ...
)
```

## Arguments

- src:

  A `dm` object.

- from:

  A length one character variable containing the name of the requested
  table

- ...:

  See original function documentation

- dest:

  For `copy_to.dm()`: The `dm` object to which a table should be copied.

- df:

  For `copy_to.dm()`: A table (can be on a different `src`)

- name:

  For `copy_to.dm()`: See
  [`dplyr::copy_to()`](https://dplyr.tidyverse.org/reference/copy_to.html)

- overwrite:

  For `copy_to.dm()`: See
  [`dplyr::copy_to()`](https://dplyr.tidyverse.org/reference/copy_to.html);
  `TRUE` leads to an error

- temporary:

  For `copy_to.dm()`: If the `dm` is on a DB, the copied version of `df`
  will only be written temporarily to the DB. After the connection is
  reset it will no longer be available.

- repair, quiet:

  Name repair options; cf.
  [`vctrs::vec_as_names()`](https://vctrs.r-lib.org/reference/vec_as_names.html)

## Details

Use [`dm_get_con()`](https://dm.cynkra.com/reference/dm_get_con.md)
instead of `dm_get_src()` to get the DBI connetion for a `dm` object

Use [`[[`](https://rdrr.io/r/base/Extract.html) instead of
[`tbl()`](https://dplyr.tidyverse.org/reference/tbl.html) to access
individual tables in a `dm` object.

Get the names from
[`dm_get_tables()`](https://dm.cynkra.com/reference/dm_get_tables.md)
instead of calling `dm_get_src()` to list the table names in a `dm`
object.

Use [`copy_to()`](https://dplyr.tidyverse.org/reference/copy_to.html) on
a table and then [`dm()`](https://dm.cynkra.com/reference/dm.md) instead
of [`copy_to()`](https://dplyr.tidyverse.org/reference/copy_to.html) on
a `dm` object.
