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

test_that("last", {
  expect_cdm_error(
    color_quos_to_display(
      flights = "blue",
      airlines =
      ),
    class = "last_col_missing"
  )
})

test_that("bad color", {
  expect_cdm_error(
    color_quos_to_display(
      flights = "mauve"
    ),
    class = "wrong_color"
  )
})

test_that("getter", {
  expect_equal(
    cdm_get_colors(cdm_nycflights13()),
    tibble::tribble(
      ~table,     ~color,
      "airlines", "orange",
      "airports", "orange",
      "flights",  "blue",
      "planes",   "orange",
      "weather",  "green"
    )
  )
})
