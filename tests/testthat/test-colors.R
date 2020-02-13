test_that("color related functions work", {
  # is_dark_color()
  expect_true(is_dark_color(rgb = c(100, 100, 100)))
  expect_false(is_dark_color(rgb = c(142, 164, 143)))

  # is_hex_color()
  expect_true(is_hex_color("#92A87F"))
  expect_true(is_hex_color("#92A87F4C"))
  expect_false(is_hex_color("#92A87F4"))
  expect_false(is_hex_color("92A87F"))

  # col_to_hex()
  expect_identical(
    col_to_hex(c("brown", "#92A87F", "darkgreen", "#92A87F4C")),
    # alpha channel gets swallowed by hex_from_rgb()
    c("#A52A2A", "#92A87F", "#006400", "#92A87F")
  )

  expect_dm_error(
    col_to_hex("darklightpink"),
    "cols_not_avail"
  )
})
