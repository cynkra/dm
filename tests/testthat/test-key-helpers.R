test_that("check_key() API", {
  local_options(lifecycle_verbosity = "warning")

  expect_snapshot({
    check_key(tibble(a = 1), a)
    check_key(.data = tibble(a = 1), a)
    check_key(a, .data = tibble(a = 1))
  })
})

test_that("check_key() checks primary key properly?", {
  expect_dm_error(
    check_key(data_mcard(), c1, c2),
    class = "not_unique_key"
  )

  expect_silent(check_key(data_mcard(), c1, c3))

  expect_silent(check_key(data_mcard(), c2, c3))

  test_tbl <- tibble(nn = 1:5, n = 6:10)
  expect_silent(
    check_key(test_tbl, !!!c("n1" = sym("n"), "n2" = sym("nn")))
  )

  expect_silent(
    check_key(test_tbl, !!!c(sym("n"), sym("nn")))
  )

  expect_silent(
    check_key(test_tbl, everything())
  )

  # Since dm 1.0.0:
  expect_silent(check_key(test_tbl))

  # if {tidyselect} selects nothing
  # cf. issue #360
  skip_if_remote_src()
  expect_dm_error(
    check_key(data_mcard(), starts_with("d")),
    "not_unique_key"
  )

  skip("Need to think about it")
  expect_silent(
    dm_nycflights_small() %>%
      dm_zoom_to(airlines) %>%
      check_key(carrier)
  )
})

test_that("check_api() new interface", {
  local_options(lifecycle_verbosity = "quiet")

  expect_same(
    check_api(data_mcard_1(), data_mcard_2(), x_select = a, y_select = c(a = b)),
    check_api(x = data_mcard_1(), data_mcard_2(), x_select = a, y_select = c(a = b)),
    check_api(data_mcard_1(), y = data_mcard_2(), x_select = a, y_select = c(a = b)),
    check_api(x = data_mcard_1(), y = data_mcard_2(), x_select = a, y_select = c(a = b)),
    check_api(y = data_mcard_2(), x = data_mcard_1(), x_select = a, y_select = c(a = b)),
    check_api(data_mcard_1(), a, data_mcard_2(), c(a = b))
  )

  expect_same(
    check_api(data_mcard_1(), data_mcard_2(), x_select = a, y_select = b, by_position = TRUE),
    check_api(x = data_mcard_1(), data_mcard_2(), x_select = a, y_select = b, by_position = TRUE),
    check_api(data_mcard_1(), y = data_mcard_2(), x_select = a, y_select = b, by_position = TRUE),
    check_api(x = data_mcard_1(), y = data_mcard_2(), x_select = a, y_select = b, by_position = TRUE),
    check_api(y = data_mcard_2(), x = data_mcard_1(), x_select = a, y_select = b, by_position = TRUE),
    check_api(data_mcard_1(), a, data_mcard_2(), b)
  )
})

