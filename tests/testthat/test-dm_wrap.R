test_that("`dm_wrap()` and `dm_unwrap()` work", {
  skip_if_remote_src()

  dm1 <- dm_for_filter()
  dm_wrapped <- dm_wrap(dm1, tf_4)
  expect_length(dm_wrapped, 1)
  expect_equal(names(dm_wrapped), "tf_4")
  tibble_from_dm <- dm_to_tibble(dm1, tf_4)
  expect_identical(dm_wrapped$tf_4, tibble_from_dm)
  dm_unwrapped <- dm_unwrap(dm_wrapped, dm1)
  expect_identical(dm_unwrapped, tibble_to_dm(tibble_from_dm, dm1))
})
