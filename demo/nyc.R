# Demo for presentation at the
# New York Open Statistical Programming Meetup,
# February 2020

# {dm}: Relational data models in R

options(tibble.print_min = 6)
options(tibble.print_max = 6)
options(rlang_backtrace_on_error = "none")
library(magrittr)





































library(nycflights13)

dm::dm_nycflights13(cycle = TRUE) %>%
  dm::dm_draw()


any(duplicated(airlines$carrier))


all(flights$carrier %in% airlines$carrier)











library(tidyverse)
library(nycflights13)


flights %>%
  left_join(airlines, by = "carrier") %>%
  select(name, carrier, year:dep_time)

# Use attributes from two tables after joining
flights %>%
  left_join(airlines, by = "carrier") %>%
  count(name, month) %>%
  ggplot() +
  aes(x = factor(month), y = name, fill = n) +
  geom_tile()

# Join many tables
flights_details <-
  flights %>%
  left_join(airlines, by = "carrier") %>%
  left_join(planes, by = "tailnum") %>%
  left_join(weather, by = c("origin", "time_hour")) %>%
  left_join(airports, by = c("origin" = "faa")) %>%
  left_join(airports, by = c("dest" = "faa"))

flights_details

##
##
##
## ...eventually
## -------------------------------------------------------
##
##
##

flights_details %>%
  count(is.na(lat.y), is.na(lon.y))

all(flights$dest %in% airports$faa)

##
##
##
## PROBLEMS (see appendix)
## -------------------------------------------------------
##
## - wrong keys
## - data mismatches
## - relationship unclear
## - combinatorial explosion
##
##
##



##
##
##
## Single source of truth
## -------------------------------------------------------
##
##
##

# Keep information in one place
flights %>%
  left_join(airlines) %>%
  select(name, carrier, tailnum)

# Update in one single location
airlines[airlines$carrier == "UA", "name"] <-
  "United broke my guitar"

airlines %>%
  filter(carrier == "UA")


flights %>%
  left_join(airlines) %>%
  select(name, carrier, tailnum)

rm(airlines)










library(dm)


dm_flights <- dm_nycflights13(cycle = TRUE)
dm_flights

dm_flights$airlines


dm_flights %>%
  names()

# NB: [ and [[ also work

# Visualize
dm_flights %>%
  dm_draw()



















































dm_flights <- dm_nycflights13()


dm_flights %>%
  dm_select_tbl(-weather)

# Selecting columns in tables
dm_flights %>%
  dm_select_tbl(-weather) %>%
  dm_select(
    flights,
    origin, dest, carrier, tailnum,
    year, month, day, dep_time
  )

# !!! Connect to a database !!!
try({
  con_pq <- DBI::dbConnect(RPostgres::Postgres())

  dm_flights <-
    dm_from_src(con_pq, schema = "nycflights13") %>%
    dm_rm_fk(flights, dest, airports)

  dm_flights
})

# Selecting more columns in tables
dm_flights %>%
  dm_select_tbl(-weather) %>%
  dm_select(
    flights,
    origin, dest, carrier, tailnum,
    year, month, day, dep_time
  ) %>%
  dm_select(planes, tailnum, year) %>%
  dm_select(airports, faa, lat, lon)

# Filtering rows in tables
dm_flights %>%
  dm_select_tbl(-weather) %>%
  dm_select(
    flights,
    origin, dest, carrier, tailnum,
    year, month, day, dep_time
  ) %>%
  dm_select(planes, tailnum, year) %>%
  dm_select(airports, faa, lat, lon) %>%
  dm_filter(flights, month == 2, day == 5)

# Filtering rows in other tables
dm_flights %>%
  dm_select_tbl(-weather) %>%
  dm_select(
    flights,
    origin, dest, carrier, tailnum,
    year, month, day, dep_time
  ) %>%
  dm_select(planes, tailnum, year) %>%
  dm_select(airports, faa, name, lat, lon) %>%
  dm_filter(flights, month == 2, day == 5) %>%
  dm_filter(airports, name == "John F Kennedy Intl") %>%
  dm_filter(airlines, name == "Delta Air Lines Inc.")

