# Getting started with dm

In this article, we’re going show you how easy it is to move from
connecting to the database holding your data to producing the results
you need. It’s meant to be a quick and friendly introduction to {dm}, so
it is low on details and caveats. Links to detailed documentation are
provided at the end. (If your data is in data frames instead of a
database and you’re in a hurry, jump over to
[`vignette("howto-dm-df")`](https://dm.cynkra.com/dev/articles/howto-dm-df.md).)

## Creating a dm object

dm objects can be created from individual tables or loaded directly from
a relational data model on an RDBMS (relational database management
system).

For this demonstration, we’re going to work with a model hosted on a
public server. The first thing we need is a connection to the RDBMS
hosting the data.

``` r
library(RMariaDB)

fin_db <- dbConnect(
  MariaDB(),
  username = "guest",
  password = "ctu-relational",
  dbname = "Financial_ijs",
  host = "relational.fel.cvut.cz"
)
```

We create a dm object from an RDBMS using
[`dm_from_con()`](https://dm.cynkra.com/dev/reference/dm_from_con.md),
passing in the connection object we just created as the first argument.

``` r
library(dm)

fin_dm <- dm_from_con(fin_db)
```

``` fansi
#> Keys queried successfully.
#> ℹ Use `learn_keys = TRUE` to enforce querying keys and to mute this
#>   message.
```

``` r
fin_dm
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

The dm object interrogates the RDBMS for table and column information,
and primary and foreign keys. Currently, primary and foreign keys are
only available from SQL Server, Postgres and MariaDB.

## Selecting tables

The dm object can be accessed like a named list of tables:

``` r
names(fin_dm)
#> [1] "accounts"  "cards"     "clients"   "disps"     "districts" "loans"    
#> [7] "orders"    "tkeys"     "trans"
fin_dm$loans
```

``` fansi
#> # Source:   table<`Financial_ijs`.`loans`> [?? x 7]
#> # Database: mysql  [guest@relational.fel.cvut.cz:3306/Financial_ijs]
#>       id account_id date       amount duration payments status
#>    <int>      <int> <date>      <dbl>    <int>    <dbl> <chr> 
#>  1  4959          2 1994-01-05  80952       24     3373 A     
#>  2  4961         19 1996-04-29  30276       12     2523 B     
#>  3  4962         25 1997-12-08  30276       12     2523 A     
#>  4  4967         37 1998-10-14 318480       60     5308 D     
#>  5  4968         38 1998-04-19 110736       48     2307 C     
#>  6  4973         67 1996-05-02 165960       24     6915 A     
#>  7  4986         97 1997-08-10 102876       12     8573 A     
#>  8  4988        103 1997-12-06 265320       36     7370 D     
#>  9  4989        105 1998-12-05 352704       48     7348 C     
#> 10  4990        110 1997-09-08 162576       36     4516 C     
#> # ℹ more rows
```

``` r
dplyr::count(fin_dm$trans)
```

``` fansi
#> # Source:   SQL [?? x 1]
#> # Database: mysql  [guest@relational.fel.cvut.cz:3306/Financial_ijs]
#>         n
#>   <int64>
#> 1 1056320
```

Additionally, most `dm` functions are
[pipe-friendly](https://r4ds.had.co.nz/pipes.html) and support [tidy
evaluation](https://adv-r.hadley.nz/metaprogramming.html). We can use
`[` or the
[`dm_select_tbl()`](https://dm.cynkra.com/dev/reference/dm_select_tbl.md)
verb to derive a smaller dm with the `loans`, `accounts`, `districts`
and `trans` tables:

``` r
fin_dm_small <- fin_dm[c("loans", "accounts", "districts", "trans")]
fin_dm_small <-
  fin_dm %>%
  dm_select_tbl(loans, accounts, districts, trans)
```

## Linking tables by adding keys

In many cases,
[`dm_from_con()`](https://dm.cynkra.com/dev/reference/dm_from_con.md)
already returns a dm with all keys set. If not, dm allows us to define
primary and foreign keys ourselves. For this, we use
`learn_keys = FALSE` to obtain a `dm` object with only the tables.

``` r
library(dm)

fin_dm_small <-
  dm_from_con(fin_db, learn_keys = FALSE) %>%
  dm_select_tbl(loans, accounts, districts, trans)
```

In our data model, `id` columns uniquely identify records in the
`accounts` and `loans` tables, and was used as a primary key. A primary
key is defined with
[`dm_add_pk()`](https://dm.cynkra.com/dev/reference/dm_add_pk.md). Each
loan is linked to one account via the `account_id` column in the `loans`
table, the relationship is established with
[`dm_add_fk()`](https://dm.cynkra.com/dev/reference/dm_add_fk.md).

``` r
fin_dm_keys <-
  fin_dm_small %>%
  dm_add_pk(table = accounts, columns = id) %>%
  dm_add_pk(loans, id) %>%
  dm_add_fk(table = loans, columns = account_id, ref_table = accounts) %>%
  dm_add_pk(trans, id) %>%
  dm_add_fk(trans, account_id, accounts) %>%
  dm_add_pk(districts, id) %>%
  dm_add_fk(accounts, district_id, districts)
```

## Visualizing a data model

Having a diagram of the data model is the quickest way to verify we’re
on the right track. We can display a visual summary of the dm at any
time. The default is to display the table name, any defined keys, and
their links to other tables.

Visualizing the dm in its current state, we can see the keys we have
created and how they link the tables together. Color guides the eye.

``` r
fin_dm_keys %>%
  dm_set_colors(darkgreen = c(loans, accounts), darkblue = trans, grey = districts) %>%
  dm_draw()
```

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjYzcHQiIGhlaWdodD0iMTUwcHQiIHZpZXdib3g9IjAuMDAgMC4wMCAyNjMuMDAgMTUwLjAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIj48ZyBpZD0iZ3JhcGgwIiBjbGFzcz0iZ3JhcGgiIHRyYW5zZm9ybT0ic2NhbGUoMSAxKSByb3RhdGUoMCkgdHJhbnNsYXRlKDQgMTQ2KSI+PHRpdGxlPiUwPC90aXRsZT4KPGcgaWQ9ImFfZ3JhcGgwIj48YSB4bGluazp0aXRsZT0iRGF0YSBNb2RlbCI+Cjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iLTQsNCAtNCwtMTQ2IDI1OSwtMTQ2IDI1OSw0IC00LDQiPjwvcG9seWdvbj48L2E+CjwvZz48IS0tIGFjY291bnRzIC0tPjxnIGlkPSJhY2NvdW50cyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5hY2NvdW50czwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiMwMDY0MDAiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTA0LC02MSAxMDQsLTgxIDE2NCwtODEgMTY0LC02MSAxMDQsLTYxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxMDkuNTEwNSIgeT0iLTY2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iI2ZmZmZmZiI+YWNjb3VudHM8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2NjZTBjYyIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxMDQsLTQxIDEwNCwtNjEgMTY0LC02MSAxNjQsLTQxIDEwNCwtNDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjEwNiIgeT0iLTQ3LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmlkPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNjY2UwY2MiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTA0LC0yMSAxMDQsLTQxIDE2NCwtNDEgMTY0LC0yMSAxMDQsLTIxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxMDUuNjEzNiIgeT0iLTI2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+ZGlzdHJpY3RfaWQ8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjMDA0MjAwIiBzdHJva2Utb3BhY2l0eT0iMC42NjY2NjciIHBvaW50cz0iMTAzLC0yMCAxMDMsLTgyIDE2NSwtODIgMTY1LC0yMCAxMDMsLTIwIj48L3BvbHlnb24+PC9nPjwhLS0gZGlzdHJpY3RzIC0tPjxnIGlkPSJkaXN0cmljdHMiIGNsYXNzPSJub2RlIj48dGl0bGU+ZGlzdHJpY3RzPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iI2JlYmViZSIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIyMDQsLTQxIDIwNCwtNjEgMjUyLC02MSAyNTIsLTQxIDIwNCwtNDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjIwNS44MzY2IiB5PSItNDYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjMDAwMDAwIj5kaXN0cmljdHM8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2YyZjJmMiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIyMDQsLTIxIDIwNCwtNDEgMjUyLC00MSAyNTIsLTIxIDIwNCwtMjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjIwNiIgeT0iLTI3LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmlkPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzdlN2U3ZSIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjIwMywtMjAgMjAzLC02MiAyNTMsLTYyIDI1MywtMjAgMjAzLC0yMCI+PC9wb2x5Z29uPjwvZz48IS0tIGFjY291bnRzJiM0NTsmZ3Q7ZGlzdHJpY3RzIC0tPjxnIGlkPSJhY2NvdW50c18xIiBjbGFzcz0iZWRnZSI+PHRpdGxlPmFjY291bnRzOmRpc3RyaWN0X2lkLSZndDtkaXN0cmljdHM6aWQ8L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik0xNjQsLTMxQzE3Ny44ODg5LC0zMSAxODMuNjM5OCwtMzEgMTkzLjk2ODMsLTMxIiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxOTQsLTM0LjUwMDEgMjA0LC0zMSAxOTQsLTI3LjUwMDEgMTk0LC0zNC41MDAxIj48L3BvbHlnb24+PC9nPjwhLS0gbG9hbnMgLS0+PGcgaWQ9ImxvYW5zIiBjbGFzcz0ibm9kZSI+PHRpdGxlPmxvYW5zPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iIzAwNjQwMCIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLjUsLTEyMSAxLjUsLTE0MSA2Ni41LC0xNDEgNjYuNSwtMTIxIDEuNSwtMTIxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxOS4yMjUxIiB5PSItMTI2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iI2ZmZmZmZiI+bG9hbnM8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2NjZTBjYyIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLjUsLTEwMSAxLjUsLTEyMSA2Ni41LC0xMjEgNjYuNSwtMTAxIDEuNSwtMTAxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzLjUiIHk9Ii0xMDcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+aWQ8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2NjZTBjYyIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLjUsLTgxIDEuNSwtMTAxIDY2LjUsLTEwMSA2Ni41LC04MSAxLjUsLTgxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzLjI4NzUiIHk9Ii04Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmFjY291bnRfaWQ8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjMDA0MjAwIiBzdHJva2Utb3BhY2l0eT0iMC42NjY2NjciIHBvaW50cz0iMCwtODAgMCwtMTQyIDY3LC0xNDIgNjcsLTgwIDAsLTgwIj48L3BvbHlnb24+PC9nPjwhLS0gbG9hbnMmIzQ1OyZndDthY2NvdW50cyAtLT48ZyBpZD0ibG9hbnNfMSIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5sb2FuczphY2NvdW50X2lkLSZndDthY2NvdW50czppZDwvdGl0bGU+CjxwYXRoIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgZD0iTTY2LjUsLTkxQzg2LjY4MDIsLTkxIDgyLjQ0MjQsLTYzLjU2ODQgOTQuMjI4OSwtNTQuMTM4NyIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iOTUuNTQ5NiwtNTcuMzkwNyAxMDQsLTUxIDkzLjQwODcsLTUwLjcyNjEgOTUuNTQ5NiwtNTcuMzkwNyI+PC9wb2x5Z29uPjwvZz48IS0tIHRyYW5zIC0tPjxnIGlkPSJ0cmFucyIgY2xhc3M9Im5vZGUiPjx0aXRsZT50cmFuczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiMwMDAwOGIiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC00MSAxLjUsLTYxIDY2LjUsLTYxIDY2LjUsLTQxIDEuNSwtNDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjIwLjM5NDgiIHk9Ii00Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiNmZmZmZmYiPnRyYW5zPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNjY2NjZTciIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC0yMSAxLjUsLTQxIDY2LjUsLTQxIDY2LjUsLTIxIDEuNSwtMjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjMuNSIgeT0iLTI3LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmlkPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNjY2NjZTciIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC0xIDEuNSwtMjEgNjYuNSwtMjEgNjYuNSwtMSAxLjUsLTEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjMuMjg3NSIgeT0iLTYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5hY2NvdW50X2lkPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzAwMDA1YyIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjAsMCAwLC02MiA2NywtNjIgNjcsMCAwLDAiPjwvcG9seWdvbj48L2c+PCEtLSB0cmFucyYjNDU7Jmd0O2FjY291bnRzIC0tPjxnIGlkPSJ0cmFuc18xIiBjbGFzcz0iZWRnZSI+PHRpdGxlPnRyYW5zOmFjY291bnRfaWQtJmd0O2FjY291bnRzOmlkPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNNjYuNSwtMTFDODYuNjgwMiwtMTEgODIuNDQyNCwtMzguNDMxNiA5NC4yMjg5LC00Ny44NjEzIiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSI5My40MDg3LC01MS4yNzM5IDEwNCwtNTEgOTUuNTQ5NiwtNDQuNjA5MyA5My40MDg3LC01MS4yNzM5Ij48L3BvbHlnb24+PC9nPjwvZz48L3N2Zz4=)

## Accessing a data model as a table

If we want to perform modeling or analysis on this relational model, we
need to transform it into a tabular format that R functions can work
with. With the argument `recursive = TRUE`,
[`dm_flatten_to_tbl()`](https://dm.cynkra.com/dev/reference/dm_flatten_to_tbl.md)
will automatically follow foreign keys across tables to gather all the
available columns into a single table.

``` r
fin_dm_keys %>%
  dm_flatten_to_tbl(loans, .recursive = TRUE)
#> Renaming ambiguous columns: %>%
#>   dm_rename(loans, date.loans = date) %>%
#>   dm_rename(accounts, date.accounts = date)
```

``` fansi
#> # Source:   SQL [?? x 25]
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
#> # ℹ 17 more variables: frequency <chr>, date.accounts <date>, A2 <chr>,
#> #   A3 <chr>, A4 <int>, A5 <int>, A6 <int>, A7 <int>, A8 <int>, A9 <int>,
#> #   A10 <dbl>, A11 <int>, A12 <dbl>, A13 <dbl>, A14 <int>, A15 <int>,
#> #   A16 <int>
```

Apart from the rows printed above, no data has been fetched from the
database. Use
[`select()`](https://dplyr.tidyverse.org/reference/select.html) to
reduce the number of columns fetched, and
[`collect()`](https://dplyr.tidyverse.org/reference/compute.html) to
retrieve the entire result for local processing.

``` r
loans_df <-
  fin_dm_keys %>%
  dm_flatten_to_tbl(loans, .recursive = TRUE) %>%
  select(id, amount, duration, A3) %>%
  collect()
#> Renaming ambiguous columns: %>%
#>   dm_rename(loans, date.loans = date) %>%
#>   dm_rename(accounts, date.accounts = date)

model <- lm(amount ~ duration + A3, data = loans_df)

model
#> 
#> Call:
#> lm(formula = amount ~ duration + A3, data = loans_df)
#> 
#> Coefficients:
#>     (Intercept)         duration   A3east Bohemia  A3north Bohemia  
#>           10196             4109           -16204           -28933  
#> A3north Moravia         A3Prague  A3south Bohemia  A3south Moravia  
#>            1467             4044            -1896           -12463  
#>  A3west Bohemia  
#>          -28572
```

## Operations on table data within a dm

We don’t need to take the extra step of exporting the data to work with
it. Through the dm object, we have complete access to dplyr’s data
manipulation verbs. These operate on the data within individual tables.

To work with a particular table we use
[`dm_zoom_to()`](https://dm.cynkra.com/dev/reference/dm_zoom_to.md) to
set the context to our chosen table. Then we can perform any of the
dplyr operations we want.

``` r
fin_dm_total <-
  fin_dm_keys %>%
  dm_zoom_to(loans) %>%
  group_by(account_id) %>%
  summarize(total_amount = sum(amount, na.rm = TRUE)) %>%
  ungroup() %>%
  dm_insert_zoomed("total_loans")

fin_dm_total$total_loans
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

Note that, in the above example, we use
[`dm_insert_zoomed()`](https://dm.cynkra.com/dev/reference/dm_zoom_to.md)
to add the results as a new table to our data model. This table is
temporary and will be deleted when our session ends. If you want to make
permanent changes to your data model on an RDBMS, please see the
“Persisting results” section in
[`vignette("howto-dm-db")`](https://dm.cynkra.com/dev/articles/howto-dm-db.md).

## Checking constraints

It’s always smart to check that your data model follows its
specifications. When building our own model or changing existing models
by adding tables or keys, it is even more important that the new model
is validated.

[`dm_examine_constraints()`](https://dm.cynkra.com/dev/reference/dm_examine_constraints.md)
checks all primary and foreign keys and reports if they violate their
expected constraints.

``` r
fin_dm_total %>%
  dm_examine_constraints()
```

``` fansi
#> ℹ All constraints satisfied.
```

For more on constraint checking, including cardinality, finding
candidate columns for keys, and normalization, see
[`vignette("tech-dm-low-level")`](https://dm.cynkra.com/dev/articles/tech-dm-low-level.md).

## Next Steps

Now that you have been introduced to the basic operation of dm, the next
step is to learn more about the dm methods that your particular use case
requires.

Is your data in an RDBMS? Then move on to
[`vignette("howto-dm-db")`](https://dm.cynkra.com/dev/articles/howto-dm-db.md)
for a more detailed look at working with an existing relational data
model.

If your data is in data frames, then you want to read
[`vignette("howto-dm-df")`](https://dm.cynkra.com/dev/articles/howto-dm-df.md)
next.

If you would like to know more about relational data models in order to
get the most out of dm, check out
[`vignette("howto-dm-theory")`](https://dm.cynkra.com/dev/articles/howto-dm-theory.md).

If you’re familiar with relational data models, but want to know how to
work with them in dm, then any of
[`vignette("tech-dm-join")`](https://dm.cynkra.com/dev/articles/tech-dm-join.md),
[`vignette("tech-dm-filter")`](https://dm.cynkra.com/dev/articles/tech-dm-filter.md),
or
[`vignette("tech-dm-zoom")`](https://dm.cynkra.com/dev/articles/tech-dm-zoom.md)
is a good next step.

## Standing on the shoulders of giants

The {dm} package follows the tidyverse principles:

- `dm` objects are immutable (your data will never be overwritten in
  place)
- most functions used on `dm` objects are pipeable (i.e., return new
  `dm` or table objects)
- tidy evaluation is used (unquoted function arguments are supported)

The {dm} package builds heavily upon the [{datamodelr}
package](https://github.com/bergant/datamodelr), and upon the
[tidyverse](https://www.tidyverse.org/). We’re looking forward to a good
collaboration!

The [{polyply} package](https://github.com/russHyde/polyply) has a
similar intent with a slightly different interface.

The [{data.cube} package](https://github.com/jangorecki/data.cube) has
quite the same intent using `array`-like interface.

Articles in the [{rquery} package](https://github.com/WinVector/rquery)
discuss [join
controllers](https://github.com/WinVector/rquery/blob/master/extras/JoinController.md)
and [join dependency
sorting](https://github.com/WinVector/rquery/blob/master/extras/DependencySorting.md),
with the intent to move the declaration of table relationships from code
to data.

The [{tidygraph} package](https://github.com/thomasp85/tidygraph) stores
a network as two related tables of `nodes` and `edges`, compatible with
{dplyr} workflows.

In object-oriented programming languages, [object-relational
mapping](https://en.wikipedia.org/wiki/Object-relational_mapping) is a
similar concept that attempts to map a set of related tables to a class
hierarchy.
