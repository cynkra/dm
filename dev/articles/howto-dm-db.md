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

Creating a dm object takes a single call to
[`dm_from_con()`](https://dm.cynkra.com/dev/reference/dm_from_con.md)
with the DBI connection object as its argument.

``` r
library(dm)

my_dm <- dm_from_con(my_db)
```

``` fansi
#> Keys queried successfully.
#> ℹ Use `learn_keys = TRUE` to enforce querying keys and to mute this
#>   message.
```

``` r
my_dm
```

``` fansi
#> ── Table source ───────────────────────────────────────────────────────────
#> src:  mysql  [guest@relational.fel.cvut.cz:3306/Financial_ijs]
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `accounts`, `cards`, `clients`, `disps`, `districts`, … (9 total)
#> Columns: 57
#> Primary keys: 9
#> Foreign keys: 8
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
#> [1] "trans"     "districts" "clients"   "orders"    "cards"     "disps"    
#> [7] "tkeys"     "accounts"  "loans"

library(dbplyr)
loans <- tbl(my_db, "loans")
accounts <- tbl(my_db, "accounts")

my_manual_dm <- dm(loans, accounts)
my_manual_dm
```

``` fansi
#> ── Table source ───────────────────────────────────────────────────────────
#> src:  mysql  [guest@relational.fel.cvut.cz:3306/Financial_ijs]
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `loans`, `accounts`
#> Columns: 11
#> Primary keys: 0
#> Foreign keys: 0
```

## Defining Primary and Foreign Keys

Primary keys and foreign keys are how relational database tables are
linked with each other. A primary key is a column or column tuple that
has a unique value for each row within a table. A foreign key is a
column or column tuple containing the primary key for a row in another
table. Foreign keys act as cross references between tables. They specify
the relationships that gives us the *relational* database. For more
information on keys and a crash course on databases, see
[`vignette("howto-dm-theory")`](https://dm.cynkra.com/dev/articles/howto-dm-theory.md).

In many cases,
[`dm_from_con()`](https://dm.cynkra.com/dev/reference/dm_from_con.md)
already returns a dm with all keys set. If not, dm allows us to define
primary and foreign keys ourselves. For this, we use
`learn_keys = FALSE` to obtain a `dm` object with only the tables.

``` r
library(dm)

fin_dm <- dm_from_con(my_db, learn_keys = FALSE)
fin_dm
```

``` fansi
#> ── Table source ───────────────────────────────────────────────────────────
#> src:  mysql  [guest@relational.fel.cvut.cz:3306/Financial_ijs]
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `trans`, `districts`, `clients`, `orders`, `cards`, … (9 total)
#> Columns: 57
#> Primary keys: 0
#> Foreign keys: 0
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
[`dm_from_con()`](https://dm.cynkra.com/dev/reference/dm_from_con.md) is
used. This process of key definition needs to be done manually for other
databases.

``` r
my_dm_keys <-
  my_manual_dm %>%
  dm_add_pk(accounts, id) %>%
  dm_add_pk(loans, id) %>%
  dm_add_fk(loans, account_id, accounts) %>%
  dm_set_colors(green = loans, orange = accounts)

my_dm_keys %>%
  dm_draw()
```

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTY1cHQiIGhlaWdodD0iNzBwdCIgdmlld2JveD0iMC4wMCAwLjAwIDE2NS4wMCA3MC4wMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayI+PGcgaWQ9ImdyYXBoMCIgY2xhc3M9ImdyYXBoIiB0cmFuc2Zvcm09InNjYWxlKDEgMSkgcm90YXRlKDApIHRyYW5zbGF0ZSg0IDY2KSI+PHRpdGxlPiUwPC90aXRsZT4KPGcgaWQ9ImFfZ3JhcGgwIj48YSB4bGluazp0aXRsZT0iRGF0YSBNb2RlbCI+Cjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iLTQsNCAtNCwtNjYgMTYxLC02NiAxNjEsNCAtNCw0Ij48L3BvbHlnb24+PC9hPgo8L2c+PCEtLSBhY2NvdW50cyAtLT48ZyBpZD0iYWNjb3VudHMiIGNsYXNzPSJub2RlIj48dGl0bGU+YWNjb3VudHM8L3RpdGxlPgo8cG9seWdvbiBmaWxsPSIjZmZhNTAwIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEwNCwtMjEgMTA0LC00MSAxNTYsLTQxIDE1NiwtMjEgMTA0LC0yMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTA1LjUxMDUiIHk9Ii0yNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiMwMDAwMDAiPmFjY291bnRzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmVkY2MiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTA0LC0xIDEwNCwtMjEgMTU2LC0yMSAxNTYsLTEgMTA0LC0xIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxMDYiIHk9Ii03LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmlkPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iI2FhNmUwMCIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjEwMywwIDEwMywtNDIgMTU3LC00MiAxNTcsMCAxMDMsMCI+PC9wb2x5Z29uPjwvZz48IS0tIGxvYW5zIC0tPjxnIGlkPSJsb2FucyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5sb2FuczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiMwMGZmMDAiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC00MSAxLjUsLTYxIDY2LjUsLTYxIDY2LjUsLTQxIDEuNSwtNDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE5LjIyNTEiIHk9Ii00Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiNmZmZmZmYiPmxvYW5zPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNjY2ZmY2MiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC0yMSAxLjUsLTQxIDY2LjUsLTQxIDY2LjUsLTIxIDEuNSwtMjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjMuNSIgeT0iLTI3LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmlkPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNjY2ZmY2MiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC0xIDEuNSwtMjEgNjYuNSwtMjEgNjYuNSwtMSAxLjUsLTEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjMuMjg3NSIgeT0iLTYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5hY2NvdW50X2lkPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzAwYWEwMCIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjAsMCAwLC02MiA2NywtNjIgNjcsMCAwLDAiPjwvcG9seWdvbj48L2c+PCEtLSBsb2FucyYjNDU7Jmd0O2FjY291bnRzIC0tPjxnIGlkPSJsb2Fuc18xIiBjbGFzcz0iZWRnZSI+PHRpdGxlPmxvYW5zOmFjY291bnRfaWQtJmd0O2FjY291bnRzOmlkPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNNjYuNSwtMTFDNzkuMTMwMiwtMTEgODQuNTgxOSwtMTEgOTMuNzM1LC0xMSIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iOTQsLTE0LjUwMDEgMTA0LC0xMSA5NCwtNy41MDAxIDk0LC0xNC41MDAxIj48L3BvbHlnb24+PC9nPjwvZz48L3N2Zz4=)

Once you have instantiated a dm object, you can continue to add tables
to it. For tables from the original source for the dm, use
[`dm()`](https://dm.cynkra.com/dev/reference/dm.md)

``` r
trans <- tbl(my_db, "trans")

my_dm_keys %>%
  dm(trans)
```

``` fansi
#> ── Table source ───────────────────────────────────────────────────────────
#> src:  mysql  [guest@relational.fel.cvut.cz:3306/Financial_ijs]
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `loans`, `accounts`, `trans`
#> Columns: 21
#> Primary keys: 2
#> Foreign keys: 1
```

## Serializing a dm object

A dm object is always linked to a database connection. This connection
is lost when the dm object is saved to disk, e.g., when saving the
workspace in R or in Posit Workbench, or when using knitr chunks:

``` r
unserialize(serialize(my_dm_keys, NULL))
```

``` fansi
#> ── Table source ───────────────────────────────────────────────────────────
```

    #> Error:
    #> ! Invalid connection

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

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTY1cHQiIGhlaWdodD0iNzBwdCIgdmlld2JveD0iMC4wMCAwLjAwIDE2NS4wMCA3MC4wMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayI+PGcgaWQ9ImdyYXBoMCIgY2xhc3M9ImdyYXBoIiB0cmFuc2Zvcm09InNjYWxlKDEgMSkgcm90YXRlKDApIHRyYW5zbGF0ZSg0IDY2KSI+PHRpdGxlPiUwPC90aXRsZT4KPGcgaWQ9ImFfZ3JhcGgwIj48YSB4bGluazp0aXRsZT0iRGF0YSBNb2RlbCI+Cjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iLTQsNCAtNCwtNjYgMTYxLC02NiAxNjEsNCAtNCw0Ij48L3BvbHlnb24+PC9hPgo8L2c+PCEtLSBhY2NvdW50cyAtLT48ZyBpZD0iYWNjb3VudHMiIGNsYXNzPSJub2RlIj48dGl0bGU+YWNjb3VudHM8L3RpdGxlPgo8cG9seWdvbiBmaWxsPSIjZmZhNTAwIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEwNCwtMjEgMTA0LC00MSAxNTYsLTQxIDE1NiwtMjEgMTA0LC0yMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTA1LjUxMDUiIHk9Ii0yNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiMwMDAwMDAiPmFjY291bnRzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmVkY2MiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTA0LC0xIDEwNCwtMjEgMTU2LC0yMSAxNTYsLTEgMTA0LC0xIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxMDYiIHk9Ii03LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmlkPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iI2FhNmUwMCIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjEwMywwIDEwMywtNDIgMTU3LC00MiAxNTcsMCAxMDMsMCI+PC9wb2x5Z29uPjwvZz48IS0tIGxvYW5zIC0tPjxnIGlkPSJsb2FucyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5sb2FuczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiMwMGZmMDAiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC00MSAxLjUsLTYxIDY2LjUsLTYxIDY2LjUsLTQxIDEuNSwtNDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE5LjIyNTEiIHk9Ii00Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiNmZmZmZmYiPmxvYW5zPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNjY2ZmY2MiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC0yMSAxLjUsLTQxIDY2LjUsLTQxIDY2LjUsLTIxIDEuNSwtMjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjMuNSIgeT0iLTI3LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmlkPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNjY2ZmY2MiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC0xIDEuNSwtMjEgNjYuNSwtMjEgNjYuNSwtMSAxLjUsLTEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjMuMjg3NSIgeT0iLTYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5hY2NvdW50X2lkPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzAwYWEwMCIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjAsMCAwLC02MiA2NywtNjIgNjcsMCAwLDAiPjwvcG9seWdvbj48L2c+PCEtLSBsb2FucyYjNDU7Jmd0O2FjY291bnRzIC0tPjxnIGlkPSJsb2Fuc18xIiBjbGFzcz0iZWRnZSI+PHRpdGxlPmxvYW5zOmFjY291bnRfaWQtJmd0O2FjY291bnRzOmlkPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNNjYuNSwtMTFDNzkuMTMwMiwtMTEgODQuNTgxOSwtMTEgOTMuNzM1LC0xMSIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iOTQsLTE0LjUwMDEgMTA0LC0xMSA5NCwtNy41MDAxIDk0LC0xNC41MDAxIj48L3BvbHlnb24+PC9nPjwvZz48L3N2Zz4=)

To avoid reconnecting and/or recreating every time you need a dm object,
you can use
[`memoise::memoise()`](https://memoise.r-lib.org/reference/memoise.html)
to memoize the connection and/or dm functions.

## Transient nature of operations

Like other R objects, a dm is immutable and all operations performed on
it are transient unless stored in a new variable.

``` r
my_dm_keys
```

``` fansi
#> ── Table source ───────────────────────────────────────────────────────────
#> src:  mysql  [guest@relational.fel.cvut.cz:3306/Financial_ijs]
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `loans`, `accounts`
#> Columns: 11
#> Primary keys: 2
#> Foreign keys: 1
```

``` r

my_dm_trans <-
  my_dm_keys %>%
  dm(trans)

my_dm_trans
```

``` fansi
#> ── Table source ───────────────────────────────────────────────────────────
#> src:  mysql  [guest@relational.fel.cvut.cz:3306/Financial_ijs]
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `loans`, `accounts`, `trans`
#> Columns: 21
#> Primary keys: 2
#> Foreign keys: 1
```

And, like {dbplyr}, results are never written to a database unless
explicitly requested.

``` r
my_dm_keys %>%
  dm_flatten_to_tbl(loans)
#> Renaming ambiguous columns: %>%
#>   dm_rename(loans, date.loans = date) %>%
#>   dm_rename(accounts, date.accounts = date)
```

``` fansi
#> # Source:   SQL [?? x 10]
#> # Database: mysql  [guest@relational.fel.cvut.cz:3306/Financial_ijs]
#>       id account_id date.loans amount duration payments status district_id
#>    <int>      <int> <date>      <dbl>    <int>    <dbl> <chr>        <int>
#>  1  4959          2 1994-01-05  80952       24     3373 A                1
#>  2  4961         19 1996-04-29  30276       12     2523 B               21
#>  3  4962         25 1997-12-08  30276       12     2523 A               68
#>  4  4967         37 1998-10-14 318480       60     5308 D               20
#>  5  4968         38 1998-04-19 110736       48     2307 C               19
#>  6  4973         67 1996-05-02 165960       24     6915 A               16
#>  7  4986         97 1997-08-10 102876       12     8573 A               74
#>  8  4988        103 1997-12-06 265320       36     7370 D               44
#>  9  4989        105 1998-12-05 352704       48     7348 C               21
#> 10  4990        110 1997-09-08 162576       36     4516 C               36
#> # ℹ more rows
#> # ℹ 2 more variables: frequency <chr>, date.accounts <date>
```

``` r

my_dm_keys %>%
  dm_flatten_to_tbl(loans) %>%
  sql_render()
#> Renaming ambiguous columns: %>%
#>   dm_rename(loans, date.loans = date) %>%
#>   dm_rename(accounts, date.accounts = date)
#> <SQL> SELECT
#>   `loans`.`id` AS `id`,
#>   `account_id`,
#>   `loans`.`date` AS `date.loans`,
#>   `amount`,
#>   `duration`,
#>   `payments`,
#>   `status`,
#>   `district_id`,
#>   `frequency`,
#>   `accounts`.`date` AS `date.accounts`
#> FROM `loans`
#> LEFT JOIN `accounts`
#>   ON (`loans`.`account_id` = `accounts`.`id`)
```

## Performing operations on tables by “zooming”

As the dm is a collection of tables, if we wish to perform operations on
an individual table, we set it as the context for those operations using
[`dm_zoom_to()`](https://dm.cynkra.com/dev/reference/dm_zoom_to.md). See
[`vignette("tech-dm-zoom")`](https://dm.cynkra.com/dev/articles/tech-dm-zoom.md)
for more detail on zooming.

dm operations are transient unless persistence is explicitly requested.
To make our chain of manipulations on the selected table permanent, we
assign the result of
[`dm_insert_zoomed()`](https://dm.cynkra.com/dev/reference/dm_zoom_to.md)
to a new object, `my_dm_total`. This is a new dm object, derived from
`my_dm_keys`, with a new lazy table `total_loans` linked to the
`accounts` table.

``` r
my_dm_total <-
  my_dm_keys %>%
  dm_zoom_to(loans) %>%
  group_by(account_id) %>%
  summarize(total_amount = sum(amount, na.rm = TRUE)) %>%
  ungroup() %>%
  dm_insert_zoomed("total_loans")
```

Context is set to the table “loans” using `dm_zoom_to(loans)`. You can
learn more about zooming in the tutorial
[`vignette("tech-dm-zoom")`](https://dm.cynkra.com/dev/articles/tech-dm-zoom.md).
We then use {[dplyr](https://dplyr.tidyverse.org/)} functions on the
zoomed table to generate a new summary table.

[`summarize()`](https://dplyr.tidyverse.org/reference/summarise.html)
returns a temporary table with one row for each group created by the
preceding
[`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html)
function. The columns in the temporary table are constrained to the
columns passed as arguments to the
[`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html)
function and the column(s) created by the
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
```

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTY1cHQiIGhlaWdodD0iMTMwcHQiIHZpZXdib3g9IjAuMDAgMC4wMCAxNjUuMDAgMTMwLjAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIj48ZyBpZD0iZ3JhcGgwIiBjbGFzcz0iZ3JhcGgiIHRyYW5zZm9ybT0ic2NhbGUoMSAxKSByb3RhdGUoMCkgdHJhbnNsYXRlKDQgMTI2KSI+PHRpdGxlPiUwPC90aXRsZT4KPGcgaWQ9ImFfZ3JhcGgwIj48YSB4bGluazp0aXRsZT0iRGF0YSBNb2RlbCI+Cjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iLTQsNCAtNCwtMTI2IDE2MSwtMTI2IDE2MSw0IC00LDQiPjwvcG9seWdvbj48L2E+CjwvZz48IS0tIGFjY291bnRzIC0tPjxnIGlkPSJhY2NvdW50cyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5hY2NvdW50czwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNmZmE1MDAiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTA0LC01MSAxMDQsLTcxIDE1NiwtNzEgMTU2LC01MSAxMDQsLTUxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxMDUuNTEwNSIgeT0iLTU2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzAwMDAwMCI+YWNjb3VudHM8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZWRjYyIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxMDQsLTMxIDEwNCwtNTEgMTU2LC01MSAxNTYsLTMxIDEwNCwtMzEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjEwNiIgeT0iLTM3LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmlkPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iI2FhNmUwMCIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjEwMywtMzAgMTAzLC03MiAxNTcsLTcyIDE1NywtMzAgMTAzLC0zMCI+PC9wb2x5Z29uPjwvZz48IS0tIGxvYW5zIC0tPjxnIGlkPSJsb2FucyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5sb2FuczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiMwMGZmMDAiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC0xMDEgMS41LC0xMjEgNjYuNSwtMTIxIDY2LjUsLTEwMSAxLjUsLTEwMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTkuMjI1MSIgeT0iLTEwNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiNmZmZmZmYiPmxvYW5zPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNjY2ZmY2MiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC04MSAxLjUsLTEwMSA2Ni41LC0xMDEgNjYuNSwtODEgMS41LC04MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMy41IiB5PSItODcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+aWQ8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2NjZmZjYyIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLjUsLTYxIDEuNSwtODEgNjYuNSwtODEgNjYuNSwtNjEgMS41LC02MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMy4yODc1IiB5PSItNjYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5hY2NvdW50X2lkPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzAwYWEwMCIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjAsLTYwIDAsLTEyMiA2NywtMTIyIDY3LC02MCAwLC02MCI+PC9wb2x5Z29uPjwvZz48IS0tIGxvYW5zJiM0NTsmZ3Q7YWNjb3VudHMgLS0+PGcgaWQ9ImxvYW5zXzEiIGNsYXNzPSJlZGdlIj48dGl0bGU+bG9hbnM6YWNjb3VudF9pZC0mZ3Q7YWNjb3VudHM6aWQ8L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik02Ni41LC03MUM4My42NzUsLTcxIDgzLjY3MDUsLTUxLjU3NDMgOTQuMTM0OCwtNDMuOTg2MiIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iOTUuNDQyOSwtNDcuMjQ3MSAxMDQsLTQxIDkzLjQxNDgsLTQwLjU0NzQgOTUuNDQyOSwtNDcuMjQ3MSI+PC9wb2x5Z29uPjwvZz48IS0tIHRvdGFsX2xvYW5zIC0tPjxnIGlkPSJ0b3RhbF9sb2FucyIgY2xhc3M9Im5vZGUiPjx0aXRsZT50b3RhbF9sb2FuczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZTgyZWUiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC0yMSAxLjUsLTQxIDY2LjUsLTQxIDY2LjUsLTIxIDEuNSwtMjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjMuMjgxOSIgeT0iLTI2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzAwMDAwMCI+dG90YWxfbG9hbnM8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZiZTZmYiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLjUsLTEgMS41LC0yMSA2Ni41LC0yMSA2Ni41LC0xIDEuNSwtMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMy4yODc1IiB5PSItNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmFjY291bnRfaWQ8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjOWU1NjllIiBzdHJva2Utb3BhY2l0eT0iMC42NjY2NjciIHBvaW50cz0iMCwwIDAsLTQyIDY3LC00MiA2NywwIDAsMCI+PC9wb2x5Z29uPjwvZz48IS0tIHRvdGFsX2xvYW5zJiM0NTsmZ3Q7YWNjb3VudHMgLS0+PGcgaWQ9InRvdGFsX2xvYW5zXzEiIGNsYXNzPSJlZGdlIj48dGl0bGU+dG90YWxfbG9hbnM6YWNjb3VudF9pZC0mZ3Q7YWNjb3VudHM6aWQ8L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik02Ni41LC0xMUM4My42NzUsLTExIDgzLjY3MDUsLTMwLjQyNTcgOTQuMTM0OCwtMzguMDEzOCIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iOTMuNDE0OCwtNDEuNDUyNiAxMDQsLTQxIDk1LjQ0MjksLTM0Ljc1MjkgOTMuNDE0OCwtNDEuNDUyNiI+PC9wb2x5Z29uPjwvZz48L2c+PC9zdmc+)

The resulting table `total_loans` can be accessed like any other table
in the dm object.

``` r
my_dm_total$total_loans
```

``` fansi
#> # Source:   SQL [?? x 2]
#> # Database: mysql  [guest@relational.fel.cvut.cz:3306/Financial_ijs]
#>    account_id total_amount
#>         <int>        <dbl>
#>  1          2        80952
#>  2         19        30276
#>  3         25        30276
#>  4         37       318480
#>  5         38       110736
#>  6         67       165960
#>  7         97       102876
#>  8        103       265320
#>  9        105       352704
#> 10        110       162576
#> # ℹ more rows
```

It is a *lazy table* powered by the
{[dbplyr](https://dbplyr.tidyverse.org/)} package: the results are not
materialized; instead, an SQL query is built and executed each time the
data is requested.

``` r
my_dm_total$total_loans %>%
  sql_render()
#> <SQL> SELECT `account_id`, SUM(`amount`) AS `total_amount`
#> FROM `loans`
#> GROUP BY `account_id`
```

Use [`compute()`](https://dplyr.tidyverse.org/reference/compute.html) on
a zoomed table to materialize it to a temporary table and avoid
recomputing. See
[`vignette("howto-dm-copy")`](https://dm.cynkra.com/dev/articles/howto-dm-copy.md)
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

my_dm_local$total_loans
```

``` fansi
#> # A tibble: 682 × 2
#>    account_id total_amount
#>         <int>        <dbl>
#>  1          2        80952
#>  2         19        30276
#>  3         25        30276
#>  4         37       318480
#>  5         38       110736
#>  6         67       165960
#>  7         97       102876
#>  8        103       265320
#>  9        105       352704
#> 10        110       162576
#> # ℹ 672 more rows
```

Use this method with caution. If you are not sure of the size of the
dataset you will be downloading, you can call
[`dm_nrow()`](https://dm.cynkra.com/dev/reference/dm_nrow.md) on your
`dm` for the row count of your data model’s tables.

``` r
my_dm_total %>%
  dm_nrow()
#>       loans    accounts total_loans 
#>         682        4500         682
```

## Persisting results

It is just as simple to move a local relational model into an RDBMS as
is using
[`collect()`](https://dplyr.tidyverse.org/reference/compute.html) to
download it. The method used is
[`copy_dm_to()`](https://dm.cynkra.com/dev/reference/copy_dm_to.md) and
it takes as arguments a database connection and a dm object. In the
example below, a local SQLite database is used to demonstrate it, but
{dm} is designed to work with any RDBMS supported by {DBI}.

``` r
destination_db <- DBI::dbConnect(RSQLite::SQLite())

deployed_dm <- copy_dm_to(destination_db, my_dm_local)

deployed_dm
```

``` fansi
#> ── Table source ───────────────────────────────────────────────────────────
#> src:  sqlite 3.51.2 []
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `loans`, `accounts`, `total_loans`
#> Columns: 13
#> Primary keys: 2
#> Foreign keys: 2
```

``` r
my_dm_local
```

``` fansi
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `loans`, `accounts`, `total_loans`
#> Columns: 13
#> Primary keys: 2
#> Foreign keys: 2
```

In the output, you can observe that the `src` for `deployed_dm` is the
SQLite database, while for `my_dm_local` the source is the local R
environment.

Persisting tables are covered in more detail in
[`vignette("howto-dm-copy")`](https://dm.cynkra.com/dev/articles/howto-dm-copy.md).

When done, do not forget to disconnect:

``` r
DBI::dbDisconnect(destination_db)
DBI::dbDisconnect(my_db)
```

## Conclusion

In this tutorial, we have demonstrated how simple it is to load a
database into a `dm` object and begin working with it. Currently,
loading a dm from most RDBMS requires you to manually set key relations,
but {dm} provides methods to make this straightforward. It is planned
that future versions of dm will support automatic key creation for more
RDBMS.

The next step is to read
[`vignette("howto-dm-copy")`](https://dm.cynkra.com/dev/articles/howto-dm-copy.md),
where copying your tables to and from an RDBMS is covered.
[`vignette("howto-dm-rows")`](https://dm.cynkra.com/dev/articles/howto-dm-rows.md)
discusses manipulation of individual rows in a database.

## Further reading

[`vignette("howto-dm-df")`](https://dm.cynkra.com/dev/articles/howto-dm-df.md)
– Is your data in local data frames? This article covers creating a data
model from your local data frames, including building the relationships
in your data model, verifying your model, and leveraging the power of
dplyr to operate on your data model.

[`vignette("howto-dm-theory")`](https://dm.cynkra.com/dev/articles/howto-dm-theory.md)
– Do you know all about data frames but very little about relational
data models? This quick introduction will walk you through the key
similarities and differences, and show you how to move from individual
data frames to a relational data model.
