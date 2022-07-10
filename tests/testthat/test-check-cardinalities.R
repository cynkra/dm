test_that("check_card_api() new interface", {
  local_options(lifecycle_verbosity = "quiet")

  expect_same(
    check_card_api(data_mcard_1(), data_mcard_2()),
    check_card_api(data_mcard_1(), data_mcard_2(), x_select = a, y_select = b),
    check_card_api(x = data_mcard_1(), data_mcard_2(), x_select = a, y_select = b),
    check_card_api(data_mcard_1(), y = data_mcard_2(), x_select = a, y_select = b),
    check_card_api(x = data_mcard_1(), y = data_mcard_2(), x_select = a, y_select = b),
    check_card_api(y = data_mcard_2(), x = data_mcard_1(), x_select = a, y_select = b),
    check_card_api(data_mcard_1(), a, data_mcard_2(), b)
  )
})

test_that("check_cardinality_...() functions work without `x_select` and `y_select`", {
  expect_silent(check_cardinality_0_n(data_card_1(), data_card_11()))
  expect_silent(check_cardinality_1_n(data_card_1(), data_card_12()))
  expect_silent(check_cardinality_1_1(data_card_1(), data_card_1()))
  expect_silent(check_cardinality_0_1(data_card_1(), data_card_11()))

  expect_snapshot({
    examine_cardinality(data_card_1(), data_card_11())
    examine_cardinality(data_card_1(), data_card_12())
    examine_cardinality(data_card_1(), data_card_1())
    examine_cardinality(data_card_1(), data_card_11())
  })
})

