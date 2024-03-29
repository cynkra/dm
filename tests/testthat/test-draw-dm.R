test_that("API", {
  expect_identical(
    color_quos_to_display(
      flights = "blue",
      airlines = ,
      airports = "orange",
      planes = "green_nb"
    ),
    set_names(
      c("flights", "airlines", "airports", "planes"),
      c("blue", "orange", "orange", "green_nb")
    )
  )
})

test_that("`dm_set_colors()` works", {
  expect_snapshot({
    dm_nycflights_small() %>%
      dm_set_colors(
        blue = starts_with("air"),
        green = contains("h")
      ) %>%
      dm_get_colors()
  })

  skip_if_not_installed("testthat", "3.1.1")

  colset <- c(blue = "flights", green = "airports")

  # test splicing
  expect_snapshot(variant = if (packageVersion("testthat") > "3.1.0") "testthat-new" else "testthat-legacy", {
    dm_nycflights_small() %>%
      dm_set_colors(!!!colset) %>%
      dm_get_colors()
  })
})

test_that("`dm_set_colors()` errors if old syntax used", {
  expect_dm_error(
    dm_set_colors(
      dm_nycflights_small(),
      airports = ,
      airlines = "blue",
      flights = ,
      weather = "green"
    ),
    class = "wrong_syntax_set_cols"
  )
})

test_that("`dm_set_colors()` errors with unnamed args", {
  expect_dm_error(
    dm_set_colors(
      dm_nycflights_small(),
      airports
    ),
    class = "only_named_args"
  )
})

test_that("last", {
  expect_dm_error(
    color_quos_to_display(
      flights = "blue",
      airlines =
      ),
    class = "last_col_missing"
  )
})

test_that("bad color", {
  skip_if_not(getRversion() >= "3.5")

  expect_dm_error(
    dm_set_colors(
      dm_nycflights_small(),
      "zzz-bogus" = flights
    ),
    class = "cols_not_avail"
  )
})

test_that("getter", {
  expect_equal(
    dm_get_colors(dm_nycflights13()),
    c(
      "#ED7D31FF" = "airlines",
      "#ED7D31FF" = "airports",
      "#5B9BD5FF" = "flights",
      "#ED7D31FF" = "planes",
      "#70AD47FF" = "weather"
    )
  )
})

test_that("get available colors", {
  expect_length(
    dm_get_available_colors(),
    length(colors()) + 1
  )
})

test_that("helpers", {
  expect_snapshot({
    dm_get_all_columns(dm_for_filter())
  })

  expect_snapshot({
    dm_get_all_column_types(dm_for_filter())
  })
})

test_that("output", {
  skip_if_not_installed("testthat", "3.1.1")

  # 444: types
  expect_snapshot_diagram(
    dm_nycflights13() %>%
      dm_draw(column_types = TRUE),
    "nycflight-dm-types.svg"
  )

  expect_snapshot_diagram(
    dm_nycflights13(cycle = TRUE) %>%
      dm_zoom_to(planes) %>%
      # Multi-fk (#37)
      dm_insert_zoomed("planes_copy") %>%
      # Loose table
      dm(loose = tibble(a = 1)) %>%
      # Non-default fk (#402)
      dm(agency = tibble(airline_name = character())) %>%
      dm_add_fk(agency, airline_name, airlines, name) %>%
      dm_draw(),
    "nycflight-dm.svg"
  )

  # empty table corner cases
  expect_snapshot_diagram(
    dm(a = tibble()) %>%
      dm_draw(),
    "single-empty-table-dm.svg"
  )

  expect_snapshot_diagram(
    dm(x = tibble(a = 1), y = tibble(b = 1), a = tibble()) %>%
      dm_draw(view_type = "all"),
    "empty-table-in-dm.svg"
  )
})

test_that("table_description works", {
  expect_error(dm_set_table_description(dm_nycflights_small(), "flight" = "Flüge"))
  expect_snapshot_diagram(
    dm_nycflights_small() %>%
      dm_set_table_description("high in the sky\nflying from NY" = flights) %>%
      dm_draw(),
    "table-desc-1-dm.svg"
  )

  expect_snapshot_diagram(
    dm_nycflights_small() %>%
      dm_set_table_description("high in the sky\nflying from NY" = flights) %>%
      dm_draw(font_size = list(table_description = 6L)),
    "table-desc-2-dm.svg"
  )

  expect_snapshot_diagram(
    dm_nycflights_small() %>%
      dm_set_table_description("high in the sky\nflying from NY" = flights) %>%
      dm_draw(font_size = c(table_description = 6L, header = 19L, column = 14L)),
    "table-desc-3-dm.svg"
  )

  expect_snapshot_diagram(
    dm_nycflights13(table_description = TRUE) %>%
      dm_draw(font_size = c(table_description = 6L, header = 19L, column = 14L)),
    "table-desc-4-dm.svg"
  )
})

test_that("UK support works", {
  expect_snapshot_diagram(
    dm_nycflights_small() %>%
      dm_add_uk(weather, time_hour) %>%
      dm_set_table_description("high in the sky\nflying from NY" = flights) %>%
      dm_draw(view_type = "all"),
    "table-uk-1-dm.svg"
  )

  expect_snapshot_diagram(
    dm_nycflights_small() %>%
      dm_add_fk(flights, time_hour, weather, time_hour) %>%
      dm_set_table_description("Wetter\npogoda" = weather) %>%
      dm_draw(),
    "table-uk-2-dm.svg"
  )
})
