# Demo for presentation at the 16th Berlin R meetup

# {dm} facilitates working with multiple tables

options(tibble.print_min = 6)
options(tibble.print_max = 6)

##
##
##
## Why?
## --------------------------------------------------------------------
##
##
##

library(nycflights13)

# Example dataset: tables linked with each other
?flights
?airports
?airlines
?planes
?weather

library(tidyverse)
flights_base <-
  flights %>%
  select(year, month, day, carrier, tailnum, origin, dest)
flights_base

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

# Same for airplanes?
planes

flights_base %>%
  left_join(planes)

flights_base %>%
  left_join(planes) %>%
  count(is.na(type))

# Take a closer look at the join
flights_base %>%
  left_join(planes, by = "tailnum")

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

##
##
##
## Keys
## --------------------------------------------------------------------
##
##
##

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

# FIXME: add dm function that explains why not key candidate

# Why is name not a key candidate for airports?
try(
  airports %>%
    dm::check_key(name)
)

airports %>%
  add_count(name) %>%
  filter(n > 1) %>%
  arrange(name)

# Cleanup
rm(t1, t2)

##
##
##
## Data model
## --------------------------------------------------------------------
##
##
##

library(dm)

# Compound object: tables, relationships, data
dm_nycflights13(cycle = TRUE)

dm_nycflights13(cycle = TRUE) %>%
  dm_draw()

# Selection of tables
dm_nycflights13(cycle = TRUE) %>%
  dm_select_tbl(flights, airlines) %>%
  dm_draw()

dm_nycflights13(cycle = TRUE) %>%
  dm_select_tbl(airports, airlines) %>%
  dm_draw()

try(
  dm_nycflights13() %>%
    dm_select_tbl(bogus)
)

# Accessing tables
dm_nycflights13() %>%
  tbl("airlines")

# Table names
dm_nycflights13() %>%
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
  mutate(w = map(z, ~ runif(.)))

##
##
##
## Filtering for data models
## --------------------------------------------------------------------
##
##
##

dm_nycflights13()

# Filtering on a table returns a dm object with the filter condition(s) stored
(dm_nyc_filtered <-
  dm_nycflights13() %>%
  dm_filter(airlines, carrier == "AA"))

# Apply all filters and retrieve an "updated" `dm`
dm_nyc_filtered %>%
  dm_apply_filters()

# If a filter condition is phrased wrongly it will only fail, once the filter is being applied
(dm_nyc_fail <-
  dm_nycflights13() %>%
  dm_filter(airports, origin == "EWR"))
try(
  tbl(dm_nyc_fail, "flights")
)
# Mind: when accessing table from a `dm` (using one of: `tbl()`, `[[.dm()`, `$.dm()`),
# only the necessary filter conditions are applied:
tbl(dm_nyc_fail, "weather")

dm_nycflights13() %>%
  dm_filter(flights, origin == "EWR") %>%
  dm_apply_filters()

# ... which then can be filtered on another table
dm_nycflights13() %>%
  dm_filter(airlines, name == "American Airlines Inc.") %>%
  dm_filter(airports, name != "John F Kennedy Intl") %>%
  dm_apply_filters()

aa_non_jfk_january <-
  dm_nycflights13() %>%
  dm_filter(airlines, name == "American Airlines Inc.") %>%
  dm_filter(airports, name != "John F Kennedy Intl") %>%
  dm_filter(flights, month == 1) %>%
  dm_apply_filters()
aa_non_jfk_january

# ... and processed further
aa_non_jfk_january %>%
  tbl("planes")

##
##
##
## Copy to database
## --------------------------------------------------------------------
##
##
##

# FIXME: SQLite with many rows

# FIXME: Make work with planes table

# FIXME: remove all_connected = TRUE for now, redo example above

# All operations are designed to work locally and on the database
nycflights13_sqlite <-
  dm_nycflights13() %>%
  dm_select_tbl(-planes) %>%
  dm_filter(flights, month == 1) %>%
  dm_apply_filters() %>%
  copy_dm_to(dbplyr::src_memdb(), ., unique_table_names = TRUE)

nycflights13_sqlite

nycflights13_sqlite %>%
  dm_draw()

nycflights13_sqlite %>%
  dm_get_tables() %>%
  map(dbplyr::sql_render)

# Filtering on the database
nycflights13_sqlite %>%
  dm_filter(airlines, name == "American Airlines Inc.") %>%
  dm_filter(airports, name != "John F Kennedy Intl") %>%
  dm_filter(flights, day == 1) %>%
  tbl("flights")

