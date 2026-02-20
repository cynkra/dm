# dm_select_tbl() remembers all FKs

    Code
      dm_nycflights_small() %>% dm_add_fk(flights, origin, airports) %>%
        dm_select_tbl(airports, flights) %>% dm_paste()
    Message
      dm::dm(
        airports,
        flights,
      ) %>%
        dm::dm_add_pk(airports, faa) %>%
        dm::dm_add_fk(flights, dest, airports) %>%
        dm::dm_add_fk(flights, origin, airports)