test_that("check_card_api() compatibility", {
  local_options(lifecycle_verbosity = "quiet")

  expect_same(
    check_card_api(data_mcard_1(), a, data_mcard_2(), b),
    check_card_api(parent_table = data_mcard_1(), pk_column = a, child_table = data_mcard_2(), fk_column = b)
  )
  expect_same(
    check_card_api(fk_column = b, data_mcard_1(), a, data_mcard_2()),
    check_card_api(data_mcard_1(), fk_column = b, a, data_mcard_2()),
    check_card_api(data_mcard_1(), a, fk_column = b, data_mcard_2()),
    check_card_api(data_mcard_1(), a, data_mcard_2(), fk_column = b)
  )
  expect_same(
    check_card_api(child_table = data_mcard_2(), data_mcard_1(), a, b),
    check_card_api(data_mcard_1(), child_table = data_mcard_2(), a, b),
    check_card_api(data_mcard_1(), a, child_table = data_mcard_2(), b),
    check_card_api(data_mcard_1(), a, b, child_table = data_mcard_2())
  )
  expect_same(
    check_card_api(child_table = data_mcard_2(), fk_column = b, data_mcard_1(), a),
    check_card_api(child_table = data_mcard_2(), data_mcard_1(), fk_column = b, a),
    check_card_api(child_table = data_mcard_2(), data_mcard_1(), a, fk_column = b),
    check_card_api(fk_column = b, child_table = data_mcard_2(), data_mcard_1(), a),
    check_card_api(fk_column = b, data_mcard_1(), child_table = data_mcard_2(), a),
    check_card_api(fk_column = b, data_mcard_1(), a, child_table = data_mcard_2()),
    check_card_api(data_mcard_1(), child_table = data_mcard_2(), fk_column = b, a),
    check_card_api(data_mcard_1(), child_table = data_mcard_2(), a, fk_column = b),
    check_card_api(data_mcard_1(), fk_column = b, child_table = data_mcard_2(), a),
    check_card_api(data_mcard_1(), fk_column = b, a, child_table = data_mcard_2()),
    check_card_api(data_mcard_1(), a, child_table = data_mcard_2(), fk_column = b),
    check_card_api(data_mcard_1(), a, fk_column = b, child_table = data_mcard_2())
  )
  expect_same(
    check_card_api(pk_column = a, data_mcard_1(), data_mcard_2(), b),
    check_card_api(data_mcard_1(), pk_column = a, data_mcard_2(), b),
    check_card_api(data_mcard_1(), data_mcard_2(), pk_column = a, b),
    check_card_api(data_mcard_1(), data_mcard_2(), b, pk_column = a)
  )
  expect_same(
    check_card_api(pk_column = a, fk_column = b, data_mcard_1(), data_mcard_2()),
    check_card_api(pk_column = a, data_mcard_1(), fk_column = b, data_mcard_2()),
    check_card_api(pk_column = a, data_mcard_1(), data_mcard_2(), fk_column = b),
    check_card_api(fk_column = b, pk_column = a, data_mcard_1(), data_mcard_2()),
    check_card_api(fk_column = b, data_mcard_1(), pk_column = a, data_mcard_2()),
    check_card_api(fk_column = b, data_mcard_1(), data_mcard_2(), pk_column = a),
    check_card_api(data_mcard_1(), pk_column = a, fk_column = b, data_mcard_2()),
    check_card_api(data_mcard_1(), pk_column = a, data_mcard_2(), fk_column = b),
    check_card_api(data_mcard_1(), fk_column = b, pk_column = a, data_mcard_2()),
    check_card_api(data_mcard_1(), fk_column = b, data_mcard_2(), pk_column = a),
    check_card_api(data_mcard_1(), data_mcard_2(), pk_column = a, fk_column = b),
    check_card_api(data_mcard_1(), data_mcard_2(), fk_column = b, pk_column = a)
  )
  expect_same(
    check_card_api(pk_column = a, child_table = data_mcard_2(), data_mcard_1(), b),
    check_card_api(pk_column = a, data_mcard_1(), child_table = data_mcard_2(), b),
    check_card_api(pk_column = a, data_mcard_1(), b, child_table = data_mcard_2()),
    check_card_api(child_table = data_mcard_2(), pk_column = a, data_mcard_1(), b),
    check_card_api(child_table = data_mcard_2(), data_mcard_1(), pk_column = a, b),
    check_card_api(child_table = data_mcard_2(), data_mcard_1(), b, pk_column = a),
    check_card_api(data_mcard_1(), pk_column = a, child_table = data_mcard_2(), b),
    check_card_api(data_mcard_1(), pk_column = a, b, child_table = data_mcard_2()),
    check_card_api(data_mcard_1(), child_table = data_mcard_2(), pk_column = a, b),
    check_card_api(data_mcard_1(), child_table = data_mcard_2(), b, pk_column = a),
    check_card_api(data_mcard_1(), b, pk_column = a, child_table = data_mcard_2()),
    check_card_api(data_mcard_1(), b, child_table = data_mcard_2(), pk_column = a)
  )
  expect_same(
    check_card_api(pk_column = a, child_table = data_mcard_2(), fk_column = b, data_mcard_1()),
    check_card_api(pk_column = a, child_table = data_mcard_2(), data_mcard_1(), fk_column = b),
    check_card_api(pk_column = a, fk_column = b, child_table = data_mcard_2(), data_mcard_1()),
    check_card_api(pk_column = a, fk_column = b, data_mcard_1(), child_table = data_mcard_2()),
    check_card_api(pk_column = a, data_mcard_1(), child_table = data_mcard_2(), fk_column = b),
    check_card_api(pk_column = a, data_mcard_1(), fk_column = b, child_table = data_mcard_2()),
    check_card_api(child_table = data_mcard_2(), pk_column = a, fk_column = b, data_mcard_1()),
    check_card_api(child_table = data_mcard_2(), pk_column = a, data_mcard_1(), fk_column = b),
    check_card_api(child_table = data_mcard_2(), fk_column = b, pk_column = a, data_mcard_1()),
    check_card_api(child_table = data_mcard_2(), fk_column = b, data_mcard_1(), pk_column = a),
    check_card_api(child_table = data_mcard_2(), data_mcard_1(), pk_column = a, fk_column = b),
    check_card_api(child_table = data_mcard_2(), data_mcard_1(), fk_column = b, pk_column = a),
    check_card_api(fk_column = b, pk_column = a, child_table = data_mcard_2(), data_mcard_1()),
    check_card_api(fk_column = b, pk_column = a, data_mcard_1(), child_table = data_mcard_2()),
    check_card_api(fk_column = b, child_table = data_mcard_2(), pk_column = a, data_mcard_1()),
    check_card_api(fk_column = b, child_table = data_mcard_2(), data_mcard_1(), pk_column = a),
    check_card_api(fk_column = b, data_mcard_1(), pk_column = a, child_table = data_mcard_2()),
    check_card_api(fk_column = b, data_mcard_1(), child_table = data_mcard_2(), pk_column = a),
    check_card_api(data_mcard_1(), pk_column = a, child_table = data_mcard_2(), fk_column = b),
    check_card_api(data_mcard_1(), pk_column = a, fk_column = b, child_table = data_mcard_2()),
    check_card_api(data_mcard_1(), child_table = data_mcard_2(), pk_column = a, fk_column = b),
    check_card_api(data_mcard_1(), child_table = data_mcard_2(), fk_column = b, pk_column = a),
    check_card_api(data_mcard_1(), fk_column = b, pk_column = a, child_table = data_mcard_2()),
    check_card_api(data_mcard_1(), fk_column = b, child_table = data_mcard_2(), pk_column = a)
  )
  expect_same(
    check_card_api(parent_table = data_mcard_1(), a, data_mcard_2(), b),
    check_card_api(a, parent_table = data_mcard_1(), data_mcard_2(), b),
    check_card_api(a, data_mcard_2(), parent_table = data_mcard_1(), b),
    check_card_api(a, data_mcard_2(), b, parent_table = data_mcard_1())
  )
  expect_same(
    check_card_api(parent_table = data_mcard_1(), fk_column = b, a, data_mcard_2()),
    check_card_api(parent_table = data_mcard_1(), a, fk_column = b, data_mcard_2()),
    check_card_api(parent_table = data_mcard_1(), a, data_mcard_2(), fk_column = b),
    check_card_api(fk_column = b, parent_table = data_mcard_1(), a, data_mcard_2()),
    check_card_api(fk_column = b, a, parent_table = data_mcard_1(), data_mcard_2()),
    check_card_api(fk_column = b, a, data_mcard_2(), parent_table = data_mcard_1()),
    check_card_api(a, parent_table = data_mcard_1(), fk_column = b, data_mcard_2()),
    check_card_api(a, parent_table = data_mcard_1(), data_mcard_2(), fk_column = b),
    check_card_api(a, fk_column = b, parent_table = data_mcard_1(), data_mcard_2()),
    check_card_api(a, fk_column = b, data_mcard_2(), parent_table = data_mcard_1()),
    check_card_api(a, data_mcard_2(), parent_table = data_mcard_1(), fk_column = b),
    check_card_api(a, data_mcard_2(), fk_column = b, parent_table = data_mcard_1())
  )
  expect_same(
    check_card_api(parent_table = data_mcard_1(), child_table = data_mcard_2(), a, b),
    check_card_api(parent_table = data_mcard_1(), a, child_table = data_mcard_2(), b),
    check_card_api(parent_table = data_mcard_1(), a, b, child_table = data_mcard_2()),
    check_card_api(child_table = data_mcard_2(), parent_table = data_mcard_1(), a, b),
    check_card_api(child_table = data_mcard_2(), a, parent_table = data_mcard_1(), b),
    check_card_api(child_table = data_mcard_2(), a, b, parent_table = data_mcard_1()),
    check_card_api(a, parent_table = data_mcard_1(), child_table = data_mcard_2(), b),
    check_card_api(a, parent_table = data_mcard_1(), b, child_table = data_mcard_2()),
    check_card_api(a, child_table = data_mcard_2(), parent_table = data_mcard_1(), b),
    check_card_api(a, child_table = data_mcard_2(), b, parent_table = data_mcard_1()),
    check_card_api(a, b, parent_table = data_mcard_1(), child_table = data_mcard_2()),
    check_card_api(a, b, child_table = data_mcard_2(), parent_table = data_mcard_1())
  )
  expect_same(
    check_card_api(parent_table = data_mcard_1(), child_table = data_mcard_2(), fk_column = b, a),
    check_card_api(parent_table = data_mcard_1(), child_table = data_mcard_2(), a, fk_column = b),
    check_card_api(parent_table = data_mcard_1(), fk_column = b, child_table = data_mcard_2(), a),
    check_card_api(parent_table = data_mcard_1(), fk_column = b, a, child_table = data_mcard_2()),
    check_card_api(parent_table = data_mcard_1(), a, child_table = data_mcard_2(), fk_column = b),
    check_card_api(parent_table = data_mcard_1(), a, fk_column = b, child_table = data_mcard_2()),
    check_card_api(child_table = data_mcard_2(), parent_table = data_mcard_1(), fk_column = b, a),
    check_card_api(child_table = data_mcard_2(), parent_table = data_mcard_1(), a, fk_column = b),
    check_card_api(child_table = data_mcard_2(), fk_column = b, parent_table = data_mcard_1(), a),
    check_card_api(child_table = data_mcard_2(), fk_column = b, a, parent_table = data_mcard_1()),
    check_card_api(child_table = data_mcard_2(), a, parent_table = data_mcard_1(), fk_column = b),
    check_card_api(child_table = data_mcard_2(), a, fk_column = b, parent_table = data_mcard_1()),
    check_card_api(fk_column = b, parent_table = data_mcard_1(), child_table = data_mcard_2(), a),
    check_card_api(fk_column = b, parent_table = data_mcard_1(), a, child_table = data_mcard_2()),
    check_card_api(fk_column = b, child_table = data_mcard_2(), parent_table = data_mcard_1(), a),
    check_card_api(fk_column = b, child_table = data_mcard_2(), a, parent_table = data_mcard_1()),
    check_card_api(fk_column = b, a, parent_table = data_mcard_1(), child_table = data_mcard_2()),
    check_card_api(fk_column = b, a, child_table = data_mcard_2(), parent_table = data_mcard_1()),
    check_card_api(a, parent_table = data_mcard_1(), child_table = data_mcard_2(), fk_column = b),
    check_card_api(a, parent_table = data_mcard_1(), fk_column = b, child_table = data_mcard_2()),
    check_card_api(a, child_table = data_mcard_2(), parent_table = data_mcard_1(), fk_column = b),
    check_card_api(a, child_table = data_mcard_2(), fk_column = b, parent_table = data_mcard_1()),
    check_card_api(a, fk_column = b, parent_table = data_mcard_1(), child_table = data_mcard_2()),
    check_card_api(a, fk_column = b, child_table = data_mcard_2(), parent_table = data_mcard_1())
  )
  expect_same(
    check_card_api(parent_table = data_mcard_1(), pk_column = a, data_mcard_2(), b),
    check_card_api(parent_table = data_mcard_1(), data_mcard_2(), pk_column = a, b),
    check_card_api(parent_table = data_mcard_1(), data_mcard_2(), b, pk_column = a),
    check_card_api(pk_column = a, parent_table = data_mcard_1(), data_mcard_2(), b),
    check_card_api(pk_column = a, data_mcard_2(), parent_table = data_mcard_1(), b),
    check_card_api(pk_column = a, data_mcard_2(), b, parent_table = data_mcard_1()),
    check_card_api(data_mcard_2(), parent_table = data_mcard_1(), pk_column = a, b),
    check_card_api(data_mcard_2(), parent_table = data_mcard_1(), b, pk_column = a),
    check_card_api(data_mcard_2(), pk_column = a, parent_table = data_mcard_1(), b),
    check_card_api(data_mcard_2(), pk_column = a, b, parent_table = data_mcard_1()),
    check_card_api(data_mcard_2(), b, parent_table = data_mcard_1(), pk_column = a),
    check_card_api(data_mcard_2(), b, pk_column = a, parent_table = data_mcard_1())
  )
  expect_same(
    check_card_api(parent_table = data_mcard_1(), pk_column = a, fk_column = b, data_mcard_2()),
    check_card_api(parent_table = data_mcard_1(), pk_column = a, data_mcard_2(), fk_column = b),
    check_card_api(parent_table = data_mcard_1(), fk_column = b, pk_column = a, data_mcard_2()),
    check_card_api(parent_table = data_mcard_1(), fk_column = b, data_mcard_2(), pk_column = a),
    check_card_api(parent_table = data_mcard_1(), data_mcard_2(), pk_column = a, fk_column = b),
    check_card_api(parent_table = data_mcard_1(), data_mcard_2(), fk_column = b, pk_column = a),
    check_card_api(pk_column = a, parent_table = data_mcard_1(), fk_column = b, data_mcard_2()),
    check_card_api(pk_column = a, parent_table = data_mcard_1(), data_mcard_2(), fk_column = b),
    check_card_api(pk_column = a, fk_column = b, parent_table = data_mcard_1(), data_mcard_2()),
    check_card_api(pk_column = a, fk_column = b, data_mcard_2(), parent_table = data_mcard_1()),
    check_card_api(pk_column = a, data_mcard_2(), parent_table = data_mcard_1(), fk_column = b),
    check_card_api(pk_column = a, data_mcard_2(), fk_column = b, parent_table = data_mcard_1()),
    check_card_api(fk_column = b, parent_table = data_mcard_1(), pk_column = a, data_mcard_2()),
    check_card_api(fk_column = b, parent_table = data_mcard_1(), data_mcard_2(), pk_column = a),
    check_card_api(fk_column = b, pk_column = a, parent_table = data_mcard_1(), data_mcard_2()),
    check_card_api(fk_column = b, pk_column = a, data_mcard_2(), parent_table = data_mcard_1()),
    check_card_api(fk_column = b, data_mcard_2(), parent_table = data_mcard_1(), pk_column = a),
    check_card_api(fk_column = b, data_mcard_2(), pk_column = a, parent_table = data_mcard_1()),
    check_card_api(data_mcard_2(), parent_table = data_mcard_1(), pk_column = a, fk_column = b),
    check_card_api(data_mcard_2(), parent_table = data_mcard_1(), fk_column = b, pk_column = a),
    check_card_api(data_mcard_2(), pk_column = a, parent_table = data_mcard_1(), fk_column = b),
    check_card_api(data_mcard_2(), pk_column = a, fk_column = b, parent_table = data_mcard_1()),
    check_card_api(data_mcard_2(), fk_column = b, parent_table = data_mcard_1(), pk_column = a),
    check_card_api(data_mcard_2(), fk_column = b, pk_column = a, parent_table = data_mcard_1())
  )
  expect_same(
    check_card_api(parent_table = data_mcard_1(), pk_column = a, child_table = data_mcard_2(), b),
    check_card_api(parent_table = data_mcard_1(), pk_column = a, b, child_table = data_mcard_2()),
    check_card_api(parent_table = data_mcard_1(), child_table = data_mcard_2(), pk_column = a, b),
    check_card_api(parent_table = data_mcard_1(), child_table = data_mcard_2(), b, pk_column = a),
    check_card_api(parent_table = data_mcard_1(), b, pk_column = a, child_table = data_mcard_2()),
    check_card_api(parent_table = data_mcard_1(), b, child_table = data_mcard_2(), pk_column = a),
    check_card_api(pk_column = a, parent_table = data_mcard_1(), child_table = data_mcard_2(), b),
    check_card_api(pk_column = a, parent_table = data_mcard_1(), b, child_table = data_mcard_2()),
    check_card_api(pk_column = a, child_table = data_mcard_2(), parent_table = data_mcard_1(), b),
    check_card_api(pk_column = a, child_table = data_mcard_2(), b, parent_table = data_mcard_1()),
    check_card_api(pk_column = a, b, parent_table = data_mcard_1(), child_table = data_mcard_2()),
    check_card_api(pk_column = a, b, child_table = data_mcard_2(), parent_table = data_mcard_1()),
    check_card_api(child_table = data_mcard_2(), parent_table = data_mcard_1(), pk_column = a, b),
    check_card_api(child_table = data_mcard_2(), parent_table = data_mcard_1(), b, pk_column = a),
    check_card_api(child_table = data_mcard_2(), pk_column = a, parent_table = data_mcard_1(), b),
    check_card_api(child_table = data_mcard_2(), pk_column = a, b, parent_table = data_mcard_1()),
    check_card_api(child_table = data_mcard_2(), b, parent_table = data_mcard_1(), pk_column = a),
    check_card_api(child_table = data_mcard_2(), b, pk_column = a, parent_table = data_mcard_1()),
    check_card_api(b, parent_table = data_mcard_1(), pk_column = a, child_table = data_mcard_2()),
    check_card_api(b, parent_table = data_mcard_1(), child_table = data_mcard_2(), pk_column = a),
    check_card_api(b, pk_column = a, parent_table = data_mcard_1(), child_table = data_mcard_2()),
    check_card_api(b, pk_column = a, child_table = data_mcard_2(), parent_table = data_mcard_1()),
    check_card_api(b, child_table = data_mcard_2(), parent_table = data_mcard_1(), pk_column = a),
    check_card_api(b, child_table = data_mcard_2(), pk_column = a, parent_table = data_mcard_1())
  )
  expect_same(
    check_card_api(parent_table = data_mcard_1(), pk_column = a, child_table = data_mcard_2(), fk_column = b),
    check_card_api(parent_table = data_mcard_1(), pk_column = a, fk_column = b, child_table = data_mcard_2()),
    check_card_api(parent_table = data_mcard_1(), child_table = data_mcard_2(), pk_column = a, fk_column = b),
    check_card_api(parent_table = data_mcard_1(), child_table = data_mcard_2(), fk_column = b, pk_column = a),
    check_card_api(parent_table = data_mcard_1(), fk_column = b, pk_column = a, child_table = data_mcard_2()),
    check_card_api(parent_table = data_mcard_1(), fk_column = b, child_table = data_mcard_2(), pk_column = a),
    check_card_api(pk_column = a, parent_table = data_mcard_1(), child_table = data_mcard_2(), fk_column = b),
    check_card_api(pk_column = a, parent_table = data_mcard_1(), fk_column = b, child_table = data_mcard_2()),
    check_card_api(pk_column = a, child_table = data_mcard_2(), parent_table = data_mcard_1(), fk_column = b),
    check_card_api(pk_column = a, child_table = data_mcard_2(), fk_column = b, parent_table = data_mcard_1()),
    check_card_api(pk_column = a, fk_column = b, parent_table = data_mcard_1(), child_table = data_mcard_2()),
    check_card_api(pk_column = a, fk_column = b, child_table = data_mcard_2(), parent_table = data_mcard_1()),
    check_card_api(child_table = data_mcard_2(), parent_table = data_mcard_1(), pk_column = a, fk_column = b),
    check_card_api(child_table = data_mcard_2(), parent_table = data_mcard_1(), fk_column = b, pk_column = a),
    check_card_api(child_table = data_mcard_2(), pk_column = a, parent_table = data_mcard_1(), fk_column = b),
    check_card_api(child_table = data_mcard_2(), pk_column = a, fk_column = b, parent_table = data_mcard_1()),
    check_card_api(child_table = data_mcard_2(), fk_column = b, parent_table = data_mcard_1(), pk_column = a),
    check_card_api(child_table = data_mcard_2(), fk_column = b, pk_column = a, parent_table = data_mcard_1()),
    check_card_api(fk_column = b, parent_table = data_mcard_1(), pk_column = a, child_table = data_mcard_2()),
    check_card_api(fk_column = b, parent_table = data_mcard_1(), child_table = data_mcard_2(), pk_column = a),
    check_card_api(fk_column = b, pk_column = a, parent_table = data_mcard_1(), child_table = data_mcard_2()),
    check_card_api(fk_column = b, pk_column = a, child_table = data_mcard_2(), parent_table = data_mcard_1()),
    check_card_api(fk_column = b, child_table = data_mcard_2(), parent_table = data_mcard_1(), pk_column = a),
    check_card_api(fk_column = b, child_table = data_mcard_2(), pk_column = a, parent_table = data_mcard_1())
  )
})

