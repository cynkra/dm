test_that("API", {
  expect_identical(
    color_quos_to_display(
      flights = "blue",
      airlines = ,
      airports = "orange",
      planes = "green_nb"
    ) %>%
      nest(data = -new_display) %>%
      deframe() %>%
      map(pull),
    list(accent1 = "flights", accent2 = c("airlines", "airports"), accent4nb = "planes")
  )
})

test_that("`dm_set_colors()` works", {
  expect_identical(
    dm_set_colors(
      dm_nycflights_small,
      blue = starts_with("air"),
      green = contains("h")
    ) %>%
      dm_get_colors(),
    set_names(
      src_tbls(dm_nycflights_small),
      c("green", NA_character_, "blue", "blue", "green")
    )
  )
})

test_that("`dm_set_colors()` errors if old syntax used", {
  expect_dm_error(
    dm_set_colors(
      dm_nycflights_small,
      airports = ,
      airlines = "blue",
      flights = ,
      weather = "green"
    ),
    class = "wrong_syntax_set_cols"
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
  expect_dm_error(
    color_quos_to_display(
      flights = "mauve"
    ),
    class = "wrong_color"
  )
})

test_that("getter", {
  expect_equal(
    dm_get_colors(dm_nycflights13()),
    c(
      orange = "airlines",
      orange = "airports",
      blue = "flights",
      orange = "planes",
      green = "weather"
    )
  )
})
