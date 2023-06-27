test_that("table_description works", {
  expect_identical(
    dm_nycflights_small() %>%
      dm_set_table_description("high in the sky\nflying from NY" = flights) %>%
      dm_get_table_description(),
    set_names("flights", "high in the sky\nflying from NY")
  )
  expect_identical(
    dm_nycflights_small() %>%
      dm_set_table_description("high in the sky\nflying from NY" = flights) %>%
      dm_get_table_description(flights),
    set_names("flights", "high in the sky\nflying from NY")
  )
  expect_identical(
    dm_nycflights_small() %>%
      dm_set_table_description("high in the sky\nflying from NY" = flights) %>%
      dm_get_table_description(planes),
    set_names(character())
  )
  expect_identical(
    dm_nycflights_small() %>%
      dm_set_table_description(
        "high in the sky\nflying from NY" = flights,
        "Flugzeuge" = planes
      ) %>%
      dm_get_table_description(planes),
    set_names("planes", "Flugzeuge")
  )

  table_desc <- dm_nycflights_small() %>%
    dm_set_table_description(
      "high in the sky\nflying from NY" = flights,
      "Flugzeuge" = planes
    ) %>%
    dm_get_table_description()
  expect_identical(
    dm_nycflights_small() %>%
      dm_set_table_description(!!!table_desc) %>%
      dm_get_table_description(),
    set_names(
      c("flights", "planes"), c("high in the sky\nflying from NY", "Flugzeuge")
    )
  )

  expect_identical(
    dm_nycflights_small() %>%
      dm_set_table_description(!!!table_desc) %>%
      dm_reset_table_description(flights) %>%
      dm_get_table_description(),
    set_names("planes", "Flugzeuge")
  )

  expect_identical(
    dm_nycflights_small() %>%
      dm_set_table_description(!!!table_desc) %>%
      dm_reset_table_description() %>%
      dm_get_table_description(),
    set_names(character())
  )
})
