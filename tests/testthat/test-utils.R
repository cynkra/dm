test_that("commas() works", {
  expect_identical(
    str_count(commas(fact$fact), ","),
    6L
  )
  expect_identical(
    str_count(commas(fact$fact), cli::symbol$ellipsis),
    1L
  )
})

test_that("default_local_src() works", {
  expect_identical(
    default_local_src(),
    src_df(env = .GlobalEnv)
  )
})

test_that("prepare_dm_for_flatten() works", {
  # unfiltered with rename
  expect_equivalent_dm(
    prepare_dm_for_flatten(dm_for_flatten, c("fact", "dim_1", "dim_3"), gotta_rename = TRUE),
    cdm_select_tbl(dm_for_flatten, fact, dim_1, dim_3) %>% cdm_disambiguate_cols(quiet = TRUE)
  )

  # filtered with rename
  red_dm <- cdm_select_tbl(dm_for_flatten, fact, dim_1, dim_3)
  tables <- cdm_get_tables(red_dm)
  tables[["fact"]] <- filter(tables[["fact"]], dim_1_key > 7)
  prep_dm <- new_dm2(base_dm = red_dm, data = tables)
  prep_dm_renamed <- cdm_disambiguate_cols(prep_dm, quiet = TRUE)

  expect_equivalent_dm(
    prepare_dm_for_flatten(
      cdm_filter(dm_for_flatten, dim_1, dim_1_pk > 7),
      c("fact", "dim_1", "dim_3"),
      gotta_rename = TRUE
      ),
    prep_dm_renamed
  )

  # filtered without rename
  expect_equivalent_dm(
    prepare_dm_for_flatten(
      cdm_filter(dm_for_flatten, dim_1, dim_1_pk > 7),
      c("fact", "dim_1", "dim_3"),
      gotta_rename = FALSE
    ),
    prep_dm
  )

  # unfiltered without rename
  expect_equivalent_dm(
    prepare_dm_for_flatten(dm_for_flatten, c("fact", "dim_1", "dim_3"), gotta_rename = FALSE),
    cdm_select_tbl(dm_for_flatten, fact, dim_1, dim_3)
  )
})
