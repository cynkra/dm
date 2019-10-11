test_that("cdm_add_tbl() works", {

  # is a table added on all sources?
  walk2(
    dm_for_filter_src,
    d1_src,
    ~expect_identical(
      length(cdm_get_tables(cdm_add_tbl(..1, ..2, d1))),
      7L
    )
  )

  # can I retrieve the tibble under its old name?
  expect_identical(
    tbl(cdm_add_tbl(dm_for_filter, d1), "d1"),
    d1
  )

  # can I retrieve the tibble under a new name?
  expect_identical(
    tbl(cdm_add_tbl(dm_for_filter, d1, "test"), "test"),
    d1
  )

  # do I get a warning in case I pipe the table? will the table's name be 'new_table' if I don't set an explicit name?
  expect_warning(
    expect_identical(
      tbl(d1 %>% cdm_add_tbl(dm_for_filter, .), "new_table"),
      d1)
  )

  # do I avoid the warning when piping the table but setting the name?
  expect_silent(
    expect_identical(
      tbl(d1 %>% cdm_add_tbl(dm_for_filter, ., new_name), "new_name"),
      d1)
  )

  # can I also set a new name with a character variable?
  expect_identical(
    tbl(cdm_add_tbl(dm_for_filter, d1, "new_name"), "new_name"),
    d1)

  # Is an error thrown in case I try to give the new table an old table's name?
  expect_error(
    cdm_add_tbl(dm_for_filter, d1, "t1"),
    class = cdm_error("table_already_exists")
  )

  # error in case table srcs don't match
  if (length(test_srcs) > 1) {
    d1_db <- d1_src[-1]
    walk(
      d1_db,
      ~expect_error(
        cdm_add_tbl(dm_for_filter, .),
        class = cdm_error("not_same_src")
      )
    )
  }
})


test_that("cdm_add_tbls() works", {

  # is a table added on all sources?
  walk2(
    dm_for_filter_src,
    d1_src,
    ~expect_identical(
      length(cdm_get_tables(cdm_add_tbls(..1, d1 = ..2))),
      7L
    )
  )

  # can I retrieve the tibble under its old name?
  expect_identical(
    tbl(cdm_add_tbls(dm_for_filter, d1), "d1"),
    d1
  )

  # can I retrieve the tibble under a new name?
  expect_identical(
    tbl(cdm_add_tbls(dm_for_filter, test = d1), "test"),
    d1
  )

  # do I get a warning in case I pipe the table? will the table's name be 'new_table' if I don't set an explicit name?
  expect_warning(
    expect_identical(
      tbl(d1 %>% cdm_add_tbls(dm_for_filter, .), "new_table"),
      d1)
  )

  # do I avoid the warning when piping the table but setting the name?
  expect_silent(
    expect_identical(
      tbl(d1 %>% cdm_add_tbls(dm_for_filter, new_name = .), "new_name"),
      d1)
  )

  # adding more than 1 table:
  # 1. Is the resulting number of tables correct?
  expect_identical(
    length(cdm_get_tables(cdm_add_tbls(dm_for_filter, d1, d2))),
    8L)

  # 2. Is the resulting order of the tables correct?
  expect_identical(
    src_tbls(cdm_add_tbls(dm_for_filter, d1, d2)),
    c("d1", "d2", src_tbls(dm_for_filter))
    )

  # Is an error thrown in case I try to give the new table an old table's name?
  expect_error(
    cdm_add_tbls(dm_for_filter, t1 = d1),
    class = cdm_error("table_already_exists")
  )

  # error in case table srcs don't match
  if (length(test_srcs) > 1) {
    d1_db <- d1_src[-1]
    walk(
      d1_db,
      ~expect_error(
        cdm_add_tbls(dm_for_filter, .),
        class = cdm_error("not_same_src")
      )
    )
  }
})
