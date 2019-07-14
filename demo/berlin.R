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
flights %>%
  select(year, month, day, carrier, tailnum, origin, dest)

# carrier column also present in `airlines`, this table contains
# additional information
airlines

flights %>%
  select(year, month, day, carrier, tailnum, origin, dest) %>%
  left_join(airlines)

# single source of truth: updating in one single location
airlines[airlines$carrier == "UA", "name"] <- "United broke my guitar"

# ...propagates to related records
flights %>%
  select(year, month, day, carrier, tailnum, origin, dest) %>%
  left_join(airlines)

# Same for airplanes
planes

flights %>%
  select(year, month, day, carrier, tailnum, origin, dest) %>%
  left_join(planes)

# Same for airports?
airports

try(
  flights %>%
    select(year, month, day, carrier, tailnum, origin, dest) %>%
    left_join(airports)
)

# Need to specify join variables!
flights %>%
  select(year, month, day, carrier, tailnum, origin, dest) %>%
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

# Determine key candidates
airports %>%
  dm::enum_pk_candidates()

# Why is name not a key?
airports %>%
  add_count(name) %>%
  filter(n > 1) %>%
  arrange(name)

## Data model
## --------------------------------------------------------------------

# Compound object: tables, relationships, data
dm::cdm_nycflights13(cycle = TRUE)

dm::cdm_nycflights13(cycle = TRUE) %>%
  dm::cdm_draw()

# Selection of tables
dm::cdm_nycflights13(cycle = TRUE) %>%
  dm::cdm_select(flights, airlines) %>%
  dm::cdm_draw()

dm::cdm_nycflights13(cycle = TRUE) %>%
  dm::cdm_select(airports, airlines) %>%
  dm::cdm_draw()

try(
  dm::cdm_nycflights13() %>%
    dm::cdm_select(bogus)
)

# Accessing tables
dm::cdm_nycflights13() %>%
  tbl("airlines")

# Table names
dm::cdm_nycflights13() %>%
  src_tbls()

# NB: [, $, [[ and names() also work

# Analogy: parallel vectors in the global environment
x <- 1:5
y <- x + 1
z <- x * y
tibble(x, y, z)

tibble(x = 1:5) %>%
  mutate(y = x + 1) %>%
  mutate(z = x * y)
