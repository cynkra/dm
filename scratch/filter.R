dm_nyc_filtered <-
  dm_nycflights13() %>%
  dm_filter(airports, name == "John F Kennedy Intl")

dm_apply_filters_to_tbl(dm_nyc_filtered, flights)

dm_nycflights13() %>%
  dm_filter(airports, name == "John F Kennedy Intl") %>%
  dm_apply_filters()

# If you want to keep only those rows in the parent tables
# whose primary key values appear as foreign key values in
# `flights`, you can set a `TRUE` filter in `flights`:
dm_nycflights13() %>%
  dm_filter(flights, 1 == 1) %>%
  dm_applyp_filters() %>%
  dm_nrow()
# note that in this example, the only affected table is
# `airports` because the departure airports in `flights` are
# only the three New York airports.

dm_nycflights13() %>%
  dm_filter(flights, month == 3) %>%
  dm_apply_filters()

dm_nycflights13() %>%
  dm_filter(planes, engine %in% c("Reciprocating", "4 Cycle")) %>%
  compute()
dm_nycflights13() %>%
  dm_filter(flights, month == 3) %>%
  dm_apply_filters_to_tbl(planes)