test_that("check_api() compatibility", {
  local_options(lifecycle_verbosity = "quiet")

  expect_same(
    check_api(data_mcard_1(), a, data_mcard_2(), b),
    check_api(t1 = data_mcard_1(), c1 = a, t2 = data_mcard_2(), c2 = b)
  )
  expect_same(
    check_api(c2 = b, data_mcard_1(), a, data_mcard_2()),
    check_api(data_mcard_1(), c2 = b, a, data_mcard_2()),
    check_api(data_mcard_1(), a, c2 = b, data_mcard_2()),
    check_api(data_mcard_1(), a, data_mcard_2(), c2 = b)
  )
  expect_same(
    check_api(t2 = data_mcard_2(), data_mcard_1(), a, b),
    check_api(data_mcard_1(), t2 = data_mcard_2(), a, b),
    check_api(data_mcard_1(), a, t2 = data_mcard_2(), b),
    check_api(data_mcard_1(), a, b, t2 = data_mcard_2())
  )
  expect_same(
    check_api(t2 = data_mcard_2(), c2 = b, data_mcard_1(), a),
    check_api(t2 = data_mcard_2(), data_mcard_1(), c2 = b, a),
    check_api(t2 = data_mcard_2(), data_mcard_1(), a, c2 = b),
    check_api(c2 = b, t2 = data_mcard_2(), data_mcard_1(), a),
    check_api(c2 = b, data_mcard_1(), t2 = data_mcard_2(), a),
    check_api(c2 = b, data_mcard_1(), a, t2 = data_mcard_2()),
    check_api(data_mcard_1(), t2 = data_mcard_2(), c2 = b, a),
    check_api(data_mcard_1(), t2 = data_mcard_2(), a, c2 = b),
    check_api(data_mcard_1(), c2 = b, t2 = data_mcard_2(), a),
    check_api(data_mcard_1(), c2 = b, a, t2 = data_mcard_2()),
    check_api(data_mcard_1(), a, t2 = data_mcard_2(), c2 = b),
    check_api(data_mcard_1(), a, c2 = b, t2 = data_mcard_2())
  )
  expect_same(
    check_api(c1 = a, data_mcard_1(), data_mcard_2(), b),
    check_api(data_mcard_1(), c1 = a, data_mcard_2(), b),
    check_api(data_mcard_1(), data_mcard_2(), c1 = a, b),
    check_api(data_mcard_1(), data_mcard_2(), b, c1 = a)
  )
  expect_same(
    check_api(c1 = a, c2 = b, data_mcard_1(), data_mcard_2()),
    check_api(c1 = a, data_mcard_1(), c2 = b, data_mcard_2()),
    check_api(c1 = a, data_mcard_1(), data_mcard_2(), c2 = b),
    check_api(c2 = b, c1 = a, data_mcard_1(), data_mcard_2()),
    check_api(c2 = b, data_mcard_1(), c1 = a, data_mcard_2()),
    check_api(c2 = b, data_mcard_1(), data_mcard_2(), c1 = a),
    check_api(data_mcard_1(), c1 = a, c2 = b, data_mcard_2()),
    check_api(data_mcard_1(), c1 = a, data_mcard_2(), c2 = b),
    check_api(data_mcard_1(), c2 = b, c1 = a, data_mcard_2()),
    check_api(data_mcard_1(), c2 = b, data_mcard_2(), c1 = a),
    check_api(data_mcard_1(), data_mcard_2(), c1 = a, c2 = b),
    check_api(data_mcard_1(), data_mcard_2(), c2 = b, c1 = a)
  )
  expect_same(
    check_api(c1 = a, t2 = data_mcard_2(), data_mcard_1(), b),
    check_api(c1 = a, data_mcard_1(), t2 = data_mcard_2(), b),
    check_api(c1 = a, data_mcard_1(), b, t2 = data_mcard_2()),
    check_api(t2 = data_mcard_2(), c1 = a, data_mcard_1(), b),
    check_api(t2 = data_mcard_2(), data_mcard_1(), c1 = a, b),
    check_api(t2 = data_mcard_2(), data_mcard_1(), b, c1 = a),
    check_api(data_mcard_1(), c1 = a, t2 = data_mcard_2(), b),
    check_api(data_mcard_1(), c1 = a, b, t2 = data_mcard_2()),
    check_api(data_mcard_1(), t2 = data_mcard_2(), c1 = a, b),
    check_api(data_mcard_1(), t2 = data_mcard_2(), b, c1 = a),
    check_api(data_mcard_1(), b, c1 = a, t2 = data_mcard_2()),
    check_api(data_mcard_1(), b, t2 = data_mcard_2(), c1 = a)
  )
  expect_same(
    check_api(c1 = a, t2 = data_mcard_2(), c2 = b, data_mcard_1()),
    check_api(c1 = a, t2 = data_mcard_2(), data_mcard_1(), c2 = b),
    check_api(c1 = a, c2 = b, t2 = data_mcard_2(), data_mcard_1()),
    check_api(c1 = a, c2 = b, data_mcard_1(), t2 = data_mcard_2()),
    check_api(c1 = a, data_mcard_1(), t2 = data_mcard_2(), c2 = b),
    check_api(c1 = a, data_mcard_1(), c2 = b, t2 = data_mcard_2()),
    check_api(t2 = data_mcard_2(), c1 = a, c2 = b, data_mcard_1()),
    check_api(t2 = data_mcard_2(), c1 = a, data_mcard_1(), c2 = b),
    check_api(t2 = data_mcard_2(), c2 = b, c1 = a, data_mcard_1()),
    check_api(t2 = data_mcard_2(), c2 = b, data_mcard_1(), c1 = a),
    check_api(t2 = data_mcard_2(), data_mcard_1(), c1 = a, c2 = b),
    check_api(t2 = data_mcard_2(), data_mcard_1(), c2 = b, c1 = a),
    check_api(c2 = b, c1 = a, t2 = data_mcard_2(), data_mcard_1()),
    check_api(c2 = b, c1 = a, data_mcard_1(), t2 = data_mcard_2()),
    check_api(c2 = b, t2 = data_mcard_2(), c1 = a, data_mcard_1()),
    check_api(c2 = b, t2 = data_mcard_2(), data_mcard_1(), c1 = a),
    check_api(c2 = b, data_mcard_1(), c1 = a, t2 = data_mcard_2()),
    check_api(c2 = b, data_mcard_1(), t2 = data_mcard_2(), c1 = a),
    check_api(data_mcard_1(), c1 = a, t2 = data_mcard_2(), c2 = b),
    check_api(data_mcard_1(), c1 = a, c2 = b, t2 = data_mcard_2()),
    check_api(data_mcard_1(), t2 = data_mcard_2(), c1 = a, c2 = b),
    check_api(data_mcard_1(), t2 = data_mcard_2(), c2 = b, c1 = a),
    check_api(data_mcard_1(), c2 = b, c1 = a, t2 = data_mcard_2()),
    check_api(data_mcard_1(), c2 = b, t2 = data_mcard_2(), c1 = a)
  )
  expect_same(
    check_api(t1 = data_mcard_1(), a, data_mcard_2(), b),
    check_api(a, t1 = data_mcard_1(), data_mcard_2(), b),
    check_api(a, data_mcard_2(), t1 = data_mcard_1(), b),
    check_api(a, data_mcard_2(), b, t1 = data_mcard_1())
  )
  expect_same(
    check_api(t1 = data_mcard_1(), c2 = b, a, data_mcard_2()),
    check_api(t1 = data_mcard_1(), a, c2 = b, data_mcard_2()),
    check_api(t1 = data_mcard_1(), a, data_mcard_2(), c2 = b),
    check_api(c2 = b, t1 = data_mcard_1(), a, data_mcard_2()),
    check_api(c2 = b, a, t1 = data_mcard_1(), data_mcard_2()),
    check_api(c2 = b, a, data_mcard_2(), t1 = data_mcard_1()),
    check_api(a, t1 = data_mcard_1(), c2 = b, data_mcard_2()),
    check_api(a, t1 = data_mcard_1(), data_mcard_2(), c2 = b),
    check_api(a, c2 = b, t1 = data_mcard_1(), data_mcard_2()),
    check_api(a, c2 = b, data_mcard_2(), t1 = data_mcard_1()),
    check_api(a, data_mcard_2(), t1 = data_mcard_1(), c2 = b),
    check_api(a, data_mcard_2(), c2 = b, t1 = data_mcard_1())
  )
  expect_same(
    check_api(t1 = data_mcard_1(), t2 = data_mcard_2(), a, b),
    check_api(t1 = data_mcard_1(), a, t2 = data_mcard_2(), b),
    check_api(t1 = data_mcard_1(), a, b, t2 = data_mcard_2()),
    check_api(t2 = data_mcard_2(), t1 = data_mcard_1(), a, b),
    check_api(t2 = data_mcard_2(), a, t1 = data_mcard_1(), b),
    check_api(t2 = data_mcard_2(), a, b, t1 = data_mcard_1()),
    check_api(a, t1 = data_mcard_1(), t2 = data_mcard_2(), b),
    check_api(a, t1 = data_mcard_1(), b, t2 = data_mcard_2()),
    check_api(a, t2 = data_mcard_2(), t1 = data_mcard_1(), b),
    check_api(a, t2 = data_mcard_2(), b, t1 = data_mcard_1()),
    check_api(a, b, t1 = data_mcard_1(), t2 = data_mcard_2()),
    check_api(a, b, t2 = data_mcard_2(), t1 = data_mcard_1())
  )
  expect_same(
    check_api(t1 = data_mcard_1(), t2 = data_mcard_2(), c2 = b, a),
    check_api(t1 = data_mcard_1(), t2 = data_mcard_2(), a, c2 = b),
    check_api(t1 = data_mcard_1(), c2 = b, t2 = data_mcard_2(), a),
    check_api(t1 = data_mcard_1(), c2 = b, a, t2 = data_mcard_2()),
    check_api(t1 = data_mcard_1(), a, t2 = data_mcard_2(), c2 = b),
    check_api(t1 = data_mcard_1(), a, c2 = b, t2 = data_mcard_2()),
    check_api(t2 = data_mcard_2(), t1 = data_mcard_1(), c2 = b, a),
    check_api(t2 = data_mcard_2(), t1 = data_mcard_1(), a, c2 = b),
    check_api(t2 = data_mcard_2(), c2 = b, t1 = data_mcard_1(), a),
    check_api(t2 = data_mcard_2(), c2 = b, a, t1 = data_mcard_1()),
    check_api(t2 = data_mcard_2(), a, t1 = data_mcard_1(), c2 = b),
    check_api(t2 = data_mcard_2(), a, c2 = b, t1 = data_mcard_1()),
    check_api(c2 = b, t1 = data_mcard_1(), t2 = data_mcard_2(), a),
    check_api(c2 = b, t1 = data_mcard_1(), a, t2 = data_mcard_2()),
    check_api(c2 = b, t2 = data_mcard_2(), t1 = data_mcard_1(), a),
    check_api(c2 = b, t2 = data_mcard_2(), a, t1 = data_mcard_1()),
    check_api(c2 = b, a, t1 = data_mcard_1(), t2 = data_mcard_2()),
    check_api(c2 = b, a, t2 = data_mcard_2(), t1 = data_mcard_1()),
    check_api(a, t1 = data_mcard_1(), t2 = data_mcard_2(), c2 = b),
    check_api(a, t1 = data_mcard_1(), c2 = b, t2 = data_mcard_2()),
    check_api(a, t2 = data_mcard_2(), t1 = data_mcard_1(), c2 = b),
    check_api(a, t2 = data_mcard_2(), c2 = b, t1 = data_mcard_1()),
    check_api(a, c2 = b, t1 = data_mcard_1(), t2 = data_mcard_2()),
    check_api(a, c2 = b, t2 = data_mcard_2(), t1 = data_mcard_1())
  )
  expect_same(
    check_api(t1 = data_mcard_1(), c1 = a, data_mcard_2(), b),
    check_api(t1 = data_mcard_1(), data_mcard_2(), c1 = a, b),
    check_api(t1 = data_mcard_1(), data_mcard_2(), b, c1 = a),
    check_api(c1 = a, t1 = data_mcard_1(), data_mcard_2(), b),
    check_api(c1 = a, data_mcard_2(), t1 = data_mcard_1(), b),
    check_api(c1 = a, data_mcard_2(), b, t1 = data_mcard_1()),
    check_api(data_mcard_2(), t1 = data_mcard_1(), c1 = a, b),
    check_api(data_mcard_2(), t1 = data_mcard_1(), b, c1 = a),
    check_api(data_mcard_2(), c1 = a, t1 = data_mcard_1(), b),
    check_api(data_mcard_2(), c1 = a, b, t1 = data_mcard_1()),
    check_api(data_mcard_2(), b, t1 = data_mcard_1(), c1 = a),
    check_api(data_mcard_2(), b, c1 = a, t1 = data_mcard_1())
  )
  expect_same(
    check_api(t1 = data_mcard_1(), c1 = a, c2 = b, data_mcard_2()),
    check_api(t1 = data_mcard_1(), c1 = a, data_mcard_2(), c2 = b),
    check_api(t1 = data_mcard_1(), c2 = b, c1 = a, data_mcard_2()),
    check_api(t1 = data_mcard_1(), c2 = b, data_mcard_2(), c1 = a),
    check_api(t1 = data_mcard_1(), data_mcard_2(), c1 = a, c2 = b),
    check_api(t1 = data_mcard_1(), data_mcard_2(), c2 = b, c1 = a),
    check_api(c1 = a, t1 = data_mcard_1(), c2 = b, data_mcard_2()),
    check_api(c1 = a, t1 = data_mcard_1(), data_mcard_2(), c2 = b),
    check_api(c1 = a, c2 = b, t1 = data_mcard_1(), data_mcard_2()),
    check_api(c1 = a, c2 = b, data_mcard_2(), t1 = data_mcard_1()),
    check_api(c1 = a, data_mcard_2(), t1 = data_mcard_1(), c2 = b),
    check_api(c1 = a, data_mcard_2(), c2 = b, t1 = data_mcard_1()),
    check_api(c2 = b, t1 = data_mcard_1(), c1 = a, data_mcard_2()),
    check_api(c2 = b, t1 = data_mcard_1(), data_mcard_2(), c1 = a),
    check_api(c2 = b, c1 = a, t1 = data_mcard_1(), data_mcard_2()),
    check_api(c2 = b, c1 = a, data_mcard_2(), t1 = data_mcard_1()),
    check_api(c2 = b, data_mcard_2(), t1 = data_mcard_1(), c1 = a),
    check_api(c2 = b, data_mcard_2(), c1 = a, t1 = data_mcard_1()),
    check_api(data_mcard_2(), t1 = data_mcard_1(), c1 = a, c2 = b),
    check_api(data_mcard_2(), t1 = data_mcard_1(), c2 = b, c1 = a),
    check_api(data_mcard_2(), c1 = a, t1 = data_mcard_1(), c2 = b),
    check_api(data_mcard_2(), c1 = a, c2 = b, t1 = data_mcard_1()),
    check_api(data_mcard_2(), c2 = b, t1 = data_mcard_1(), c1 = a),
    check_api(data_mcard_2(), c2 = b, c1 = a, t1 = data_mcard_1())
  )
  expect_same(
    check_api(t1 = data_mcard_1(), c1 = a, t2 = data_mcard_2(), b),
    check_api(t1 = data_mcard_1(), c1 = a, b, t2 = data_mcard_2()),
    check_api(t1 = data_mcard_1(), t2 = data_mcard_2(), c1 = a, b),
    check_api(t1 = data_mcard_1(), t2 = data_mcard_2(), b, c1 = a),
    check_api(t1 = data_mcard_1(), b, c1 = a, t2 = data_mcard_2()),
    check_api(t1 = data_mcard_1(), b, t2 = data_mcard_2(), c1 = a),
    check_api(c1 = a, t1 = data_mcard_1(), t2 = data_mcard_2(), b),
    check_api(c1 = a, t1 = data_mcard_1(), b, t2 = data_mcard_2()),
    check_api(c1 = a, t2 = data_mcard_2(), t1 = data_mcard_1(), b),
    check_api(c1 = a, t2 = data_mcard_2(), b, t1 = data_mcard_1()),
    check_api(c1 = a, b, t1 = data_mcard_1(), t2 = data_mcard_2()),
    check_api(c1 = a, b, t2 = data_mcard_2(), t1 = data_mcard_1()),
    check_api(t2 = data_mcard_2(), t1 = data_mcard_1(), c1 = a, b),
    check_api(t2 = data_mcard_2(), t1 = data_mcard_1(), b, c1 = a),
    check_api(t2 = data_mcard_2(), c1 = a, t1 = data_mcard_1(), b),
    check_api(t2 = data_mcard_2(), c1 = a, b, t1 = data_mcard_1()),
    check_api(t2 = data_mcard_2(), b, t1 = data_mcard_1(), c1 = a),
    check_api(t2 = data_mcard_2(), b, c1 = a, t1 = data_mcard_1()),
    check_api(b, t1 = data_mcard_1(), c1 = a, t2 = data_mcard_2()),
    check_api(b, t1 = data_mcard_1(), t2 = data_mcard_2(), c1 = a),
    check_api(b, c1 = a, t1 = data_mcard_1(), t2 = data_mcard_2()),
    check_api(b, c1 = a, t2 = data_mcard_2(), t1 = data_mcard_1()),
    check_api(b, t2 = data_mcard_2(), t1 = data_mcard_1(), c1 = a),
    check_api(b, t2 = data_mcard_2(), c1 = a, t1 = data_mcard_1())
  )
  expect_same(
    check_api(t1 = data_mcard_1(), c1 = a, t2 = data_mcard_2(), c2 = b),
    check_api(t1 = data_mcard_1(), c1 = a, c2 = b, t2 = data_mcard_2()),
    check_api(t1 = data_mcard_1(), t2 = data_mcard_2(), c1 = a, c2 = b),
    check_api(t1 = data_mcard_1(), t2 = data_mcard_2(), c2 = b, c1 = a),
    check_api(t1 = data_mcard_1(), c2 = b, c1 = a, t2 = data_mcard_2()),
    check_api(t1 = data_mcard_1(), c2 = b, t2 = data_mcard_2(), c1 = a),
    check_api(c1 = a, t1 = data_mcard_1(), t2 = data_mcard_2(), c2 = b),
    check_api(c1 = a, t1 = data_mcard_1(), c2 = b, t2 = data_mcard_2()),
    check_api(c1 = a, t2 = data_mcard_2(), t1 = data_mcard_1(), c2 = b),
    check_api(c1 = a, t2 = data_mcard_2(), c2 = b, t1 = data_mcard_1()),
    check_api(c1 = a, c2 = b, t1 = data_mcard_1(), t2 = data_mcard_2()),
    check_api(c1 = a, c2 = b, t2 = data_mcard_2(), t1 = data_mcard_1()),
    check_api(t2 = data_mcard_2(), t1 = data_mcard_1(), c1 = a, c2 = b),
    check_api(t2 = data_mcard_2(), t1 = data_mcard_1(), c2 = b, c1 = a),
    check_api(t2 = data_mcard_2(), c1 = a, t1 = data_mcard_1(), c2 = b),
    check_api(t2 = data_mcard_2(), c1 = a, c2 = b, t1 = data_mcard_1()),
    check_api(t2 = data_mcard_2(), c2 = b, t1 = data_mcard_1(), c1 = a),
    check_api(t2 = data_mcard_2(), c2 = b, c1 = a, t1 = data_mcard_1()),
    check_api(c2 = b, t1 = data_mcard_1(), c1 = a, t2 = data_mcard_2()),
    check_api(c2 = b, t1 = data_mcard_1(), t2 = data_mcard_2(), c1 = a),
    check_api(c2 = b, c1 = a, t1 = data_mcard_1(), t2 = data_mcard_2()),
    check_api(c2 = b, c1 = a, t2 = data_mcard_2(), t1 = data_mcard_1()),
    check_api(c2 = b, t2 = data_mcard_2(), t1 = data_mcard_1(), c1 = a),
    check_api(c2 = b, t2 = data_mcard_2(), c1 = a, t1 = data_mcard_1())
  )
})