# ... and the corresponding SQL statement
nycflights13_sqlite %>%
  dm_filter(airlines, name == "American Airlines Inc.") %>%
  dm_filter(airports, name != "John F Kennedy Intl") %>%
  dm_filter(flights, day == 1) %>%
  tbl("flights") %>%
  dbplyr::sql_render()

##
##
##
## Joining tables
## --------------------------------------------------------------------
##
##
##

dm_nycflights13() %>%
  dm_join_to_tbl(airlines, flights, join = left_join)

dm_nycflights13() %>%
  dm_join_to_tbl(flights, airlines, join = left_join)

nycflights13_sqlite %>%
  dm_join_to_tbl(airlines, flights, join = left_join)

aa_non_jfk_january %>%
  dm_join_to_tbl(flights, airlines, join = left_join)

# FIXME: Multi-joins

try(
  dm_nycflights13() %>%
    dm_join_to_tbl(airports, airlines, join = left_join)
)

try(
  dm_nycflights13() %>%
    dm_join_to_tbl(flights, airports, airlines, join = left_join)
)

##
##
##
## Build up data model from scratch
## --------------------------------------------------------------------
##
##
##

# Linking the weather table

# Determine key candidates
weather %>%
  enum_pk_candidates()

weather %>%
  enum_pk_candidates() %>%
  count(candidate)

# It's tricky:
weather %>%
  unite("slot_id", origin, year, month, day, hour, remove = FALSE) %>%
  count(slot_id) %>%
  filter(n > 1)

weather %>%
  count(origin, time_hour) %>%
  filter(n > 1)

weather %>%
  count(origin, format(time_hour)) %>%
  filter(n > 1)

# This looks like a good candidate:
weather %>%
  count(origin, format(time_hour, tz = "UTC")) %>%
  filter(n > 1)

# FIXME: Support compound keys (#3)

# Currently, we need to create surrogate keys:
weather_link <-
  weather %>%
  mutate(time_hour_fmt = format(time_hour, tz = "UTC")) %>%
  unite("origin_slot_id", origin, time_hour_fmt, remove = FALSE)

flights_link <-
  flights %>%
  mutate(time_hour_fmt = format(time_hour, tz = "UTC")) %>%
  unite("origin_slot_id", origin, time_hour_fmt, remove = FALSE)

# one option to create a `dm` is to use `as_dm()`:
nycflights13_dm <- as_dm(list(airlines = airlines, airports = airports, flights = flights_link, planes = planes, weather = weather_link))

# Copy to this environment
airlines_global <- airlines
airports_global <- airports
planes_global <- planes

global <-
  dm_from_src(src_df(env = .GlobalEnv))
global

global %>%
  dm_rename_tbl(
    airlines = airlines_global,
    airports = airports_global,
    planes = planes_global,
    flights = flights_link,
    weather = weather_link
  ) %>%
  dm_select_tbl(airlines, airports, planes, flights, weather)

# or better:
nycflights13_tbl <-
  global %>%
  dm_select_tbl(
    airlines = airlines_global,
    airports = airports_global,
    planes = planes_global,
    flights = flights_link,
    weather = weather_link
  )


nycflights13_tbl

nycflights13_tbl %>%
  dm_draw()

# Adding primary keys
nycflights13_pk <-
  nycflights13_tbl %>%
  dm_add_pk(weather, origin_slot_id) %>%
  dm_add_pk(planes, tailnum) %>%
  dm_add_pk(airports, faa) %>%
  dm_add_pk(airlines, carrier)

nycflights13_pk %>%
  dm_draw()

# FIXME: Model weak constraints, show differently in diagram (#4)

# Adding foreign keys
nycflights13_fk <-
  nycflights13_pk %>%
  dm_add_fk(flights, origin_slot_id, weather, check = FALSE) %>%
  dm_add_fk(flights, tailnum, planes, check = FALSE) %>%
  dm_add_fk(flights, origin, airports) %>%
  dm_add_fk(flights, dest, airports, check = FALSE) %>%
  dm_add_fk(flights, carrier, airlines)

nycflights13_fk %>%
  dm_draw()

# Color it!
dm_get_available_colors()

nycflights13_fk %>%
  dm_set_colors(airlines = , planes = , weather = , airports = "blue") %>%
  dm_draw()

##
##
##
## Import a dm from a database, including key constraints
## --------------------------------------------------------------------
##
##
##

try({
  # Import
  dm_pq <-
    dm_nycflights13() %>%
    dm_select_tbl(-planes) %>%
    dm_filter(flights, month == 1) %>%
    copy_dm_to(src_postgres(), ., temporary = FALSE)

  dm_from_pq <-
    dm_learn_from_db(src_postgres())
})
