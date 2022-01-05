test_that("dm_examine_cardinalities() works", {

  expect_snapshot({
    dm_examine_cardinalities(dm_for_card())
    dm_for_card() %>%
      dm_rm_fk(dc_6, c, dc_1, a) %>%
      dm_rm_fk(dc_4, c(b, a), dc_3, c(b, a)) %>%
      dm_examine_cardinalities()
    dm_examine_cardinalities(dm())
  })


})
