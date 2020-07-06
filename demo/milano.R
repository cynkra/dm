# Demo for presentation at e-Rum in Milano,
# June 2020

# {dm}: Relational data models in R

# Slides at https://krlmlr.github.io/dm-slides/

##
##
##
## RELATIONAL DATA MODELS WITH R
## -------------------------------------------------------
##
##
##

# The dm package helps

## 1. **consume** data models
## 2. **build** data models
## 3. **deploy** data models

### (on database or locally)



## ----setup, include = FALSE----
library(tidyverse)
library(dbplyr)
library(dm)
set.seed(20200314)


## ----connect, cache = FALSE----
library(DBI) # <<

mydb <- dbConnect(
  RMariaDB::MariaDB(),
  username = "guest",
  password = "relational",
  dbname = "Financial_ijs",
  host = "relational.fit.cvut.cz"
)


## ----dm, cache = FALSE, echo = FALSE----
mydm <- dm_from_src(mydb, learn_keys = FALSE)


## ----echo = FALSE------------
financial_dm <- function(mydb) {
  mydm %>%
    dm_add_pk(districts, id) %>%
    dm_add_pk(accounts, id) %>%
    dm_add_pk(clients, id) %>%
    dm_add_pk(loans, id) %>%
    dm_add_pk(orders, id) %>%
    dm_add_pk(trans, id) %>%
    dm_add_pk(disps, id) %>%
    dm_add_pk(cards, id) %>%
    dm_add_fk(
      loans, account_id,
      accounts
    ) %>%
    dm_add_fk(
      orders, account_id,
      accounts
    ) %>%
    dm_add_fk(
      trans, account_id,
      accounts
    ) %>%
    dm_add_fk(
      disps, account_id,
      accounts
    ) %>%
    dm_add_fk(
      disps, client_id,
      clients
    ) %>%
    dm_add_fk(
      accounts,
      district_id, districts
    ) %>%
    dm_add_fk(
      clients,
      district_id, districts
    ) %>%
    dm_add_fk(
      cards, disp_id,
      disps
    ) %>%
    dm_rm_tbl(tkeys) %>%
    dm_set_colors(orange = accounts)
}


## ----dm-load, cache = FALSE----
my_dm <- financial_dm()


## ----dm-visualize------------
dm_draw(my_dm)


## ----dm-squash---------------
dm_squash_to_tbl(my_dm, loans)


## ----dm-squash-vis, echo = FALSE----
my_dm %>%
  dm_set_colors(darkblue = loans, darkgreen = c(accounts, districts)) %>%
  dm_draw()


## ----flights-----------------
library(nycflights13)

flights_dm <-
  dm(flights, planes) %>%
  dm_add_pk(planes, tailnum) %>%
  dm_add_fk(flights, tailnum, planes)


## ----flights-examine---------
dm_draw(flights_dm)


## ----sqlite, cache = FALSE, highlight.output = 2----
sqlite <- dbConnect(RSQLite::SQLite(), dbname = ":memory:")

flights_dm_production <- copy_dm_to(sqlite, flights_dm)
flights_dm_production
