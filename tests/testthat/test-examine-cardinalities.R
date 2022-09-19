test_that("dm_examine_cardinalities() works", {
  expect_snapshot({
    dm_examine_cardinalities(dm_for_card())
    dm_examine_cardinalities(dm_for_card()) %>% as_tibble()
    dm_for_card() %>%
      dm_rm_fk(dc_6, c, dc_1, a) %>%
      dm_rm_fk(dc_4, c(b, a), dc_3, c(b, a)) %>%
      dm_examine_cardinalities()
    dm_examine_cardinalities(dm())
  })
})

test_that("`dm_examine_cardinalities()` API", {
  local_options(lifecycle_verbosity = "warning")

  expect_snapshot({
    dm_examine_cardinalities(dm_test_obj(), progress = FALSE)
    dm_examine_cardinalities(dm = dm_test_obj())
  })

  expect_snapshot(error = TRUE, {
    dm_examine_cardinalities(dm_test_obj(), foo = "bar")
  })
})
