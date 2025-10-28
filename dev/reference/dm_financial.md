# Creates a dm object for the Financial data

`dm_financial()` creates an example
[`dm`](https://dm.cynkra.com/dev/reference/dm.md) object from the tables
at https://relational.fel.cvut.cz/dataset/Financial. The connection is
established once per session, subsequent calls return the same
connection.

`dm_financial_sqlite()` copies the data to a temporary SQLite database.
The data is downloaded once per session, subsequent calls return the
same database. The `trans` table is excluded due to its size.

## Usage

``` r
dm_financial()

dm_financial_sqlite()
```

## Value

A `dm` object.

## Examples

``` r
dm_financial() %>%
  dm_draw()
%0


accounts
accountsiddistrict_iddistricts
districtsidaccounts:district_id->districts:id
cards
cardsiddisp_iddisps
dispsidclient_idaccount_idcards:disp_id->disps:id
clients
clientsiddisps:account_id->accounts:id
disps:client_id->clients:id
loans
loansidaccount_idloans:account_id->accounts:id
orders
ordersidaccount_idorders:account_id->accounts:id
tkeys
tkeystrans
transidaccount_idtrans:account_id->accounts:id
```
