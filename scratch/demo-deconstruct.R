# pkgload::load_all()
library(dm)
library(dplyr)

dm <- dm_nycflights13()

dm %>%
  dm_draw()

tbls <-
  dm %>%
  dm_get_tables(keyed = TRUE)

flights <- tbls$flights
airports <- tbls$airports

flights
airports

flights %>%
  left_join(airports)

by_origin <-
  flights %>%
  group_by(origin) %>%
  summarize(n = n()) %>%
  ungroup()

by_origin

result_dm <- dm(flights, airports, by_origin)
result_dm %>%
  dm_draw()
