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
[`vignette("howto-dm-rows")`](https://dm.cynkra.com/articles/howto-dm-rows.md).

## Copy models or copy tables?

Using {dm} you can persist an entire relational data model with a single
function call.
[`copy_dm_to()`](https://dm.cynkra.com/reference/copy_dm_to.md) will
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
[`vignette("howto-dm-db")`](https://dm.cynkra.com/articles/howto-dm-db.md)
and will be discussed in more detail in the [Copying a relational
model](#copy-model) section.

``` r
library(dm)
library(dbplyr)

fin_dm <-
  dm_financial() %>%
  dm_select_tbl(-trans) %>%
  collect()
#> Error in `financial_db_con()` at dm/R/financial.R:18:3:
#> ! Can't connect to relational.fel.cvut.cz or databases.pacha.dev:
#>   Failed to connect: Can't connect to MySQL server on
#>   'relational.fel.cvut.cz:3306' (101) Failed to connect: Can't connect to
#>   MySQL server on 'databases.pacha.dev:3306' (110)

local_db <- DBI::dbConnect(RSQLite::SQLite())
deployed_dm <- copy_dm_to(local_db, fin_dm, temporary = FALSE)
#> Error:
#> ! object 'fin_dm' not found
```

## Copying and persisting individual tables

As part of your data analysis, you may combine tables from multiple
sources and create links to existing tables via foreign keys, or create
new tables holding data summaries. The example below, already discussed
in
[`vignette("howto-dm-db")`](https://dm.cynkra.com/articles/howto-dm-db.md),
computes the total amount of all loans for each account.

``` r
my_dm_total <-
  deployed_dm %>%
  dm_zoom_to(loans) %>%
  summarize(.by = account_id, total_amount = sum(amount, na.rm = TRUE)) %>%
  dm_insert_zoomed("total_loans")
#> Error:
#> ! object 'deployed_dm' not found
```

The derived table `total_loans` is a *lazy table* powered by the
{[dbplyr](https://dbplyr.tidyverse.org/)} package: the results are not
materialized, instead an SQL query is built and executed each time the
data is requested.

``` r
my_dm_total$total_loans %>%
  sql_render()
#> Error:
#> ! object 'my_dm_total' not found
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
#> Error:
#> ! object 'deployed_dm' not found

my_dm_total_computed$total_loans %>%
  sql_render()
#> Error:
#> ! object 'my_dm_total_computed' not found
```

    #> Error:
    #> ! object 'my_dm_total_computed' not found

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
#> Error:
#> ! object 'my_dm_total' not found
```

## Adding local data frames to an RDBMS

If you need to add local data frames to an existing `dm` object, use the
[`copy_to()`](https://dplyr.tidyverse.org/reference/copy_to.html)
method. It takes the same arguments as
[`copy_dm_to()`](https://dm.cynkra.com/reference/copy_dm_to.md), except
the second argument takes a data frame rather than a dm. The result is a
derived `dm` object that contains the new table.

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
#> Error:
#> ! object 'deployed_dm' not found
```

Please note the use of `recursive = TRUE` for
[`dm_flatten_to_tbl()`](https://dm.cynkra.com/reference/dm_flatten_to_tbl.md).
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
#> Error:
#> ! object 'loans_df' not found

loans_residuals <- tibble::tibble(
  id = loans_df$id,
  resid = unname(residuals(model))
)
#> Error:
#> ! object 'loans_df' not found

loans_residuals
#> Error:
#> ! object 'loans_residuals' not found
```

Adding `loans_residuals` to the dm is done using
[`copy_to()`](https://dplyr.tidyverse.org/reference/copy_to.html). The
call to the method includes the argument `temporary = FALSE` because we
want this table to persist beyond our current session. In the same
pipeline we create the necessary primary and foreign keys to integrate
the table with the rest of our relational model. For more information on
key creation, see
[`vignette("howto-dm-db")`](https://dm.cynkra.com/articles/howto-dm-db.md)
and
[`vignette("howto-dm-theory")`](https://dm.cynkra.com/articles/howto-dm-theory.md).

``` r
my_dm_sqlite_resid <-
  copy_to(deployed_dm, loans_residuals, temporary = FALSE) %>%
  dm_add_pk(loans_residuals, id) %>%
  dm_add_fk(loans_residuals, id, loans)
#> Error:
#> ! object 'deployed_dm' not found

my_dm_sqlite_resid %>%
  dm_set_colors(violet = loans_residuals) %>%
  dm_draw()
#> Error:
#> ! object 'my_dm_sqlite_resid' not found
my_dm_sqlite_resid %>%
  dm_examine_constraints()
#> Error:
#> ! object 'my_dm_sqlite_resid' not found
my_dm_sqlite_resid$loans_residuals
#> Error:
#> ! object 'my_dm_sqlite_resid' not found
```

## Persisting a relational model with `copy_dm_to()`

Persistence, because it is intended to make permanent changes, requires
write access to the source RDBMS. The code below is a repeat of the code
that opened the [Copying and persisting individual
tables](#copying-tables) section at the beginning of the tutorial. It
uses the {dm} convenience function
[`dm_financial()`](https://dm.cynkra.com/reference/dm_financial.md) to
create a dm object corresponding to a data model from a public dataset
repository. The dm object is downloaded locally first, before deploying
it to a local SQLite database.

[`dm_select_tbl()`](https://dm.cynkra.com/reference/dm_select_tbl.md) is
used to exclude the transaction table `trans` due to its size, then the
[`collect()`](https://dplyr.tidyverse.org/reference/compute.html) method
retrieves the remaining tables and returns them as a local dm object.

``` r
dm_financial() %>%
  dm_nrow()
#> Error in `financial_db_con()` at dm/R/financial.R:18:3:
#> ! Can't connect to relational.fel.cvut.cz or databases.pacha.dev:
#>   Failed to connect: Can't connect to MySQL server on
#>   'relational.fel.cvut.cz:3306' (101) Failed to connect: Can't connect to
#>   MySQL server on 'databases.pacha.dev:3306' (110)
fin_dm <-
  dm_financial() %>%
  dm_select_tbl(-trans) %>%
  collect()
#> Error in `financial_db_con()` at dm/R/financial.R:18:3:
#> ! Can't connect to relational.fel.cvut.cz or databases.pacha.dev:
#>   Failed to connect: Can't connect to MySQL server on
#>   'relational.fel.cvut.cz:3306' (101) Failed to connect: Can't connect to
#>   MySQL server on 'databases.pacha.dev:3306' (110)

fin_dm
#> Error:
#> ! object 'fin_dm' not found
```

It is just as simple to move a local relational model into an RDBMS.

``` r
destination_db <- DBI::dbConnect(RSQLite::SQLite())

deployed_dm <-
  copy_dm_to(destination_db, fin_dm, temporary = FALSE)
#> Error:
#> ! object 'fin_dm' not found

deployed_dm
#> Error:
#> ! object 'deployed_dm' not found
```

Note that in the call to
[`copy_dm_to()`](https://dm.cynkra.com/reference/copy_dm_to.md) the
argument `temporary = FALSE` is supplied. Without this argument, the
model would still be copied into the database, but the argument would
default to `temporary = TRUE` and the data would be deleted once your
session ends.

In the output you can observe that the `src` for `deployed_dm` is
SQLite, while for `fin_dm` the source is not indicated because it is a
local data model.

Copying a relational model into an empty database is the simplest use
case for
[`copy_dm_to()`](https://dm.cynkra.com/reference/copy_dm_to.md). If you
want to copy a model into an RDBMS that is already populated, be aware
that [`copy_dm_to()`](https://dm.cynkra.com/reference/copy_dm_to.md)
will not overwrite pre-existing tables. In this case you will need to
use the `table_names` argument to give the tables unique names.

`table_names` can be a named character vector, with the names matching
the table names in the dm object and the values containing the desired
names in the RDBMS, or a function or one-sided formula. In the example
below, [`paste0()`](https://rdrr.io/r/base/paste.html) is used to add a
prefix to the table names to provide uniqueness.

``` r
dup_dm <-
  copy_dm_to(destination_db, fin_dm, temporary = FALSE, table_names = ~ paste0("dup_", .x))
#> Error:
#> ! object 'fin_dm' not found

dup_dm
#> Error:
#> ! object 'dup_dm' not found
remote_name(dup_dm$accounts)
#> Error:
#> ! object 'dup_dm' not found
remote_name(deployed_dm$accounts)
#> Error:
#> ! object 'deployed_dm' not found
```

Note the different table names for `dup_dm$accounts` and
`deployed_dm$accounts`. For both, the table name is `accounts` in the
`dm` object, but they link to different tables on the database. In
`dup_dm`, the table is backed by the table `dup_accounts` in the RDBMS.
`dm_deployed$accounts` shows us that this table is still backed by the
`accounts` table from the
[`copy_dm_to()`](https://dm.cynkra.com/reference/copy_dm_to.md)
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
[`copy_dm_to()`](https://dm.cynkra.com/reference/copy_dm_to.md)
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
[`vignette("howto-dm-rows")`](https://dm.cynkra.com/articles/howto-dm-rows.md)
for an introduction to row level operations, including updates,
insertions, deletions and patching.

If you would like to know more about relational data models in order to
get the most out of dm, check out
[`vignette("howto-dm-theory")`](https://dm.cynkra.com/articles/howto-dm-theory.md).

If you’re familiar with relational data models but want to know how to
work with them in dm, then any of
[`vignette("tech-dm-join")`](https://dm.cynkra.com/articles/tech-dm-join.md),
[`vignette("tech-dm-filter")`](https://dm.cynkra.com/articles/tech-dm-filter.md),
or
[`vignette("tech-dm-zoom")`](https://dm.cynkra.com/articles/tech-dm-zoom.md)
is a good next step.
