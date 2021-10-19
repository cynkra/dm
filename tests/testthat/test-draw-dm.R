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
  skip_if_not_installed("nycflights13")

  expect_snapshot({
    dm_nycflights_small() %>%
      dm_set_colors(
        blue = starts_with("air"),
        green = contains("h")
      ) %>%
      dm_get_colors()
  })

  colset <- c(blue = "flights", green = "airports")

  # test splicing
  expect_snapshot({
    dm_nycflights_small() %>%
      dm_set_colors(!!!colset) %>%
      dm_get_colors()
  })
})

test_that("`dm_set_colors()` errors if old syntax used", {
  skip_if_not_installed("nycflights13")
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
  skip_if_not_installed("nycflights13")

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
  skip_if_not_installed("nycflights13")

  expect_dm_error(
    dm_set_colors(
      dm_nycflights_small(),
      "zzz-bogus" = flights
    ),
    class = "cols_not_avail"
  )
})

test_that("getter", {
  skip_if_not_installed("nycflights13")

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

test_that("datamodel-code for drawing", {
  local_options(max.print = 10000)

  expect_snapshot({
    dm_get_data_model(dm_for_filter(), column_types = TRUE)
  })
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
  skip_if_not_installed("DiagrammeRsvg")
  skip_if_not_installed("nycflights13")

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
      dm_add_tbl(loose = tibble(a = 1)) %>%
      # Non-default fk (#402)
      dm_add_tbl(agency = tibble(airline_name = character())) %>%
      dm_add_fk(agency, airline_name, airlines, name) %>%
      dm_draw(),
    "nycflight-dm.svg"
  )

  # empty table corner cases
  expect_snapshot_diagram(
    dm(a = tibble()) %>%
      dm_draw(),
    "single-empty-table-dm.svg")

  expect_snapshot_diagram(
    dm(x = tibble(a = 1), y = tibble(b = 1), a = tibble()) %>%
      dm_draw(view_type = "all"),
    "empty-table-in-dm.svg")
})
