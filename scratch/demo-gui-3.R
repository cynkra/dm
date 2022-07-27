library(conflicted)
library(dm)
library(tidyverse)

dm <- dm_nycflights13(cycle = TRUE)
dm
dm_deconstruct(dm)

airlines <- pull_tbl(dm, "airlines", keyed = TRUE)
airports <- pull_tbl(dm, "airports", keyed = TRUE)
flights <- pull_tbl(dm, "flights", keyed = TRUE)
planes <- pull_tbl(dm, "planes", keyed = TRUE)
weather <- pull_tbl(dm, "weather", keyed = TRUE)

dm(airlines, airports, flights, planes, weather)

by_origin <-
  flights %>%
  group_by(origin) %>%
  summarize(n = n(), mean_arr_delay = mean(arr_delay)) %>%
  ungroup()

dm(airlines, airports, flights, planes, weather, by_origin) %>%
  dm_draw()
