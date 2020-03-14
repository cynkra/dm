# Demo for presentation at the satRday Neuch^atel,
# March 2020

# {dm}: Relational data models in R

options(tibble.print_min = 6)
options(tibble.print_max = 6)
options(rlang_backtrace_on_error = "none")
library(magrittr)

##
##
##
## RELATIONAL DATA MODELS WITH R
## -------------------------------------------------------
##
##
##



# Take home messages

## The dm package helps
## 1. **use** data models
## 2. **build** data models
## 3. **deploy** data models

### (on database or locally)

options(tibble.print_min = 6)
options(tibble.print_max = 6)
set.seed(20200314)


## ----connect, cache = FALSE------------------------------------
library(DBI) # <<

mydb <- dbConnect(
  RMariaDB::MariaDB(),
  user = "guest",
  password = "relational",
  dbname = "Financial_ijs",
  host = "relational.fit.cvut.cz"
)


## ----list-tables-----------------------------------------------
dbListTables(mydb)


## ----load-table, highlight.output = 1--------------------------
loans <- dbReadTable(mydb, "loans")

library(tidyverse)
as_tibble(loans)


## ----lazy-table, highlight.output = 2:3------------------------
library(dbplyr) # <<
loans <- tbl(mydb, "loans")
loans


## ----eval = FALSE----------------------------------------------
## accounts <- tbl(mydb, "accounts")
## cards <- tbl(mydb, "cards")
## clients <- tbl(mydb, "clients")
## disps <- tbl(mydb, "disps")
## districts <- tbl(mydb, "districts")
## loans <- tbl(mydb, "loans")
## orders <- tbl(mydb, "orders")
## tkeys <- tbl(mydb, "tkeys")
## trans <- tbl(mydb, "trans")
## ...
## ...
## ...
## ...
## ...
## ...
## ...
## ...
## ...
## ...
## ...
## ...
## ...


## ----dm-object, highlight.output = 2, cache = FALSE------------
library(dm)
dm <- dm_from_src(mydb)
dm


## ----dm-container----------------------------------------------
names(dm)
dm$accounts


## ----dm-download, highlight.output = 1-------------------------
dm_local <-
  dm %>%
  collect()
dm_local$accounts


## ----dm-download-size------------------------------------------
object.size(dm_local)


## ----dm-pk, cache = FALSE--------------------------------------
dm_pk <-
  dm_local %>%
  dm_add_pk(districts, id) %>%
  dm_add_pk(accounts, id) %>%
  dm_add_pk(clients, id) %>%
  dm_add_pk(loans, id) %>%
  dm_add_pk(orders, id) %>%
  dm_add_pk(trans, id) %>%
  dm_add_pk(disps, id) %>%
  dm_add_pk(cards, id)


## ----dm-pk-out, highlight.output = 6---------------------------
dm_pk


## ----dm-fk, cache = FALSE--------------------------------------
dm_fk <-
  dm_pk %>% # <<
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
  )


## ----dm-fk-out, highlight.output = 7---------------------------
dm_fk


## ----dm-visualize----------------------------------------------
dm_fk %>%
  dm_draw()


## ----dm-tweak--------------------------------------------------
dm_fk %>%
  dm_rm_tbl(tkeys) %>%
  dm_set_colors(green = loans, red = trans, orange = districts) %>%
  dm_draw()


## ----dm-immutable, highlight.output = 4:5----------------------
dm_fk


## ----dm-tweak-assign, highlight.output = 4:5-------------------
dm_tweaked <- # <<
  dm_fk %>%
  dm_rm_tbl(tkeys) %>%
  dm_set_colors(green = loans, red = trans, orange = districts)
dm_tweaked # <<


## ----dm-constraints--------------------------------------------
dm_fk %>%
  dm_examine_constraints()
dm_nycflights13() %>%
  dm_examine_constraints()


## ----dm-flatten------------------------------------------------
dm_fk %>%
  dm_flatten_to_tbl(loans)


## ----starwars-show---------------------------------------------
starwars


## ----starwars-pk-----------------------------------------------
starwars %>%
  select_if(~ !is.list(.)) %>%
  enum_pk_candidates()


## ----starwars-nested-------------------------------------------
starwars %>%
  select(name, films)


## ----starwars-nested-expand------------------------------------
characters_films <-
  starwars %>%
  select(name, films) %>%
  unnest(films) %>%
  rename(film = films)
characters_films


## ----starwars-films--------------------------------------------
films <-
  characters_films %>%
  distinct(film) %>%
  mutate(year = round(runif(7, max = 40) + 1980))

films


## ----starwars-dm-create----------------------------------------
characters <-
  starwars %>%
  select(-films)

dm_starwars <-
  dm( # <<
    characters,
    films,
    characters_films
  ) %>%
  dm_add_pk(characters, name) %>%
  dm_add_pk(films, film) %>%
  dm_add_fk(
    characters_films, name,
    characters
  ) %>%
  dm_add_fk(characters_films, film, films)

dm_starwars %>%
  dm_examine_constraints()


## ----starwars-dm-draw------------------------------------------
dm_starwars %>%
  dm_draw()


## ----starwars-dm-clean-----------------------------------------
dm_starwars_clean <-
  dm_starwars %>%
  dm_zoom_to(characters) %>%
  select_if(~ !is.list(.)) %>% # <<
  dm_update_zoomed()

dm_starwars_clean$characters


## ----sqlite, cache = FALSE-------------------------------------
sqlite <- dbConnect(RSQLite::SQLite(), dbname = ":memory:")

dm_starwars_production <- copy_dm_to(sqlite, dm_starwars_clean)
dm_starwars_production


## ----sqlite-examine, highlight.output = 2----------------------
dm_starwars_production %>%
  dm_examine_constraints()
