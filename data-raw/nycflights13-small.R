flights <-
  nycflights13::flights %>%
  filter(day == 10, month %in% c(1, 2))

weather <-
  nycflights13::weather %>%
  filter(day == 10, month %in% c(1, 2))

airlines <-
  nycflights13::airlines %>%
  semi_join(flights, by = "carrier")

airports <-
  nycflights13::airports %>%
  left_join(flights %>% select(origin, origin_day = day), by = c("faa" = "origin")) %>%
  left_join(flights %>% select(dest, dest_day = day), by = c("faa" = "dest")) %>%
  filter(!is.na(origin_day) | !is.na(dest_day)) %>%
  select(-origin_day, -dest_day) %>%
  distinct()

planes <-
  nycflights13::planes %>%
  semi_join(flights, by = "tailnum")

data <- tibble::lst(flights, weather, airlines, airports, planes)

dir.create("inst/extdata", showWarnings = FALSE)
saveRDS(data, "inst/extdata/nycflights13-small.rds", compress = "gzip", version = 2)
