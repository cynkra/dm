# Demo for presentation at the 16th Berlin R meetup

# {dm} facilitates working with multiple tables

## Why?
## --------------------------------------------------------------------

library(nycflights13)

# Example dataset: tables linked with each other
?flights
?airports
?airlines

library(tidyverse)
flights_base <-
  flights %>%
  select(year, month, day, carrier, tailnum, origin, dest)

# carrier column also present in `airlines`, this table contains
# additional information
airlines

flights_base %>%
  left_join(airlines)

# single source of truth: updating in one single location
airlines[airlines$carrier == "UA", "name"] <- "United broke my guitar"

# ...propagates to related records
flights_base %>%
  left_join(airlines)

# Same for airplanes
planes

flights_base %>%
  left_join(planes)

# Same for airports?
airports

try(
  flights_base %>%
    left_join(airports)
)

# Need to specify join variables!
flights_base %>%
  left_join(airports, by = c("origin" = "faa"))

# cleanup
rm(airlines)

## Keys
## --------------------------------------------------------------------

# Row identifiers
t1 <- tibble(a = 1, b = letters[1:3])
t1
t2 <- tibble(a = 1, c = 1:2)
t2

# What happens here?
left_join(t1, t2)

# When joining, the column(s) must be unique in at least one
# participating table!

# Ensure uniqueness:
airlines %>%
  count(carrier)

airlines %>%
  count(carrier) %>%
  count(n)

planes %>%
  count(tailnum) %>%
  count(n)

# dm shortcut:
planes %>%
  dm::check_key(tailnum)

try(
  planes %>%
    dm::check_key(engines)
)

airports %>%
  dm::check_key(faa)

## Data model
## --------------------------------------------------------------------

library(dm)

# Compound object: tables, relationships, data
cdm_nycflights13(cycle = TRUE)

cdm_nycflights13(cycle = TRUE) %>%
  cdm_draw()

# Selection of tables
cdm_nycflights13(cycle = TRUE) %>%
  cdm_select_tbl(flights, airlines) %>%
  cdm_draw()

cdm_nycflights13(cycle = TRUE) %>%
  cdm_select_tbl(airports, airlines) %>%
  cdm_draw()

try(
  cdm_nycflights13() %>%
    cdm_select_tbl(bogus)
)

# Accessing tables
cdm_nycflights13() %>%
  tbl("airlines")

# Table names
cdm_nycflights13() %>%
  src_tbls()

# NB: [, $, [[ and names() also work

# Analogy: parallel vectors in the global environment
x <- 1:5
y <- x + 1
z <- x * y
w <- map(z, ~ runif(.))
tibble(x, y, z, w)

tibble(x = 1:5) %>%
  mutate(y = x + 1) %>%
  mutate(z = x * y) %>%
  mutate(w = vctrs::list_of(!!!map(z, ~ runif(.))))

## Operations on the data model
## --------------------------------------------------------------------

cdm_nycflights13()

cdm_nycflights13() %>%
  cdm_filter(airlines, carrier == "AA")

cdm_nycflights13() %>%
  cdm_filter(airlines, carrier == "AA") %>%
  cdm_filter(airports, faa != "JFK")

cdm_nycflights13() %>%
  cdm_filter(airlines, carrier == "AA") %>%
  cdm_filter(airports, faa != "JFK") %>%
  cdm_filter(flights, month == 1)

cdm_nycflights13() %>%
  cdm_filter(airlines, carrier == "AA") %>%
  cdm_filter(airports, faa != "JFK") %>%
  cdm_filter(flights, month == 1) %>%
  tbl("planes")

# - cdm_join_tbl()

## Build up data model from scratch
## --------------------------------------------------------------------

# - cdm_add_pk()
# - cdm_add_fk()

# Determine key candidates
airports %>%
  enum_pk_candidates()

# Why is name not a key?
airports %>%
  add_count(name) %>%
  filter(n > 1) %>%
  arrange(name)

## Link weather table
## --------------------------------------------------------------------

# time_hour is a key to the time_slots table, how to decompose?

## Copy to database
## --------------------------------------------------------------------