# Immutable object: need to assign a name to persist
dm_flights_jfk_today <-
  dm_flights %>%
  dm_select_tbl(-weather) %>%
  dm_select(
    flights,
    origin, dest, carrier, tailnum,
    year, month, day, dep_time
  ) %>%
  dm_select(planes, tailnum, year) %>%
  dm_select(airports, faa, name, lat, lon) %>%
  dm_filter(flights, month == 2, day == 4) %>%
  dm_filter(airports, name == "John F Kennedy Intl") %>%
  dm_filter(airlines, name == "Delta Air Lines Inc.") %>%
  dm_apply_filters()

dm_flights_jfk_today

dm_flights_jfk_today %>%
  dm_draw()

# Lazy tables
dm_flights_jfk_today %>%
  pull_tbl(flights)

try(
  dm_flights_jfk_today %>%
    pull_tbl(flights) %>%
    dbplyr::sql_render()
)

# Load the entire data model into memory
dm_flights_jfk_today_df <-
  dm_flights_jfk_today %>%
  collect()

dm_flights_jfk_today_df



##
##
##
## Joining two tables
## -------------------------------------------------------
##
##
##

dm_flights <- dm_nycflights13()
dm_flights %>%
  dm_draw()

dm_flights %>%
  dm_join_to_tbl(airlines, flights)

airlines_flights <-
  dm_flights %>%
  dm_join_to_tbl(airlines, flights)

airlines_flights

try(
  dm_flights %>%
    dm_join_to_tbl(airports, airlines)
)













dm_flights %>%
  dm_flatten_to_tbl(flights)


dm_flights %>%
  dm_select(planes, -year) %>%
  dm_rename(airlines, airline_name = name) %>%
  dm_flatten_to_tbl(flights)

# Separate access to automatic disambiguation:
dm_flights %>%
  dm_disambiguate_cols() %>%
  dm_draw()


##
##
##
## NEW NEW NEW: Data manipulation in a dm
## -------------------------------------------------------
##
##
##


# A single table of a `dm` can be activated (or zoomed to),
# and subsequently be manipulated by many {dplyr}-verbs.
# Eventually, either the original table can be updated
# or the manipulated table can be inserted as a new table.


# The print output for a `zoomed_dm` looks very much
# like that from a normal `tibble`.
dm_flights %>%
  dm_zoom_to(flights)


dm_flights %>%
  dm_zoom_to(flights) %>%
  mutate(
    am_pm_dep = if_else(dep_time < 1200, "am", "pm")
  ) %>%
  select(year:dep_time, am_pm_dep, everything())

# Put back into the dm:
dm_flights %>%
  dm_zoom_to(flights) %>%
  mutate(
    am_pm_dep = if_else(dep_time < 1200, "am", "pm")
  ) %>%
  select(year:dep_time, am_pm_dep, everything()) %>%
  dm_update_zoomed()

# Immutable objects, like in {dplyr}
dm_flights


dm_with_summary <-
  dm_flights %>%
  dm_zoom_to(flights) %>%
  count(origin) %>%
  dm_insert_zoomed("origin_count")

dm_with_summary$origin_count

dm_with_summary %>%
  dm_draw()



dm_flights %>%
  dm_zoom_to(flights) %>%
  count(carrier, origin) %>%
  dm_insert_zoomed("origin_carrier_count") %>%
  dm_draw()




























nycflights13_tbl <-
  dm(airlines, airports, flights, planes, weather)
nycflights13_tbl

nycflights13_tbl %>%
  dm_draw()



dm() %>%
  dm_add_tbl(airlines, airports, flights, planes, weather)


nycflights13_tbl %>%
  dm_draw()


nycflights13_pk <-
  nycflights13_tbl %>%
  dm_add_pk(planes, tailnum) %>%
  dm_add_pk(airports, faa) %>%
  dm_add_pk(airlines, carrier)

