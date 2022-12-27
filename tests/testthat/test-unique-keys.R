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
    # dm_has_uk()
    dm_has_uk(nyc_1_uk, planes)
    dm_has_uk(nyc_1_uk, flights)
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
    # dm_get_uk_impl()
    dm_get_uk_impl(nyc_1_uk, "planes")
    dm_get_uk_impl(nyc_1_uk, "flights")
    # dm_examine_constraints()
    dm_examine_constraints(
      dm_nycflights_small() %>%
        dm_add_uk(
          planes,
          c(year, manufacturer, model)
        )
    )
    # trying to remove a UK with a FK pointing to it and `fail_fk = FALSE`
    dm_add_fk(
      dm_nycflights_small(),
      flights,
      time_hour,
      weather,
      time_hour
    ) %>%
      dm_rm_uk(weather, time_hour, fail_fk = FALSE)
  })

  expect_snapshot({
    # failing check upon addition of UK
    dm_add_uk(
      dm_nycflights_small(),
      planes,
      c(year, manufacturer, model),
      check = TRUE
    )
    # trying to remove a UK with a FK pointing to it and `fail_fk = TRUE`
    dm_add_fk(
      dm_nycflights_small(),
      flights,
      time_hour,
      weather,
      time_hour
    ) %>%
      dm_rm_uk(weather, time_hour, fail_fk = TRUE)
  },
  error = TRUE)
})
