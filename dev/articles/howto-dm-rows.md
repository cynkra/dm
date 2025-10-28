# Insert, update, or remove rows in a database

This tutorial introduces the methods {dm} provides for modifying the
data in the tables of a relational model. There are 6 methods:

- [`dm_rows_insert()`](#insert) - adds new unique rows
- [`dm_rows_append()`](#insert) - adds new rows unconditionally
- [`dm_rows_update()`](#update) - changes values in rows
- [`dm_rows_patch()`](#patch) - fills in missing values
- [`dm_rows_upsert()`](#upsert) - adds new rows or changes values if
  pre-existing
- [`dm_rows_delete()`](#delete) - deletes rows

## The dm_rows\_\* process

All six methods take the same arguments and using them follows the same
process:

1.  Create a temporary *changeset dm* object that defines the intended
    changes on the RDBMS
2.  If desired, simulate changes with `in_place = FALSE` to double-check
3.  Apply changes with `in_place = TRUE`.

To start, a `dm` object is created containing the tables and rows that
you want to change. This changeset `dm` is then copied into the same
source as the dm you want to modify. With the dm in the same RDBMS as
the destination dm, you call the appropriate method, such as
[`dm_rows_insert()`](https://dm.cynkra.com/dev/reference/rows-dm.md), to
make your planned changes, along with an argument of `in_place = FALSE`
so you can confirm you achieve the changes that you want.

This verification can be done visually, looking at row counts and the
like, or using {dm}’s constraint checking method,
[`dm_examine_constraints()`](https://dm.cynkra.com/dev/reference/dm_examine_constraints.md).
The biggest danger is damaging key relations between data spread across
multiple tables by deleting or duplicating rows and their keys.
[`dm_examine_constraints()`](https://dm.cynkra.com/dev/reference/dm_examine_constraints.md)
will catch errors where primary keys are duplicated or foreign keys do
not have a matching primary key (unless the foreign key value is `NA`).

With the changes confirmed, you execute the method again, this time with
the argument `in_place = TRUE` to make the changes permanent. Note that
`in_place = FALSE` is the default: you must opt in to actually change
data on the database.

Each method has its own requirements in order to maintain database
consistency. These involve constraints on primary key values that
uniquely identify rows.

| Method                                                               | Requirements                                                                                                                                  |
|----------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| [`dm_rows_insert()`](https://dm.cynkra.com/dev/reference/rows-dm.md) | Records with existing primary keys are silently ignored (via `dplyr::rows_insert(conflict = "ignore")`).                                      |
| [`dm_rows_append()`](https://dm.cynkra.com/dev/reference/rows-dm.md) | All records are inserted, the underlying database might check for uniqueness of primary keys (and fail the operation) if a constraint is set. |
| [`dm_rows_update()`](https://dm.cynkra.com/dev/reference/rows-dm.md) | Primary keys must match for all records to be updated.                                                                                        |
| [`dm_rows_patch()`](https://dm.cynkra.com/dev/reference/rows-dm.md)  | Updates missing values in existing records. Primary keys must match for all records to be patched.                                            |
| [`dm_rows_upsert()`](https://dm.cynkra.com/dev/reference/rows-dm.md) | Updates existing records and adds new records, based on the primary key.                                                                      |
| [`dm_rows_delete()`](https://dm.cynkra.com/dev/reference/rows-dm.md) | Removes matching records based on the primary key. Primary keys must match for all records to be deleted.                                     |

To ensure the integrity of all relations during the process, all methods
automatically determine the correct processing order for the tables
involved. For operations that create records, parent tables (which hold
primary keys) are processed before child tables (which hold foreign
keys). For
[`dm_rows_delete()`](https://dm.cynkra.com/dev/reference/rows-dm.md),
child tables are processed before their parent tables. Note that the
user is still responsible for setting transactions to ensure integrity
of operations across multiple tables. For more details on this see
[`vignette("howto-dm-theory")`](https://dm.cynkra.com/dev/articles/howto-dm-theory.md)
and
[`vignette("howto-dm-db")`](https://dm.cynkra.com/dev/articles/howto-dm-db.md).

## Usage

To demonstrate the use of these table modifying methods, we will create
a simple `dm` object with two tables linked by a foreign key. Note that
the `child` table has a foreign key missing (`NA`).

``` r
library(dm)
parent <- tibble(value = c("A", "B", "C"), pk = 1:3)
parent
```

``` fansi
#> # A tibble: 3 × 2
#>   value    pk
#>   <chr> <int>
#> 1 A         1
#> 2 B         2
#> 3 C         3
```

``` r
child <- tibble(value = c("a", "b", "c"), pk = 1:3, fk = c(1, 1, NA))
child
```

``` fansi
#> # A tibble: 3 × 3
#>   value    pk    fk
#>   <chr> <int> <dbl>
#> 1 a         1     1
#> 2 b         2     1
#> 3 c         3    NA
```

``` r
demo_dm <-
  dm(parent = parent, child = child) %>%
  dm_add_pk(parent, pk) %>%
  dm_add_pk(child, pk) %>%
  dm_add_fk(child, fk, parent)

demo_dm %>%
  dm_draw(view_type = "all")
```

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTUycHQiIGhlaWdodD0iOTBwdCIgdmlld2JveD0iMC4wMCAwLjAwIDE1Mi4wMCA5MC4wMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayI+PGcgaWQ9ImdyYXBoMCIgY2xhc3M9ImdyYXBoIiB0cmFuc2Zvcm09InNjYWxlKDEgMSkgcm90YXRlKDApIHRyYW5zbGF0ZSg0IDg2KSI+PHRpdGxlPiUwPC90aXRsZT4KPGcgaWQ9ImFfZ3JhcGgwIj48YSB4bGluazp0aXRsZT0iRGF0YSBNb2RlbCI+Cjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iLTQsNCAtNCwtODYgMTQ4LC04NiAxNDgsNCAtNCw0Ij48L3BvbHlnb24+PC9hPgo8L2c+PCEtLSBjaGlsZCAtLT48ZyBpZD0iY2hpbGQiIGNsYXNzPSJub2RlIj48dGl0bGU+Y2hpbGQ8L3RpdGxlPgo8cG9seWdvbiBmaWxsPSIjZWZlYmRkIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEwLC02MSAxMCwtODEgNDQsLTgxIDQ0LC02MSAxMCwtNjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjEzLjAwMjEiIHk9Ii02Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiMwMDAwMDAiPmNoaWxkPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTAsLTQxIDEwLC02MSA0NCwtNjEgNDQsLTQxIDEwLC00MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTEuODQwMSIgeT0iLTQ2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+dmFsdWU8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxMCwtMjEgMTAsLTQxIDQ0LC00MSA0NCwtMjEgMTAsLTIxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxMiIgeT0iLTI3LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPnBrPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTAsLTEgMTAsLTIxIDQ0LC0yMSA0NCwtMSAxMCwtMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTIiIHk9Ii02LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+Zms8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjksMCA5LC04MiA0NSwtODIgNDUsMCA5LDAiPjwvcG9seWdvbj48L2c+PCEtLSBwYXJlbnQgLS0+PGcgaWQ9InBhcmVudCIgY2xhc3M9Im5vZGUiPjx0aXRsZT5wYXJlbnQ8L3RpdGxlPgo8cG9seWdvbiBmaWxsPSIjZWZlYmRkIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9Ijk4LC00MSA5OCwtNjEgMTM2LC02MSAxMzYsLTQxIDk4LC00MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iOTkuNTA5OCIgeT0iLTQ2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzAwMDAwMCI+cGFyZW50PC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iOTgsLTIxIDk4LC00MSAxMzYsLTQxIDEzNiwtMjEgOTgsLTIxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxMDAiIHk9Ii0yNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPnZhbHVlPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iOTgsLTEgOTgsLTIxIDEzNiwtMjEgMTM2LC0xIDk4LC0xIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxMDAiIHk9Ii03LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPnBrPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSI5NywwIDk3LC02MiAxMzcsLTYyIDEzNywwIDk3LDAiPjwvcG9seWdvbj48L2c+PCEtLSBjaGlsZCYjNDU7Jmd0O3BhcmVudCAtLT48ZyBpZD0iY2hpbGRfMSIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5jaGlsZDpmay0mZ3Q7cGFyZW50OnBrPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNNDQsLTExQzY0LjI1LC0xMSA3MS42ODU1LC0xMSA4Ny45MzEsLTExIiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSI4OCwtMTQuNTAwMSA5OCwtMTEgODgsLTcuNTAwMSA4OCwtMTQuNTAwMSI+PC9wb2x5Z29uPjwvZz48L2c+PC9zdmc+)

{dm} doesn’t check your key values when you create a dm, we add this
check:[¹](#fn1)

``` r
dm_examine_constraints(demo_dm)
```

``` fansi
#> ℹ All constraints satisfied.
```

Then we copy `demo_dm` into an SQLite database. Note: the default for
the method used,
[`copy_dm_to()`](https://dm.cynkra.com/dev/reference/copy_dm_to.md), is
to create temporary tables that will be automatically deleted when your
session ends. As `demo_sql` will be the destination dm for the examples,
the argument `temporary = FALSE` is used to make this distinction
apparent.

``` r
library(DBI)
sqlite_db <- DBI::dbConnect(RSQLite::SQLite())
demo_sql <- copy_dm_to(sqlite_db, demo_dm, temporary = FALSE)
demo_sql
```

``` fansi
#> ── Table source ───────────────────────────────────────────────────────────
#> src:  sqlite 3.50.4 []
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `parent`, `child`
#> Columns: 5
#> Primary keys: 2
#> Foreign keys: 1
```

{dm}’s table modification methods can be piped together to create a
repeatable sequence of operations that returns a dm incorporating all
the changes required. This is a common use case for {dm} – manually
building a sequence of operations using temporary results until it is
complete and correct, and then committing the result.

## `dm_rows_insert()`

To demonstrate
[`dm_rows_insert()`](https://dm.cynkra.com/dev/reference/rows-dm.md), we
create a dm with tables containing the rows to insert and copy it to
`sqlite_db`, the same source as `demo_sql`. For all of the
[`dm_rows_...()`](https://dm.cynkra.com/dev/reference/rows-dm.md)
methods, the source and destination `dm` objects must be in the same
RDBMS. You will get an error message if this is not the case.

The code below adds `parent` and `child` table entries for the letter
“D”. First, the changeset dm is created and temporarily copied to the
database:

``` r
new_parent <- tibble(value = "D", pk = 4)
new_parent
```

``` fansi
#> # A tibble: 1 × 2
#>   value    pk
#>   <chr> <dbl>
#> 1 D         4
```

``` r
new_child <- tibble(value = "d", pk = 4, fk = 4)
new_child
```

``` fansi
#> # A tibble: 1 × 3
#>   value    pk    fk
#>   <chr> <dbl> <dbl>
#> 1 d         4     4
```

``` r
dm_insert_in <-
  dm(parent = new_parent, child = new_child) %>%
  copy_dm_to(sqlite_db, ., temporary = TRUE)
```

The changeset dm is then used as an argument to
[`dm_rows_insert()`](https://dm.cynkra.com/dev/reference/rows-dm.md).

``` r
dm_insert_out <-
  demo_sql %>%
  dm_rows_insert(dm_insert_in)
#> Result is returned as a dm object with lazy tables. Use `in_place = FALSE`
#> to mute this message, or `in_place = TRUE` to write to the underlying
#> tables.
```

This gives us a warning that changes will not persist (i.e., they are
temporary). Inspecting the `child` table of the resulting
`dm_insert_out` and `demo_sql`, we can see that’s exactly what happened.
{dm} returned to us a dm object with our inserted rows in place, but the
underlying database has not changed.

``` r
dm_insert_out$child
```

``` fansi
#> # Source:   SQL [?? x 3]
#> # Database: sqlite 3.50.4 []
#>   value    pk    fk
#>   <chr> <dbl> <dbl>
#> 1 a         1     1
#> 2 b         2     1
#> 3 c         3    NA
#> 4 d         4     4
```

``` r
demo_sql$child
```

``` fansi
#> # Source:   table<`child`> [?? x 3]
#> # Database: sqlite 3.50.4 []
#>   value    pk    fk
#>   <chr> <int> <dbl>
#> 1 a         1     1
#> 2 b         2     1
#> 3 c         3    NA
```

We repeat the operation, this time with the argument `in_place = TRUE`
and the changes now persist in `demo_sql`.

``` r
dm_insert_out <-
  demo_sql %>%
  dm_rows_insert(dm_insert_in, in_place = TRUE)

demo_sql$child
```

``` fansi
#> # Source:   table<`child`> [?? x 3]
#> # Database: sqlite 3.50.4 []
#>   value    pk    fk
#>   <chr> <int> <dbl>
#> 1 a         1     1
#> 2 b         2     1
#> 3 c         3    NA
#> 4 d         4     4
```

## `dm_rows_update()`

[`dm_rows_update()`](https://dm.cynkra.com/dev/reference/rows-dm.md)
works the same as
[`dm_rows_insert()`](https://dm.cynkra.com/dev/reference/rows-dm.md). We
create the dm object and copy it to the same source as the destination.
Here we will change the foreign key for the row in `child` containing
“b” to point to the correct row in `parent`. And we will persist the
changes.

``` r
updated_child <- tibble(value = "b", pk = 2, fk = 2)
updated_child
```

``` fansi
#> # A tibble: 1 × 3
#>   value    pk    fk
#>   <chr> <dbl> <dbl>
#> 1 b         2     2
```

``` r
dm_update_in <-
  dm(child = updated_child) %>%
  copy_dm_to(sqlite_db, ., temporary = TRUE)

dm_update_out <-
  demo_sql %>%
  dm_rows_update(dm_update_in, in_place = TRUE)

demo_sql$child
```

``` fansi
#> # Source:   table<`child`> [?? x 3]
#> # Database: sqlite 3.50.4 []
#>   value    pk    fk
#>   <chr> <int> <dbl>
#> 1 a         1     1
#> 2 b         2     2
#> 3 c         3    NA
#> 4 d         4     4
```

## `dm_rows_delete()`

[`dm_rows_delete()`](https://dm.cynkra.com/dev/reference/rows-dm.md) is
not currently implemented to work with an RDBMS, so we will shift our
demonstrations back to the local R environment. We’ve made changes to
`demo_sql`, so we use
[`collect()`](https://dplyr.tidyverse.org/reference/compute.html) to
copy the current tables out of SQLite. Note that persistence is not a
concern for *local* `dm` objects. Every operation returns a new dm
object containing the changes made.

``` r
local_dm <- collect(demo_sql)

local_dm$parent
```

``` fansi
#> # A tibble: 4 × 2
#>   value    pk
#>   <chr> <int>
#> 1 A         1
#> 2 B         2
#> 3 C         3
#> 4 D         4
```

``` r
local_dm$child
```

``` fansi
#> # A tibble: 4 × 3
#>   value    pk    fk
#>   <chr> <int> <dbl>
#> 1 a         1     1
#> 2 b         2     2
#> 3 c         3    NA
#> 4 d         4     4
```

``` r
dm_deleted <-
  dm(parent = new_parent, child = new_child) %>%
  dm_rows_delete(local_dm, .)
#> Result is returned as a dm object with lazy tables. Use `in_place = FALSE` to mute this message, or `in_place = TRUE` to write to the underlying tables.
#> Ignoring extra `y` columns: value, fk
#> Ignoring extra `y` columns: value

dm_deleted$child
```

``` fansi
#> # A tibble: 3 × 3
#>   value    pk    fk
#>   <chr> <int> <dbl>
#> 1 a         1     1
#> 2 b         2     2
#> 3 c         3    NA
```

## `dm_rows_patch()`

[`dm_rows_patch()`](https://dm.cynkra.com/dev/reference/rows-dm.md)
updates missing values in existing records. We use it here to fix the
missing foreign key in the `child` table.

``` r
patched_child <- tibble(value = "c", pk = 3, fk = 3)
patched_child
```

``` fansi
#> # A tibble: 1 × 3
#>   value    pk    fk
#>   <chr> <dbl> <dbl>
#> 1 c         3     3
```

``` r
dm_patched <-
  dm(child = patched_child) %>%
  dm_rows_patch(dm_deleted, .)
#> Result is returned as a dm object with lazy tables. Use `in_place = FALSE`
#> to mute this message, or `in_place = TRUE` to write to the underlying
#> tables.

dm_patched$child
```

``` fansi
#> # A tibble: 3 × 3
#>   value    pk    fk
#>   <chr> <int> <dbl>
#> 1 a         1     1
#> 2 b         2     2
#> 3 c         3     3
```

## `dm_rows_upsert()`

[`dm_rows_upsert()`](https://dm.cynkra.com/dev/reference/rows-dm.md)
updates rows with supplied values if they exist or inserts the supplied
values as new rows if they don’t. In this example we add the letter “D”
back to our dm, and update the foreign key for “b”.

``` r
upserted_parent <- tibble(value = "D", pk = 4)
upserted_parent
```

``` fansi
#> # A tibble: 1 × 2
#>   value    pk
#>   <chr> <dbl>
#> 1 D         4
```

``` r
upserted_child <- tibble(value = c("b", "d"), pk = c(2, 4), fk = c(3, 4))
upserted_child
```

``` fansi
#> # A tibble: 2 × 3
#>   value    pk    fk
#>   <chr> <dbl> <dbl>
#> 1 b         2     3
#> 2 d         4     4
```

``` r
dm_upserted <-
  dm(parent = upserted_parent, child = upserted_child) %>%
  dm_rows_upsert(dm_patched, .)
#> Result is returned as a dm object with lazy tables. Use `in_place = FALSE`
#> to mute this message, or `in_place = TRUE` to write to the underlying
#> tables.

dm_upserted$parent
```

``` fansi
#> # A tibble: 4 × 2
#>   value    pk
#>   <chr> <int>
#> 1 A         1
#> 2 B         2
#> 3 C         3
#> 4 D         4
```

``` r
dm_upserted$child
```

``` fansi
#> # A tibble: 4 × 3
#>   value    pk    fk
#>   <chr> <int> <dbl>
#> 1 a         1     1
#> 2 b         2     3
#> 3 c         3     3
#> 4 d         4     4
```

When done, do not forget to disconnect:

``` r
DBI::dbDisconnect(sqlite_db)
```

## Conclusion

The [`dm_rows_...()`](https://dm.cynkra.com/dev/reference/rows-dm.md)
methods give you row-level granularity over the modifications you need
to make to your relational model. Using the common `in_place` argument,
they all can construct and verify your modifications before committing
them. There are a few limitations, as mentioned in the tutorial, but
these will be addressed in future updates to {dm}.

## Further Reading

If this tutorial answered some questions, but opened others, these
resources might be of assistance.

Is your data in an RDBMS?
[`vignette("howto-dm-db")`](https://dm.cynkra.com/dev/articles/howto-dm-db.md)
offers a detailed look at working with an existing relational data
model.

If your data is in data frames, then you may want to read
[`vignette("howto-dm-df")`](https://dm.cynkra.com/dev/articles/howto-dm-df.md)
next.

If you would like to know more about relational data models in order to
get the most out of dm, check out
[`vignette("howto-dm-theory")`](https://dm.cynkra.com/dev/articles/howto-dm-theory.md).

If you’re familiar with relational data models but want to know how to
work with them in dm, then any of
[`vignette("tech-dm-join")`](https://dm.cynkra.com/dev/articles/tech-dm-join.md),
[`vignette("tech-dm-filter")`](https://dm.cynkra.com/dev/articles/tech-dm-filter.md),
or
[`vignette("tech-dm-zoom")`](https://dm.cynkra.com/dev/articles/tech-dm-zoom.md)
is a good next step.

------------------------------------------------------------------------

1.  Be aware that when using
    [`dm_examine_constraints()`](https://dm.cynkra.com/dev/reference/dm_examine_constraints.md),
    missing (denoted by `NULL` in SQL, while `NA` in R) foreign keys are
    allowed and will be counted as a match. In some cases this doesn’t
    make sense and non-NULL columns should be enforced by the RDBMS.
    Currently, {dm} does not specify or check non-NULL constraints for
    columns.
