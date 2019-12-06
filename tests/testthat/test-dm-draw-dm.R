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

test_that("`dm_set_colors2()` works", {
  expect_identical(
    dm_set_colors2(
      dm_nycflights_small,
      blue = starts_with("air"),
      green = contains("h")
    ) %>%
      dm_get_colors(),
    tibble(
      table = src_tbls(dm_nycflights_small),
      color = c("green", NA_character_, "blue", "blue", "green")
    )
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
    tibble::tribble(
      ~table,       ~color,
      "airlines", "orange",
      "airports", "orange",
      "flights",    "blue",
      "planes",   "orange",
      "weather",   "green"
    )
  )
})
