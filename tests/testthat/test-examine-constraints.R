test_that("`dm_examine_constraints()` works", {
  # case of no constraints:
  expect_identical(
    dm_examine_constraints(dm_test_obj()),
    tibble(
      table = character(),
      kind = character(),
      columns = new_keys(),
      ref_table = character(),
      is_key = logical(),
      problem = character()
    ) %>%
      new_dm_examine_constraints()
  )

  skip_if_src("maria")

  # case of some constraints, all met:
  expect_identical(
    dm_examine_constraints(dm_for_disambiguate()),
    tibble(
      table = c("iris_1", "iris_2"),
      kind = c("PK", "FK"),
      columns = new_keys("key"),
      ref_table = c(NA, "iris_1"),
      is_key = TRUE,
      problem = ""
    ) %>%
      new_dm_examine_constraints()
  )
})

test_that("output", {
  skip_if_ide()

  skip_if_not_installed("nycflights13")

  expect_snapshot({
    dm() %>% dm_examine_constraints()

    dm_nycflights_small() %>% dm_examine_constraints()
    dm_nycflights_small_cycle() %>% dm_examine_constraints()
    dm_nycflights_small_cycle() %>%
      dm_select_tbl(-flights) %>%
      dm_examine_constraints()

    "n column"
    dm_for_filter_w_cycle() %>%
      dm_examine_constraints()
  })
})

test_that("output as tibble", {
  skip_if_ide()

  skip_if_not_installed("nycflights13")

  expect_snapshot({
    dm_nycflights_small_cycle() %>%
      dm_examine_constraints() %>%
      as_tibble()
  })
})


# test compound keys ------------------------------------------------------

test_that("output for compound keys", {
  # FIXME: COMPOUND: Need proper test
  skip_if_remote_src()

  expect_snapshot({
    bad_dm() %>%
      dm_examine_constraints()
  })
})

# Test unique keys for weak FK (no explicit PK set) -----------------------

test_that("Non-explicit PKs should be tested too", {
  expect_snapshot(
    # dm_for_card() has no PKs set, only FKs
    dm_for_card() %>%
      dm_examine_constraints()
  )
})
