test_that("unique keys", {
  expect_snapshot({
    nyc_1_uk <- dm_add_uk(
      dm_nycflights_small(),
      flights,
      everything()
    )

    # add 1 UK
    nyc_1_uk %>%
      dm_get_all_uks()
    # add 2 UK to same table and 1 to another table
    nyc_1_uk %>%
      dm_add_uk(
        flights,
        c(origin, dest, time_hour)
      ) %>%
      dm_add_uk(
        planes,
        c(year, manufacturer, model)
      ) %>%
      dm_get_all_uks()

    # add 2 UK to same table and 1 to another table and remove 1 of the 2 for the first table
    nyc_1_uk %>%
      dm_add_uk(
        flights,
        c(origin, dest, time_hour)
      ) %>%
      dm_add_uk(
        planes,
        c(year, manufacturer, model)
      ) %>%
      dm_rm_uk(flights, c(origin, dest, time_hour)) %>%
      dm_get_all_uks()

    # add 2 UK to same table and 1 to another table and remove 1 of the 2 for
    # the first table using the tidyselect function used to create the UK
    nyc_1_uk %>%
      dm_add_uk(
        flights,
        c(origin, dest, time_hour)
      ) %>%
      dm_add_uk(
        planes,
        c(year, manufacturer, model)
      ) %>%
      dm_rm_uk(flights, everything()) %>%
      dm_get_all_uks()

    # dm_rm_uk()
    nyc_1_uk %>%
      dm_rm_uk() %>%
      dm_get_all_uks()
    nyc_1_uk %>%
      dm_rm_uk(flights) %>%
      dm_get_all_uks()
    nyc_1_uk %>%
      dm_rm_uk(flights, everything()) %>%
      dm_get_all_uks()

    # test for code generation:
    # add 2 UK to same table and 1 of length > 1 to another table and remove all UKs
    nyc_1_uk %>%
      dm_add_uk(
        flights,
        c(origin, dest, time_hour)
      ) %>%
      dm_add_uk(
        planes,
        c(year, manufacturer, model)
      ) %>%
      dm_rm_uk() %>%
      dm_get_all_uks()

    # test for code generation:
    # add 2 UK to same table and 1 of length 1  to another table and remove all UKs
    nyc_1_uk %>%
      dm_add_uk(
        flights,
        c(origin, dest, time_hour)
      ) %>%
      dm_add_uk(
        planes,
        manufacturer
      ) %>%
      dm_rm_uk() %>%
      dm_get_all_uks()

    # dm_examine_constraints()
    dm_examine_constraints(
      dm_nycflights_small() %>%
        dm_add_uk(
          planes,
          c(year, manufacturer, model)
        )
    )

    dm_add_fk(
      dm_nycflights_small(),
      flights,
      time_hour,
      weather,
      time_hour
    ) %>%
      dm_rm_uk(weather, time_hour) %>%
      dm_get_all_uks()

    # key tracking needs to work also for UKs
    dm_rename(dm_for_filter(), tf_6, p = n) %>% dm_get_all_uks()
    dm_rename(dm_for_filter(), tf_6, p = n) %>% dm_get_all_fks()
    dm_select(dm_for_filter(), tf_6, -n) %>% dm_get_all_uks()
    dm_select(dm_for_filter(), tf_6, -n) %>% dm_get_all_fks()

    # test table arg for dm_get_all_uks()
    nyc_1_uk %>%
      dm_get_all_uks("flights")

    nyc_1_uk %>%
      dm_get_all_uks("airports")
  })

  expect_snapshot_error(
    # failing check upon addition of UK
    dm_add_uk(
      dm_nycflights_small(),
      planes,
      c(year, manufacturer, model),
      check = TRUE
    ),
    class = dm_error("not_unique_key")
  )

  expect_snapshot_error(
    # trying to add a UK for which a PK already exists
    dm_add_uk(
      dm_nycflights_small(),
      airlines,
      carrier,
    ),
    class = dm_error("no_uk_if_pk")
  )

  expect_snapshot_error(
    # trying to request a table not part of the dm
    nyc_1_uk %>%
      dm_get_all_uks("timetable"),
    class = dm_error("table_not_in_dm")
  )

  expect_snapshot_error(
    # trying to request 2 tables that are not part of the dm and a few others
    nyc_1_uk %>%
      dm_get_all_uks(c("timetable", "weather", "flights", "tabletime")),
    class = dm_error("table_not_in_dm")
  )

  expect_snapshot_error(
    # trying to add a UK for which a PK already exists
    dm_add_uk(
      dm_for_filter(),
      tf_6,
      n
    ),
    class = dm_error("no_uk_if_pk")
  )
})