test_that("check_cardinality_...() functions are checking the cardinality correctly?", {
  #  expecting silent: ------------------------------------------------------

  expect_silent(check_cardinality_0_n(data_card_1(), data_card_3(), x_select = a, y_select = c))

  expect_silent(check_cardinality_1_n(data_card_1(), data_card_3(), x_select = a, y_select = c))

  expect_silent(check_cardinality_1_1(data_card_1(), data_card_3(), x_select = a, y_select = c))

  expect_silent(check_set_equality(data_card_1(), data_card_3(), x_select = a, y_select = c))

  expect_silent(check_cardinality_0_n(data_card_5(), data_card_4(), x_select = a, y_select = c))

  expect_silent(check_cardinality_0_1(data_card_5(), data_card_6(), x_select = a, y_select = c))


  # scenarios for examine_cardinality() -------------------------------------

  expect_identical(
    examine_cardinality(data_card_8(), data_card_2(), x_select = c, y_select = a),
    "injective mapping (child: 0 or 1 -> parent: 1)"
  )

  expect_identical(
    examine_cardinality(data_card_5(), data_card_4(), x_select = a, y_select = c),
    "surjective mapping (child: 1 to n -> parent: 1)"
  )

  expect_identical(
    examine_cardinality(data_card_8(), data_card_4(), x_select = c, y_select = c),
    "generic mapping (child: 0 to n -> parent: 1)"
  )

  expect_identical(
    examine_cardinality(data_card_1(), data_card_3(), x_select = a, y_select = c),
    "bijective mapping (child: 1 -> parent: 1)"
  )

  # expect specific errors and sometimes specific output due to errors ---------------

  expect_snapshot({
    expect_dm_error(
      check_cardinality_0_n(
        data_card_1(),
        data_card_2(),
        x_select = a,
        y_select = a
      ),
      class = "not_subset_of"
    )

    expect_dm_error(
      check_cardinality_1_1(data_card_5(), data_card_4(), x_select = a, y_select = c),
      class = "not_bijective"
    )

    expect_dm_error(
      check_cardinality_1_1(data_card_4(), data_card_5(), x_select = c, y_select = a),
      class = "not_unique_key"
    )

    expect_dm_error(
      check_cardinality_1_1(data_card_4(), data_card_1(), x_select = c, y_select = a),
      class = "not_unique_key"
    )

    expect_dm_error(
      check_cardinality_0_1(data_card_1(), data_card_4(), x_select = a, y_select = c),
      class = "not_injective"
    )

    expect_dm_error(
      check_cardinality_0_n(data_card_4(), data_card_1(), x_select = c, y_select = a),
      class = "not_unique_key"
    )

    expect_dm_error(
      check_cardinality_1_1(data_card_4(), data_card_1(), x_select = c, y_select = a),
      class = "not_unique_key"
    )

    expect_dm_error(
      check_cardinality_1_1(data_card_1(), data_card_4(), x_select = a, y_select = c),
      class = "not_bijective"
    )
  })
})


