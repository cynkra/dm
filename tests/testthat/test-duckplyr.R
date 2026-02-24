test_that("Check assumptions on duckplyr class", {
  skip_if_not_installed("duckplyr", "1.1.99")
  expect_true(inherits(duckplyr::duckdb_tibble(a = 1), "duckplyr_df"))
})

test_that("Simple duckplyr test", {
  skip_if_not_installed("duckplyr", "1.1.99")

  expect_snapshot({
    dm(a = duckplyr::duckdb_tibble(x = 1:3, .prudence = "stingy")) |>
      dm_zoom_to(a) |>
      summarize(mean_x = mean(x))
  })
})
