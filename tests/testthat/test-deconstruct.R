# TODO: can probably be deleted once this feature branch is ready for a merge
test_that("`new_fks_in()` generates expected tibble", {
  expect_snapshot({
    new_fks_in(
      child_table = "flights",
      child_fk_cols = new_keys(list(list("origin", "dest"))),
      parent_key_cols = new_keys(list(list("faa")))
    )
  })
})

test_that("`new_fks_out()` generates expected tibble", {
  expect_snapshot({
    new_fks_out(
      child_fk_cols = new_keys(list(list("origin", "dest"))),
      parent_table = "airports",
      parent_key_cols = new_keys(list(list("faa")))
    )
  })
})

test_that("`new_keyed_tbl()` generates expected output", {
  expect_snapshot({
    dm <- dm_nycflights13(cycle = TRUE)

    # should look similar to `dm_get_all_fks_impl(dm, "airports")`
    keyed_tbl <- new_keyed_tbl(
      x = dm$airports,
      pk = "faa",
      fks_in = new_fks_in(
        child_table = "flights",
        child_fk_cols = new_keys(list("origin", "dest")),
        parent_key_cols = new_keys(list("faa"))
      ),
      fks_out = new_fks_out(
        child_fk_cols = new_keys(list("origin", "dest")),
        parent_table = "airports",
        parent_key_cols = new_keys(list("faa"))
      ),
      uuid = "0a0c060f-0d01-0b03-0402-05090800070e"
    )

    keyed_get_info(keyed_tbl)
  })

  expect_equal(dm$airports, keyed_tbl, ignore_attr = TRUE)
})

test_that("`new_keyed_tbl()` formatting", {
  expect_snapshot({
    dm_nycflights13()$flights
    dm_nycflights13()$airports
    dm_nycflights13(cycle = TRUE)$airports
  })
})

test_that("both subsetting operators for `dm` produce the same object", {
  dm <- dm_nycflights13()

  expect_equal(dm$airlines, dm[["airlines"]])
  expect_equal(dm[[1]], dm[["airlines"]])
})

test_that("subsetting `dm` produces `dm_keyed_tbl` objects", {
  dm <- dm_nycflights13()

  expect_s3_class(dm$airlines, "dm_keyed_tbl")
  expect_s3_class(dm[[1]], "dm_keyed_tbl")
  expect_s3_class(dm[["airlines"]], "dm_keyed_tbl")
})
