# Copy tables to and from a database

In this tutorial, we introduce {dm} methods and techniques for copying
individual tables and entire relational data models into a relational
database management system (RDBMS). This is an integral part of the {dm}
workflow. Copying tables to an RDBMS is often a step in the process of
building a relational data model from locally hosted data. If your data
model is complete, copying it to an RDBMS in a single operation allows
you to leverage the power of the database and make it accessible to
others. For modifying and persisting changes to your data at the
row-level see
[`vignette("howto-dm-rows")`](https://dm.cynkra.com/dev/articles/howto-dm-rows.md).

## Copy models or copy tables?

Using {dm} you can persist an entire relational data model with a single
function call.
[`copy_dm_to()`](https://dm.cynkra.com/dev/reference/copy_dm_to.md) will
move your entire model into a destination RDBMS. This may be all you
need to deploy a new model. You may want to add new tables to an
existing model on an RDBMS. These requirements can be handled using the
[`compute()`](https://dplyr.tidyverse.org/reference/compute.html) and
[`copy_to()`](https://dplyr.tidyverse.org/reference/copy_to.html)
methods.

Calling
[`compute()`](https://dplyr.tidyverse.org/reference/compute.html) or
[`copy_to()`](https://dplyr.tidyverse.org/reference/copy_to.html)
requires write permission on the RDBMS; otherwise, an error is returned.
Therefore, for the following examples, we will instantiate a test `dm`
object and move it into a local SQLite database with full permissions.
{dm} and {dbplyr} are designed to treat the code used to manipulate a
**local** SQLite database and a **remote** RDBMS similarly. The steps
for this were already introduced in
[`vignette("howto-dm-db")`](https://dm.cynkra.com/dev/articles/howto-dm-db.md)
and will be discussed in more detail in the [Copying a relational
model](#copy-model) section.

``` r
library(dm)
library(dbplyr)

fin_dm <-
  dm_financial() %>%
  dm_select_tbl(-trans) %>%
  collect()

local_db <- DBI::dbConnect(RSQLite::SQLite())
deployed_dm <- copy_dm_to(local_db, fin_dm, temporary = FALSE)
```

## Copying and persisting individual tables

As part of your data analysis, you may combine tables from multiple
sources and create links to existing tables via foreign keys, or create
new tables holding data summaries. The example below, already discussed
in
[`vignette("howto-dm-db")`](https://dm.cynkra.com/dev/articles/howto-dm-db.md),
computes the total amount of all loans for each account.

``` r
my_dm_total <-
  deployed_dm %>%
  dm_zoom_to(loans) %>%
  summarize(.by = account_id, total_amount = sum(amount, na.rm = TRUE)) %>%
  dm_insert_zoomed("total_loans")
```

The derived table `total_loans` is a *lazy table* powered by the
{[dbplyr](https://dbplyr.tidyverse.org/)} package: the results are not
materialized, instead an SQL query is built and executed each time the
data is requested.

``` r
my_dm_total$total_loans %>%
  sql_render()
#> <SQL> SELECT `account_id`, SUM(`amount`) AS `total_amount`
#> FROM `loans`
#> GROUP BY `account_id`
```

To avoid recomputing the query every time you use `total_loans`, call
[`compute()`](https://dplyr.tidyverse.org/reference/compute.html) right
before inserting the derived table with `dm_insert_tbl()`.
[`compute()`](https://dplyr.tidyverse.org/reference/compute.html) forces
the computation of a query and stores the full results in a table on the
RDBMS.

``` r
my_dm_total_computed <-
  deployed_dm %>%
  dm_zoom_to(loans) %>%
  summarize(.by = account_id, total_amount = sum(amount, na.rm = TRUE)) %>%
  compute() %>%
  dm_insert_zoomed("total_loans")

my_dm_total_computed$total_loans %>%
  sql_render()
#> <SQL> SELECT *
#> FROM `dbplyr_b4eYrKPRds`
```

Note the differences in queries returned by
[`sql_render()`](https://dbplyr.tidyverse.org/reference/sql_build.html).
`my_dm_total$total_loans` is still being lazily evaluated and the full
query constructed from the chain of operations that generated it is
still in place and needs to be run to access it. Contrast that with
`my_dm_total_computed$total_loans`, where the query has been realized
and accessing its rows requires a simple `SELECT *` statement. The table
name, `dbplyr_`, was automatically generated as the `name` argument was
not supplied to
[`compute()`](https://dplyr.tidyverse.org/reference/compute.html).

The default is to create a **temporary** tables. If you want results to
persist across sessions in **permanent** tables,
[`compute()`](https://dplyr.tidyverse.org/reference/compute.html) must
be called with the argument `temporary = FALSE` and a table name for the
`name` argument. See
[`?compute`](https://dplyr.tidyverse.org/reference/compute.html) for
more details.

When called on a whole `dm` object (without zoom),
[`compute()`](https://dplyr.tidyverse.org/reference/compute.html)
materializes all tables into new temporary tables by executing the
associated SQL query and storing the full results. Depending on the size
of your data, this may take considerable time or may even be infeasible.
It may be useful occasionally to create snapshots of data that is
subject to change.

``` r
my_dm_total_snapshot <-
  my_dm_total %>%
  compute()
```

## Adding local data frames to an RDBMS

If you need to add local data frames to an existing `dm` object, use the
[`copy_to()`](https://dplyr.tidyverse.org/reference/copy_to.html)
method. It takes the same arguments as
[`copy_dm_to()`](https://dm.cynkra.com/dev/reference/copy_dm_to.md),
except the second argument takes a data frame rather than a dm. The
result is a derived `dm` object that contains the new table.

To demonstrate the use of
[`copy_to()`](https://dplyr.tidyverse.org/reference/copy_to.html), the
example below will use {dm} to pull consolidated data from several
tables out of an RDBMS, estimate a linear model from the data, then
insert the residuals back into the RDBMS and link it to the existing
tables. This is all done with a local SQLite database, but the process
would work unchanged on any supported RDBMS.

``` r
loans_df <-
  deployed_dm %>%
  dm_flatten_to_tbl(loans, .recursive = TRUE) %>%
  select(id, amount, duration, A3) %>%
  collect()
#> Renaming ambiguous columns: %>%
#>   dm_rename(loans, date.loans = date) %>%
#>   dm_rename(accounts, date.accounts = date)
```

Please note the use of `recursive = TRUE` for
[`dm_flatten_to_tbl()`](https://dm.cynkra.com/dev/reference/dm_flatten_to_tbl.md).
This method gathers all linked information into a single wide table. It
follows foreign key relations starting from the table supplied as its
argument and gathers all the columns from related tables, disambiguating
column names as it goes.

In the above code, the
[`select()`](https://dplyr.tidyverse.org/reference/select.html)
statement isolates the columns we need for our model.
[`collect()`](https://dplyr.tidyverse.org/reference/compute.html) works
similarly to
[`compute()`](https://dplyr.tidyverse.org/reference/compute.html) by
forcing the execution of the underlying SQL query, but it returns the
results as a local tibble.

Below, the local tibble, `loans_df`, is used to estimate the linear
model and the residuals are stored along with the original associated
`id` in a new tibble, `loans_residuals`. The `id` column is necessary to
link the new tibble to the tables in the dm it was collected from.

``` r
model <- lm(amount ~ duration + A3, data = loans_df)

loans_residuals <- tibble::tibble(
  id = loans_df$id,
  resid = unname(residuals(model))
)

loans_residuals
```

``` fansi
#> # A tibble: 682 × 2
#>       id   resid
#>    <int>   <dbl>
#>  1  4959 -31912.
#>  2  4961 -27336.
#>  3  4962 -30699.
#>  4  4967  63621.
#>  5  4968 -94811.
#>  6  4973  59036.
#>  7  4986  41901.
#>  8  4988 123392.
#>  9  4989 147157.
#> 10  4990  33377.
#> # ℹ 672 more rows
```

Adding `loans_residuals` to the dm is done using
[`copy_to()`](https://dplyr.tidyverse.org/reference/copy_to.html). The
call to the method includes the argument `temporary = FALSE` because we
want this table to persist beyond our current session. In the same
pipeline we create the necessary primary and foreign keys to integrate
the table with the rest of our relational model. For more information on
key creation, see
[`vignette("howto-dm-db")`](https://dm.cynkra.com/dev/articles/howto-dm-db.md)
and
[`vignette("howto-dm-theory")`](https://dm.cynkra.com/dev/articles/howto-dm-theory.md).

``` r
my_dm_sqlite_resid <-
  copy_to(deployed_dm, loans_residuals, temporary = FALSE) %>%
  dm_add_pk(loans_residuals, id) %>%
  dm_add_fk(loans_residuals, id, loans)
#> Warning: `copy_to.dm()` was deprecated in dm 0.2.0.
#> ℹ Use `copy_to(dm_get_con(dm), ...)` and `dm()`.
#> This warning is displayed once per session.
#> Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
#> generated.

my_dm_sqlite_resid %>%
  dm_set_colors(violet = loans_residuals) %>%
  dm_draw()
```

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzkxcHQiIGhlaWdodD0iMjcwcHQiIHZpZXdib3g9IjAuMDAgMC4wMCAzOTEuMDAgMjcwLjAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIj48ZyBpZD0iZ3JhcGgwIiBjbGFzcz0iZ3JhcGgiIHRyYW5zZm9ybT0ic2NhbGUoMSAxKSByb3RhdGUoMCkgdHJhbnNsYXRlKDQgMjY2KSI+PHRpdGxlPiUwPC90aXRsZT4KPGcgaWQ9ImFfZ3JhcGgwIj48YSB4bGluazp0aXRsZT0iRGF0YSBNb2RlbCI+Cjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iLTQsNCAtNCwtMjY2IDM4NywtMjY2IDM4Nyw0IC00LDQiPjwvcG9seWdvbj48L2E+CjwvZz48IS0tIGFjY291bnRzIC0tPjxnIGlkPSJhY2NvdW50cyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5hY2NvdW50czwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMjMyLC0xMDEgMjMyLC0xMjEgMjkyLC0xMjEgMjkyLC0xMDEgMjMyLC0xMDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjIzNy41MTA1IiB5PSItMTA2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzAwMDAwMCI+YWNjb3VudHM8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIyMzIsLTgxIDIzMiwtMTAxIDI5MiwtMTAxIDI5MiwtODEgMjMyLC04MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMjM0IiB5PSItODcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+aWQ8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIyMzIsLTYxIDIzMiwtODEgMjkyLC04MSAyOTIsLTYxIDIzMiwtNjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjIzMy42MTM2IiB5PSItNjYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5kaXN0cmljdF9pZDwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMjMxLC02MCAyMzEsLTEyMiAyOTMsLTEyMiAyOTMsLTYwIDIzMSwtNjAiPjwvcG9seWdvbj48L2c+PCEtLSBkaXN0cmljdHMgLS0+PGcgaWQ9ImRpc3RyaWN0cyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5kaXN0cmljdHM8L3RpdGxlPgo8cG9seWdvbiBmaWxsPSIjZWZlYmRkIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjMzMiwtODEgMzMyLC0xMDEgMzgwLC0xMDEgMzgwLC04MSAzMzIsLTgxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzMzMuODM2NiIgeT0iLTg2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzAwMDAwMCI+ZGlzdHJpY3RzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMzMyLC02MSAzMzIsLTgxIDM4MCwtODEgMzgwLC02MSAzMzIsLTYxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzMzQiIHk9Ii02Ny40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5pZDwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMzMxLC02MCAzMzEsLTEwMiAzODEsLTEwMiAzODEsLTYwIDMzMSwtNjAiPjwvcG9seWdvbj48L2c+PCEtLSBhY2NvdW50cyYjNDU7Jmd0O2Rpc3RyaWN0cyAtLT48ZyBpZD0iYWNjb3VudHNfMSIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5hY2NvdW50czpkaXN0cmljdF9pZC0mZ3Q7ZGlzdHJpY3RzOmlkPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMjkyLC03MUMzMDUuODg4OSwtNzEgMzExLjYzOTgsLTcxIDMyMS45NjgzLC03MSIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMzIyLC03NC41MDAxIDMzMiwtNzEgMzIyLC02Ny41MDAxIDMyMiwtNzQuNTAwMSI+PC9wb2x5Z29uPjwvZz48IS0tIGNhcmRzIC0tPjxnIGlkPSJjYXJkcyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5jYXJkczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMjQsLTI0MSAyNCwtMjYxIDY5LC0yNjEgNjksLTI0MSAyNCwtMjQxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzMS43MzI4IiB5PSItMjQ2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzAwMDAwMCI+Y2FyZHM8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIyNCwtMjIxIDI0LC0yNDEgNjksLTI0MSA2OSwtMjIxIDI0LC0yMjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjI2IiB5PSItMjI3LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmlkPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMjQsLTIwMSAyNCwtMjIxIDY5LC0yMjEgNjksLTIwMSAyNCwtMjAxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIyNS44ODcxIiB5PSItMjA2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+ZGlzcF9pZDwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMjIuNSwtMjAwIDIyLjUsLTI2MiA2OS41LC0yNjIgNjkuNSwtMjAwIDIyLjUsLTIwMCI+PC9wb2x5Z29uPjwvZz48IS0tIGRpc3BzIC0tPjxnIGlkPSJkaXNwcyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5kaXNwczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTI5LjUsLTIyMSAxMjkuNSwtMjQxIDE5NC41LC0yNDEgMTk0LjUsLTIyMSAxMjkuNSwtMjIxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNDcuNjEwMSIgeT0iLTIyNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiMwMDAwMDAiPmRpc3BzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTI5LjUsLTIwMSAxMjkuNSwtMjIxIDE5NC41LC0yMjEgMTk0LjUsLTIwMSAxMjkuNSwtMjAxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxMzEuNSIgeT0iLTIwNy40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5pZDwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEyOS41LC0xODEgMTI5LjUsLTIwMSAxOTQuNSwtMjAxIDE5NC41LC0xODEgMTI5LjUsLTE4MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTMxLjUiIHk9Ii0xODYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5jbGllbnRfaWQ8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxMjkuNSwtMTYxIDEyOS41LC0xODEgMTk0LjUsLTE4MSAxOTQuNSwtMTYxIDEyOS41LC0xNjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjEzMS4yODc1IiB5PSItMTY2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+YWNjb3VudF9pZDwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTI4LC0xNjAgMTI4LC0yNDIgMTk1LC0yNDIgMTk1LC0xNjAgMTI4LC0xNjAiPjwvcG9seWdvbj48L2c+PCEtLSBjYXJkcyYjNDU7Jmd0O2Rpc3BzIC0tPjxnIGlkPSJjYXJkc18xIiBjbGFzcz0iZWRnZSI+PHRpdGxlPmNhcmRzOmRpc3BfaWQtJmd0O2Rpc3BzOmlkPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNNjksLTIxMUM5Mi4yMTI3LC0yMTEgMTAwLjM5NiwtMjExIDExOS40OTkxLC0yMTEiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjExOS41LC0yMTQuNTAwMSAxMjkuNSwtMjExIDExOS41LC0yMDcuNTAwMSAxMTkuNSwtMjE0LjUwMDEiPjwvcG9seWdvbj48L2c+PCEtLSBjbGllbnRzIC0tPjxnIGlkPSJjbGllbnRzIiBjbGFzcz0ibm9kZSI+PHRpdGxlPmNsaWVudHM8L3RpdGxlPgo8cG9seWdvbiBmaWxsPSIjZWZlYmRkIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjI0MiwtMjAxIDI0MiwtMjIxIDI4MiwtMjIxIDI4MiwtMjAxIDI0MiwtMjAxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIyNDMuNzI3MiIgeT0iLTIwNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiMwMDAwMDAiPmNsaWVudHM8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIyNDIsLTE4MSAyNDIsLTIwMSAyODIsLTIwMSAyODIsLTE4MSAyNDIsLTE4MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMjQ0IiB5PSItMTg3LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmlkPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIyNDEsLTE4MCAyNDEsLTIyMiAyODMsLTIyMiAyODMsLTE4MCAyNDEsLTE4MCI+PC9wb2x5Z29uPjwvZz48IS0tIGRpc3BzJiM0NTsmZ3Q7YWNjb3VudHMgLS0+PGcgaWQ9ImRpc3BzXzIiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZGlzcHM6YWNjb3VudF9pZC0mZ3Q7YWNjb3VudHM6aWQ8L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik0xOTQuNSwtMTcxQzIyOS42MjY0LC0xNzEgMjAwLjQ5NDgsLTEwNi45ODUxIDIyMi4wNjY4LC05My40ODIiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjIyMy4xNDY3LC05Ni44MTk4IDIzMiwtOTEgMjIxLjQ0OTgsLTkwLjAyODYgMjIzLjE0NjcsLTk2LjgxOTgiPjwvcG9seWdvbj48L2c+PCEtLSBkaXNwcyYjNDU7Jmd0O2NsaWVudHMgLS0+PGcgaWQ9ImRpc3BzXzEiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZGlzcHM6Y2xpZW50X2lkLSZndDtjbGllbnRzOmlkPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTk0LjUsLTE5MUMyMTEuODE3NywtMTkxIDIxOC40ODEsLTE5MSAyMzEuOTY5NywtMTkxIiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIyMzIsLTE5NC41MDAxIDI0MiwtMTkxIDIzMiwtMTg3LjUwMDEgMjMyLC0xOTQuNTAwMSI+PC9wb2x5Z29uPjwvZz48IS0tIGxvYW5zIC0tPjxnIGlkPSJsb2FucyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5sb2FuczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiMwMDY0MDAiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTI5LjUsLTEyMSAxMjkuNSwtMTQxIDE5NC41LC0xNDEgMTk0LjUsLTEyMSAxMjkuNSwtMTIxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNDcuMjI1MSIgeT0iLTEyNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiNmZmZmZmYiPmxvYW5zPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNjY2UwY2MiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTI5LjUsLTEwMSAxMjkuNSwtMTIxIDE5NC41LC0xMjEgMTk0LjUsLTEwMSAxMjkuNSwtMTAxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxMzEuNSIgeT0iLTEwNy40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5pZDwvdGV4dD48cG9seWdvbiBmaWxsPSIjY2NlMGNjIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEyOS41LC04MSAxMjkuNSwtMTAxIDE5NC41LC0xMDEgMTk0LjUsLTgxIDEyOS41LC04MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTMxLjI4NzUiIHk9Ii04Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmFjY291bnRfaWQ8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjMDA0MjAwIiBzdHJva2Utb3BhY2l0eT0iMC42NjY2NjciIHBvaW50cz0iMTI4LC04MCAxMjgsLTE0MiAxOTUsLTE0MiAxOTUsLTgwIDEyOCwtODAiPjwvcG9seWdvbj48L2c+PCEtLSBsb2FucyYjNDU7Jmd0O2FjY291bnRzIC0tPjxnIGlkPSJsb2Fuc18xIiBjbGFzcz0iZWRnZSI+PHRpdGxlPmxvYW5zOmFjY291bnRfaWQtJmd0O2FjY291bnRzOmlkPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTk0LjUsLTkxQzIwNy4xMzAyLC05MSAyMTIuNTgxOSwtOTEgMjIxLjczNSwtOTEiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjIyMiwtOTQuNTAwMSAyMzIsLTkxIDIyMiwtODcuNTAwMSAyMjIsLTk0LjUwMDEiPjwvcG9seWdvbj48L2c+PCEtLSBsb2Fuc19yZXNpZHVhbHMgLS0+PGcgaWQ9ImxvYW5zX3Jlc2lkdWFscyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5sb2Fuc19yZXNpZHVhbHM8L3RpdGxlPgo8cG9seWdvbiBmaWxsPSIjZWU4MmVlIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEsLTEyMSAxLC0xNDEgOTEsLTE0MSA5MSwtMTIxIDEsLTEyMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMi44NDUiIHk9Ii0xMjYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjMDAwMDAwIj5sb2Fuc19yZXNpZHVhbHM8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZiZTZmYiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLC0xMDEgMSwtMTIxIDkxLC0xMjEgOTEsLTEwMSAxLC0xMDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjMiIHk9Ii0xMDcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+aWQ8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjOWU1NjllIiBzdHJva2Utb3BhY2l0eT0iMC42NjY2NjciIHBvaW50cz0iMCwtMTAwIDAsLTE0MiA5MiwtMTQyIDkyLC0xMDAgMCwtMTAwIj48L3BvbHlnb24+PC9nPjwhLS0gbG9hbnNfcmVzaWR1YWxzJiM0NTsmZ3Q7bG9hbnMgLS0+PGcgaWQ9ImxvYW5zX3Jlc2lkdWFsc18xIiBjbGFzcz0iZWRnZSI+PHRpdGxlPmxvYW5zX3Jlc2lkdWFsczppZC0mZ3Q7bG9hbnM6aWQ8L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik05MSwtMTExQzEwNC4xMDA3LC0xMTEgMTA5LjY3ODcsLTExMSAxMTkuMjUzMiwtMTExIiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxMTkuNSwtMTE0LjUwMDEgMTI5LjUsLTExMSAxMTkuNSwtMTA3LjUwMDEgMTE5LjUsLTExNC41MDAxIj48L3BvbHlnb24+PC9nPjwhLS0gb3JkZXJzIC0tPjxnIGlkPSJvcmRlcnMiIGNsYXNzPSJub2RlIj48dGl0bGU+b3JkZXJzPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iI2VmZWJkZCIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxMjkuNSwtNDEgMTI5LjUsLTYxIDE5NC41LC02MSAxOTQuNSwtNDEgMTI5LjUsLTQxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNDQuNTA5OCIgeT0iLTQ2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzAwMDAwMCI+b3JkZXJzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTI5LjUsLTIxIDEyOS41LC00MSAxOTQuNSwtNDEgMTk0LjUsLTIxIDEyOS41LC0yMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTMxLjUiIHk9Ii0yNy40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5pZDwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEyOS41LC0xIDEyOS41LC0yMSAxOTQuNSwtMjEgMTk0LjUsLTEgMTI5LjUsLTEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjEzMS4yODc1IiB5PSItNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmFjY291bnRfaWQ8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjEyOCwwIDEyOCwtNjIgMTk1LC02MiAxOTUsMCAxMjgsMCI+PC9wb2x5Z29uPjwvZz48IS0tIG9yZGVycyYjNDU7Jmd0O2FjY291bnRzIC0tPjxnIGlkPSJvcmRlcnNfMSIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5vcmRlcnM6YWNjb3VudF9pZC0mZ3Q7YWNjb3VudHM6aWQ8L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik0xOTQuNSwtMTFDMjI5LjYyNjQsLTExIDIwMC40OTQ4LC03NS4wMTQ5IDIyMi4wNjY4LC04OC41MTgiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjIyMS40NDk4LC05MS45NzE0IDIzMiwtOTEgMjIzLjE0NjcsLTg1LjE4MDIgMjIxLjQ0OTgsLTkxLjk3MTQiPjwvcG9seWdvbj48L2c+PCEtLSB0a2V5cyAtLT48ZyBpZD0idGtleXMiIGNsYXNzPSJub2RlIj48dGl0bGU+dGtleXM8L3RpdGxlPgo8cG9seWdvbiBmaWxsPSIjZWZlYmRkIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjI4LC0zNCAyOCwtNTQgNjEsLTU0IDYxLC0zNCAyOCwtMzQiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjI5LjcyNTEiIHk9Ii0zOS40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiMwMDAwMDAiPnRrZXlzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIyNi41LC0zMyAyNi41LC01NSA2MS41LC01NSA2MS41LC0zMyAyNi41LC0zMyI+PC9wb2x5Z29uPjwvZz48L2c+PC9zdmc+)

``` r
my_dm_sqlite_resid %>%
  dm_examine_constraints()
```

``` fansi
#> ℹ All constraints satisfied.
```

``` r
my_dm_sqlite_resid$loans_residuals
```

``` fansi
#> # Source:   table<`loans_residuals_1_20200828_071303_12345`> [?? x 2]
#> # Database: sqlite 3.51.2 []
#>       id   resid
#>    <int>   <dbl>
#>  1  4959 -31912.
#>  2  4961 -27336.
#>  3  4962 -30699.
#>  4  4967  63621.
#>  5  4968 -94811.
#>  6  4973  59036.
#>  7  4986  41901.
#>  8  4988 123392.
#>  9  4989 147157.
#> 10  4990  33377.
#> # ℹ more rows
```

## Persisting a relational model with `copy_dm_to()`

Persistence, because it is intended to make permanent changes, requires
write access to the source RDBMS. The code below is a repeat of the code
that opened the [Copying and persisting individual
tables](#copying-tables) section at the beginning of the tutorial. It
uses the {dm} convenience function
[`dm_financial()`](https://dm.cynkra.com/dev/reference/dm_financial.md)
to create a dm object corresponding to a data model from a public
dataset repository. The dm object is downloaded locally first, before
deploying it to a local SQLite database.

[`dm_select_tbl()`](https://dm.cynkra.com/dev/reference/dm_select_tbl.md)
is used to exclude the transaction table `trans` due to its size, then
the [`collect()`](https://dplyr.tidyverse.org/reference/compute.html)
method retrieves the remaining tables and returns them as a local dm
object.

``` r
dm_financial() %>%
  dm_nrow()
#>     trans districts   clients    orders     cards     disps     tkeys 
#>   1056320        77      5369      6471       892      5369       234 
#>  accounts     loans 
#>      4500       682
fin_dm <-
  dm_financial() %>%
  dm_select_tbl(-trans) %>%
  collect()

fin_dm
```

``` fansi
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `districts`, `clients`, `orders`, `cards`, `disps`, … (8 total)
#> Columns: 47
#> Primary keys: 7
#> Foreign keys: 6
```

It is just as simple to move a local relational model into an RDBMS.

``` r
destination_db <- DBI::dbConnect(RSQLite::SQLite())

deployed_dm <-
  copy_dm_to(destination_db, fin_dm, temporary = FALSE)

deployed_dm
```

``` fansi
#> ── Table source ───────────────────────────────────────────────────────────
#> src:  sqlite 3.51.2 []
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `districts`, `clients`, `orders`, `cards`, `disps`, … (8 total)
#> Columns: 47
#> Primary keys: 7
#> Foreign keys: 6
```

Note that in the call to
[`copy_dm_to()`](https://dm.cynkra.com/dev/reference/copy_dm_to.md) the
argument `temporary = FALSE` is supplied. Without this argument, the
model would still be copied into the database, but the argument would
default to `temporary = TRUE` and the data would be deleted once your
session ends.

In the output you can observe that the `src` for `deployed_dm` is
SQLite, while for `fin_dm` the source is not indicated because it is a
local data model.

Copying a relational model into an empty database is the simplest use
case for
[`copy_dm_to()`](https://dm.cynkra.com/dev/reference/copy_dm_to.md). If
you want to copy a model into an RDBMS that is already populated, be
aware that
[`copy_dm_to()`](https://dm.cynkra.com/dev/reference/copy_dm_to.md) will
not overwrite pre-existing tables. In this case you will need to use the
`table_names` argument to give the tables unique names.

`table_names` can be a named character vector, with the names matching
the table names in the dm object and the values containing the desired
names in the RDBMS, or a function or one-sided formula. In the example
below, [`paste0()`](https://rdrr.io/r/base/paste.html) is used to add a
prefix to the table names to provide uniqueness.

``` r
dup_dm <-
  copy_dm_to(destination_db, fin_dm, temporary = FALSE, table_names = ~ paste0("dup_", .x))

dup_dm
```

``` fansi
#> ── Table source ───────────────────────────────────────────────────────────
#> src:  sqlite 3.51.2 []
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `districts`, `clients`, `orders`, `cards`, `disps`, … (8 total)
#> Columns: 47
#> Primary keys: 7
#> Foreign keys: 6
```

``` r
remote_name(dup_dm$accounts)
#> [1] "dup_accounts"
remote_name(deployed_dm$accounts)
#> [1] "accounts"
```

Note the different table names for `dup_dm$accounts` and
`deployed_dm$accounts`. For both, the table name is `accounts` in the
`dm` object, but they link to different tables on the database. In
`dup_dm`, the table is backed by the table `dup_accounts` in the RDBMS.
`dm_deployed$accounts` shows us that this table is still backed by the
`accounts` table from the
[`copy_dm_to()`](https://dm.cynkra.com/dev/reference/copy_dm_to.md)
operation we performed in the preceding example.

Managing tables in the RDBMS is outside the scope of `dm`. If you find
you need to remove tables or perform operations directly on the RDBMS,
see the {[DBI](https://dbi.r-dbi.org/)} package.

When done, do not forget to disconnect:

``` r
DBI::dbDisconnect(destination_db)
DBI::dbDisconnect(local_db)
```

## Conclusion

`dm` makes it straightforward to deploy your complete relational model
to an RDBMS using the
[`copy_dm_to()`](https://dm.cynkra.com/dev/reference/copy_dm_to.md)
function. For tables that are created from a relational model during
analysis or development,
[`compute()`](https://dplyr.tidyverse.org/reference/compute.html) and
[`copy_to()`](https://dplyr.tidyverse.org/reference/copy_to.html) can be
used to persist them (using argument `temporary = FALSE`) between
sessions or to copy local tables to a database `dm`. The
[`collect()`](https://dplyr.tidyverse.org/reference/compute.html) method
downloads an entire `dm` object that fits into memory from the database.

## Further Reading

If you need finer-grained control over modifications to your relational
model, see
[`vignette("howto-dm-rows")`](https://dm.cynkra.com/dev/articles/howto-dm-rows.md)
for an introduction to row level operations, including updates,
insertions, deletions and patching.

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
