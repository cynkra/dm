test_that("dm_disentangle() works", {
  expect_snapshot({
    dm_disentangle(dm_for_filter_w_cycle(), tf_1) %>%
      dm_get_all_fks()
    dm_disentangle(dm_for_filter_w_cycle(), tf_5) %>%
      dm_get_all_fks()
    dm_disentangle(entangled_dm(), a) %>%
      dm_get_all_fks()
    dm_disentangle(entangled_dm(), c) %>%
      dm_get_all_fks()
    dm_disentangle(entangled_dm_2(), a) %>%
      dm_get_all_fks()
    dm_disentangle(entangled_dm_2(), d) %>%
      dm_get_all_fks()
  })

  expect_snapshot_error(class = dm_error("only_possible_wo_zoom"), {
    dm_for_filter_w_cycle() %>%
      dm_zoom_to(tf_1) %>%
      dm_disentangle(tf_1)
    })
})
