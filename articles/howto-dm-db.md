# Create a dm object from a database

{dm} was designed to make connecting to and working with a relational
database management system (RDBMS) as straightforward as possible. To
this end, a dm object can be created from any database that has a
{[DBI](https://dbi.r-dbi.org/)} backend available ([see
list](https://github.com/r-dbi/backends)).

When a dm object is created via a DBI connection to an RDBMS, it can
import all the tables in the database, the active schema, or a limited
set. For some RDBMS, such as Postgres, SQL Server and MariaDB, primary
and foreign keys are also imported and do not have to be manually added
afterwards.

To demonstrate, we will connect to a [relational dataset
repository](https://relational.fel.cvut.cz/) with a database server that
is publicly accessible without registration. It hosts a [financial
dataset](https://relational.fel.cvut.cz/dataset/Financial) that contains
loan data along with relevant account information and transactions. We
chose this dataset because the relationships between `loan`, `account`,
and `transactions` tables are a good representation of databases that
record real-world business transactions.

Below, we open a connection to the publicly accessible database server
using their documented connection parameters. Connection details vary
from database to database. Before connecting to your own RDBMS, you may
want to read
[`vignette("DBI", package = "DBI")`](https://dbi.r-dbi.org/articles/DBI.html)
for further information.

``` r
library(RMariaDB)

my_db <- dbConnect(
  MariaDB(),
  username = "guest",
  password = "ctu-relational",
  dbname = "Financial_ijs",
  host = "relational.fel.cvut.cz"
)
```

    #> Error in `dm:::financial_db_con()`:
    #> ! Can't connect to relational.fel.cvut.cz or databases.pacha.dev:
    #>   Failed to connect: Can't connect to MySQL server on
    #>   'relational.fel.cvut.cz:3306' (101) Failed to connect: Can't connect to
    #>   MySQL server on 'databases.pacha.dev:3306' (110)

Creating a dm object takes a single call to
[`dm_from_con()`](https://dm.cynkra.com/reference/dm_from_con.md) with
the DBI connection object as its argument.

``` r
library(dm)

my_dm <- dm_from_con(my_db)
#> Error:
#> ! object 'my_db' not found
my_dm
#> Error:
#> ! object 'my_dm' not found
```

The components of the `my_dm` object are lazy tables powered by
{[dbplyr](https://dbplyr.tidyverse.org/)}. {dbplyr} translates the
{[dplyr](https://dplyr.tidyverse.org/)} grammar of data manipulation
into queries the database server understands. Lazy tables defer
downloading of table data until results are required for printing or
local processing.

## Building a dm from a subset of tables

A dm can also be constructed from individual tables or views. This is
useful for when you want to work with a subset of a database’s tables,
perhaps from different schemas.

Below, we use the `$` notation to extract two tables from the financial
database. Then we create our dm by passing the tables in as arguments.
Note that the tables arguments have to all be from the same source, in
this case `my_db`.

``` r
dbListTables(my_db)
#> Error in `h()`:
#> ! error in evaluating the argument 'conn' in selecting a method for function 'dbListTables': object 'my_db' not found

library(dbplyr)
loans <- tbl(my_db, "loans")
#> Error:
#> ! object 'my_db' not found
accounts <- tbl(my_db, "accounts")
#> Error:
#> ! object 'my_db' not found

my_manual_dm <- dm(loans, accounts)
#> Error in `map()` at dm/R/dm.R:60:3:
#> ℹ In index: 1.
#> Caused by error:
#> ! object 'loans' not found
my_manual_dm
#> Error:
#> ! object 'my_manual_dm' not found
```

## Defining Primary and Foreign Keys

Primary keys and foreign keys are how relational database tables are
linked with each other. A primary key is a column or column tuple that
has a unique value for each row within a table. A foreign key is a
column or column tuple containing the primary key for a row in another
table. Foreign keys act as cross references between tables. They specify
the relationships that gives us the *relational* database. For more
information on keys and a crash course on databases, see
[`vignette("howto-dm-theory")`](https://dm.cynkra.com/articles/howto-dm-theory.md).

In many cases,
[`dm_from_con()`](https://dm.cynkra.com/reference/dm_from_con.md)
already returns a dm with all keys set. If not, dm allows us to define
primary and foreign keys ourselves. For this, we use
`learn_keys = FALSE` to obtain a `dm` object with only the tables.

``` r
library(dm)

fin_dm <- dm_from_con(my_db, learn_keys = FALSE)
#> Error:
#> ! object 'my_db' not found
fin_dm
#> Error:
#> ! object 'fin_dm' not found
```

The [model
diagram](https://relational.fel.cvut.cz/assets/img/datasets-generated/financial.svg)
provided by our test database loosely illustrates the intended
relationships between tables. In the diagram, we can see that the
`loans` table should be linked to the `accounts` table. Below, we create
those links in 3 steps:

1.  Add a primary key `id` to the `accounts` table
2.  Add a primary key `id` to the `loans` table
3.  Add a foreign key `account_id` to the `loans` table referencing the
    `accounts` table

Then we assign colors to the tables and draw the structure of the dm.

Note that when the foreign key is created, the primary key in the
referenced table does not need to be *specified*, but the primary key
must already be *defined*. And, as mentioned above, primary and foreign
key constraints on the database are currently only imported for
Postgres, SQL Server databases and MariaDB, and only when
[`dm_from_con()`](https://dm.cynkra.com/reference/dm_from_con.md) is
used. This process of key definition needs to be done manually for other
databases.

``` r
my_dm_keys <-
  my_manual_dm %>%
  dm_add_pk(accounts, id) %>%
  dm_add_pk(loans, id) %>%
  dm_add_fk(loans, account_id, accounts) %>%
  dm_set_colors(green = loans, orange = accounts)
#> Error:
#> ! object 'my_manual_dm' not found

my_dm_keys %>%
  dm_draw()
#> Error:
#> ! object 'my_dm_keys' not found
```

Once you have instantiated a dm object, you can continue to add tables
to it. For tables from the original source for the dm, use
[`dm()`](https://dm.cynkra.com/reference/dm.md)

``` r
trans <- tbl(my_db, "trans")
#> Error:
#> ! object 'my_db' not found

my_dm_keys %>%
  dm(trans)
#> Error in `map()` at dm/R/dm.R:60:3:
#> ℹ In index: 1.
#> Caused by error:
#> ! object 'my_dm_keys' not found
```

## Serializing a dm object

A dm object is always linked to a database connection. This connection
is lost when the dm object is saved to disk, e.g., when saving the
workspace in R or in Posit Workbench, or when using knitr chunks:

``` r
unserialize(serialize(my_dm_keys, NULL))
#> Error:
#> ! object 'my_dm_keys' not found
```

The connection is tightly coupled with the tables in the dm object and
cannot be replaced. A practical solution is to define, for each dm
object your project uses, a function that recreates it using a new
database connection:

``` r
my_db_fun <- function() {
  dbConnect(
    MariaDB(),
    username = "guest",
    password = "ctu-relational",
    dbname = "Financial_ijs",
    host = "relational.fel.cvut.cz"
  )
}

my_dm_fun <- function(my_db = my_db_fun()) {
  loans <- tbl(my_db, "loans")
  accounts <- tbl(my_db, "accounts")
  dm(loans, accounts) %>%
    dm_add_pk(accounts, id) %>%
    dm_add_pk(loans, id) %>%
    dm_add_fk(loans, account_id, accounts) %>%
    dm_set_colors(green = loans, orange = accounts)
}
```

    #> Error in `dm:::financial_db_con()`:
    #> ! Can't connect to relational.fel.cvut.cz or databases.pacha.dev:
    #>   Failed to connect: Can't connect to MySQL server on
    #>   'relational.fel.cvut.cz:3306' (101) Failed to connect: Can't connect to
    #>   MySQL server on 'databases.pacha.dev:3306' (110)

To avoid reconnecting and/or recreating every time you need a dm object,
you can use
[`memoise::memoise()`](https://memoise.r-lib.org/reference/memoise.html)
to memoize the connection and/or dm functions.

## Transient nature of operations

Like other R objects, a dm is immutable and all operations performed on
it are transient unless stored in a new variable.

``` r
my_dm_keys
#> Error:
#> ! object 'my_dm_keys' not found

my_dm_trans <-
  my_dm_keys %>%
  dm(trans)
#> Error in `map()` at dm/R/dm.R:60:3:
#> ℹ In index: 1.
#> Caused by error:
#> ! object 'my_dm_keys' not found

my_dm_trans
#> Error:
#> ! object 'my_dm_trans' not found
```

And, like {dbplyr}, results are never written to a database unless
explicitly requested.

``` r
my_dm_keys %>%
  dm_flatten_to_tbl(loans)
#> Error:
#> ! object 'my_dm_keys' not found

my_dm_keys %>%
  dm_flatten_to_tbl(loans) %>%
  sql_render()
#> Error:
#> ! object 'my_dm_keys' not found
```

## Performing operations on tables by “zooming”

As the dm is a collection of tables, if we wish to perform operations on
an individual table, we set it as the context for those operations using
[`dm_zoom_to()`](https://dm.cynkra.com/reference/dm_zoom_to.md). See
[`vignette("tech-dm-zoom")`](https://dm.cynkra.com/articles/tech-dm-zoom.md)
for more detail on zooming.

dm operations are transient unless persistence is explicitly requested.
To make our chain of manipulations on the selected table permanent, we
assign the result of
[`dm_insert_zoomed()`](https://dm.cynkra.com/reference/dm_zoom_to.md) to
a new object, `my_dm_total`. This is a new dm object, derived from
`my_dm_keys`, with a new lazy table `total_loans` linked to the
`accounts` table.

``` r
my_dm_total <-
  my_dm_keys %>%
  dm_zoom_to(loans) %>%
  summarize(.by = account_id, total_amount = sum(amount, na.rm = TRUE)) %>%
  dm_insert_zoomed("total_loans")
#> Error:
#> ! object 'my_dm_keys' not found
```

Context is set to the table “loans” using `dm_zoom_to(loans)`. You can
learn more about zooming in the tutorial
[`vignette("tech-dm-zoom")`](https://dm.cynkra.com/articles/tech-dm-zoom.md).
We then use {[dplyr](https://dplyr.tidyverse.org/)} functions on the
zoomed table to generate a new summary table.

[`summarize()`](https://dplyr.tidyverse.org/reference/summarise.html)
returns a temporary table with one row for each group created by the
`.by` argument. The columns in the temporary table are constrained to
the columns passed as the `.by` argument and the column(s) created by
the
[`summarize()`](https://dplyr.tidyverse.org/reference/summarise.html)
function.

`dm_insert_zoomed("total_loans")` adds the temporary table created by
[`summarize()`](https://dplyr.tidyverse.org/reference/summarise.html) to
the data model under a new name, `total_loans`. Because the grouping
variable `account_id` is a primary key, the new derived table is
automatically linked to the `accounts` table.

``` r
my_dm_total %>%
  dm_set_colors(violet = total_loans) %>%
  dm_draw()
#> Error:
#> ! object 'my_dm_total' not found
```

The resulting table `total_loans` can be accessed like any other table
in the dm object.

``` r
my_dm_total$total_loans
#> Error:
#> ! object 'my_dm_total' not found
```

It is a *lazy table* powered by the
{[dbplyr](https://dbplyr.tidyverse.org/)} package: the results are not
materialized; instead, an SQL query is built and executed each time the
data is requested.

``` r
my_dm_total$total_loans %>%
  sql_render()
#> Error:
#> ! object 'my_dm_total' not found
```

Use [`compute()`](https://dplyr.tidyverse.org/reference/compute.html) on
a zoomed table to materialize it to a temporary table and avoid
recomputing. See
[`vignette("howto-dm-copy")`](https://dm.cynkra.com/articles/howto-dm-copy.md)
for more details.

## Downloading data

When it becomes necessary to move data locally for analysis or
reporting, the {dm} method
[`collect()`](https://dplyr.tidyverse.org/reference/compute.html) is
used. Operations on dm objects for databases are limited to report only
the first ten results.
[`collect()`](https://dplyr.tidyverse.org/reference/compute.html) forces
the evaluation of all SQL queries and the generation of the complete set
of results. The resulting tables are transferred from the RDBMS and
stored as local tibbles.

``` r
my_dm_local <-
  my_dm_total %>%
  collect()
#> Error:
#> ! object 'my_dm_total' not found

my_dm_local$total_loans
#> Error:
#> ! object 'my_dm_local' not found
```

Use this method with caution. If you are not sure of the size of the
dataset you will be downloading, you can call
[`dm_nrow()`](https://dm.cynkra.com/reference/dm_nrow.md) on your `dm`
for the row count of your data model’s tables.

``` r
my_dm_total %>%
  dm_nrow()
#> Error:
#> ! object 'my_dm_total' not found
```

## Persisting results

It is just as simple to move a local relational model into an RDBMS as
is using
[`collect()`](https://dplyr.tidyverse.org/reference/compute.html) to
download it. The method used is
[`copy_dm_to()`](https://dm.cynkra.com/reference/copy_dm_to.md) and it
takes as arguments a database connection and a dm object. In the example
below, a local SQLite database is used to demonstrate it, but {dm} is
designed to work with any RDBMS supported by {DBI}.

``` r
destination_db <- DBI::dbConnect(RSQLite::SQLite())

deployed_dm <- copy_dm_to(destination_db, my_dm_local)
#> Error:
#> ! object 'my_dm_local' not found

deployed_dm
#> Error:
#> ! object 'deployed_dm' not found
my_dm_local
#> Error:
#> ! object 'my_dm_local' not found
```

In the output, you can observe that the `src` for `deployed_dm` is the
SQLite database, while for `my_dm_local` the source is the local R
environment.

Persisting tables are covered in more detail in
[`vignette("howto-dm-copy")`](https://dm.cynkra.com/articles/howto-dm-copy.md).

When done, do not forget to disconnect:

``` r
DBI::dbDisconnect(destination_db)
DBI::dbDisconnect(my_db)
#> Error in `h()`:
#> ! error in evaluating the argument 'conn' in selecting a method for function 'dbDisconnect': object 'my_db' not found
```

## Conclusion

In this tutorial, we have demonstrated how simple it is to load a
database into a `dm` object and begin working with it. Currently,
loading a dm from most RDBMS requires you to manually set key relations,
but {dm} provides methods to make this straightforward. It is planned
that future versions of dm will support automatic key creation for more
RDBMS.

The next step is to read
[`vignette("howto-dm-copy")`](https://dm.cynkra.com/articles/howto-dm-copy.md),
where copying your tables to and from an RDBMS is covered.
[`vignette("howto-dm-rows")`](https://dm.cynkra.com/articles/howto-dm-rows.md)
discusses manipulation of individual rows in a database.

## Further reading

[`vignette("howto-dm-df")`](https://dm.cynkra.com/articles/howto-dm-df.md)
– Is your data in local data frames? This article covers creating a data
model from your local data frames, including building the relationships
in your data model, verifying your model, and leveraging the power of
dplyr to operate on your data model.

[`vignette("howto-dm-theory")`](https://dm.cynkra.com/articles/howto-dm-theory.md)
– Do you know all about data frames but very little about relational
data models? This quick introduction will walk you through the key
similarities and differences, and show you how to move from individual
data frames to a relational data model.
