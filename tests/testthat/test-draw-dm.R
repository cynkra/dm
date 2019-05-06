test_that("API", {
  expect_identical(
    color_quos_to_display(
      flights = "blue",
      airlines = ,
      airports = "orange",
      planes = "green_nb"
    ),
    list(accent4nb = "flights", accent2 = c("airlines", "airports"), accent1 = "planes")
  )
})

test_that("last", {
  expect_error(
    color_quos_to_display(
      flights = "blue",
      airlines =
    ),
    "last"
  )
})

test_that("bad color", {
  expect_error(
    color_quos_to_display(
      flights = "mauve"
    ),
    "Avail"
  )
})