test_that("check_subset() checks if tf_1$c1 column values are subset of tf_2$c2 properly?", {
  expect_silent(check_subset(data_mcard_1(), data_mcard_2(), x_select = a, y_select = a))
})

test_that("output for legacy API", {
  expect_snapshot({
    check_subset(data_mcard_1(), a, data_mcard_2(), a)
  })
})

test_that("output", {
  expect_snapshot(error = TRUE, {
    check_subset(data_mcard_1(), data_mcard_2(), x_select = c(x = a))
  })
  expect_snapshot(error = TRUE, {
    check_subset(data_mcard_2(), data_mcard_1(), x_select = a)
  })
})

test_that("output for compound keys", {
  expect_snapshot(error = TRUE, {
    check_subset(data_mcard_2(), data_mcard_1(), x_select = c(a, b))
  })
})

test_that("check_set_equality() checks properly if 2 sets of values are equal?", {
  expect_silent(check_set_equality(data_mcard_1(), data_mcard_3(), x_select = a))

  expect_snapshot(error = TRUE, {
    check_set_equality(data_mcard_1(), data_mcard_2(), x_select = c(a, c))
  })
})

# FIXME: COMPOUND:: regarding compound keys: should `check_subset()` and `check_set_equality()`
# also work for multiple columns? (matching needs to be provided, implicitly by order?)
