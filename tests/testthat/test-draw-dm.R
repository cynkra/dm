test_that("API", {
  expect_identical(
    color_quos_to_display(
      flights = "blue",
      airlines = ,
      airports = "orange",
      planes = "green_nb"
    ),
    list(accent1 = "flights", accent2 = c("airlines", "airports"), accent4nb = "planes")
  )
})

test_that("last", {
  expect_error(
    color_quos_to_display(
      flights = "blue",
      airlines =
      ),
    class = cdm_error("last_col_missing"),
    error_txt_last_col_missing()
  )
})

test_that("bad color", {
  expect_error(
    color_quos_to_display(
      flights = "mauve"
    ),
    class = cdm_error("wrong_color"),
    error_txt_wrong_color(paste0("'", colors$dm, "' ", colors$nb)),
    fixed = TRUE
  )
})
