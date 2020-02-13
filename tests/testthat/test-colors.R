test_that("color related functions work", {
  # is_dark_color()
  # FIXME: after #279 needs vector of 4
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
    # FIXME: after #279 results will always contain alpha channel
    c("#A52A2A", "#92A87F", "#006400", "#92A87F")
  )

  expect_dm_error(
    col_to_hex("darklightpink"),
    "cols_not_avail"
  )

  # hex_from_rgb()
  expect_identical(
    hex_from_rgb(matrix(100, 4, 1)),
    # FIXME: after #279 result will be: "#64646464"
    "#646464"
  )

  expect_identical(
    hex_from_rgb(matrix(100:107, 4, 2)),
    # FIXME: after #279 result will be: c("#64656667", "#68696A6B")
    c("#646566", "#68696A")
  )

  # calc_bodycol_rgb()
  # FIXME: test after #279:
  # expect_identical(
  #    calc_bodycol_rgb(matrix(c(100, 20, 200, 155), 3, 1)),
  #    matrix(c(224, 208, 244, 155), 4, 1)
  #    )
  expect_identical(
    calc_bodycol_rgb(matrix(c(100, 20, 200), 3, 1)),
    matrix(c(224, 208, 244), 3, 1)
  )
})
