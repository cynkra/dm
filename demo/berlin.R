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

# Need to specify join variables
flights %>%
  select(year, month, day, carrier, tailnum, origin, dest) %>%
  left_join(airports, by = c("origin" = "faa"))

# Ensure uniqueness
airlines %>%
  count(carrier)

airlines %>%
  count(carrier) %>%
  count(n)

planes %>%
  count(tailnum) %>%
  count(n)

# dm shortcut
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
  dm::pk_candidates(faa)

# cleanup
rm(airlines)