# tests for compound keys -------------------------------------------------

test_that("check_cardinality_...() functions are supporting compound keys", {
  # successes
  expect_silent(check_cardinality_0_n(data_card_1(), data_card_11(), x_select = c(a, b), y_select = c(a, b)))
  expect_silent(check_cardinality_1_n(data_card_1(), data_card_12(), x_select = c(a, b), y_select = c(a, b)))
  expect_silent(check_cardinality_1_1(data_card_1(), data_card_1(), x_select = c(a, b), y_select = c(a, b)))
  expect_silent(check_set_equality(data_card_12(), data_card_1(), x_select = c(a, b), y_select = c(a, b)))
  expect_silent(check_cardinality_0_1(data_card_1(), data_card_11(), x_select = c(a, b), y_select = c(a, b)))

  # scenarios for examine_cardinality() -------------------------------------

  expect_identical(
    examine_cardinality(data_card_1(), data_card_11(), x_select = c(a, b), y_select = c(a, b)),
    "injective mapping (child: 0 or 1 -> parent: 1)"
  )

  expect_identical(
    examine_cardinality(data_card_1(), data_card_12(), x_select = c(a, b), y_select = c(a, b)),
    "surjective mapping (child: 1 to n -> parent: 1)"
  )

  expect_identical(
    examine_cardinality(data_card_13(), data_card_12(), x_select = c(b, a), y_select = c(b, a)),
    "generic mapping (child: 0 to n -> parent: 1)"
  )

  expect_identical(
    examine_cardinality(data_card_1(), data_card_1(), x_select = c(b, a), y_select = c(b, a)),
    "bijective mapping (child: 1 -> parent: 1)"
  )

  # expect specific errors and sometimes specific output due to errors ---------------

  expect_snapshot({
    expect_dm_error(
      check_cardinality_0_n(
        data_card_1(),
        data_card_2(),
        x_select = c(a, b),
        y_select = c(a, b)
      ),
      class = "not_subset_of"
    )

    expect_dm_error(
      check_cardinality_1_1(data_card_1(), data_card_12(), x_select = c(a, b), y_select = c(a, b)),
      class = "not_bijective"
    )

    expect_dm_error(
      check_cardinality_1_1(data_card_12(), data_card_1(), x_select = c(a, b), y_select = c(a, b)),
      class = "not_unique_key"
    )

    expect_dm_error(
      check_cardinality_0_1(data_card_1(), data_card_12(), x_select = c(b, a), y_select = c(b, a)),
      class = "not_injective"
    )
  })
})
