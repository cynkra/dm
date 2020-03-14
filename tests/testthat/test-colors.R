test_that("color related functions work", {
  # is_dark_color()
  expect_true(is_dark_color(rgb = c(100, 100, 100, 255)))
  expect_false(is_dark_color(rgb = c(142, 164, 143, 255)))

  # is_hex_color()
  expect_true(is_hex_color("#92A87F"))
  expect_true(is_hex_color("#92A87F4C"))
  expect_false(is_hex_color("#92A87F4"))
  expect_false(is_hex_color("92A87F"))

  # col_to_hex()
  expect_identical(
    col_to_hex(c("brown", "#92A87F", "darkgreen", "#92A87F4C")),
    c("#A52A2AFF", "#92A87FFF", "#006400FF", "#92A87F4C")
  )

  expect_dm_error(
    col_to_hex("darklightpink"),
    "cols_not_avail"
  )

  # hex_from_rgb()
  expect_identical(
    hex_from_rgb(matrix(100, 4, 1)),
    "#64646464"
  )

  expect_identical(
    hex_from_rgb(matrix(100:107, 4, 2)),
    c("#64656667", "#68696A6B")
  )

  expect_identical(
    calc_bodycol_rgb(matrix(c(100, 20, 200, 155), 4, 1)),
    matrix(c(224, 208, 244, 155), 4, 1)
  )
})