nycflights13_pk %>%
  dm_draw()





nycflights13_fk <-
  nycflights13_pk %>%
  dm_add_fk(flights, tailnum, planes) %>%
  dm_add_fk(flights, origin, airports) %>%
  dm_add_fk(flights, dest, airports) %>%
  dm_add_fk(flights, carrier, airlines, check = TRUE)

nycflights13_fk %>%
  dm_draw()


dm_get_available_colors()

nycflights13_base <-
  nycflights13_fk %>%
  dm_set_colors(
    blue = c(airlines, planes, airports)
  )

nycflights13_base %>%
  dm_draw()

nycflights13_base %>%
  dm_paste()

# !!! NEW: Examine all constraints of a dm !!!
nycflights13_base %>%
  dm_examine_constraints()






##
##
##
## USE CASE 3: Publish a dm to a relational database
##             (and load from it)
## -------------------------------------------------------
##
##
##




##
##
##
## Copy to database
## -------------------------------------------------------
##
##
##

# All operations are designed to work locally
# and on the database
dm_flights_sqlite <-
  dm_flights %>%
  copy_dm_to(
    dbplyr::src_memdb(), .,
    unique_table_names = TRUE, set_key_constraints = FALSE
  )

dm_flights_sqlite

dm_flights_sqlite %>%
  dm_draw()


dm_flights_sqlite %>%
  dm_flatten_to_tbl(flights) %>%
  dbplyr::sql_render()











try({
  dm_flights <- dm_nycflights13(cycle = TRUE)

  con_pq <- DBI::dbConnect(RPostgres::Postgres())

  # Off by default, to ensure that no tables are
  # accidentally deleted
  if (FALSE) {
    DBI::dbExecute(
      con_pq,
      "DROP SCHEMA IF EXISTS nycflights13 CASCADE"
    )
    DBI::dbExecute(
      con_pq,
      "CREATE SCHEMA nycflights13"
    )
  }

  # Ensure referential integrity (FIXME: Better way):
  dm_flights_ref <-
    dm_flights %>%

    # FIXME: Can't use cycles for now.
    dm_rm_fk(flights, origin, airports) %>%

    # Fill bad links with NA/NULL values:
    dm_zoom_to(flights) %>%
    left_join(planes, select = c(tailnum, type)) %>%
    mutate(
      tailnum =
        ifelse(is.na(type), NA_character_, tailnum)
    ) %>%
    dm_update_zoomed() %>%
    dm_add_fk(flights, tailnum, planes) %>%

    # Insert synthetic rows:
    dm_zoom_to(flights) %>%
    count(dest) %>%
    dm_insert_zoomed("dest") %>%
    dm_zoom_to(airports) %>%
    full_join(dest, select = dest) %>%
    dm_update_zoomed() %>%
    dm_select_tbl(-dest) %>%
    dm_add_fk(flights, origin, airports)

  qualified_names <-
    rlang::set_names(names(dm_flights_ref))
  qualified_names[] <- paste0(
    "nycflights13.", qualified_names
  )

  dm_flights_pq <-
    dm_flights_ref %>%
    copy_dm_to(
      con_pq, .,
      temporary = FALSE,
      table_names = qualified_names
    )

  dm_flights_from_pq <-
    dm_from_src(con_pq, schema = "nycflights13")

  dm_flights_from_pq %>%
    dm_draw()
})






##
##
##
##
## THREE USE CASES:
## -------------------------------------------------------
##
## 1. Work with a prepared dm object or connect to a
##    database
## 2. Build a data model for your own data
## 3. Publish a dm to a relational database (and load
##    from it)
## 4. Data documentation (?)
##
##
##
##











##
##
##
## Appendix
## ======================================================
##
##
##

##
##
##
## Analogy?
## -------------------------------------------------------
##
##
##

# Analogy: parallel vectors
# Multiple parallel vectors can be combined into a data
# frame.
# Multiple related tables can be combined into a dm.
x <- 1:5
x
y <- x + 1
y
z <- diff(y)
z

