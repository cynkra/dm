# Demo for presentation at the Zurich R meetup, September 2019

# {dm} facilitates working with multiple tables

options(tibble.print_min = 6)
options(tibble.print_max = 6)
options(rlang_backtrace_on_error = "none")











dm::dm_nycflights13(cycle = TRUE) %>%
  dm::dm_draw()


















library(nycflights13)


?flights

flights










library(tidyverse)
flights_base <-
  flights %>%
  select(year, month, day, carrier, tailnum, origin, dest, time_hour)
flights_base



airlines

flights_base %>%
  left_join(airlines)











any(duplicated(airlines$carrier))


all(flights$carrier %in% airlines$carrier)











airlines[airlines$carrier == "UA", "name"] <-
  "United broke my guitar"

airlines %>%
  filter(carrier == "UA")


flights_base %>%
  left_join(airlines)










flights_base %>%
  left_join(airlines, by = "carrier") %>%
  left_join(planes, by = "tailnum") %>%
  left_join(weather, by = c("origin", "time_hour")) %>%
  left_join(airports, by = c("origin" = "faa")) %>%
  left_join(airports, by = c("dest" = "faa"))
























library(dm)


dm_flights <- dm_nycflights13(cycle = TRUE)
dm_flights

dm_flights %>%
  dm_draw()


dm_flights %>%
  dm_select_tbl(flights, airlines) %>%
  dm_draw()

dm_flights %>%
  dm_select_tbl(airports, airlines) %>%
  dm_draw()

try(
  dm_flights %>%
    dm_select_tbl(bogus)
)


dm_flights %>%
  tbl("airlines")

# Table names
dm_flights %>%
  src_tbls()












dm_flights <- dm_nycflights13()
dm_flights %>%
  dm_draw()

dm_flights %>%
  dm_join_to_tbl(airlines, flights)

try(
  dm_flights %>%
    dm_join_to_tbl(airports, airlines)
)










dm_flights %>%
  dm_flatten_to_tbl(flights)











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
  dm_get_tables() %>%
  map(dbplyr::sql_render)

dm_flights_sqlite %>%
  dm_join_to_tbl(airlines, flights) %>%
  dbplyr::sql_render()

dm_flights_sqlite %>%
  dm_flatten_to_tbl(flights) %>%
  dbplyr::sql_render()


dm_flights_sqlite %>%
  dm_filter(airlines, name == "Delta Air Lines Inc.") %>%
  dm_filter(airports, name != "John F Kennedy Intl") %>%
  dm_filter(flights, day == 1) %>%
  tbl("flights")

# ... and the corresponding SQL statement and query plan
dm_flights_sqlite %>%
  dm_filter(airlines, name == "Delta Air Lines Inc.") %>%
  dm_filter(airports, name != "John F Kennedy Intl") %>%
  dm_filter(flights, day == 1) %>%
  tbl("flights") %>%
  dbplyr::sql_render()

##
##
##
## Filtering for data models
## --------------------------------------------------------------------
##
##
##

# Filtering on a table returns a dm object
# with the filter condition(s) stored
dm_flights %>%
  dm_filter(airlines, name == "Delta Air Lines Inc.")


dm_flights %>%
  dm_filter(airlines, name == "Delta Air Lines Inc.") %>%
  dm_filter(airports, name != "John F Kennedy Intl")


delta_non_jfk_january <-
  dm_flights %>%
  dm_filter(airlines, name == "Delta Air Lines Inc.") %>%
  dm_filter(airports, name != "John F Kennedy Intl") %>%
  dm_filter(planes, year < 2000) %>%
  dm_filter(flights, month == 1)
delta_non_jfk_january


delta_non_jfk_january %>%
  tbl("planes")



delta_non_jfk_january %>%
  dm_apply_filters() %>%
  dm_join_to_tbl(flights, airlines)

delta_non_jfk_january %>%
  dm_flatten_to_tbl(flights)














weather %>%
  enum_pk_candidates()

weather %>%
  enum_pk_candidates() %>%
  count(candidate)


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


weather %>%
  count(origin, format(time_hour, tz = "UTC")) %>%
  filter(n > 1)




weather_link <-
  weather %>%
  mutate(time_hour_fmt = format(time_hour, tz = "UTC")) %>%
  unite("origin_slot_id", origin, time_hour_fmt, remove = FALSE)

weather_link

flights_link <-
  flights %>%
  mutate(time_hour_fmt = format(time_hour, tz = "UTC")) %>%
  unite("origin_slot_id", origin, time_hour_fmt, remove = FALSE)

flights_link

# one option to create a `dm` is to use `as_dm()`:
nycflights13_tbl <- as_dm(list(
  airlines = airlines,
  airports = airports,
  flights = flights_link,
  planes = planes,
  weather = weather_link
))

nycflights13_tbl

nycflights13_tbl %>%
  dm_draw()


nycflights13_pk <-
  nycflights13_tbl %>%
  dm_add_pk(weather, origin_slot_id) %>%
  dm_add_pk(planes, tailnum) %>%
  dm_add_pk(airports, faa) %>%
  dm_add_pk(airlines, carrier)

nycflights13_pk %>%
  dm_draw()




nycflights13_fk <-
  nycflights13_pk %>%
  dm_add_fk(flights, origin_slot_id, weather) %>%
  dm_add_fk(flights, tailnum, planes) %>%
  dm_add_fk(flights, origin, airports) %>%
  dm_add_fk(flights, dest, airports) %>%
  dm_add_fk(flights, carrier, airlines)

nycflights13_fk %>%
  dm_draw()


dm_get_available_colors()

nycflights13_fk %>%
  dm_set_colors(
    airlines = , planes = , weather = , airports = "blue"
  ) %>%
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
  con_pq <- DBI::dbConnect(RPostgres::Postgres())

  # FIXME: Schema support

  # Off by default, to ensure that no tables are accidentally deleted
  if (FALSE) {
    walk(
      names(dm_flights),
      ~ DBI::dbExecute(
        con_pq,
        paste0("DROP TABLE IF EXISTS ", ., " CASCADE")
      )
    )
  }

  # Import
  dm_flights_pq <-
    dm_flights %>%
    dm_filter(planes, TRUE) %>%
    dm_filter(flights, month == 1, day == 1) %>%
    copy_dm_to(con_pq, ., temporary = FALSE)

  dm_flights_from_pq <-
    dm_learn_from_db(con_pq)

  dm_flights_from_pq %>%
    dm_draw()
})






















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
