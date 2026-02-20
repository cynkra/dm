test_that("enumerate_all_paths() works", {
  expect_snapshot({
    enumerate_all_paths(dm_for_filter_w_cycle(), "tf_1")
    enumerate_all_paths(dm_for_filter_w_cycle(), "tf_5")
    enumerate_all_paths(entangled_dm(), "a")
    enumerate_all_paths(entangled_dm(), "c")
    enumerate_all_paths(entangled_dm_2(), "a")
    enumerate_all_paths(entangled_dm_2(), "d")
  })
})