try(
  tibble(x = 1:5) %>%
    mutate(y = x + 1) %>%
    mutate(z = diff(y))
)











planes

flights_base <-
  flights %>%
  select(
    carrier, tailnum, origin, dest,
    year, month, day, time_hour
  )

flights_base %>%
  left_join(planes)

flights_base %>%
  left_join(planes) %>%
  count(is.na(type))


flights_base %>%
  left_join(planes, by = "tailnum")

flights_base %>%
  left_join(planes, by = "tailnum") %>%
  count(is.na(type))










flights_base %>%
  left_join(planes, by = "tailnum") %>%
  group_by(carrier) %>%
  summarize(mismatch_rate = mean(is.na(type))) %>%
  filter(mismatch_rate > 0) %>%
  ggplot(aes(x = carrier, y = mismatch_rate)) +
  geom_col()











airports

try(
  flights_base %>%
    left_join(airports)
)


flights_base %>%
  left_join(airports, by = c("origin" = "faa"))


rm(airlines)











t1 <- tibble(a = 1, b = letters[1:3])
t1
t2 <- tibble(a = 1, c = 1:2)
t2


left_join(t1, t2)





airlines %>%
  count(carrier)

airlines %>%
  count(carrier) %>%
  count(n)

planes %>%
  count(tailnum) %>%
  count(n)


planes %>%
  check_key(tailnum)

try(
  planes %>%
    check_key(engines)
)

airports %>%
  check_key(faa)


try(
  airports %>%
    check_key(name)
)


airports %>%
  enum_pk_candidates()


rm(t1, t2)















zoomed_weather <- dm_zoom_to(nycflights13_base, weather)
zoomed_weather



enum_pk_candidates(zoomed_weather)

enum_pk_candidates(zoomed_weather) %>%
  count(candidate)


zoomed_weather %>%
  unite(
    "slot_id", origin, year, month, day, hour,
    remove = FALSE
  ) %>%
  count(slot_id) %>%
  filter(n > 1)

zoomed_weather %>%
  count(origin, time_hour) %>%
  filter(n > 1)

zoomed_weather %>%
  count(origin, format(time_hour)) %>%
  filter(n > 1)


zoomed_weather %>%
  count(origin, format(time_hour, tz = "UTC")) %>%
  filter(n > 1)




nycflights13_weather_link <-
  zoomed_weather %>%
  mutate(time_hour_fmt = format(time_hour, tz = "UTC")) %>%
  unite("origin_slot_id", origin, time_hour_fmt) %>%
  # Update the original `weather` table
  dm_update_zoomed() %>%
  # Add a PK for the "enhanced" weather table
  dm_add_pk(weather, origin_slot_id)

nycflights13_weather_link$weather

nycflights13_weather_link %>%
  dm_draw()



nycflights13_weather_flights_link <-
  dm_zoom_to(nycflights13_weather_link, flights) %>%
  # same procedure with `flights` table
  mutate(time_hour_fmt = format(time_hour, tz = "UTC")) %>%
  # for flights we need to keep the column `origin`,
  # since it is a FK pointing to `airports`
  unite("origin_slot_id", origin, time_hour_fmt,
    remove = FALSE
  ) %>%
  select(origin_slot_id, everything(), -time_hour_fmt) %>%
  dm_update_zoomed()

# `dm_enum_fk_candidates()` of a `dm` gives info
# about potential FK columns from one table to another
dm_enum_fk_candidates(
  nycflights13_weather_flights_link,
  flights, weather
)

# well, it's almost perfect, let's add the FK anyway...

nycflights13_perfect <-
  nycflights13_weather_flights_link %>%
  dm_add_fk(flights, origin_slot_id, weather)

nycflights13_perfect %>%
  dm_draw()


nycflights13_perfect %>%
  dm_zoom_to(flights) %>%
  anti_join(weather) %>%
  count(origin_slot_id)
